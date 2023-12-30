module Processor (
    input logic clk,
    input logic rst,
    input logic interupt
);
    //control signals
    logic            rf_en;
    logic           sel_pc;
    logic        sel_opr_a;
    logic        sel_opr_b;
    logic            sel_m;
    logic  [ 1:0]   sel_wb;
    logic  [ 2:0] imm_type;


    //operation signals
    logic [31:0] pc_out;
    logic [31:0] inst;
    logic [ 4:0] rs2;
    logic [ 4:0] rs1;
    logic [ 4:0] rd;
    logic [ 6:0] opcode;
    logic [ 2:0] func3;
    logic [ 6:0] func7;
    logic [31:0] addr;
    logic [31:0] wdata;
    logic [31:0] rdata;
    logic [31:0] rdata1;
    logic [31:0] rdata2;
    logic [ 3:0] aluop;
    logic [31:0] imm;
    logic [31:0] opr_res;

   //pc control signal
    logic [31:0] mux_out_pc;
    logic [31:0] mux_out_opr_a;
    logic [31:0] mux_out_opr_b;
    logic [ 2:0] br_type;
    logic        br_taken;
    logic        rd_en;
    logic        wr_en;
    logic [ 2:0] mem_type;

    //csr
    logic        tm_interupt;
    logic        csr_rd;
    logic        csr_wr;
    logic [31:0] csr_rdata;
    logic [31:0] epc;
    logic        is_mret;
    logic        epc_taken;
    logic        excep;

    // Pipeline registers
    logic [31:0] pc_out_reg;
    logic [31:0] inst_reg;
    logic [ 4:0] rs2_reg;
    logic [ 4:0] rs1_reg;
    logic [ 4:0] rd_reg;
    logic [ 6:0] opcode_reg;
    logic [ 2:0] func3_reg;
    logic [ 6:0] func7_reg;
    logic [31:0] addr_reg;
    logic [31:0] wdata_reg;
    logic [31:0] rdata_reg;
    logic [31:0] rdata1_reg;
    logic [31:0] rdata2_reg;
    logic [ 3:0] aluop_reg;
    logic [31:0] imm_reg;
    logic [31:0] opr_res_reg;

    // IF stage
    always_ff @(posedge clk or posedge rst)
    begin
        if (rst)
            pc_out_reg <= 'h0;
        else
            pc_out_reg <= mux_out_pc;
    end

    // ID stage
    always_ff @(posedge clk or posedge rst)
    begin
        if (rst)
        begin
            inst_reg    <= 'h0;
            rs2_reg     <= 'h0;
            rs1_reg     <= 'h0;
            rd_reg      <= 'h0;
            opcode_reg  <= 'h0;
            func3_reg   <= 'h0;
            func7_reg   <= 'h0;
            addr_reg    <= 'h0;
            wdata_reg   <= 'h0;
            rdata_reg   <= 'h0;
            rdata1_reg  <= 'h0;
            rdata2_reg  <= 'h0;
            aluop_reg   <= 'h0;
            imm_reg     <= 'h0;
            opr_res_reg <= 'h0;
        end
        else
        begin
            inst_reg    <= inst;
            rs2_reg     <= rs2;
            rs1_reg     <= rs1;
            rd_reg      <= rd;
            opcode_reg  <= opcode;
            func3_reg   <= func3;
            func7_reg   <= func7;
            addr_reg    <= addr;
            wdata_reg   <= wdata;
            rdata_reg   <= rdata;
            rdata1_reg  <= rdata1;
            rdata2_reg  <= rdata2;
            aluop_reg   <= aluop;
            imm_reg     <= imm;
            opr_res_reg <= opr_res;
        end
    end

    // EX stage
    always_ff @(posedge clk or posedge rst)
    begin
        if (rst)
            opr_res_reg <= 'h0;
        else
            opr_res_reg <= opr_res;

        // Data forwarding
        if (rd_en && (rd == rs1_reg) && (rs1_reg != 0))
            mux_out_opr_a <= opr_res_reg;
        else
            mux_out_opr_a <= sel_opr_a ? pc_out_reg : rdata1_reg;

        if (rd_en && (rd == rs2_reg) && (rs2_reg != 0))
            mux_out_opr_b <= opr_res_reg;
        else
            mux_out_opr_b <= sel_opr_b ? imm_reg : rdata2_reg;
    end

    // pc selection mux
    always_comb 
    begin 
    if (epc_taken)
        begin
            mux_out_pc= epc;
        end
        else
        begin
            mux_out_pc = sel_pc ? opr_res : (pc_out + 32'd4);
        end
    end



    PC PC_i
    (
        .clk    ( clk            ),
        .rst    ( rst            ),
        .pc_in  ( mux_out_pc     ),
        .pc_out ( pc_out         )
    );

    inst_mem inst_mem_i
    (
        .addr   ( pc_out          ),
        .data   ( inst            )
    );
    
    inst_decode inst_decode_i
    (
        .inst   ( inst            ),
        .rd     ( rd              ),
        .rs1    ( rs1             ),
        .rs2    ( rs2             ),
        .opcode ( opcode          ),
        .func3  ( func3           ),
        .func7  ( func7           )
    );

    reg_file reg_file_i
    (
        .clk    ( clk             ),
        .rs2    ( rs2             ),
        .rs1    ( rs1             ),
        .rd     ( rd              ),
        .wdata  ( wdata           ),
        .rdata1 ( rdata1          ),
        .rdata2 ( rdata2          ),
        .rf_en  ( rf_en           )

    );

     // controller
    controller controller_i
    (
        .opcode    ( opcode         ),
        .func7     ( func7          ),
        .func3     ( func3          ),
        .rf_en     ( rf_en          ),
        .sel_opr_a ( sel_opr_a      ),
        .sel_opr_b ( sel_opr_b      ),
        .sel_pc    ( sel_pc         ),
        .sel_wb    ( sel_wb         ),
        .imm_type  ( imm_type       ),
        .aluop     ( aluop          ),
        .br_type   ( br_type        ),
        .br_taken  ( br_taken       ),
        .rd_en     ( rd_en          ),
        .wr_en     ( wr_en          ),
        .mem_type  ( mem_type       ),
        .csr_rd    ( csr_rd         ),
        .csr_wr    ( csr_wr         ),
        .is_mret   ( is_mret        )
    );

     alu alu_i
    (
        .aluop    ( aluop          ),
        .opr_a    ( mux_out_opr_a  ),
        .opr_b    ( mux_out_opr_b  ),
        .opr_res  ( opr_res        )
    );


    // immediate generator
    imm_gen imm_gen_i
    (
        .inst      ( inst           ),
        .imm_type  ( imm_type       ),
        .imm       ( imm            )
    );

    Branch_comp Branch_comp_i
    (
        .br_type   ( br_type        ),
        .opr_a     ( mux_out_opr_a  ),
        .opr_b     ( mux_out_opr_b  ),
        .br_taken  ( br_taken       )
    );


    data_mem data_mem_i
    (
        .clk       ( clk            ),
        .rd_en     ( rd_en          ),
        .wr_en     ( wr_en          ),
        .mem_type  ( mem_type       ),
        .addr      ( opr_res        ),
        .wdata     ( rdata2         ),
        .rdata     ( rdata          )
    );

     // csr 
    csr_reg csr_reg_i
    (
        .clk        ( clk             ),
        .rst        ( rst             ),
        .addr       ( opr_res         ),
        .wdata      ( rdata1          ),
        .pc         ( pc_out          ),
        .csr_rd     ( csr_rd          ),
        .csr_wr     ( csr_wr          ),
        .inst       ( inst            ),
        .is_mret    ( is_mret         ),    
        .tm_interupt( interupt        ),
        .rdata      ( csr_rdata       ),
        .epc        ( epc             ),
        .epc_taken  ( epc_taken       ),    
        .excep      ( excep           )
    );

    // operand a selection mux
    assign mux_out_opr_a = sel_opr_a ? pc_out : rdata1;

    // operand b selection mux
    assign mux_out_opr_b = sel_opr_b ? imm    : rdata2;

    always_comb
    begin
        case(sel_wb)
            2'b00: wdata = opr_res;
            2'b01: wdata = rdata;
            2'b10: wdata = pc_out + 32'd4;
            2'b11: wdata = csr_rdata;
            default:
            begin
                wdata = 32'b0;
            end
        endcase
    end

endmodule
