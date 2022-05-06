module incline_sat(
    input [12:0] incline,
    output logic [9:0] incline_sat
);

assign incline_sat = (~incline[12] && |incline[12:9]) ? 10'h1FF :// if pos and larger
                    (incline[12] && ~(&incline[12:9])) ? 10'h200 : incline[9:0];
endmodule