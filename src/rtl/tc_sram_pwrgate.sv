// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Lorenzo Leone <lleone@iis.ee.ethz.ch>
//
// This SRAM module models the Retention adn Power gating behaviour of a generic
// SRAM macro.
// So far the model behaves as a standard tc_sram (no retention nor power gate),
// the only additions are the Power Aware ports:
//   - powergate_i: Signal to swicth ON/OFF the SRAM bank
//   - deepesleep_i: Signal to activate retion
//
// TODO: Model the power off and retention mode for simulation.

module tc_sram_pwrgate #(
    parameter int unsigned NumWords = 32'd1024,                                   // Number of Words in data array
    parameter int unsigned DataWidth = 32'd128,                                   // Data signal width
    parameter int unsigned ByteWidth = 32'd8,                                     // Width of a data byte
    parameter int unsigned NumPorts = 32'd2,                                      // Number of read and write ports
    parameter int unsigned Latency = 32'd1,                                       // Latency when the read data is available
    parameter              SimInit = "none",                                      // Simulation initialization
    parameter bit          PrintSimCfg = 1'b0,                                    // Print configuration
    parameter              ImplKey = "none",                                      // Reference to specific implementation
    // DEPENDENT PARAMETERS, DO NOT OVERWRITE!
    parameter int unsigned AddrWidth = (NumWords > 32'd1) ? $clog2(NumWords) : 32'd1,
    parameter int unsigned BeWidth = (DataWidth + ByteWidth - 32'd1) / ByteWidth, // ceil_div
    parameter type         addr_t = logic [AddrWidth-1:0],
    parameter type         data_t = logic [DataWidth-1:0],
    parameter type         be_t = logic [BeWidth-1:0]
) (
    input  logic                 clk_i,        // Clock
    input  logic                 rst_ni,       // Asynchronous reset active low
    // input ports
    input  logic  [NumPorts-1:0] req_i,        // request
    input  logic  [NumPorts-1:0] we_i,         // write enable
    input  addr_t [NumPorts-1:0] addr_i,       // request address
    input  data_t [NumPorts-1:0] wdata_i,      // write data
    input  be_t   [NumPorts-1:0] be_i,         // write byte enable
    input  logic                 deepsleep_i,  // deep sleep enable
    input  logic                 powergate_i,  // power gate enable
    // output ports
    output data_t [NumPorts-1:0] rdata_o       // read data
);

   tc_sram #(
       .NumWords   (NumWords),
       .DataWidth  (DataWidth),
       .ByteWidth  (ByteWidth),
       .NumPorts   (NumPorts),
       .Latency    (Latency),
       .SimInit    (SimInit),
       .PrintSimCfg(PrintSimCfg),
       .ImplKey    (ImplKey)
   ) i_tc_sram (
       .clk_i,
       .rst_ni,
       .req_i,
       .we_i,
       .addr_i,
       .wdata_i,
       .be_i,
       .rdata_o
   );


endmodule
