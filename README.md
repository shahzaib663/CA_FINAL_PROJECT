# 3 Stage Piplined Processor #

## Overview: ##
This storehouse contains the Framework Verilog code for a basic processor plan. The processor is written in Framework Verilog and upholds different RISC-V guidelines. Modules for the ALU, register file, memory, and control unit are included in the design.

## Files: ##
- `Processor.sv:` The main module that instantiates all the components of the processor.
- `alu.sv:` The Arithmetic Logic Unit responsible for executing arithmetic and logic operations.
- `reg_file.sv:` The Register File module for handling register read and write operations.
- `data_mem.sv:` The Data Memory module for managing data memory operations.
- `csr_reg.sv:` The Control and Status Register module for handling system control operations.
- `controller.sv:` The Controller module that generates control signals based on the opcode and function codes.
- `PC.v:` The Program Counter module for managing the program counter.
- `inst_mem.sv:` The Instruction Memory module for storing instructions.
- `Inst_decode.sv:` The Instruction Decoder module for decoding instructions.
- `imm_gen.sv:` The Immediate Generator module for generating immediate values.

## HowToUse ##
The design can be simulated using a Verilog simulator like ModelSim. By running the command `./cc.bat`

## System Diagram ##
![System Diagram](/system%20diagram/1.png)

## Author ##
- Shahzaib Javed 
- 2020-CE-25
"# CA_FINAL_PROJECT" 
