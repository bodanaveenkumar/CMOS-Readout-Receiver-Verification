\# CMOS Readout Receiver – Functional Verification using SystemVerilog



\## 1. Project Overview



This project focuses on the functional verification of a CMOS Readout Receiver RTL design using SystemVerilog.



The verification environment generates pixel-frame transactions, drives input signals into the Design Under Test (DUT), monitors video output signals, and checks the received pixel data using a scoreboard.



\## 2. Tools and Technologies



\- \*\*HDL:\*\* Verilog, SystemVerilog

\- \*\*Simulator:\*\* Xilinx Vivado XSim

\- \*\*Tool Version:\*\* Vivado 2020.2

\- \*\*Operating System:\*\* Windows

\- \*\*Verification Methodology:\*\* Modular SystemVerilog Testbench



\## 3. Design Under Test (DUT)



\*\*RTL Module:\*\* `cmos\_readout\_rx.v`



The CMOS Readout Receiver processes incoming pixel data and generates corresponding video output signals.



\### Input Signals



| Signal | Description |

|---|---|

| `pix\_clk` | Pixel clock |

| `rst\_n` | Active-low reset |

| `fval` | Frame-valid signal |

| `lval` | Line-valid signal |

| `pix\_data\[11:0]` | 12-bit pixel input data |



\### Output Signals



\- `vid\_valid`

\- `vid\_data`

\- Start of Frame (SOF)

\- End of Line (EOL)



\## 4. Verification Environment



The testbench follows a modular architecture with separate components.



| File | Responsibility |

|---|---|

| `frame\_txn.svh` | Transaction definition |

| `generator.svh` | Generates pixel-frame transactions |

| `driver.svh` | Drives DUT input signals |

| `monitor.svh` | Monitors DUT output signals |

| `scoreboard.svh` | Checks expected versus actual output data |

| `tb\_driver\_test.sv` | Main driver-based testbench |

| `cmos\_if.sv` | SystemVerilog interface |



Additional testbenches are included for interface-based, simple, generator and transaction testing.



\## 5. Simulation and Testing



Simulation was performed using Vivado 2020.2 and XSim.



\### Previously Tested Frame Configurations



| Frame Configuration | Description |

|---|---|

| 64 × 2 | Frame test configuration |

| 54 × 3 | Frame test configuration |

| 50 × 16 | Frame test configuration |



\- Total monitored pixels reported: \*\*1,090\*\*

\- Simulation duration: \*\*1,000 ns\*\*

\- Simulation waveforms were inspected using Vivado.



\*\*Verification note:\*\* Simulation completion was observed. Final scoreboard PASS/FAIL status requires confirmation from the simulation logs.



\## 6. Verification Features



\- Modular SystemVerilog testbench architecture.

\- Pixel-frame transaction generation.

\- DUT input driving.

\- Video output monitoring.

\- Expected versus actual data comparison using a scoreboard.

\- Multiple frame configuration testing.

\- Behavioral simulation using XSim.

\- Waveform inspection.



\## 7. Future Improvements



\- Strengthen scoreboard checking.

\- Add SystemVerilog Assertions (SVA).

\- Implement functional coverage.

\- Add corner-case and error-condition testing.

\- Improve automated simulation reporting.



\## 8. Repository Structure



```text

CMOS-Readout-Receiver-Verification/

├── rtl/

├── testbench/

├── simulation/

├── vivado/

├── README.md

└── .gitignore

```



\## 9. Author



\*\*Naveen Kumar\*\*



M.Tech – VLSI Design



NIT Jalandhar, India



\---



\*This project is developed as a functional verification portfolio project using SystemVerilog and Xilinx Vivado XSim.\*

