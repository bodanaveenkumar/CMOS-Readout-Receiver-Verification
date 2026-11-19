\# CMOS Readout Receiver – Verification Summary



\## Simulation Environment

\- Simulator: Vivado 2020.2 XSim

\- Language: SystemVerilog

\- Testbench: tb\_driver\_test



\## Test Scenarios



| Frame | Width | Height | Pixels |

|---|---:|---:|---:|

| 1 | 64 | 2 | 128 |

| 2 | 54 | 3 | 162 |

| 3 | 50 | 16 | 800 |

| Total | | | 1090 |



\## Verification Results



| Metric | Result |

|---|---:|

| Frames checked | 3 |

| Pixels checked | 1090 |

| Pixel data errors | 0 |

| SOF errors | 0 |

| EOL errors | 0 |

| Frame errors | 0 |

| SOF events | 3 |

| EOL events | 21 |

| Frame start events | 3 |

| Frame done events | 3 |



\## Final Result



SCOREBOARD RESULT: PASS



All three frames were successfully checked.

No pixel data or protocol errors were detected.



Simulation finished at 11470 ns.

