# ----------------------------------------------------------------------------
#
#        ** **        **          **  ****      **  **********  ********** ®
#       **   **        **        **   ** **     **  **              **
#      **     **        **      **    **  **    **  **              **
#     **       **        **    **     **   **   **  *********       **
#    **         **        **  **      **    **  **  **              **
#   **           **        ****       **     ** **  **              **
#  **  .........  **        **        **      ****  **********      **
#     ...........
#                                     Reach Further™
#
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
#  Create Date:         Nov 19, 2020
#  Design Name:         HDMI HW Platform
#  Module Name:         hdmi.tcl
#  Project Name:        HDMI BSP Generator
#  Target Devices:      Zynq UltraScale+ 7EV
#  Hardware Boards:     UltraZed-EV SOM Carrier
# 
#  Tool versions:       Vivado 2020.2
# 
#  Description:         Build Script for HDMI support HW Platform
# 
#  Dependencies:        To be called from a configured make script call
#                       Calls support scripts, such as board configuration 
#                       scripts IP generation scripts or others as needed
# 
#
#  Revision:            Nov 19, 2020: 1.00 Initial version
# 
# ----------------------------------------------------------------------------

# 'private' used to allow this project to be privately tagged
# 'public' used to allow this project to be publicly tagged
set release_state public

if {[string match -nocase "yes" $clean]} {
   # Clean up project output products.

   # Open the existing project.
   puts ""
   puts "***** Opening Vivado Project $projects_folder/$project.xpr ..."
   open_project $projects_folder/$project.xpr
   
   # Reset output products.
   reset_target all [get_files ${projects_folder}/${project}.srcs/sources_1/bd/${project}/${project}.bd]

   # Reset design runs.
   reset_run impl_1
   reset_run synth_1

   # Reset project.
   reset_project
} else {
   # Create Vivado project
   puts ""
   puts "***** Creating Vivado Project..."
   source ../boards/$board/$project/${board}_${project}.tcl -notrace
#TC   avnet_create_project $project $projects_folder $scriptdir
   avnet_create_project $board $projects_folder $scriptdir
   # Remove the SOM specific XDC file since no constraints are needed for 
   # the basic system design
   remove_files -fileset constrs_1 *.xdc
   
   # Apply board specific project property settings
   switch -nocase $board {
      uz7ev_evcc {
         puts ""
         puts "***** Assigning Vivado Project board_part Property to ultrazed_ev_evcc_production..."
         set_property board_part avnet.com:ultrazed_7ev_cc:part0:1.4 [current_project]
      }
   }

   # Generate Avnet IP
   puts ""
   puts "***** Generating IP..."
   source ./makeip.tcl -notrace
   #avnet_generate_ip PWM_w_Int

   # Add Avnet IP Repository
   # The IP_REPO_PATHS looks for a <component>.xml file, where <component> is the name of the IP to add to the catalog. The XML file identifies the various files that define the IP.
   # The IP_REPO_PATHS property does not have to point directly at the XML file for each IP in the repository.
   # The IP catalog searches through the sub-folders of the specified IP repositories, looking for IP to add to the catalog. 
   puts ""
   puts "***** Updating Vivado to include IP Folder"
   cd ../projects
   set_property ip_repo_paths  ../ip [current_fileset]
   update_ip_catalog
   
   # Create Block Design and Add PS core
   puts ""
   puts "***** Creating Block Design..."
#TC   create_bd_design ${project}
#TC   set design_name ${project}
   create_bd_design ${board}
   set design_name ${board}
   
   # Add Processing System presets from board definitions.
#TC   avnet_add_ps_preset $project $projects_folder $scriptdir
   avnet_add_ps_preset $board $projects_folder $scriptdir

   # Add User IO presets from board definitions.
   puts ""
   puts "***** Add defined IP blocks to Block Design..."
#TC   avnet_add_user_io_preset $project $projects_folder $scriptdir
   avnet_add_user_io_preset $board $projects_folder $scriptdir

   # General Config
   puts ""
   puts "***** General Configuration for Design..."
   set_property target_language VHDL [current_project]
   #set_property target_language Verilog [current_project]
   
   avnet_add_hdmi $board $projects_folder $scriptdir
   avnet_assign_addresses $board $projects_folder $scriptdir


   # Redraw the BD and validate the design
   regenerate_bd_layout
   validate_bd_design

   # Add the constraints that are needed
   import_files -fileset constrs_1 -norecurse ../boards/${board}/hdmi/hdmi.xdc


   # Add Project source files
   puts ""
   puts "***** Adding Source Files to Block Design..."
#TC   make_wrapper -files [get_files ${projects_folder}/${project}.srcs/sources_1/bd/${project}/${project}.bd] -top
#TC   add_files -norecurse ${projects_folder}/${project}.srcs/sources_1/bd/${project}/hdl/${project}_wrapper.vhd
   make_wrapper -files [get_files ${projects_folder}/${board}.srcs/sources_1/bd/${board}/${board}.bd] -top
   add_files -norecurse ${projects_folder}/${board}.srcs/sources_1/bd/${board}/hdl/${board}_wrapper.vhd
   #add_files -norecurse ${projects_folder}/${project}.srcs/sources_1/bd/${project}/hdl/${project}_wrapper.v
   

   # Add Vitis directives
   puts ""
#TC   puts "***** Adding SDSoC Directves to Design..."
#TC   avnet_add_sdsoc_directives $project $projects_folder $scriptdir
#TC   avnet_add_sdsoc_directives $board $projects_folder $scriptdir
   puts "***** Adding Vitis Directves to Design..."
   avnet_add_vitis_directives $board $projects_folder $scriptdir
   update_compile_order -fileset sources_1
   import_files

   
   # Build the binary
   #*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
   #*- KEEP OUT, do not touch this section unless you know what you are doing! -*
   #*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
   puts ""
   puts "***** Building Binary..."
   # add this to allow up+enter rebuild capability 
   cd $scripts_folder
   update_compile_order -fileset sources_1
   update_compile_order -fileset sim_1
   save_bd_design
   #launch_runs impl_1 -to_step write_bitstream -j 4
   launch_runs impl_1 -to_step write_bitstream -jobs $numberOfCores
   #*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
   #*- KEEP OUT, do not touch this section unless you know what you are doing! -*
   #*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
   puts ""
   puts "***** Wait for bitstream to be written..."
   wait_on_run impl_1
   puts ""
   puts "***** Open the implemented design..."
   open_run impl_1
   puts ""
   puts "***** Write and validate the design archive..."
#TC   write_dsa ${projects_folder}/${project}.dsa -include_bit -force
#TC   validate_dsa ${projects_folder}/${project}.dsa -verbose
   write_hw_platform ${projects_folder}/${board}.xsa -include_bit -force
   validate_hw_platform ${projects_folder}/${board}.xsa -verbose
   puts "***** Close the implemented design..."
   close_design
}