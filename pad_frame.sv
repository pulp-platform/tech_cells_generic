// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the “License”); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


module pad_frame
    (

        // CONFIGURATION SIGNALS
`ifdef HYPER_RAM
        input logic             pd_hyper_dq0_i     ,
        input logic             pd_hyper_dq1_i     ,
        input logic             pd_hyper_dq2_i     ,
        input logic             pd_hyper_dq3_i     ,
        input logic             pd_hyper_dq4_i     ,
        input logic             pd_hyper_dq5_i     ,
        input logic             pd_hyper_dq6_i     ,
        input logic             pd_hyper_dq7_i     ,
        input logic             pd_hyper_rwds_i    ,
        input logic             pd_hyper_ckn_i     ,
        input logic             pd_hyper_ck_i      ,
        input logic             pd_hyper_csn0_i    ,
        input logic             pd_hyper_csn1_i    ,
`endif
        input logic             pd_spim_sck_i      ,
        input logic             pd_spim_sdio0_i    ,
        input logic             pd_spim_sdio1_i    ,
        input logic             pd_spim_sdio2_i    ,
        input logic             pd_spim_sdio3_i    ,
        input logic             pd_spim_csn1_i     ,
        input logic             pd_spim_csn0_i     ,
        input logic             pd_i2s1_sdi_i      ,
        input logic             pd_i2s0_ws_i       ,
        input logic             pd_i2s0_sdi_i      ,
        input logic             pd_i2s0_sck_i      ,
        input logic             pd_cam_pclk_i      ,
        input logic             pd_cam_hsync_i     ,
        input logic             pd_cam_data0_i     ,
        input logic             pd_cam_data1_i     ,
        input logic             pd_cam_data2_i     ,
        input logic             pd_cam_data3_i     ,
        input logic             pd_cam_data4_i     ,
        input logic             pd_cam_data5_i     ,
        input logic             pd_cam_data6_i     ,
        input logic             pd_cam_data7_i     ,
        input logic             pd_cam_vsync_i     ,
        input logic             pd_i2c0_sda_i      ,
        input logic             pd_i2c0_scl_i      ,
        input logic             pu_uart_rx_i       ,
        input logic             pu_uart_tx_i       ,

`ifdef HYPER_RAM
        input logic             oe_hyper_ckn_i     ,
        input logic             oe_hyper_ck_i      ,
        input logic             oe_hyper_dq0_i     ,
        input logic             oe_hyper_dq1_i     ,
        input logic             oe_hyper_dq2_i     ,
        input logic             oe_hyper_dq3_i     ,
        input logic             oe_hyper_dq4_i     ,
        input logic             oe_hyper_dq5_i     ,
        input logic             oe_hyper_dq6_i     ,
        input logic             oe_hyper_dq7_i     ,
        input logic             oe_hyper_csn0_i    ,
        input logic             oe_hyper_csn1_i    ,
        input logic             oe_hyper_rwds_i    ,
`endif
        input logic             oe_spim_sdio0_i    ,
        input logic             oe_spim_sdio1_i    ,
        input logic             oe_spim_sdio2_i    ,
        input logic             oe_spim_sdio3_i    ,
        input logic             oe_spim_csn0_i     ,
        input logic             oe_spim_csn1_i     ,
        input logic             oe_spim_sck_i      ,
        input logic             oe_i2s0_sck_i      ,
        input logic             oe_i2s0_ws_i       ,
        input logic             oe_i2s0_sdi_i      ,
        input logic             oe_i2s1_sdi_i      ,
        input logic             oe_cam_pclk_i      ,
        input logic             oe_cam_hsync_i     ,
        input logic             oe_cam_data0_i     ,
        input logic             oe_cam_data1_i     ,
        input logic             oe_cam_data2_i     ,
        input logic             oe_cam_data3_i     ,
        input logic             oe_cam_data4_i     ,
        input logic             oe_cam_data5_i     ,
        input logic             oe_cam_data6_i     ,
        input logic             oe_cam_data7_i     ,
        input logic             oe_cam_vsync_i     ,
        input logic             oe_i2c0_sda_i      ,
        input logic             oe_i2c0_scl_i      ,
        input logic             oe_uart_rx_i       ,
        input logic             oe_uart_tx_i       ,

        // REF CLOCK
        output logic            ref_clk_o        ,

        // RESET SIGNALS
        output logic            rstn_o           ,

        // JTAG SIGNALS
        output logic            jtag_tck_o       ,
        output logic            jtag_tdi_o       ,
        input  logic            jtag_tdo_i       ,
        output logic            jtag_tms_o       ,
        output logic            jtag_trst_o      ,

        // INPUTS SIGNALS TO THE PADS
`ifdef HYPER_RAM
        input logic             out_hyper_ckn_i  ,
        input logic             out_hyper_ck_i   ,
        input logic             out_hyper_dq0_i  ,
        input logic             out_hyper_dq1_i  ,
        input logic             out_hyper_dq2_i  ,
        input logic             out_hyper_dq3_i  ,
        input logic             out_hyper_dq4_i  ,
        input logic             out_hyper_dq5_i  ,
        input logic             out_hyper_dq6_i  ,
        input logic             out_hyper_dq7_i  ,
        input logic             out_hyper_csn0_i ,
        input logic             out_hyper_csn1_i ,
        input logic             out_hyper_rwds_i ,
`endif
        input logic             out_spim_sdio0_i ,
        input logic             out_spim_sdio1_i ,
        input logic             out_spim_sdio2_i ,
        input logic             out_spim_sdio3_i ,
        input logic             out_spim_csn0_i  ,
        input logic             out_spim_csn1_i  ,
        input logic             out_spim_sck_i   ,
        input logic             out_i2s0_sck_i   ,
        input logic             out_i2s0_ws_i    ,
        input logic             out_i2s0_sdi_i   ,
        input logic             out_i2s1_sdi_i   ,
        input logic             out_cam_pclk_i   ,
        input logic             out_cam_hsync_i  ,
        input logic             out_cam_data0_i  ,
        input logic             out_cam_data1_i  ,
        input logic             out_cam_data2_i  ,
        input logic             out_cam_data3_i  ,
        input logic             out_cam_data4_i  ,
        input logic             out_cam_data5_i  ,
        input logic             out_cam_data6_i  ,
        input logic             out_cam_data7_i  ,
        input logic             out_cam_vsync_i  ,
        input logic             out_i2c0_sda_i   ,
        input logic             out_i2c0_scl_i   ,
        input logic             out_uart_rx_i    ,
        input logic             out_uart_tx_i    ,

        // OUTPUT SIGNALS FROM THE PADS
`ifdef HYPER_RAM
        output logic            in_hyper_ckn_o   ,
        output logic            in_hyper_ck_o    ,
        output logic            in_hyper_dq0_o   ,
        output logic            in_hyper_dq1_o   ,
        output logic            in_hyper_dq2_o   ,
        output logic            in_hyper_dq3_o   ,
        output logic            in_hyper_dq4_o   ,
        output logic            in_hyper_dq5_o   ,
        output logic            in_hyper_dq6_o   ,
        output logic            in_hyper_dq7_o   ,
        output logic            in_hyper_csn0_o  ,
        output logic            in_hyper_csn1_o  ,
        output logic            in_hyper_rwds_o  ,
`endif
        output logic            in_spim_sdio0_o  ,
        output logic            in_spim_sdio1_o  ,
        output logic            in_spim_sdio2_o  ,
        output logic            in_spim_sdio3_o  ,
        output logic            in_spim_csn0_o   ,
        output logic            in_spim_csn1_o   ,
        output logic            in_spim_sck_o    ,
        output logic            in_i2s0_sck_o    ,
        output logic            in_i2s0_ws_o     ,
        output logic            in_i2s0_sdi_o    ,
        output logic            in_i2s1_sdi_o    ,
        output logic            in_cam_pclk_o    ,
        output logic            in_cam_hsync_o   ,
        output logic            in_cam_data0_o   ,
        output logic            in_cam_data1_o   ,
        output logic            in_cam_data2_o   ,
        output logic            in_cam_data3_o   ,
        output logic            in_cam_data4_o   ,
        output logic            in_cam_data5_o   ,
        output logic            in_cam_data6_o   ,
        output logic            in_cam_data7_o   ,
        output logic            in_cam_vsync_o   ,
        output logic            in_i2c0_sda_o    ,
        output logic            in_i2c0_scl_o    ,
        output logic            in_uart_rx_o     ,
        output logic            in_uart_tx_o     ,

        // EXT CHIP TP PADS
`ifdef HYPER_RAM
        inout wire              pad_hyper_ckn    ,
        inout wire              pad_hyper_ck     ,
        inout wire              pad_hyper_dq0    ,
        inout wire              pad_hyper_dq1    ,
        inout wire              pad_hyper_dq2    ,
        inout wire              pad_hyper_dq3    ,
        inout wire              pad_hyper_dq4    ,
        inout wire              pad_hyper_dq5    ,
        inout wire              pad_hyper_dq6    ,
        inout wire              pad_hyper_dq7    ,
        inout wire              pad_hyper_csn0   ,
        inout wire              pad_hyper_csn1   ,
        inout wire              pad_hyper_rwds   ,
`endif
        inout wire              pad_spim_sdio0   ,
        inout wire              pad_spim_sdio1   ,
        inout wire              pad_spim_sdio2   ,
        inout wire              pad_spim_sdio3   ,
        inout wire              pad_spim_csn0    ,
        inout wire              pad_spim_csn1    ,
        inout wire              pad_spim_sck     ,
        inout wire              pad_i2s0_sck     ,
        inout wire              pad_i2s0_ws      ,
        inout wire              pad_i2s0_sdi     ,
        inout wire              pad_i2s1_sdi     ,
        inout wire              pad_cam_pclk     ,
        inout wire              pad_cam_hsync    ,
        inout wire              pad_cam_data0    ,
        inout wire              pad_cam_data1    ,
        inout wire              pad_cam_data2    ,
        inout wire              pad_cam_data3    ,
        inout wire              pad_cam_data4    ,
        inout wire              pad_cam_data5    ,
        inout wire              pad_cam_data6    ,
        inout wire              pad_cam_data7    ,
        inout wire              pad_cam_vsync    ,
        inout wire              pad_i2c0_sda     ,
        inout wire              pad_i2c0_scl     ,
        inout wire              pad_uart_rx      ,
        inout wire              pad_uart_tx      ,

        inout wire              pad_reset_n      ,
        inout wire              pad_bootsel      ,
        inout wire              pad_jtag_tck     ,
        inout wire              pad_jtag_tdi     ,
        inout wire              pad_jtag_tdo     ,
        inout wire              pad_jtag_tms     ,
        inout wire              pad_jtag_trst    ,
        inout wire              pad_xtal_in


    );
`ifdef HYPER_RAM
    pad_functional_pd padinst_hyper_dq0  (.OEN(~oe_hyper_dq0_i ), .I(out_hyper_dq0_i ), .O(in_hyper_dq0_o ), .PAD(pad_hyper_dq0 ), .PEN(pd_hyper_dq0_i ) );
    pad_functional_pd padinst_hyper_dq1  (.OEN(~oe_hyper_dq1_i ), .I(out_hyper_dq1_i ), .O(in_hyper_dq1_o ), .PAD(pad_hyper_dq1 ), .PEN(pd_hyper_dq1_i ) );
    pad_functional_pd padinst_hyper_dq2  (.OEN(~oe_hyper_dq2_i ), .I(out_hyper_dq2_i ), .O(in_hyper_dq2_o ), .PAD(pad_hyper_dq2 ), .PEN(pd_hyper_dq2_i ) );
    pad_functional_pd padinst_hyper_dq3  (.OEN(~oe_hyper_dq3_i ), .I(out_hyper_dq3_i ), .O(in_hyper_dq3_o ), .PAD(pad_hyper_dq3 ), .PEN(pd_hyper_dq3_i ) );
    pad_functional_pd padinst_hyper_dq4  (.OEN(~oe_hyper_dq4_i ), .I(out_hyper_dq4_i ), .O(in_hyper_dq4_o ), .PAD(pad_hyper_dq4 ), .PEN(pd_hyper_dq4_i ) );
    pad_functional_pd padinst_hyper_dq5  (.OEN(~oe_hyper_dq5_i ), .I(out_hyper_dq5_i ), .O(in_hyper_dq5_o ), .PAD(pad_hyper_dq5 ), .PEN(pd_hyper_dq5_i ) );
    pad_functional_pd padinst_hyper_dq6  (.OEN(~oe_hyper_dq6_i ), .I(out_hyper_dq6_i ), .O(in_hyper_dq6_o ), .PAD(pad_hyper_dq6 ), .PEN(pd_hyper_dq6_i ) );
    pad_functional_pd padinst_hyper_dq7  (.OEN(~oe_hyper_dq7_i ), .I(out_hyper_dq7_i ), .O(in_hyper_dq7_o ), .PAD(pad_hyper_dq7 ), .PEN(pd_hyper_dq7_i ) );
    pad_functional_pd padinst_hyper_rwds (.OEN(~oe_hyper_rwds_i), .I(out_hyper_rwds_i), .O(in_hyper_rwds_o), .PAD(pad_hyper_rwds), .PEN(pd_hyper_rwds_i) );
    pad_functional_pd padinst_hyper_ckn  (.OEN(~oe_hyper_ckn_i ), .I(out_hyper_ckn_i ), .O(in_hyper_ckn_o ), .PAD(pad_hyper_ckn ), .PEN(pd_hyper_ckn_i ) );
    pad_functional_pd padinst_hyper_ck   (.OEN(~oe_hyper_ck_i  ), .I(out_hyper_ck_i  ), .O(in_hyper_ck_o  ), .PAD(pad_hyper_ck  ), .PEN(pd_hyper_ck_i  ) );
    pad_functional_pd padinst_hyper_csn0 (.OEN(~oe_hyper_csn0_i), .I(out_hyper_csn0_i), .O(in_hyper_csn0_o), .PAD(pad_hyper_csn0), .PEN(pd_hyper_csn0_i) );
    pad_functional_pd padinst_hyper_csn1 (.OEN(~oe_hyper_csn1_i), .I(out_hyper_csn1_i), .O(in_hyper_csn1_o), .PAD(pad_hyper_csn1), .PEN(pd_hyper_csn1_i) );
`endif
    pad_functional_pd padinst_spim_sck   (.OEN(~oe_spim_sck_i  ), .I(out_spim_sck_i  ), .O(in_spim_sck_o  ), .PAD(pad_spim_sck  ), .PEN(pd_spim_sck_i  ) );
    pad_functional_pd padinst_spim_sdio0 (.OEN(~oe_spim_sdio0_i), .I(out_spim_sdio0_i), .O(in_spim_sdio0_o), .PAD(pad_spim_sdio0), .PEN(pd_spim_sdio0_i) );
    pad_functional_pd padinst_spim_sdio1 (.OEN(~oe_spim_sdio1_i), .I(out_spim_sdio1_i), .O(in_spim_sdio1_o), .PAD(pad_spim_sdio1), .PEN(pd_spim_sdio1_i) );
    pad_functional_pd padinst_spim_sdio2 (.OEN(~oe_spim_sdio2_i), .I(out_spim_sdio2_i), .O(in_spim_sdio2_o), .PAD(pad_spim_sdio2), .PEN(pd_spim_sdio2_i) );
    pad_functional_pd padinst_spim_sdio3 (.OEN(~oe_spim_sdio3_i), .I(out_spim_sdio3_i), .O(in_spim_sdio3_o), .PAD(pad_spim_sdio3), .PEN(pd_spim_sdio3_i) );
    pad_functional_pd padinst_spim_csn1  (.OEN(~oe_spim_csn1_i ), .I(out_spim_csn1_i ), .O(in_spim_csn1_o ), .PAD(pad_spim_csn1 ), .PEN(pd_spim_csn1_i ) );
    pad_functional_pd padinst_spim_csn0  (.OEN(~oe_spim_csn0_i ), .I(out_spim_csn0_i ), .O(in_spim_csn0_o ), .PAD(pad_spim_csn0 ), .PEN(pd_spim_csn0_i ) );

    pad_functional_pd padinst_i2s1_sdi   (.OEN(~oe_i2s1_sdi_i  ), .I(out_i2s1_sdi_i  ), .O(in_i2s1_sdi_o  ), .PAD(pad_i2s1_sdi  ), .PEN(pd_i2s1_sdi_i  ) );
    pad_functional_pd padinst_i2s0_ws    (.OEN(~oe_i2s0_ws_i   ), .I(out_i2s0_ws_i   ), .O(in_i2s0_ws_o   ), .PAD(pad_i2s0_ws   ), .PEN(pd_i2s0_ws_i   ) );
    pad_functional_pd padinst_i2s0_sdi   (.OEN(~oe_i2s0_sdi_i  ), .I(out_i2s0_sdi_i  ), .O(in_i2s0_sdi_o  ), .PAD(pad_i2s0_sdi  ), .PEN(pd_i2s0_sdi_i  ) );
    pad_functional_pd padinst_i2s0_sck   (.OEN(~oe_i2s0_sck_i  ), .I(out_i2s0_sck_i  ), .O(in_i2s0_sck_o  ), .PAD(pad_i2s0_sck  ), .PEN(pd_i2s0_sck_i  ) );

    pad_functional_pu padinst_jtag_tck   (.OEN(1'b1            ), .I(                ), .O(jtag_tck_o     ), .PAD(pad_jtag_tck  ), .PEN(1'b1           ) );
    pad_functional_pu padinst_jtag_tms   (.OEN(1'b1            ), .I(                ), .O(jtag_tms_o     ), .PAD(pad_jtag_tms  ), .PEN(1'b1           ) );
    pad_functional_pu padinst_jtag_tdi   (.OEN(1'b1            ), .I(                ), .O(jtag_tdi_o     ), .PAD(pad_jtag_tdi  ), .PEN(1'b1           ) );
    pad_functional_pu padinst_jtag_trstn (.OEN(1'b1            ), .I(                ), .O(jtag_trst_o    ), .PAD(pad_jtag_trst ), .PEN(1'b1           ) );
    pad_functional_pd padinst_jtag_tdo   (.OEN(1'b0            ), .I(jtag_tdo_i      ), .O(               ), .PAD(pad_jtag_tdo  ), .PEN(1'b1           ) );

    pad_functional_pd padinst_cam_pclk   (.OEN(~oe_cam_pclk_i  ), .I(out_cam_pclk_i  ), .O(in_cam_pclk_o  ), .PAD(pad_cam_pclk  ), .PEN(pd_cam_pclk_i  ) );
    pad_functional_pd padinst_cam_hsync  (.OEN(~oe_cam_hsync_i ), .I(out_cam_hsync_i ), .O(in_cam_hsync_o ), .PAD(pad_cam_hsync ), .PEN(pd_cam_hsync_i ) );
    pad_functional_pd padinst_cam_data0  (.OEN(~oe_cam_data0_i ), .I(out_cam_data0_i ), .O(in_cam_data0_o ), .PAD(pad_cam_data0 ), .PEN(pd_cam_data0_i ) );
    pad_functional_pd padinst_cam_data1  (.OEN(~oe_cam_data1_i ), .I(out_cam_data1_i ), .O(in_cam_data1_o ), .PAD(pad_cam_data1 ), .PEN(pd_cam_data1_i ) );
    pad_functional_pd padinst_cam_data2  (.OEN(~oe_cam_data2_i ), .I(out_cam_data2_i ), .O(in_cam_data2_o ), .PAD(pad_cam_data2 ), .PEN(pd_cam_data2_i ) );
    pad_functional_pd padinst_cam_data3  (.OEN(~oe_cam_data3_i ), .I(out_cam_data3_i ), .O(in_cam_data3_o ), .PAD(pad_cam_data3 ), .PEN(pd_cam_data3_i ) );
    pad_functional_pd padinst_cam_data4  (.OEN(~oe_cam_data4_i ), .I(out_cam_data4_i ), .O(in_cam_data4_o ), .PAD(pad_cam_data4 ), .PEN(pd_cam_data4_i ) );
    pad_functional_pd padinst_cam_data5  (.OEN(~oe_cam_data5_i ), .I(out_cam_data5_i ), .O(in_cam_data5_o ), .PAD(pad_cam_data5 ), .PEN(pd_cam_data5_i ) );
    pad_functional_pd padinst_cam_data6  (.OEN(~oe_cam_data6_i ), .I(out_cam_data6_i ), .O(in_cam_data6_o ), .PAD(pad_cam_data6 ), .PEN(pd_cam_data6_i ) );
    pad_functional_pd padinst_cam_data7  (.OEN(~oe_cam_data7_i ), .I(out_cam_data7_i ), .O(in_cam_data7_o ), .PAD(pad_cam_data7 ), .PEN(pd_cam_data7_i ) );
    pad_functional_pd padinst_cam_vsync  (.OEN(~oe_cam_vsync_i ), .I(out_cam_vsync_i ), .O(in_cam_vsync_o ), .PAD(pad_cam_vsync ), .PEN(pd_cam_vsync_i ) );

    pad_functional_pu padinst_uart_rx    (.OEN(~oe_uart_rx_i   ), .I(out_uart_rx_i   ), .O(in_uart_rx_o   ), .PAD(pad_uart_rx   ), .PEN(pu_uart_rx_i   ) );
    pad_functional_pu padinst_uart_tx    (.OEN(~oe_uart_tx_i   ), .I(out_uart_tx_i   ), .O(in_uart_tx_o   ), .PAD(pad_uart_tx   ), .PEN(pu_uart_tx_i   ) );
    pad_functional_pd padinst_i2c0_sda   (.OEN(~oe_i2c0_sda_i  ), .I(out_i2c0_sda_i  ), .O(in_i2c0_sda_o  ), .PAD(pad_i2c0_sda  ), .PEN(pd_i2c0_sda_i  ) );
    pad_functional_pd padinst_i2c0_scl   (.OEN(~oe_i2c0_scl_i  ), .I(out_i2c0_scl_i  ), .O(in_i2c0_scl_o  ), .PAD(pad_i2c0_scl  ), .PEN(pd_i2c0_scl_i  ) );

    pad_functional_pu padinst_reset_n    (.OEN(1'b1            ), .I(                ), .O(rstn_o         ), .PAD(pad_reset_n   ), .PEN(1'b1           ) );
    pad_functional_pu padinst_ref_clk    (.OEN(1'b1            ), .I(                ), .O(ref_clk_o      ), .PAD(pad_xtal_in   ), .PEN(1'b1           ) );

endmodule // pad_frame
