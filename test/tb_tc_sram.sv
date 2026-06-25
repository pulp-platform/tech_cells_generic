// Copyright 2020 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
// Author: Wolfgang Roenninger <wroennin@ethz.ch>, ETH Zurich
// Description: Testbench for the functional `*_sram` modules

module tb_tc_sram #(
  parameter int unsigned NumPorts  = 32'd2,
  parameter int unsigned Latency   = 32'd1,
  parameter int unsigned NumWords  = 32'd1024,
  parameter int unsigned DataWidth = 32'd64,
  parameter int unsigned ByteWidth = 32'd8,
  parameter int unsigned NoReq     = 32'd200000,
  parameter string       SimInit   = "zeros",
  parameter time         CyclTime  = 10ns,
  parameter time         ApplTime  = 2ns,
  parameter time         TestTime  = 8ns
);

  //-----------------------------------
  // Clock generator
  //-----------------------------------
  logic clk, rst_n;
  clk_rst_gen #(
    .ClkPeriod   ( CyclTime ),
    .RstClkCycles( 5        )
  ) i_clk_gen (
    .clk_o  ( clk   ),
    .rst_no ( rst_n )
  );

  logic [NumPorts-1:0] done;

  localparam int unsigned AddrWidth = (NumWords > 32'd1) ? $clog2(NumWords) : 32'd1;
  localparam int unsigned BeWidth   = (DataWidth + ByteWidth - 32'd1) / ByteWidth;

  typedef logic [AddrWidth-1:0] addr_t;
  typedef logic [DataWidth-1:0] data_t;
  typedef logic [BeWidth-1:0]   be_t;

  // signal declarations for each sram
  logic  [NumPorts-1:0] req,   we;
  addr_t [NumPorts-1:0] addr;
  data_t [NumPorts-1:0] wdata, rdata;
  be_t   [NumPorts-1:0] be;

  // golden model
  data_t           memory [NumWords-1:0];
  longint unsigned failed_test = 0;

  // This process drives the requests on the port with random data.
  for (genvar i = 0; i < NumPorts; i++) begin : gen_stimuli
    initial begin : proc_drive_port
      automatic logic  stim_write;
      automatic addr_t stim_addr;
      automatic data_t stim_data;
      automatic be_t   stim_be;

      done[i]  <= 1'b0;
      req[i]   <= 1'b0;
      we[i]    <= 1'b0;
      addr[i]  <= addr_t'(0);
      wdata[i] <= data_t'(0);
      be[i]    <= be_t'(0);

      @(posedge rst_n);
      repeat (10) @(posedge clk);

      // read every initialized word before traffic can overwrite it
      for (int unsigned j = 0; j < NumWords; j++) begin
        req[i]   <= #ApplTime 1'b1;
        we[i]    <= #ApplTime 1'b0;
        addr[i]  <= #ApplTime addr_t'(j);
        wdata[i] <= #ApplTime data_t'(0);
        be[i]    <= #ApplTime be_t'(0);
        @(posedge clk);
        req[i]   <= #ApplTime 1'b0;
        we[i]    <= #ApplTime 1'b0;
        addr[i]  <= #ApplTime addr_t'(0);
        wdata[i] <= #ApplTime data_t'(0);
        be[i]    <= #ApplTime be_t'(0);
      end

      for (int unsigned j = 0; j < NoReq; j++) begin
        stim_write = bit'($urandom());
        for (int unsigned k = 0; k < AddrWidth; k++) begin
          stim_addr[k] = bit'($urandom());
        end
        // this statement makes sure that only valid addresses are in a request
        while (stim_addr >= NumWords) begin
          for (int unsigned k = 0; k < AddrWidth; k++) begin
            stim_addr[k] = bit'($urandom());
          end
        end
        for (int unsigned k = 0; k < DataWidth; k++) begin
          stim_data[k] = bit'($urandom());
        end
        for (int unsigned k = 0; k < BeWidth; k++) begin
          stim_be[k] = bit'($urandom());
        end

        req[i]   <= #ApplTime 1'b1;
        we[i]    <= #ApplTime stim_write;
        addr[i]  <= #ApplTime stim_addr;
        wdata[i] <= #ApplTime stim_data;
        be[i]    <= #ApplTime stim_be;
        @(posedge clk);
        req[i]   <= #ApplTime 1'b0;
        we[i]    <= #ApplTime 1'b0;
        addr[i]  <= #ApplTime addr_t'(0);
        wdata[i] <= #ApplTime data_t'(0);
        be[i]    <= #ApplTime be_t'(0);

        repeat ($urandom_range(0,5)) @(posedge clk);
      end
      done[i] <= 1'b1;
    end
  end

  // This process controls the golden model
  // - The memory array is initialized according to the parameter
  // - Data is written exactly at the clock edge, if there is a write request on a port.
  // - At `TestTime` a process is launched on read requests which lives for `Latency` cycles.
  //   This process asserts the expected read output at `TestTime` in the respective cycle.
  initial begin: proc_golden_model
    #0;
    for (int unsigned i = 0; i < NumWords; i++) begin
      case (SimInit)
        "zeros":  memory[i] = '0;
        "ones":   memory[i] = '1;
        "random": memory[i] = i_tc_sram_dut.init_val[i];
        default:  memory[i] = 'x;
      endcase
    end

    @(posedge rst_n);

    forever begin
      @(posedge clk);
      // writes get latched at clock in golden model array
      for (int unsigned i = 0; i < NumPorts; i++) begin
        if (req[i] && we[i]) begin
          for (int unsigned j = 0; j < DataWidth; j++) begin
            if (be[i][j/ByteWidth]) begin
              memory[addr[i]][j] = wdata[i][j];
            end
          end
        end
      end

      // read test process is launched at `TestTime`
      #TestTime;
      fork
        for (int unsigned i = 0; i < NumPorts; i++) begin
          check_read(i, addr[i]);
        end
      join_none
    end
  end

  // Read test process. This task lives for a number of cycles determined by `Latency`.
  task automatic check_read(input int unsigned port, input addr_t read_addr);
    // only continue if there is a read request at this port
    if (req[port] && !we[port]) begin
      data_t exp_data = memory[read_addr];

      if (Latency > 0) begin
        repeat (Latency) @(posedge clk);
        #TestTime;
      end

      for (int unsigned i = 0; i < DataWidth; i++) begin
        if (!$isunknown(exp_data[i])) begin
          assert(exp_data[i] === rdata[port][i]) else begin
            $warning("Port: %0d unexpected bit[%0h], Addr: %0h expected: %0h, measured: %0h",
                port, i, read_addr, exp_data[i], rdata[port][i]);
            failed_test++;
          end
        end
      end
    end
  endtask : check_read

  initial begin : proc_check_initialization
    automatic bit random_diff_seen = 1'b0;
    automatic bit random_zero_seen = 1'b0;
    automatic bit random_one_seen = 1'b0;
    automatic data_t init_word;

    #0;
    for (int unsigned i = 0; i < NumWords; i++) begin
      init_word = i_tc_sram_dut.init_val[i];
      case (SimInit)
        "zeros": begin
          assert (init_word === '0) else begin
            $warning("Initial value at word %0d is not zero: %0h", i, init_word);
            failed_test++;
          end
        end
        "ones": begin
          assert (init_word === '1) else begin
            $warning("Initial value at word %0d is not one: %0h", i, init_word);
            failed_test++;
          end
        end
        "random": begin
          assert (!$isunknown(init_word)) else begin
            $warning("Random initial value at word %0d contains unknown bits: %0h", i, init_word);
            failed_test++;
          end
          random_zero_seen |= (init_word !== '1);
          random_one_seen  |= (init_word !== '0);
          for (int unsigned j = 32; j < DataWidth; j++) begin
            if (init_word[j] !== init_word[j-32]) begin
              random_diff_seen = 1'b1;
            end
          end
        end
        default: begin
          assert (init_word === 'x) else begin
            $warning("Initial value at word %0d is not unknown: %0h", i, init_word);
            failed_test++;
          end
        end
      endcase
    end

    if (SimInit == "random" && DataWidth > 32 && NumWords > 1) begin
      assert (random_diff_seen) else begin
        $warning("Random initialization repeats the low 32 bits across all initialized words");
        failed_test++;
      end
    end
    if (SimInit == "random" && (DataWidth > 1 || NumWords > 1)) begin
      assert (random_zero_seen && random_one_seen) else begin
        $warning("Random initialization does not contain both 0 and 1 bits across all words");
        failed_test++;
      end
    end

    @(posedge rst_n);
    #TestTime;
    for (int unsigned i = 0; i < NumWords; i++) begin
      if (SimInit == "none") begin
        assert ($isunknown(i_tc_sram_dut.sram[i])) else begin
          $warning("SRAM word %0d is not unknown with SimInit none: %0h",
              i, i_tc_sram_dut.sram[i]);
          failed_test++;
        end
      end else begin
        assert (i_tc_sram_dut.sram[i] === memory[i]) else begin
          $warning("SRAM word %0d does not match initial value, expected: %0h, measured: %0h",
              i, memory[i], i_tc_sram_dut.sram[i]);
          failed_test++;
        end
      end
    end
  end

  // Stop the simulation at the end.
  initial begin : proc_stop
    @(posedge rst_n);
    wait (&done);
    repeat (10) @(posedge clk);
    assert (failed_test == 0) else $fatal(1, "Simulation done, errors: %0d", failed_test);
    $info("Simulation done, errors: 0");
    $stop();
  end

  tc_sram #(
    .NumWords    ( NumWords  ), // Number of Words in data array
    .DataWidth   ( DataWidth ), // Data signal width
    .ByteWidth   ( ByteWidth ), // Width of a data byte
    .NumPorts    ( NumPorts  ), // Number of read and write ports
    .Latency     ( Latency   ), // Latency when the read data is available
    .SimInit     ( SimInit   ), // Simulation initialization
    .PrintSimCfg ( 1'b1      )  // Print configuration
  ) i_tc_sram_dut (
    .clk_i   ( clk   ), // Clock
    .rst_ni  ( rst_n ), // Asynchronous reset active low
    .req_i   ( req   ), // request
    .we_i    ( we    ), // write enable
    .addr_i  ( addr  ), // request address
    .wdata_i ( wdata ), // write data
    .be_i    ( be    ), // write byte enable
    .rdata_o ( rdata )  // read data
  );
endmodule
