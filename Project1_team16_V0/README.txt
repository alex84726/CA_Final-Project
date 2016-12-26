How to run the code ?
1. Put the input file name at the same level of the "src/" file, and modify the input file name in the testbench.v that is to be read.
2. Type "iverilog -o (whatever) *.v" to compile all verilog files.
3. Type "vvp (whatever)" to run.
4. The result will be output in the same dir of src/. The .vcd is for visualizing the wave using gtkwave.
