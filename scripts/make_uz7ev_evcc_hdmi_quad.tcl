# ----------------------------------------------------------------------------
#       _____
#      *     *
#     *____   *____
#    * *===*   *==*
#   *___*===*___**  AVNET
#        *======*
#         *====*
# ----------------------------------------------------------------------------
# 
#  This design is the property of Avnet.  Publication of this
#  design is not authorized without written consent from Avnet.
# 
#  Please direct any questions to the UltraZed community support forum:
#     http://www.ultrazed.org/forum
# 
#  Product information is available at:
#     http://www.ultrazed.org/product/ultrazed
# 
#  Disclaimer:
#     Avnet, Inc. makes no warranty for the use of this code or design.
#     This code is provided  "As Is". Avnet, Inc assumes no responsibility for
#     any errors, which may appear in this code, nor does it make a commitment
#     to update the information contained herein. Avnet, Inc specifically
#     disclaims any implied warranties of fitness for a particular purpose.
#                      Copyright(c) 2016 Avnet, Inc.
#                              All rights reserved.
# 
# ----------------------------------------------------------------------------
# 
#  Create Date:         Dec 11, 2020
#  Design Name:         UltraZed HDMI QUAD Design Platform
#  Module Name:         make_uz_hdmi_quad.tcl
#  Project Name:        UltraZed HDMI QUAD Design Generator
#  Target Devices:      UltraZed
#  Hardware Boards:     UltraZed
# 
#  Tool versions:       Xilinx Vivado 2020.2
# 
#  Description:         Build Script for UltraZed HDMI QUAD HW Platform
# 
#  Dependencies:        make.tcl
#
#  Revision:            Dec 11, 2020: 1.00 Initial version
# 
# ----------------------------------------------------------------------------

if {$argc != 0} {
    # Build HDMI QUAD HW Platform
    # for UltraZed Defined from external source
    set argv [list board=[lindex $argv 0] project=[lindex $argv 1] sdk=no close_project=yes version_override=yes dev_arch=zynqmp]
    set argc [llength $argv]
    source ./make.tcl -notrace
} else {

   # Build HDMI QUAD HW Platform
   # for UltraZed 7EV SOM + EV Carrier
   set argv [list board=uz7ev_evcc project=hdmi_quad sdk=no close_project=yes version_override=yes dev_arch=zynqmp]
   set argc [llength $argv]
   source ./make.tcl -notrace

}