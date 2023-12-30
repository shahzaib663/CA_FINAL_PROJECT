module csr_reg
(
    input  logic         clk,
    input  logic         rst,
    input  logic [31: 0] addr,
    input  logic [31: 0] wdata, 
    input  logic [31: 0] pc,   
    input  logic         csr_rd, 
    input  logic         csr_wr,
    input  logic [31: 0] inst,
    input  logic         is_mret,
    input  logic         tm_interupt,
    output logic [31: 0] rdata,
    output logic [31: 0] epc,
    output logic         epc_taken, 
    output logic         excep
);
    logic [31: 0] mstatus_reg, mie_reg, mepc_reg, mip_reg;
    // logic [31: 0] mepc_reg = 
    logic [31: 0] mstatus_comb, mie_comb, mepc_comb, mip_comb;

    // Combinational block for asynchronous read
    always_comb
    begin
        mstatus_comb = mstatus_reg;
        mie_comb = mie_reg;
        mepc_comb = mepc_reg;
        mip_comb = mip_reg;

        if (csr_rd)
        begin
            case (addr)
                12'h300: rdata = mstatus_comb; 
                12'h304: rdata = mie_comb;
                12'h341: rdata = mepc_comb;
                12'h344: rdata = mip_comb;
            endcase
        end
        else
        begin
            rdata = 32'b0;
        end

        // interrupt handling
        if (tm_interupt)
        begin
            mstatus_comb[3] = 1'b1;        
            mie_comb[7] = 1'b1;        
            mip_comb[7] = 1'b1;      
        end    

        if(mstatus_comb[3] & mie_comb[7] & mip_comb[7])
        begin
            excep = 1'b1;
        end
        else
        begin
            excep = 1'b0;
        end
 
        if (is_mret)
        begin
            epc_taken = 1'b1;
            epc       = mepc_comb;
        end
        else
        begin
            epc_taken = 1'b0;
        end
    end

    // Sequential block for synchronous write
    always_ff @(posedge clk)
    begin
        if (csr_wr)
        begin
            mstatus_reg <= wdata;
            mie_reg <= wdata;
            mepc_reg <= wdata;
            mip_reg <= wdata; 
        end
    end
    
endmodule



// module csr_reg
// (
//     input  logic         clk,
//     input  logic         rst,
//     input  logic [31: 0] addr,
//     input  logic [31: 0] wdata, 
//     input  logic [31: 0] pc,   
//     input  logic         csr_rd, 
//     input  logic         csr_wr,
//     input  logic [31: 0] inst,
//     input  logic         is_mret,
//     input  logic         tm_interupt,
//     output logic [31: 0] rdata,
//     output logic [31: 0] epc,
//     output logic         epc_taken, 
//     output logic         excep
// );
//     logic [31: 0] mstatus, mie, mepc, mip;
//     logic [31: 0] mcause   = 32'b0;
//     logic [31: 0] mtvec    = 32'b0;

//     // asynchronous read and interrupt handling
//     always_comb
//     begin
//         if (csr_rd)
//         begin
//             case (addr)
//                 12'h300: rdata = mstatus; 
//                 12'h304: rdata = mie;
//                 12'h341: rdata = mepc;
//                 12'h344: rdata = mip;
//             endcase
//         end
//         else
//         begin
//             rdata = 32'b0;
//         end

//         // interrupt handling
//         if (tm_interupt)
//         begin
//             mstatus[3] = 1'b1;        
//             mie[7] = 1'b1;        
//             mip[7] = 1'b1;      
//         end    

//         if(mstatus[3] & mie[7] & mip[7])
//         begin
//             excep = 1'b1;
//         end
//         else
//         begin
//             excep = 1'b0;
//         end
 
//         if (is_mret)
//         begin
//             epc_taken = 1'b1;
//             epc       = mepc;
//         end
//         else
//         begin
//             epc_taken = 1'b0;
//         end
//     end

//     // synchronous write
//     always_ff @(posedge clk)
//     begin
//         if (csr_wr)
//         begin
//             case (addr)
//                 12'h300: mstatus <= wdata;
//                 12'h304: mie <= wdata;
//                 12'h341: mepc <= wdata;
//                 12'h344: mip <= wdata; 
//             endcase
//         end
//     end
    
// endmodule


// module csr_reg
// (
//     input  logic         clk,
//     input  logic         rst,
//     input  logic [31: 0] addr,
//     input  logic [31: 0] wdata, 
//     input  logic [31: 0] pc,   
//     input  logic         csr_rd, 
//     input  logic         csr_wr,
//     input  logic [31: 0] inst,
//     input  logic         is_mret,
//     input  logic         tm_interupt,
//     output logic [31: 0] rdata,
//     output logic [31: 0] epc,
//     output logic         epc_taken, 
//     output logic         excep
// );
//     logic [31: 0] mstatus, mie, mepc, mip;
//     // logic [31: 0] mstatus  = 00000000000000000000000000001000;
//     // logic [31: 0] mie      = 32'b0;
//     // logic [31: 0] mepc     = 32'b0;
//     // logic [31: 0] mip      = 00000000000000000000000010000000;
//     logic [31: 0] mcause   = 32'b0;
//     logic [31: 0] mtvec    = 32'b0;

//     // asynchronous read
//     always_comb
//     begin
//         if (csr_rd)
//         begin
//             case (addr)
//                 12'h300: rdata = mstatus; 
//                 12'h304: rdata = mie;
//                 12'h341: rdata = mepc;
//                 12'h344: rdata = mip;
//             endcase
//         end
//         else
//         begin
//             rdata = 32'b0;
//         end

//         // interrupt handling
//         if (tm_interupt)
//         begin
//             mstatus[3] = 1'b1;        
//             mie[7] = 1'b1;        
//             mip[7] = 1'b1;      
//         end    

//         if(mstatus[3] & mie[7] & mip[7])
//         begin
//             excep = 1'b1;
//         end
//         else
//         begin
//             excep = 1'b0;
//         end
 
//         if (is_mret)
//         begin
//             epc_taken = 1'b1;
//             epc       = mepc;
//         end
//         else
//         begin
//             epc_taken = 1'b0;
//         end
//     end

//     // synchronous write
//     always_ff @(posedge clk)
//     begin
//         if (csr_wr)
//         begin
//             case (addr)
//                 12'h300: mstatus <= wdata;
//                 12'h304: mie <= wdata;
//                 12'h341: mepc <= wdata;
//                 12'h344: mip <= wdata; 
//             endcase
//         end
//     end
    

// endmodule

// module csr_reg
// (
//     input  logic         clk,
//     input  logic         rst,
//     input  logic [31: 0] addr,
//     input  logic [31: 0] wdata, 
//     input  logic [31: 0] pc,   
//     input  logic         csr_rd, 
//     input  logic         csr_wr,
//     input  logic [31: 0] inst,
//     input  logic         is_mret,
//     input  logic         tm_interupt,
//     output logic [31: 0] rdata,
//     output logic [31: 0] epc,
//     output logic         epc_taken, 
//     output logic         excep
// );
//     logic [31: 0] csr_reg [4];
//     logic [31: 0] mcause   = 32'b0;
//     logic [31: 0] mtvec    = 32'b0;

//     // asynchronous read
//     always_comb
//     begin
//         if (csr_rd)
//         begin
//             case (addr)
//                 12'h300: rdata = csr_reg[0]; // mstatus 
//                 12'h304: rdata = csr_reg[1]; // mie
//                 12'h341: rdata = csr_reg[2]; // mepc
//                 12'h344: rdata = csr_reg[3]; // mip
//             endcase
//         end
//         else
//         begin
//             rdata = 32'b0;
//         end
//     end

//     // synchronous write
//     always_ff @(posedge clk)
//     begin
//         if (csr_wr)
//         begin
//             case (addr)
//                 12'h300: csr_reg[0] <= wdata; // mstatus
//                 12'h304: csr_reg[1] <= wdata; // mie
//                 12'h341: csr_reg[2] <= wdata; // mepc
//                 12'h344: csr_reg[3] <= wdata; // mip 
//             endcase
//         end
//     end

//     // Interrupt logic
//     always_comb 
//     begin
//         if (tm_interupt)
//         begin
//             csr_reg[0][3] = 1'b1;        
//             csr_reg[1][7] = 1'b1;        
//             csr_reg[3][7] = 1'b1;        
//         end    
//     end

//     always_comb 
//     begin
//         if(csr_reg[0][3] & csr_reg[1][7] & csr_reg[3][7])
//         begin
//             excep = 1'b1;
//         end
//         else
//         begin
//             excep = 1'b0;
//         end
//     end
    
//     always_comb
//     begin
//         if (is_mret)
//         begin
//             epc_taken = 1'b1;
//             epc       = csr_reg[2]; // reading the value of 'mepc' register
//         end
//         else
//         begin
//             epc_taken = 1'b0;
//         end
//     end

// endmodule





































// module csr_reg
// (
//     input  logic         clk,
//     input  logic         rst,
//     input  logic [31: 0] addr,
//     input  logic [31: 0] wdata, 
//     input  logic [31: 0] pc,   
//     input  logic         csr_rd, 
//     input  logic         csr_wr,
//     input  logic [31: 0] inst,
//     output logic [31: 0] rdata
// );
//     logic [31: 0] csr_reg [4];

//     // asynchronous read
//     always_comb
//     begin
//         if (csr_rd)
//         begin
//             case (addr)
//                 12'h300: rdata = csr_reg[0]; // mstatus 
//                 12'h304: rdata = csr_reg[1]; // mie
//                 12'h341: rdata = csr_reg[2]; // mepc
//                 12'h344: rdata = csr_reg[3]; // mip
//             endcase
//         end
//         else
//         begin
//             rdata = 32'b0;
//         end
//     end

//     // synchronous write
//     always_ff @(posedge clk)
//     begin
//         if (csr_wr)
//         begin
//             case (addr)
//                 12'h300: csr_reg[0] <= wdata; // mstatus
//                 12'h304: csr_reg[1] <= wdata; // mie
//                 12'h341: csr_reg[2] <= wdata; // mepc
//                 12'h344: csr_reg[3] <= wdata; // mip 
//             endcase
//         end
//     end

    
// endmodule