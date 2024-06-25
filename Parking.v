module Parking 
(
    input clock, reset, car_entered, is_uni_car_entered, car_exited, is_uni_car_exited,
    output wire [4:0] hour,
    output reg [9:0] uni_parked_car, parked_care, uni_vacated_space, vacated_space,
    output reg uni_is_vacated_space, is_vacated_space, ja_nist, faulty_exit
);
    localparam CLOCKS_IN_HOUR = 500;
    localparam TOTAL_CAPACITY = 700;
    reg [4:0] hourBase8;
    integer counter; //each hour is 500 clocks
    integer uni_capacity;

    assign hour = hourBase8 + 8;

    always @(posedge reset or posedge clock) begin
        if (reset) begin
            hourBase8 = 5'b0;
            counter = 0;
            // reset (day is over)
            uni_parked_car = 10'b0;
            parked_care = 10'b0;
            uni_vacated_space = 10'd500;
            vacated_space = 10'd700;
            uni_is_vacated_space = 1'b1;
            is_vacated_space = 1'b1;
            ja_nist = 1'b0;
            faulty_exit = 1'b0;
        end
        else begin
            counter = (counter + 1) % CLOCKS_IN_HOUR;
            if (counter == 0) begin
                hourBase8 = (hourBase8 + 1) % 24;
                if (hourBase8 == 0) begin
                    // reset (day is over)
                    uni_parked_car = 10'b0;
                    parked_care = 10'b0;
                    uni_vacated_space = 10'd500;
                    vacated_space = 10'd700;
                    uni_is_vacated_space = 1'b1;
                    is_vacated_space = 1'b1;
                    ja_nist = 1'b0;
                    faulty_exit = 1'b0;
                end

            end
        end
    end
    
endmodule
