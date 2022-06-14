# Source Code Structure
Source folder contain the design of hardware architectures. Simulation folder contains files to test function of components. 

# Installation Steps
1. Install vivado at https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools.html
2. Create a new project, add all files under "/SourceCode/Source/all" as source code.
3. Add all files under SourceCode/Simulation as simulation code.
4. Change compilation order to make sure util.vhd is complied first.
5. Set "FPGA_ROS_ACTION.vhd" as top module and set "testbenches_tb.vhd" as simulation top.
6. Change the path names in "testbenches_tb.vhd" from "/home/ziyuan/Projects/actionlib/" to your own path and copy all files under "/SourceCode/Simulation/Test" into that folder. Or just copy the Test folder to "/home/ziyuan/Projects/actionlib/".
7. Run simulation.
