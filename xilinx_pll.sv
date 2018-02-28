/*
 * xilinx_pll.sv
 * Francesco Conti <fconti@iis.ee.ethz.ch>
 *
 * Copyright (C) 2018 ETH Zurich, University of Bologna
 * All rights reserved.
 */

module xilinx_pll (
  output logic        clk_o,
  input  logic        ref_clk_i,
  output logic        cfg_lock_o,     
  input  logic        cfg_req_i,    
  output logic        cfg_ack_o,  
  input  logic [1:0]  cfg_add_i,
  input  logic [31:0] cfg_data_i,
  output logic [31:0] cfg_r_data_o,
  input  logic        cfg_wrn_i,
  input  logic        rstn_glob_i
);

  always_ff @(posedge ref_clk_i or negedge rstn_glob_i)
  begin
    if(~rstn_glob_i) begin
      cfg_ack_o    <= '0;
      cfg_r_data_o <= '0;
    end
    else if(cfg_req_i) begin
      cfg_ack_o    <= 1'b1;
      cfg_r_data_o <= '0;
    end
  end

    wire clk_2083;
    wire clk01, clk02, clk03, clk04, clk05, clk0fb, lock0;
    wire clk10, clk11, clk12, clk13, clk14, clk15, clk1fb, lock1;
    wire clk_mux01, clk_mux23, clk_mux0123, clk_mux01234;
    logic [3:0] s;

    PLLE2_BASE #(
      .BANDWIDTH          ( "OPTIMIZED" ),
      .CLKFBOUT_MULT      ( 64          ),
      .CLKFBOUT_PHASE     ( 0.0         ),
      .CLKIN1_PERIOD      ( 30722.0     ), // REF clock
      .CLKOUT0_DIVIDE     ( 1           ),
      .CLKOUT1_DIVIDE     ( 1           ),
      .CLKOUT2_DIVIDE     ( 1           ),
      .CLKOUT3_DIVIDE     ( 1           ),
      .CLKOUT4_DIVIDE     ( 1           ),
      .CLKOUT5_DIVIDE     ( 1           ),
      .CLKOUT0_DUTY_CYCLE ( 0.5         ),
      .CLKOUT1_DUTY_CYCLE ( 0.5         ),
      .CLKOUT2_DUTY_CYCLE ( 0.5         ),
      .CLKOUT3_DUTY_CYCLE ( 0.5         ),
      .CLKOUT4_DUTY_CYCLE ( 0.5         ),
      .CLKOUT5_DUTY_CYCLE ( 0.5         ),
      .CLKOUT0_PHASE      ( 0.0         ),
      .CLKOUT1_PHASE      ( 0.0         ),
      .CLKOUT2_PHASE      ( 0.0         ),
      .CLKOUT3_PHASE      ( 0.0         ),
      .CLKOUT4_PHASE      ( 0.0         ),
      .CLKOUT5_PHASE      ( 0.0         ),
      .DIVCLK_DIVIDE      ( 1           ),
      .REF_JITTER1        ( 0.0         ),
      .STARTUP_WAIT       ( "TRUE"      )
    ) i_pll_0 (
      .CLKOUT0  ( clk_2083     ),
      .CLKOUT1  ( clk01        ),
      .CLKOUT2  ( clk02        ),
      .CLKOUT3  ( clk03        ),
      .CLKOUT4  ( clk04        ),
      .CLKOUT5  ( clk05        ),
      .CLKFBOUT ( clk0fb       ),
      .LOCKED   ( lock0        ),
      .CLKIN1   ( ref_clk_i    ),
      .PWRDWN   ( 1'b0         ),
      .RST      ( ~rstn_glob_i ),
      .CLKFBIN  ( clk0fb       )
    );

    PLLE2_BASE #(
      .BANDWIDTH          ( "OPTIMIZED" ),
      .CLKFBOUT_MULT      ( 64          ), // 133.31 MHz
      .CLKFBOUT_PHASE     ( 0.0         ),
      .CLKIN1_PERIOD      ( 480.0       ), // clk_2083
      .CLKOUT0_DIVIDE     ( 1           ), // 133.31 MHz
      .CLKOUT1_DIVIDE     ( 2           ), // 66.655 MHz
      .CLKOUT2_DIVIDE     ( 3           ), // 44.44 MHz
      .CLKOUT3_DIVIDE     ( 4           ), // 33.3275 MHz
      .CLKOUT4_DIVIDE     ( 13          ), // 10.25 MHz
      .CLKOUT5_DIVIDE     ( 1           ),
      .CLKOUT0_DUTY_CYCLE ( 0.5         ),
      .CLKOUT1_DUTY_CYCLE ( 0.5         ),
      .CLKOUT2_DUTY_CYCLE ( 0.5         ),
      .CLKOUT3_DUTY_CYCLE ( 0.5         ),
      .CLKOUT4_DUTY_CYCLE ( 0.5         ),
      .CLKOUT5_DUTY_CYCLE ( 0.5         ),
      .CLKOUT0_PHASE      ( 0.0         ),
      .CLKOUT1_PHASE      ( 0.0         ),
      .CLKOUT2_PHASE      ( 0.0         ),
      .CLKOUT3_PHASE      ( 0.0         ),
      .CLKOUT4_PHASE      ( 0.0         ),
      .CLKOUT5_PHASE      ( 0.0         ),
      .DIVCLK_DIVIDE      ( 1           ),
      .REF_JITTER1        ( 0.0         ),
      .STARTUP_WAIT       ( "TRUE"      )
    ) i_pll_1 (
      .CLKOUT0  ( clk10                 ), // 133.31 MHz
      .CLKOUT1  ( clk11                 ), // 66.655 MHz
      .CLKOUT2  ( clk12                 ), // 44.44 MHz
      .CLKOUT3  ( clk13                 ), // 33.3275 MHz
      .CLKOUT4  ( clk14                 ), // 10.25 MHz
      .CLKOUT5  ( clk15                 ),
      .CLKFBOUT ( clk1fb                ),
      .LOCKED   ( lock1                 ),
      .CLKIN1   ( clk_2083              ),
      .PWRDWN   ( 1'b0                  ),
      .RST      ( ~lock0 | ~rstn_glob_i ),
      .CLKFBIN  ( clk1fb                )
    );

    // for the moment, select 44 MHz
    assign s[0] = 1'b0;
    assign s[1] = 1'b0;
    assign s[2] = 1'b1;
    assign s[3] = 1'b0;

    BUFGMUX_CTRL i_buf_mux01 (
      .O  ( clk_mux01 ),
      .I0 ( clk10     ),
      .I1 ( clk11     ),
      .S  ( s[0]      )
    );

    BUFGMUX_CTRL i_buf_mux23 (
      .O  ( clk_mux23 ),
      .I0 ( clk12     ),
      .I1 ( clk13     ),
      .S  ( s[1]      )
    );

    BUFGMUX_CTRL i_buf_mux0123 (
      .O  ( clk_mux0123 ),
      .I0 ( clk_mux01   ),
      .I1 ( clk_mux23   ),
      .S  ( s[2]      )
    );

    BUFGMUX_CTRL i_buf_mux01234 (
      .O  ( clk_mux01234 ),
      .I0 ( clk0123      ),
      .I1 ( clk14        ),
      .S  ( s[3]         )
    );

    BUFGCE i_bufgce (
      .O  ( clk_o    ),
      .CE ( lock1    ),
      .I  ( clk01234 )
    );

    assign cfg_lock_o = lock1;

endmodule /* xilinx_pll */
