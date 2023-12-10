# CPUy: A simple 8-bits processor using external ROM and featuring Timers and Interruptions (WIP)

This CPUy, a simple "mind-crafted by experience" implementation of an 8-bits CPU. CPUy does not follow any design pattern for it's implementation, it's rather inspired on the AT89SXX series from Atmel used by the author during his days at [the university](https://virtualunexpo.com/) as an electronics engineer undergraduate student implementing microncontroller projects.

## CPUy features

- 10-bits address bus for a maximum external memory of 4096 bytes.
- 8-bits data bus.
- 256 bytes internal scratch pad memory.
- 8 x 8-bits registers, some with special functions like CPU and Timers configuration.
- 44 supported instructions (arithmetic, logic, branching, movement), some instructions requiring 2 clock cycles and more complex instructions requiring 3 clock cycles for execution.
- 2 bidirectional/configurable I/O ports: P0 8-bits, P1 4-bits.
- 2 16-bits timers with configurable mode (up/down count), autoreload and interrupt.
- 1 dedicated pin for external interrupt.
- 16-levels LIFO stack.
- Combinational-logic ALU and microcode.

## Overview of CPUy architecture

TODO: Add diagram.

The main flow of instructions execution is made in the [main cpuy verilog file](./cpuy.v) where a state machine, implemented as a verilog case statement, controls the cpu.

CPUy uses one register to hold the current instruction OpCode and two registers to hold operands for instructions that have them.

The microcode takes the OpCode fetched and decodes the instruction indicating it's type and other parameters for the execution, the microcode is a combinational logic circuit so the outputs signals are driven once the opcode is fetched and ready to be used by the CPU control in later phases of instructions execution.

The type of instructions can be:

- ALU instructions: operations performed through the ALU, like Inc, Add, Not.

- Movement instructions: operations to move data to W from Memory, Ports or Registers, or to move data from W to Memory, Ports, Registers and Configuration Registers.

- Jump operations: branch operations under a given condition, these instructions do not Push onto the stack.

- Stack Instructions: operations like Call or Ret that make use of Pop/Push into the stack and perform a jump (PC change) to another address.

The ALU is also a combinational logic circuit, so, the operations are performed once the corresponding values are available, the CPU takes the result in the right moment of the execution cycle.

The possible states of the CPU state machine are:

- RESETTING: When the *rst* pin is driven high for at least one clock cycle the CPU state machine is set to this state, after *rst* pin goes low, the CPU will remain in this state for 2 more clock cycles to reset the peripherals like the stack and timers. After reset, the PC will be set to the *RESET_VECTOR* which ROM address is 0x000;
- FETCHING_OPCODE: In this state the CPU is reading the data bus that must be holding the output of the current Address Bus memory value.
- FETCHING_OPERANDS: If the instructions have operands (indicated by the MSB of OpCode) the CPU enters this state to fetch 1 or 2 operands from the ROM.
- POPPING_STACK: For instrucctions that require poping an address from the stack, particularly the RET instructions, the CPU must provide an additional Clock Cycle for the stack to output the address.
- EXECUTING: This is the main execution state where the CPU performs the movement of data, or read from the ALU results, etc., according to the signals coming from the microcode.
- INTERRUPT_REDIRECTION: if an interruption was detected, the CPU takes a clock cycle to perform the stack push and redirection to the corresponding interruption vector.

## CPU configuration register

The CPU Configuration register has the following structure:

**[GIE] [ExtIE] [T0IE] [T1IE] [X] [X] [X] [X]**

- bit 0: UNUSED
- bit 1: UNUSED
- bit 2: UNUSED
- bit 3: UNUSED
- bit 4: Timer 0 Interruption Enable (if set to 1 enables the Timer 0 Interruption)
- bit 5: Timer 1 Interruption Enable (if set to 1 enables the Timer 1 Interruption)
- bit 6: External Interruption Enable (if set to 1 enables the External Interruption)
- bit 7: Global Interruption Enable (GIE) (if zero no interruption is triggered)

## Timers configuration register

The Timers Configuration register has the following structure:

**[x] [T1AR] [T1DIR] [T1E] [x] [T0AR] [T0DIR] [T0E]**

- bit 0: Timer 0 Interruption Enable (if set to 1 enables interruption of Timer 0)
- bit 1: Timer 0 counter direction: 0 down, 1 Up
- bit 2: Timer 0 Autoreload (1 autoreload last configured count value)
- bit 3: UNUSED
- bit 4: Timer 1 Interruption Enable (if set to 1 enables interruption of Timer 1)
- bit 5: Timer 1 counter direction: 0 down, 1 Up
- bit 6: Timer 1 Autoreload (1 autoreload last configured count value)
- bit 7: UNUSED

## Instructions

The instructions are divided in two main types: instructions with operands and instructions without operands. The first group has 0 in the OpCode MSB, the other group has 1 on it.

The list of instructions are:

### Instructions without operands:

- NOP: Performs no operation.
- Dec: Decreases W by 1.
- Inc: Increases W by 1.
- Not: Logical NOT over W.
- SetC: Sets carry to 1.
- ClrC: Sets carry to 0.
- RL: Rotates W to left.
- RR: Rotates W to right.
- RLC: Rotates W to left using carry.
- RRC: Rotates W to right using carry.
- Swap: Swaps W nibbles.
- RET: Returns from Call.
- PortsCfg: Moves R0 and R1 to ports config to set pins direction.
- CpuCfg: Moves W to CPU configuration registers.
- TmrCfg: Moves W to Timers Configuraion register, the count values are taken from R0 and R1 for Timer 0 and from R2 and R3 for Timer 1.
- MovWPX: Moves W to PortX (X = 0 or 1).
- MovPXW: Moves PortX to W (X = 0 or 1).
- MovWRX: Moves W to RegisterX (X in [0, 7]).
- MovRXW: Moves RegisterX to W (X in [0, 7]).
- SetbXW: Sets bit X of W to 1 (X in [0, 7]).
- ClrbXW: Sets bit X of W to 0 (X in [0, 7]).

### Instructions with operands:

- MovMW: Moves a RAM address to W.
- MovWM: Moves W to a RAM address.
- MovLW: Moves a literal to W.
- MovLM: Moves a literal to a RAM address.
- AddLW: Adds a literal to W.
- AddMW: Adds a RAM address to W.
- SubLW: Subs a literal from W.
- SubMW: Subs a RAM address from W.
- MulLW: Multiplies a literal with W.
- MulMW: Multiplies a RAM address with W.
- AndLW: Performs a logical AND between a literal and W.
- AndMW: Performs a logical AND between a RAM address and W.
- OrLW: Performs a logical OR between a literal and W.
- OrMW: Performs a logical OR between a RAM address and W.
- XorLW: Performs a logical XOR between a literal and W.
- XorMW: Performs a logical XOR between a RAM address and W.
- XchWM: Exchanges W with a RAM address.
- Jmp: Performs an unconditional jump.
- JmpC: Jumps if carry is 1.
- JmpZ: Jumps if zero flag is 1.
- JmpS: Jumps if sign flag is 1.
- Call: Calls a ROM address (no stack).
- TbXjc: Jumps to a ROM address if bit X of W is 0 (X in [0, 7]).
- TbXjs: Jumps to a ROM address if bit X of W is 1 (X in [0, 7]).

As a compementary resources please refer to the [instructions excel sheet](./instructions/Processor%20instructions%20set.xlsx)

TODO: provide detailed instructions hex implementation
