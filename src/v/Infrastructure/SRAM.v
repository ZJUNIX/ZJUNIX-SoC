module SRAM(
    input wire clk,  // main clock
    input wire rst,  // synchronous reset

    // SRAM interfaces
    (* IOB="true" *)
    output reg [2:0]sram_ce_n,
    (* IOB="true" *)
    output reg [2:0]sram_oe_n,
    (* IOB="true" *)
    output reg [2:0]sram_we_n,
    (* IOB="true" *)
    output reg [2:0]sram_ub_n,
    (* IOB="true" *)    
    output reg [2:0]sram_lb_n,
    (* IOB="true" *)
    output reg [19:0] sram_addr,
    (* IOB="true" *)
    inout wire [47:0] sram_data,
    
    // WishBone Bus
    input wire wb_stb,  // chip select
    input wire [31:0] wb_addr,  // address
    input wire [3:0] wb_we,
    input wire [31:0] wb_din,
    output wire [47:0] wb_dout,
    output reg wb_nak
    );
    
    reg [47:0] sram_dout;
    assign
            sram_data = (&sram_we_n) ? {48{1'bz}} : sram_dout,
            wb_dout = sram_data;
            
    localparam
        S_IDLE = 0,  // idle
        S_READ = 1,  // read data
        S_WRITE = 2,  // write data
        S_READ_D = 3, //read delay
        S_READ_RES = 4, //read result
        S_WRITE_RES = 5, //write result
        S_WRITE_D = 6;
    
    reg [2:0] state = 0;
    reg [2:0] next_state;
    reg [3:0] bus_we;
    reg [31:0] bus_din;
    
    always @(*) begin
        next_state = 0;
        case (state)
            S_IDLE: begin
                if (wb_stb)
                    if (|wb_we)
                       next_state = S_WRITE;
                    else
                       next_state = S_READ;
                else
                    next_state = S_IDLE;
            end
            S_READ: begin
                 next_state = S_READ_D;
            end
            S_READ_D: begin
                 next_state = S_READ_RES;
            end
            S_READ_RES: begin
                 if (wb_stb)
                    if (|wb_we)
                       next_state = S_WRITE;
                    else
                       next_state = S_READ;
                 else
                    next_state = S_IDLE;
            end
            S_WRITE: begin
                 next_state = S_WRITE_D;
            end
            S_WRITE_D:begin
                next_state = S_WRITE_RES;
            end
            S_WRITE_RES: begin
                 if (wb_stb)
                     if (|wb_we)
                         next_state = S_WRITE;
                     else
                         next_state = S_READ;
                 else
                     next_state = S_IDLE;
            end
        endcase
    end
    
    always @(posedge clk) begin
        if (rst) begin
            state <= 0;
        end
        else begin
            state <= next_state;
        end
    end
    
    always @(posedge clk) begin
        wb_nak <= 1'b0;
        sram_ce_n <= 3'b111;
        sram_oe_n <= 3'b111;
        sram_we_n <= 3'b111;
        sram_ub_n <= 3'b111;
        sram_lb_n <= 3'b111;
        sram_addr <= 20'b0;
        sram_dout <= 48'b0;
        if (~rst) case (next_state)
            S_IDLE: begin
                wb_nak <= 1'b0;
            end
            S_READ: begin
                 wb_nak <= 1'b1;
                 sram_ce_n <= 3'b000;
                 sram_oe_n <= 3'b000;
                 sram_ub_n <= 3'b000;
                 sram_lb_n <= 3'b000;
                 sram_addr <= wb_addr[21:2];
            end
            S_READ_D: begin
                wb_nak <= 1'b1;
                sram_ce_n <= sram_ce_n;
                sram_oe_n <= sram_oe_n;
                sram_ub_n <= sram_ub_n;
                sram_lb_n <= sram_lb_n;
                sram_addr <= sram_addr;
            end
            S_READ_RES: begin
                wb_nak <= 1'b0;
                sram_ce_n <= sram_ce_n;
                sram_oe_n <= sram_oe_n;
                sram_ub_n <= sram_ub_n;
                sram_lb_n <= sram_lb_n;
                sram_addr <= sram_addr;
            end
            S_WRITE: begin
                wb_nak <= 1'b1;
                sram_ce_n <= 3'b0;
                sram_addr <= wb_addr[21:2];
                sram_dout <= {16'b0, wb_din};
                sram_we_n <= 3'b111;
                bus_we <= wb_we;
                sram_ub_n <= {1'b1, ~wb_we[3], ~wb_we[1]};
                sram_lb_n <= {1'b1, ~wb_we[2], ~wb_we[0]};
            end
            S_WRITE_D: begin
                wb_nak <= 1'b1;
                sram_ce_n <= sram_ce_n;
                sram_addr <= sram_addr;
                sram_dout <= sram_dout;
                sram_we_n <= {1'b1, ~(bus_we[3] | bus_we[2]), ~(bus_we[1] | bus_we[0])};
                sram_ub_n <= sram_ub_n;
                sram_lb_n <= sram_lb_n;
            end
            S_WRITE_RES: begin
                 wb_nak <= 1'b0;
                 sram_ce_n <= sram_ce_n;
                 sram_addr <= sram_addr;
                 sram_dout <= sram_dout;
                 sram_we_n <= 3'b111;
                 sram_ub_n <= sram_ub_n;
                 sram_lb_n <= sram_lb_n;
            end
        endcase
    end
    
endmodule
