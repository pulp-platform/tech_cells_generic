// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Lorenzo Leone <lleone@iis.ee.ethz.ch>

// Description: A wrapper for `tc_sram` which instantiate logic banks that can be in retentive mode
//              or can be turned off. This module can be used for Power Aware simulations and the
//              comntrol signals can be driven directly from the UPF signals.
//
// Additional paramters:
//   - `NumLogicBanks`: Is the number of logic banks to instantiate. By default is equal to 32'd1,
//                      i.e. only one tc_sram will be instantiated.
//
// Additional Ports:
//   - `deepsleep_i`: Asynchronous deep-sleep enable
//   - `powergate_i`: Asynchornous power gating enable

module tc_sram_multibank #(
    parameter int unsigned NumWords = 32'd1024,  // Number of Words in data array
    parameter int unsigned DataWidth = 32'd128,  // Data signal width
    parameter int unsigned ByteWidth = 32'd8,  // Width of a data byte
    parameter int unsigned NumPorts = 32'd2,  // Number of read and write ports
    parameter int unsigned Latency = 32'd1,  // Latency when the read data is available
    parameter int unsigned NumLogicBanks = 32'd1,  // Logic bank for Power Management
    parameter SimInit = "none",  // Simulation initialization
    parameter bit PrintSimCfg = 1'b0,  // Print configuration
    parameter ImplKey = "none",  // Reference to specific implementation
    // DEPENDENT PARAMETERS, DO NOT OVERWRITE!
    parameter int unsigned AddrWidth = (NumWords > 32'd1) ? $clog2(NumWords) : 32'd1,
    parameter int unsigned BeWidth = (DataWidth + ByteWidth - 32'd1) / ByteWidth,  // ceil_div
    parameter type addr_t = logic [AddrWidth-1:0],
    parameter type data_t = logic [DataWidth-1:0],
    parameter type be_t = logic [BeWidth-1:0]
) (
    input  logic                      clk_i,        // Clock
    input  logic                      rst_ni,       // Asynchronous reset active low
    // input ports
    input  logic  [     NumPorts-1:0] req_i,        // request
    input  logic  [     NumPorts-1:0] we_i,         // write enable
    input  addr_t [     NumPorts-1:0] addr_i,       // request address
    input  data_t [     NumPorts-1:0] wdata_i,      // write data
    input  be_t   [     NumPorts-1:0] be_i,         // write byte enable
    input  logic  [NumLogicBanks-1:0] deepsleep_i,  // deep sleep enable
    input  logic  [NumLogicBanks-1:0] powergate_i,  // power gate enable
    // output ports
    output data_t [     NumPorts-1:0] rdata_o       // read data
);

   if (NumLogicBanks == 32'd0) begin : gen_no_logic_bank
      $fatal("Error: %d logic banks are not supported", NumLogicBanks);
   end else if (NumLogicBanks == 32'd1) begin : gen_simple_sram
      tc_sram_pwrgate #(
          .NumWords     (NumWords),
          .DataWidth    (DataWidth),
          .ByteWidth    (ByteWidth),
          .NumPorts     (NumPorts),
          .Latency      (Latency),
          .NumLogicBanks(NumLogicBanks),
          .SimInit      (SimInit),
          .PrintSimCfg  (PrintSimCfg),
          .ImplKey      (ImplKey)
      ) i_tc_sram (
          .clk_i,
          .rst_ni,
          .req_i,
          .we_i,
          .addr_i,
          .wdata_i,
          .be_i,
          .deepsleep_i,
          .powergate_i,
          .rdata_o
      );
   end else begin : gen_logic_bank  // block: gen_simple_sram
      localparam int unsigned LogicBankSize = NumWords/NumLogicBanks;
      localparam int unsigned BankSelWidth = (NumLogicBanks > 32'd1) ? $clog2(NumLogicBanks) : 32'd1;

      if (LogicBankSize != 2**(AddrWidth-BankSelWidth))
        $fatal("Logic Bank size is not a power of two: UNSUPPORTED ");

      // Signals from/to logic banks
      logic  [NumLogicBanks-1:0][    NumPorts-1:0]                             req_cut;
      logic  [NumLogicBanks-1:0][    NumPorts-1:0]                             we_cut;
      logic  [NumLogicBanks-1:0][    NumPorts-1:0][AddrWidth-BankSelWidth-1:0] addr_cut;
      data_t [NumLogicBanks-1:0][    NumPorts-1:0]                             wdata_cut;
      be_t   [NumLogicBanks-1:0][    NumPorts-1:0]                             be_cut;
      data_t [NumLogicBanks-1:0][    NumPorts-1:0]                             rdata_cut;

      // Signals to select the right bank
      logic  [     NumPorts-1:0][BankSelWidth-1:0]                             bank_sel;
      logic  [     NumPorts-1:0][BankSelWidth-1:0]                             out_mux_sel;

      // Store the Bank Select signal to correctly select the output data
      for (genvar PortIdx = 0; PortIdx < NumPorts; PortIdx++) begin : gen_cut_muxing_signals
         assign bank_sel[PortIdx] = addr_i[PortIdx][AddrWidth-1-:BankSelWidth];
         always_ff @(posedge clk_i or negedge rst_ni) begin
            if (!rst_ni) begin
               out_mux_sel[PortIdx] <= '0;
            end else begin
               out_mux_sel[PortIdx] <= bank_sel[PortIdx];
            end
         end
         // Assign output data looking the latest Bank Select signal
         assign rdata_o[PortIdx] = rdata_cut[bank_sel[PortIdx]][PortIdx];
      end

      for (genvar BankIdx = 0; BankIdx < NumLogicBanks; BankIdx++) begin : gen_logic_bank
         for (genvar PortIdx = 0; PortIdx < NumPorts; PortIdx++) begin
            // DEMUX the input signals to the correct logic bank
            // Assign req channel to the correct logic bank
            assign req_cut[BankIdx][PortIdx] = req_i[PortIdx] && (bank_sel[PortIdx] == BankIdx);
            // Assign lowest part of the address to the correct logic bank
            assign addr_cut[BankIdx][PortIdx]  = req_cut[BankIdx][PortIdx] ? addr_i[PortIdx][AddrWidth-BankSelWidth-1:0] : '0;
            // Assign data to the correct logic bank
            assign wdata_cut[BankIdx][PortIdx] = req_cut[BankIdx][PortIdx] ? wdata_i[PortIdx] : '0;
            assign we_cut[BankIdx][PortIdx] = req_cut[BankIdx][PortIdx] ? we_i[PortIdx] : '0;
            assign be_cut[BankIdx][PortIdx] = req_cut[BankIdx][PortIdx] ? be_i[PortIdx] : '0;
         end
         tc_sram_pwrgate #(
             .NumWords     (NumWords / NumLogicBanks),
             .DataWidth    (DataWidth),
             .ByteWidth    (ByteWidth),
             .NumPorts     (NumPorts),
             .Latency      (Latency),
             .NumLogicBanks(NumLogicBanks),
             .SimInit      (SimInit),
             .PrintSimCfg  (PrintSimCfg),
             .ImplKey      (ImplKey)
         ) i_tc_sram (
             .clk_i,
             .rst_ni,
             .req_i      (req_cut[BankIdx]),
             .we_i       (we_cut[BankIdx]),
             .addr_i     (addr_cut[BankIdx]),
             .wdata_i    (wdata_cut[BankIdx]),
             .be_i       (be_cut[BankIdx]),
             .deepsleep_i(deepsleep_i[BankIdx]),
             .powergate_i(powergate_i[BankIdx]),
             .rdata_o    (rdata_cut[BankIdx])
         );
      end
   end

endmodule  //endmodule: tc_sram_multibank
