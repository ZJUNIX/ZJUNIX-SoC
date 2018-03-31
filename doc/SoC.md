# Overall Description

### 1. CPU Pipeline

The processor supports a subset of MIPS32 instruction set(87 instructions in total).

* 4-stage single-issue static pipeline
* 2-bit dynamic branch prediction
* Address translation prediction to speed up address translation in IF stage
* COP0, TLB, and L1 cache

The full list of instructions is as follows:

| Type           | Instructions                             |
| -------------- | ---------------------------------------- |
| Arithmetic(22) | add, addi, addiu, addu, sub, subu, slt, slti, sltiu, sltu, mul, mult, multu, madd, maddu, msub, msubu, div, divu, clo, clz, lui |
| Logic(13)      | and, andi, or, ori, xor, xori, nor, sll, sllv, srl, srlv, sra, srav |
| Memory(12)     | lb, lbu, lh, lhu, lwl, lwr, lw, sb, sh, swl, swr, sw |
| Branch(12)     | beq, bne, blez, bgez, bltz, bgtz, bltzal, bgezal, j, jal, jr, jalr |
| Move(6)        | movz, movn, mfhi, mthi, mflo, mtlo       |
| Trap(12)       | tge, tgei, tgeiu, tgeu, tlt, tlti, tltiu, tltu, teq, teqi, tne, tnei |
| COP0(7)        | mfc0, mtc0, tlbr, tlbwi, tlbwr, tlbp, eret |
| Misc.(3)       | break, syscall, cache                    |

All instructions takes 1 clock cycle to execute if no RAW(read-after-write) data dependency exists. If there is RAW dependency, memory load and integer multiplication instructions take 2 cycles; divide instructions take approximately 32 cycles; all other instructions take 1 cycle.

For detailed explanations on individual instructions please consult *MIPS32™ Architecture For Programmers Volume II: The MIPS32™ Instruction Set*. The exception is the **cache** instruction, with any data cache operations interpreted as **hit writeback** and any instruction cache operations interpreted as **hit invalidate**.

### 2. Translation Look-aside Buffer

The processor uses a TLB for address translation. The TLB is designed to be compliant with MIPS32 specifications, and has a size of 32 entries, random replacement. The value for the Random register is generated using a linear congruential generator $X_{n+1}=(65521X_n+1)\ mod\ 2^{18}$ and $\$Random=X_n\times(32-\$Wired)\div2^{18}+\$Wired$. The length of the translated physical address is 32 bits.

For detailed explanations on MIPS32 TLB behavior please consult *MIPS32™ Architecture For Programmers Volume III: The MIPS32™ Privileged Resource Architecture*. Note that the PageMask field of the TLB is not fully compliant with the specification: Odd numbers of 1 bits in this field are also valid, which means, besides 4KB, 16KB etc., page sizes of 8KB, 32KB etc. are also valid. In addition, consecutive writes to TLB will put it in undefined state, so make sure to separate TLB writes at least one instruction apart.

On processor reset, contents in TLB are not cleared, so the software should initialize the TLB to a valid state.

### 3. Coprocessor 0

The processor uses a coprocessor for privileged resource and system state management. This coprocessor is designed to be compliant with MIPS32 specifications. Note that all data hazards in the coprocessor should be resolved by software: at least 2 No-op's should be inserted between COP0 register modification and TLB operation or *eret* instruction.

The coprocessor implements the following registers:

| Name        | ID   |
| ----------- | ---- |
| $Index      | 0:0  |
| $Random     | 1:0  |
| $EntryLo0   | 2:0  |
| $EntryLo1   | 3:0  |
| $Context    | 4:0  |
| $PageMask   | 5:0  |
| $Wired      | 6:0  |
| $BadVAddr   | 8:0  |
| $Count      | 9:0  |
| $SysTimerLo | 9:6  |
| $SysTimerHi | 9:7  |
| $EntryHi    | 10:0 |
| $Compare    | 11:0 |
| $Status     | 12:0 |
| $Cause      | 13:0 |
| $EPC        | 14:0 |
| $PRId       | 15:0 |
| $Config     | 16:0 |
| $Config1    | 16:1 |
| $ErrorEPC   | 30:0 |

\$SysTimerLo and \$SysTimerHi are not defined in MIPS32 specifications; they are a pair of 64-bit high-resolution counter which are unaffected by any processor events except cold reset. Two **consecutive** *mfc0* instructions, first lo then hi, are required to get the complete 64-bit value of this counter.

The coprocessor implements Kernel Mode and User Mode; there is no Supervisor Mode or Debug Mode.

The coprocessor implements the following exceptions:

* Reset
* Address Error
* TLB Refill
* TLB Invalid
* TLB Modified
* Integer Overflow
* Trap
* System Call
* Breakpoint
* Reserved Instruction
* Coprocessor Unusable
* Interrupt

Refer to *MIPS32™ Architecture For Programmers Volume III: The MIPS32™ Privileged Resource Architecture* for detailed explanations on Coprocessor 0 and other privileged resource architecture.

### 4. Cache

There are no specifications in MIPS32 describing the cache, so the cache is fully custom-designed. Cache is designed to be transparent to the processor, except for instructions for writing back or invalidating cache blocks (see description above in *CPU pipeline*).

Cache architecture is 2-way set associative, 64-byte line size, 512 sets per way, LRU replacement, no allocate on write miss. Instruction and data reference use individual caches, each 64KB, resulting in total L1 cache size of 128KB.

On system reset, tags of the cache are initialized to the lower 64KB of physical memory and valid bits are cleared, while dirty bits and data are maintained.

Note that there is no mechanism for ensuring data consistency between the instruction cache and the data cache, so data written to the data cache will not appear in the instruction cache unless explicit **cache** instructions are executed to writeback/invalidate certain cache blocks.

### 5. Bus Architecture

The SoC consists of 3 buses: instruction bus, data bus, and cache-DRAM high-speed bus.

The bus between cache and DRAM is a standard Wishbone bus, and the width is 512 bits. It operates at 200MHz.

Instruction bus and data bus are modified Wishbone bus. It uses *nak* instead of *ack* for handshake; further, responds on the data bus are always 1 clock cycle behind the request: data response or *nak* assertion are generated 1 cycle after the corresponding bus request. Responds on the instruction bus are generated in the same cycle of the request, though. These 2 buses operate synchronously to the processor, at 100MHz.

Sample data bus transactions(from master's point of view):

![](image/img1.png)

* A0 is a write transaction(stb=1, we=1). nak is not generated in the cycle after A0, so this transaction completes without stall.
* A1 is a read transaction(stb=1, we=0). nak is generated in the cycle after A1, and after nak is deasserted by peripheral, a valid data is presented on din. This transaction completes after stalling for 2 cycles.
* A2 is a read transaction. It is initiated in the cycle after A1, but since A1 is stalled, A2 is not responded until transaction A1 is completed.
* A3 is a write transaction. It completes without stall.

### 6. Address Space

The virtual address space is compliant with MIPS32 specifications:

| Virtual Address         | Usage                    |
| ----------------------- | ------------------------ |
| 0x00000000 - 0x7FFFFFFF | User Mapped              |
| 0x80000000 - 0x9FFFFFFF | Kernel Unmapped          |
| 0xA0000000 - 0xBFFFFFFF | Kernel Unmapped Uncached |
| 0xC0000000 - 0xFFFFFFFF | Kernel Mapped            |

Physical address space is slightly different from industrial conventions: the *Kernel Unmapped Uncached* segment maps to a dedicated I/O address space, and this physical address space cannot be access via cached virtual address segments even they map to the same physical address. In other words, any cached memory reference goes to the DRAM main memory, while any uncached memory reference goes to this I/O address space.

Unmapped uncached memory references correspond to transactions on instruction bus and data bus mentioned above.

### 7. Peripherals

Basic I/Os include 16 slide switched, a 5x5 pushbutton array, 8-digit 7-segment display, 16 LEDs, PS/2 controller and UART controller. The PS/2 and UART controllers have hardware buffers that map to a single word in the address space; memory references to those addresses will automatically fill transmit buffer or empty receive buffer.

The system uses SD card as external storage. Software interface of the SD card controller is compatible with the controller at https://github.com/mczerski/SD-card-controller, except for the clock divider register(it divides input clock by $(X+1)$ instead of $2(X+1)$). See its document for details on the control register set.

The system has a VGA controller for output, which provides 4-bit color depth per channel and 640x480 resolution. It has character mode only.

Address allocation(shown in virtual address space):

| Address                 | Device                        |
| ----------------------- | ----------------------------- |
| 0xBF000000 - 0xBF3FFFFF | SRAM                          |
| 0xBFC00000 - 0xBFC03FFF | ROM for BIOS/bootloader       |
| 0xBFC04000 - 0xBFC07FFF | Character mode VRAM           |
| 0xBFC08000 - 0xBFC08FFF | Buffer for SD card controller |
| 0xBFC09000              | 16 slide switches             |
| 0xBFC09004              | button pad                    |
| 0xBFC09008              | 7-segment display             |
| 0xBFC0900C              | 16 LEDs                       |
| 0xBFC09010              | UART data register(buffer)    |
| 0xBFC09014              | UART control register         |
| 0xBFC09018              | PS/2 data register(buffer)    |
| 0xBFC0901C              | PS/2 control register         |
| 0xBFC09100 - 0xBFC091FF | SD card controller registers  |

### 8. Bootstrapping

The bootloader is written in the ROM mentioned above. Note that this ROM is actually a RAM; writing to this address are accepted, and if the writing is careless, it can corrupt the bootloader; in this case, the FPGA should be programmed again.

The ROM can be reprogrammed when holding down system reset and sending new data via UART. The UART is configured at 115200, 8N1 in this case. Data in a word should be sent least-significant byte first. **Reprogram the ROM only if you know what your are doing**.

After system reset, the processor starts to execute instructions in the bootloader. The bootloader performs 2 major functions:

1. Initialize the SD card to 4-bit SD bus mode, clock speed 25MHz, transfer size 512 bytes;
2. Search for a file named *kernel.bin* in the first partition (file system should be FAT32, cluster size 4KB) and load it into main memory

The kernel image is loaded to the lowest part of physical memory: virtual address starting from 0x80000000. Cache instructions are also executed to ensure the kernel image is written to the SDRAM main memory. Kernel entry point is 0x80001000.

The bootloader also includes code for capturing unhandled exceptions in the operating system. Current processor state, including GPRs and some COP0 registers, will be printed on the screen. However, in case the bootloader is corrupted, this function may not operate correctly.

