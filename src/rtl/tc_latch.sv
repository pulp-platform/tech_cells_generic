// Copyright (c) 2025 Mosaic SoC AG, ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// Author: Moritz Scherer <moritz@mosaic-soc.com>

module tc_latch_enpos_rstn (
    input  logic clk_i,
    input  logic rst_ni,
    input  logic data_i,
    output logic data_o
);

  always_latch begin
    if (~rst_ni) begin
      data_o <= '0;
    end else if (clk_i) begin
      data_o <= data_i;
    end
  end

endmodule
