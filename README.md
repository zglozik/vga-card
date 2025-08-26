Overview
========

FPGA learner project in System Verilog to implement a hardware VGA graphics card (640x480, 12bit colors) with simple drawing primitives, SDRAM-based frame buffer and 2D sprite support, on a [Terasic DE10-Lite dev board](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=234&No=1021). The implementation was tested by running the Chrome Dinosaur game on the same FPGA using the Nios II soft core CPU, using hardware registers and custom NIOS instructions to interface with the hardware video card.

[<img src="https://img.youtube.com/vi/6tkLuwqnhOc/0.jpg">](https://youtu.be/6tkLuwqnhOc)

## Features

- Frame buffer stored in SDRAM with 12-bit color depth, 2 bytes per pixel. Frame buffer is accessible via Avalon MM Slave interface by user code and hardware drawing primitives.
- Hardware implementation for drawing lines, filling rectangles and moving regions in frame buffer.
- Hardware implementation for displaying 2-D sprites (48 pixel by 48 pixel) at a given location on the screen, sprite bitmap can come from SDRAM or any other source using Avalon MM Slave interface. 
- Frame buffer and sprite pixels are continuously cached from SDRAM into on-chip FPGA memory during VGA display, this is necessary due to variable SDRAM read latency.
- QSYS interconnect priority based arbitration is used to ensure SDRAM framebuffer caching to on-chip FPGA RAM has highest priority for the pixel stream to keep up with VGA scan line.
- Two clock domains: vga driver operates in 25Mhz VGA frequency, the rest of the system can run at a higher frequency (60Mhz with the board above).
- The system is built with Intel's Qsys Platform designer using standard Avalon interfaces and Qsys interconnect, so it is easy to reconfigure for using only the components required.
- The Chrome Dino demo game is written in C using Intel's Eclipse-based Software Build Tool, the C code is small as it just instructs the hardware where to display sprites and when to scroll background.

## Directory structure

```
|
|- utils/                         # System Verilog modules (FIFO, 7 segment display driver, Avalon ST bridge)
|- vga/                           # System Verilog modules for VGA signal generation, frame buffer and sprite streaming to display module
|- graphics/                      # System Verilog modules for hardware drawing primitives
|- dino-demo/                     # Chrome Dinosaur game demo system and software
    |- v/                         # Top-Level Verilog module for instantiating demo QSYS system
    |- dino-system/
        |- dino_system.{tcl,qsys} # QSYS system configuration for the hardware above, SDRAM access and Nios II soft CPU core
        |- software/
            |- dino-software_bsp/ # QSys Board Support package for the NIOS-based hardware platform
            |- dino-software/     # Chrome Dino game C source code using the BSP and hardware above
```

## Building and running the demo

### Hardware/Software requirements

- [Terasic DE10-Lite dev board](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=234&No=1021) board
- 640x480 VGA screen
- Quartus Prime Lite 16.x or higher (Linux or Windows, I have used 20.1.1). The demo system uses the Intel SDRAM controller IP, which is not free after 20.1.1.
- [Nios II Embedded Design Suite](https://www.intel.com/content/www/us/en/docs/programmable/683525/21-3/installing-eclipse-ide-into-eds.html)
- Intel FPGA IP used from Quartus: SDRAM Controller IP, QSys interconnect, Dual Clock FIFO for clock domain crossing, Nios II CPU core.

### Building the QSys platform and FPGA configuration

- Generate the HDL for the QSYS interconnect and Nios II CPU core by using the included `dino_system.qsys` file, either using the Platform Designer or on the command line:

```
$ <QUARTUS_DIR>/nios2eds/nios2_command_shell.sh
$ cd .../dino-demo/dino-system/
$ qsys-generate --synthesis=VERILOG dino_system.qsys
```

This will create the full FPGA system under the `dino-demo/dino-system/dino_system` directory.

- Open the `vga-card.qpf` Quartus Prime project and compile the design.

- Use the Quartus Programmer to download `output_files/output_files/` to the board.

- Create and build the C Board Support Package for the hardware from the `dino_system.sopcinfo` system descriptor file using the Nios II Embedded Design Suite:

```
$ cd .../dino-demo/dino-system/software/dino-software_bsp
$ nios2-bsp-update-settings --settings settings.bsp
$ nios2-bsp-generate-files --settings settings.bsp  --bsp-dir .
$ make
...
[BSP build complete]
```

- Build the Dino C application using the above BSP:

```
$ cd .../dino-demo/dino-system/software/dino-software
$ make
...
Info: (dino-software.elf) 18 KBytes program size (code + initialized data).
Info:                     13 KBytes free for stack + heap.
...
[dino-software build complete]
```

- Start a NIOS II terminal to see debug console output from JTAG UART connection:

```
$ nios2-terminal 
nios2-terminal: connected to hardware target using JTAG UART on cable
...
```

- Download the ELF application to the NIOS II system:

```
$ make download-elf
Info: Building ../dino-software_bsp/
make --no-print-directory -C ../dino-software_bsp/
[BSP build complete]
Info: Downloading dino-software.elf
Using cable "USB-Blaster [1-2]", device 1, instance 0x00
Pausing target processor: not responding.
Resetting and trying again: OK
Reading System ID at address 0x00000210: verified
Initializing CPU cache (if present)
OK
Downloaded 18KB in 0.0s        
Verified OK                         
Starting processor at address 0x00010180
```

- You should see th Dino game on the screen. One of the board buttons is the reset, the other button is for jumping. Debug output on nios2 terminal:

```
[crt0.S] Inst & Data Cache Initialized.
[crt0.S] Setting up stack and global pointers.
[crt0.S] Clearing BSS 
[crt0.S] Calling alt_main.
[alt_main.c] Entering alt_main, calling alt_irq_init.
[alt_main.c] Done alt_irq_init, calling alt_os_init.
[alt_main.c] Done OS Init, calling alt_sem_create.
[alt_main.c] Calling alt_sys_init.
[alt_main.c] Done alt_sys_init.
[alt_main.c] Calling main.
Hello from Nios II, drawing sprites!
ticks_per_second: 100
timestamp frequency: 60000000
```
