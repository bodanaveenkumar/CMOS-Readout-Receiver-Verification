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



## 5. Simulation and Testing

Simulation was performed using **Vivado 2020.2 XSim**.

### Tested Frame Configurations

| Frame | Width | Height | Pixels |
|---|---:|---:|---:|
| 1 | 64 | 2 | 128 |
| 2 | 54 | 3 | 162 |
| 3 | 50 | 16 | 800 |
| **Total** | | | **1,090** |

### Scoreboard Verification Results

| Metric | Result |
|---|---:|
| Frames checked | 3 |
| Pixels checked | 1,090 |
| Pixel data errors | 0 |
| SOF errors | 0 |
| EOL errors | 0 |
| Frame errors | 0 |

### Monitor Results

| Metric | Result |
|---|---:|
| Valid pixels observed | 1,090 |
| SOF events | 3 |
| EOL events | 21 |
| Frame start events | 3 |
| Frame done events | 3 |
| Error flag samples | 0 |

### Final Simulation Result

**SCOREBOARD RESULT: PASS**

All three tested frames were successfully checked. No pixel data or protocol errors were detected during this simulation.

- Simulation completion time: 11,470 ns
- Testbench: `tb_driver_test`
- Simulator: Vivado 2020.2 XSim

Detailed results are available in `simulation/reports/verification_summary.md`.

Simulation waveforms are available in `simulation/waveforms/`.



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

