module pulse_control(
    input clock,
    input ready,
    output pcEn,
);
    reg r1, r2, r3;

    always @(posedge clock) begin
        r1 <= ready;    // first stage of 2-stage synchronizer
        r2 <= r1;       // second stage of 2-stage synchronizer
        r3 <= r2;       // edge detector memory
    end

    assign pcEn = r2 && ~r3;   // pulse on rising edge
endmodule
