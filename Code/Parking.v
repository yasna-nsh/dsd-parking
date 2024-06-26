module Parking 
(
    input clock, reset, car_entered, is_uni_car_entered, car_exited, is_uni_car_exited,
    output wire [4:0] hour,
    output reg [9:0] uni_parked_car, free_parked_car, uni_vacated_space, free_vacated_space,
    output reg uni_is_vacated_space, free_is_vacated_space, ja_nist, faulty_exit
);
    localparam CLOCKS_IN_HOUR = 500;
    localparam TOTAL_CAPACITY = 700;
    reg [4:0] hourBase8;
    reg clock_edge_det, car_entered_det, car_exited_det;
    integer counter; //each hour is 500 clocks
    integer uni_capacity;

    assign hour = (hourBase8 + 8)%24;

    integer enteredUniCarCount, exitedUniCarCount, enteredFreeCarCount, exitedFreeCarCount;
    integer tempUni, tempFree;

    always @(reset or clock or car_entered or car_exited) begin
        if (reset) begin
            hourBase8 = 5'b0;
            counter = 0;
            // reset
            uni_parked_car = 10'b0;
            free_parked_car = 10'b0;
            uni_vacated_space = 10'd500;
            free_vacated_space = 10'd200;
            uni_is_vacated_space = 1'b1;
            free_is_vacated_space = 1'b1;
            ja_nist = 1'b0;
            faulty_exit = 1'b0;
            uni_capacity = 500;
            enteredUniCarCount = 0;
            exitedUniCarCount = 0;
            enteredFreeCarCount = 0;
            exitedFreeCarCount = 0;
        end
        else begin
            // increase time at posedge of clock
            if (clock && !clock_edge_det) begin
                counter = (counter + 1) % CLOCKS_IN_HOUR;
                if (counter == 0) begin
                    hourBase8 = (hourBase8 + 1) % 24;
                    if (hourBase8 == 0) begin
                        // reset (day is over)
                        uni_parked_car = 10'b0;
                        free_parked_car = 10'b0;
                        uni_vacated_space = 10'd500;
                        free_vacated_space = 10'd200;
                        uni_is_vacated_space = 1'b1;
                        free_is_vacated_space = 1'b1;
                        ja_nist = 1'b0;
                        faulty_exit = 1'b0;
                        uni_capacity = 500;
                        enteredUniCarCount = 0;
                        exitedUniCarCount = 0;
                        enteredFreeCarCount = 0;
                        exitedFreeCarCount = 0;
                    end
                end
            end

            // update capacity
            if (counter == 0) begin
                if (hourBase8 == 6)
                    uni_capacity = 450;
                else if (hourBase8 == 7)
                    uni_capacity = 400;
                else if (hourBase8 == 8)
                    uni_capacity = 200;

                // free uni cars if they don't fit
                if (uni_parked_car > uni_capacity) begin
                    enteredFreeCarCount = enteredFreeCarCount + (uni_parked_car - uni_capacity);
                    enteredUniCarCount = enteredUniCarCount - (uni_parked_car - uni_capacity);
                end
            end

            if (car_entered_det && !car_entered) begin
                if (is_uni_car_entered) enteredUniCarCount = enteredUniCarCount + 1;
                else enteredFreeCarCount = enteredFreeCarCount + 1;
            end

            if (car_exited_det && !car_exited) begin
                if (is_uni_car_exited) exitedUniCarCount = exitedUniCarCount + 1;
                else exitedFreeCarCount = exitedFreeCarCount + 1;
            end

            // update car counts and error signals
            ja_nist = 0;
            faulty_exit = 0;
            tempUni = enteredUniCarCount - exitedUniCarCount;
            tempFree = enteredFreeCarCount - exitedFreeCarCount;
            if (tempUni > uni_capacity) begin
                enteredUniCarCount = exitedUniCarCount + uni_capacity;
                ja_nist = 1;
            end
            else if (tempUni < 0) begin
                exitedUniCarCount = enteredUniCarCount;
                faulty_exit = 1;
            end
            else if (tempFree > TOTAL_CAPACITY - uni_capacity) begin
                enteredFreeCarCount = exitedFreeCarCount + TOTAL_CAPACITY - uni_capacity;
                ja_nist = 1;
            end
            else if (tempFree < 0) begin
                exitedFreeCarCount = enteredFreeCarCount;
                faulty_exit = 1;
            end
            uni_parked_car = enteredUniCarCount - exitedUniCarCount;
            free_parked_car = enteredFreeCarCount - exitedFreeCarCount;
            uni_vacated_space = uni_capacity - uni_parked_car;
            free_vacated_space = TOTAL_CAPACITY - uni_capacity - free_parked_car;
            uni_is_vacated_space = (uni_vacated_space != 0);
            free_is_vacated_space = (free_vacated_space != 0);
        end

        clock_edge_det = clock;
        car_entered_det = car_entered;
        car_exited_det = car_exited;
    end
    
endmodule