
# 5-Stage Pipelined RISC-V Processor

## 1. Overview

This project implements a 32-bit RISC-V processor using Verilog HDL.
It explores instruction pipelining, data forwarding, hazard detection,
and modular RTL design.

## 2. Processor Architecture

The processor is organized into five stages:

1. Instruction Fetch (IF)
2. Instruction Decode (ID)
3. Execute (EX)
4. Memory Access (MEM)
5. Write Back (WB)

## 3. Pipeline Stages

### Instruction Fetch (IF)
- Maintains the program counter.
- Fetches instructions from instruction memory.
- Calculates the next sequential address.

### Instruction Decode (ID)
- Decodes instruction fields.
- Reads source operands from the register file.
- Generates control signals and immediate values.

### Execute (EX)
- Performs arithmetic and logical operations.
- Calculates effective memory addresses.
- Evaluates branch conditions.

### Memory Access (MEM)
- Reads data from memory for load instructions.
- Writes data to memory for store instructions.

### Write Back (WB)
- Selects the ALU result or memory-read data.
- Writes the result to the destination register.

## 4. Hazard Handling

### Data Forwarding
Forwarding logic selects results from later pipeline stages
to reduce unnecessary data stalls.

### Hazard Detection
The hazard detection unit identifies load-use dependencies
and requests pipeline stalls.

### Branch Handling
Branch-control logic selects the next PC and requires
pipeline flushing when a branch changes program flow.

## 5. RTL Modules

| Module | Responsibility |
|---|---|
| program_counter.v | Program counter |
| instruction_memory.v | Instruction storage |
| instruction_decoder.v | Instruction decoding |
| immediate_generator.v | Immediate extraction |
| register_file.v | General-purpose registers |
| alu.v | Arithmetic and logic |
| forwarding_unit.v | Data forwarding |
| hazard_detection.v | Load-use detection |
| data_memory.v | Data storage |
| branch_unit.v | Branch comparison |
| riscv_pipeline.v | Top-level integration |

## 6. Tools

- Verilog HDL
- Icarus Verilog
- GTKWave
- AMD Vivado (optional)

## 7. Verification Plan

- Verify reset and program-counter behavior.
- Test arithmetic and logical instructions.
- Verify load and store operations.
- Test data forwarding and pipeline stalls.
- Verify branch decisions and pipeline flushing.

## 8. Current Development Status

The project modules are being developed incrementally.
Full processor integration, simulation, and functional verification
must be completed before the design is considered operational.

## 9. Future Improvements

- Expand RV32I instruction coverage.
- Add automated regression tests.
- Perform FPGA synthesis.
- Analyze timing and hardware resource utilization.
