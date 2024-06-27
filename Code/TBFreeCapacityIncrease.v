/*
This module is a test for how the capacity of free cars increases from 13:00 to 16:00.
Each hour is 500 clocks.
*/

module TBFreeCapacityIncrease;

    reg clock;

    initial
        clock = 0;
    always
        #1 clock = !clock;

    reg reset, car_entered, is_uni_car_entered, car_exited, is_uni_car_exited;
    wire [4:0] hour;
    wire [9:0] uni_parked_car, free_parked_car, uni_vacated_space, free_vacated_space;
    wire uni_is_vacated_space, free_is_vacated_space, ja_nist, faulty_exit;

    Parking parking(clock, reset, car_entered, is_uni_car_entered, car_exited, is_uni_car_exited, 
                            hour, uni_parked_car, free_parked_car, uni_vacated_space, free_vacated_space, 
                            uni_is_vacated_space, free_is_vacated_space, ja_nist, faulty_exit);


    integer i;
    initial begin
        reset = 1;
        car_entered = 0;
        is_uni_car_entered = 0;
        car_exited = 0;
        is_uni_car_exited = 0;

        #2
        reset = 0;

        for (i = 0; i < 1000; i = i + 1) begin
            #9
            car_entered = 1;
            is_uni_car_entered = i%3;
            #1
            car_entered = 0;
        end

        $stop();

    end

    initial begin
        $monitor("%t) hour = %d || uni por = %d, khali = %d, iskhali = %d | free por = %d, khali = %d, iskhali = %d | janist = %d, exitna = %d", 
        $time, hour, 
        uni_parked_car, uni_vacated_space, uni_is_vacated_space,
        free_parked_car, free_vacated_space, free_is_vacated_space,
        ja_nist, faulty_exit);
    end
    
endmodule

