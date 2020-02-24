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
//
// Description: Xilinx implementation using the xpm constructs for `tc_sram`
//              Make sure that Vivado can detect the xpm macros by issuing
//              the `auto_detect_xpm` or `set_property XPM_LIBRARIES XPM_MEMORY [current_project]`
//              command.
//
module tc_sram #(
  parameter int unsigned NoWords      = 32'd1024, // Number of Words in data array
  parameter int unsigned DataWidth    = 32'd128,  // Data signal width
  parameter int unsigned ByteWidth    = 32'd8,    // Width of a data byte
  parameter int unsigned NoPorts      = 32'd2,    // Number of read and write ports
  parameter int unsigned Latency      = 32'd1,    // Latency when the read data is available
  parameter string       SimInit      = "none",   // Simulation initialization
  parameter bit          PrintSimCfg  = 1'b0,     // Print configuration
  // DEPENDENT PARAMETERS, DO NOT OVERWRITE!
  parameter int unsigned AddrWidth = (NoWords > 32'd1) ? $clog2(NoWords) : 32'd1,
  parameter int unsigned BeWidth   = (DataWidth + ByteWidth - 32'd1) / ByteWidth, // ceil_div
  parameter type         addr_t    = logic [AddrWidth-1:0],
  parameter type         data_t    = logic [DataWidth-1:0],
  parameter type         be_t      = logic [BeWidth-1:0]
) (
  input  logic                clk_i,      // Clock
  input  logic                rst_ni,     // Asynchronous reset active low
  // input ports
  input  logic  [NoPorts-1:0] req_i,      // request
  input  logic  [NoPorts-1:0] we_i,       // write enable
  input  addr_t [NoPorts-1:0] addr_i,     // request address
  input  data_t [NoPorts-1:0] wdata_i,    // write data
  input  be_t   [NoPorts-1:0] be_i,       // write byte enable
  // output ports
  output data_t [NoPorts-1:0] rdata_o     // read data
);

  localparam int unsigned DataWidthAligned = ByteWidth * BeWidth;
  localparam int unsigned Size             = NoWords * DataWidthAligned;

  typedef logic [DataWidthAligned-1:0] data_aligned_t;

  data_aligned_t [NoPorts-1:0] wdata_al;
  data_aligned_t [NoPorts-1:0] rdata_al;
  be_t           [NoPorts-1:0] we;

  // pad with 0 to next byte for inferable macro below
  always_comb begin : p_align
    wdata_aligned = '0;
    for (int unsigned i = 0; i < NoPorts; i++) begin
      wdata_al[DataWidth-1:0] = wdata_i;
    end
  end

  for (genvar i = 0; i < NoPorts; i++) begin : gen_port_assign
    for (genvar j = 0; j < BeWidth; j++) begin : gen_we_assign
      assign we[i][j] = be_i[i][j] & we_i[i];
    end
    assign rdata_o[i] = data_t'(rdata_al[i]);
  end

  if (NoPorts == 32'd1) begin : gen_1_ports
    // xpm_memory_spram: Single Port RAM
    // XilinxParameterizedMacro, version 2018.1
    xpm_memory_spram#(
      .ADDR_WIDTH_A        ( AddrWidth        ), // DECIMAL
      .AUTO_SLEEP_TIME     ( 0                ), // DECIMAL
      .BYTE_WRITE_WIDTH_A  ( ByteWidth        ), // DECIMAL
      .ECC_MODE            ( "no_ecc"         ), // String
      .MEMORY_INIT_FILE    ( "none"           ), // String
      .MEMORY_INIT_PARAM   ( "0"              ), // String  TODO
      .MEMORY_OPTIMIZATION ( "true"           ), // String
      .MEMORY_PRIMITIVE    ( "auto"           ), // String
      .MEMORY_SIZE         ( Size             ), // DECIMAL in bit!
      .MESSAGE_CONTROL     ( 0                ), // DECIMAL
      .READ_DATA_WIDTH_A   ( DataWidthAligned ), // DECIMAL
      .READ_LATENCY_A      ( Latency          ), // DECIMAL
      .READ_RESET_VALUE_A  ( "0"              ), // String  TODO
      .USE_MEM_INIT        ( 1                ), // DECIMAL
      .WAKEUP_TIME         ( "disable_sleep"  ), // String
      .WRITE_DATA_WIDTH_A  ( DataWidthAligned ), // DECIMAL
      .WRITE_MODE_A        ( "no_change"      )  // String
    ) i_xpm_memory_spram (
      .dbiterra ( /*not used*/ ), // 1-bit output: Status signal to indicate double biterror
      .douta    ( rdata_o      ), // READ_DATA_WIDTH_A-bitoutput: Data output for port A
      .sbiterra ( /*not used*/ ), // 1-bit output: Status signal to indicate single biterror
      .addra    ( addr_i       ), // ADDR_WIDTH_A-bit input: Address for port A
      .clka     ( clk_i        ), // 1-bit input: Clock signal for port A.
      .dina     ( wdata_i      ), // WRITE_DATA_WIDTH_A-bitinput: Data input for port A
      .ena      ( req_i        ), // 1-bit input: Memory enable signal for port A.
      .injectdbiterra ( 1'b0   ), // 1-bit input: Controls double biterror injection
      .injectsbiterra ( 1'b0   ), // 1-bit input: Controls single biterror injection
      .regcea   ( 1'b1         ), // 1-bit input: Clock Enable for the last register
      .rsta     ( ~rst_ni      ), // 1-bit input: Reset signal for the final port A output
      .sleep    ( 1'b0         ), // 1-bit input: sleep signal to enable the dynamic power savie
      .wea      ( we           )
    );
  end else if (NoPorts == 32'd2) begin : gen_2_ports
    // xpm_memory_tdpram: True Dual Port RAM
    // XilinxParameterizedMacro, version 2018.1
    xpm_memory_tdpram#(
      .ADDR_WIDTH_A            ( AddrWidth        ), // DECIMAL
      .ADDR_WIDTH_B            ( AddrWidth        ), // DECIMAL
      .AUTO_SLEEP_TIME         ( 0                ), // DECIMAL
      .BYTE_WRITE_WIDTH_A      ( ByteWidth        ), // DECIMAL
      .BYTE_WRITE_WIDTH_B      ( ByteWidth        ), // DECIMAL
      .CLOCKING_MODE           ( "common_clock"   ), // String
      .ECC_MODE                ( "no_ecc"         ), // String
      .MEMORY_INIT_FILE        ( "none"           ), // String
      .MEMORY_INIT_PARAM       ( "0"              ), // String  TODO
      .MEMORY_OPTIMIZATION     ( "true"           ), // String
      .MEMORY_PRIMITIVE        ( "auto"           ), // String
      .MEMORY_SIZE             ( Size             ), // DECIMAL in bits!
      .MESSAGE_CONTROL         ( 0                ), // DECIMAL
      .READ_DATA_WIDTH_A       ( DataWidthAligned ), // DECIMAL
      .READ_DATA_WIDTH_B       ( DataWidthAligned ), // DECIMAL
      .READ_LATENCY_A          ( Latency          ), // DECIMAL
      .READ_LATENCY_B          ( Latency          ), // DECIMAL
      .READ_RESET_VALUE_A      ( "0"              ), // String  TODO
      .READ_RESET_VALUE_B      ( "0"              ), // String  TODO
      .USE_EMBEDDED_CONSTRAINT ( 0                ), // DECIMAL
      .USE_MEM_INIT            ( 1                ), // DECIMAL
      .WAKEUP_TIME             ( "disable_sleep"  ), // String
      .WRITE_DATA_WIDTH_A      ( DataWidthAligned ), // DECIMAL
      .WRITE_DATA_WIDTH_B      ( DataWidthAligned ), // DECIMAL
      .WRITE_MODE_A            ( "no_change"      ), // String
      .WRITE_MODE_B            ( "no_change"      )  // String
    ) i_xpm_memory_tdpram (
      .dbiterra ( /*not used*/ ), // 1-bit output: Doubble bit error A
      .dbiterrb ( /*not used*/ ), // 1-bit output: Doubble bit error B
      .douta    ( douta        ), // READ_DATA_WIDTH_A-bit output: Data output for portA
      .doutb    ( doutb        ), // READ_DATA_WIDTH_B-bit output: Data output for portB
      .sbiterra ( /*not used*/ ), // 1-bit output: Single bit error A
      .sbiterrb ( /*not used*/ ), // 1-bit output: Single bit error B
      .addra    ( addr_i[0]    ), // ADDR_WIDTH_A-bit input: Address for port A
      .addrb    ( addr_i[1]    ), // ADDR_WIDTH_B-bit input: Address for port B
      .clka     ( clk_i        ), // 1-bit input: Clock signal for port A
      .clkb     ( clk_i        ), // 1-bit input: Clock signal for port B
      .dina     ( wdata_al[0]  ), // WRITE_DATA_WIDTH_A-bit input: Data input for port A
      .dinb     ( wdata_al[1]  ), // WRITE_DATA_WIDTH_B-bit input: Data input for port B
      .douta    ( rdata_al[0]  ), // READ_DATA_WIDTH_A-bit output: Data output for port A
      .doutb    ( rdata_al[1]  ), // READ_DATA_WIDTH_B-bit output: Data output for port B
      .ena      ( req_i[0]     ), // 1-bit input: Memory enable signal for port A
      .enb      ( req_i[1]     ), // 1-bit input: Memory enable signal for port B
      .injectdbiterra ( 1'b0   ), // 1-bit input: Controls doublebiterror injection on input data
      .injectdbiterrb ( 1'b0   ), // 1-bit input: Controls doublebiterror injection on input data
      .injectsbiterra ( 1'b0   ), // 1-bit input: Controls singlebiterror injection on input data
      .injectsbiterrb ( 1'b0   ), // 1-bit input: Controls singlebiterror injection on input data
      .regcea   ( 1'b1         ), // 1-bit input: Clock Enable for the last register stage
      .regceb   ( 1'b1         ), // 1-bit input: Clock Enable for the last register stage
      .rsta     ( ~rst_ni      ), // 1-bit input: Reset signal for the final port A output
      .rstb     ( ~rst_ni      ), // 1-bit input: Reset signal for the final port B output
      .sleep    ( 1'b0         ), // 1-bit input: sleep signal to enable the dynamic power
      .wea      ( we[0]        ), // WRITE_DATA_WIDTH_A-bit input: Write enable vector for port A
      .web      ( we[1]        )  // WRITE_DATA_WIDTH_B-bit input: Write enable vector for port B
    );
  end else begin : gen_err_ports
    $fatal(1, "Not supported port parametrisation for NoPorts: %0d", NoPorts);
  end
endmodule
