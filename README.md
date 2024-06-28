# Problem 8: DSD Parking Controller - spring 2024

This project is a parking controller which monitors the capacity, parked, and empty spaces and updates them when cars enter or exit.
## Implementation Details
### Input
| signal name  | purpose | sensitive to pos/neg edge |
| :-------------: | :-------------: | :-------------: |
| `clock`  | clock of the design  | posedge |
| `reset`  | resets parked spaces to 0 and clock to 8  | posedge |
| `car_entered`  | =1 if entering is requested  | negedge |
| `is_uni_car_entered`  | type of entering car  | - |
| `car_exited`  | =1 if exiting is requested  | negedge |
| `is_uni_car_exited`  | type of exiting car  | - |

### Output
| signal name  | purpose |
| :-------------: | :-------------: |
| `hour` | current time |
| `uni_parked_car` | number of university parked cars |
| `free_parked_car` | number of free parked cars |
| `uni_vacated_space` | number of university empty spaces |
| `free_vacated_space` | number of free empty spaces |
| `uni_is_vacated_space` | is there an empty uni space |
| `free_is_vacated_space` | is there an empty free space |
| `ja_nist` | not enough space for the new car to enter |
| `faulty_exit` | invalid exit request, no car to exit |

### Assumptions and Details
- All signals are generated asynchronously except for `hour` which increases every 500 clock pulses until it's 8 A.M. again.
- If a university entering has been requested and there is no uni space, but free spaces are empty the request is still rejected and a free request should be submitted instead.
- When a new day starts at 8 A.M., number of parked cars is reset to zero and uni capacity goes back to 500.
- From 1 P.M. to 4 P.M., uni capacity is decreased by 50 and when 4 P.M. arrives the uni capacity is set to 200. Therefore the uni capacity is 500 from 1 to 2, 450 from 2 to 3, 400 from 3 to 4, and 200 from 4 P.M. to 8 A.M. next day.
- Request response signals (ja_nist, faulty_exit) are set when the invalid request is submitted (at negedge of `car_entered` or `car_exited`) and reset to 0 after the next posedge of `clock`
- Some edge detection signals are used instead of using multiple always blocks so that the code is synthesizable.

A more detailed explanation of the module can be found in the [report](Document/report.pdf).

## Testing
Testing was done in modelsim and three benchmarks were used to check general and edge cases.
- Test 1 (TB1): General tests
- Test 2 (TBFreeCapacityIncrease): Check capcacity changes after 1 P.M.
- Test 3 (TBExit): Check valid and invalid exiting

After testing was successfully completed, synthesis reports were generated using Quartus for Cyclone V.

Synthesis and test results are explained in the [report](Document/report.pdf).

## Author
Yasna Nooshiravani - 401106674
