# 16-bit-RISC-processor-core
16 bit RISC processor core with Basys 3 FPGA

# 16-Bit Custom RISC Processor Core

A custom single-cycle 16-bit RISC processor designed in Verilog HDL, verified via RTL simulation, and implemented on the Digilent Basys 3 (Xilinx Artix-7) FPGA board.

## 📌 Architecture Overview

* **Data Width:** 16-bit
* **Instruction Width:** 16-bit Fixed-length
* **Register File:** 8 General-Purpose Registers (`R0`–`R7`), where `R0` is hardwired to `0x0000`.
* **Execution Model:** Single-cycle datapath (Fetch, Decode, Execute, Memory, Write-back in a single clock cycle).
* **Memory Architecture:** Harvard architecture with independent Instruction and Data address spaces.
* **Target Hardware:** Digilent Basys 3 (Artix-7 XC7A35T-1CPG236C).
* **I/O Interface:** Memory-Mapped I/O (MMIO) driving on-board LEDs and a multiplexed 4-digit 7-segment display.

---

## 🛠️ Instruction Set Architecture (ISA)

The processor supports R-type, I-type, and J-type instruction formats:

| Format | 15:12 (Opcode) | 11:9 (Rd) | 8:6 (Rs1) | 5:3 (Rs2 / Func) | 2:0 / Immediate |
|:---|:---:|:---:|:---:|:---:|:---:|
| **R-Type** | `0000` | Rd | Rs1 | Rs2 | ALU Func (ADD, SUB, AND, OR, SLT) |
| **I-Type** | Opcode | Rd | Rs1 | Immediate [5:0] (Sign/Zero Extended) | |
| **J-Type** | `0110` (JUMP) | Target Address [11:0] | | | |

### Supported Instructions
* **Arithmetic / Logic:** `ADD`, `SUB`, `AND`, `OR`, `SLT`, `ADDI`
* **Memory Access:** `LW` (Load Word), `SW` (Store Word)
* **Control Flow:** `BEQ` (Branch if Equal), `JUMP` (Unconditional Jump)

---

## 💻 Hardware Verification & FPGA Deployment

1. **RTL Simulation:** Verified with a self-checking testbench (`tb/risc16_core_tb.v`) validating register hazards, branch execution, immediate sign extension, and memory write-back cycles.
2. **Synthesis & Timing Closure:** Synthesized using AMD Xilinx Vivado. Memory-mapped I/O registers ensure zero hierarchical reference violations during physical netlist generation.
3. **Debugging Infrastructure:**
   * Scalable Clock Divider (`sw[15]` toggles between 5 Hz human-readable step mode and 5 MHz high-speed mode).
   * Real-time 7-segment display shows Program Counter (`PC[7:0]`) on the left two digits and ALU output (`ALU_Out[7:0]`) on the right two digits.

---
