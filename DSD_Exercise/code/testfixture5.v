`timescale 1ns/10ps
`define CYCLE    10           	         // Modify your clock period here
`define SDFFILE  "./GSIM_syn.sdf"	      // Modify your sdf file name
`define PAT      "./pattern5.dat"    
`define DEL      1
module test;
parameter N_PAT   = 16;

reg   clk ;
reg   reset ;
reg   in_en;
reg   [15:0]  b_in;
wire  out_valid;
wire  [31:0]  x_out;

reg   [15:0]  pat_mem   [0:N_PAT-1];
reg   [31:0]  x         [0:N_PAT-1];
reg   [15:0]  b         [0:N_PAT-1];
reg   [15:0]  b_tmp;
integer       loop, i, j, out_f;
reg           stop;
real  Mb [0:15];
real  x_f[0:15];
real  SquareError, error, temp;


   GSIM GSIM( .clk(clk), .reset(reset), .in_en(in_en), .b_in(b_in),
              .out_valid(out_valid), .x_out(x_out));
   

`ifdef SDF
   initial $sdf_annotate(`SDFFILE, GSIM);
`endif

initial	$readmemh (`PAT, pat_mem);


initial begin
   clk         = 1'b0;
   reset       = 1'b0;
   in_en       = 1'b0;   
   b_in        = 'hz;
   stop        = 1'b0;   
   loop        = 0;
end

always begin #(`CYCLE/2) clk = ~clk; end

initial begin
$dumpfile("GSIM.vcd");
$dumpvars;
//$fsdbDumpfile("GSIM.fsdb");
//$fsdbDumpvars;

   out_f = $fopen("out.dat");
   if (out_f == 0) begin
        $display("Output file open error !");
        $finish;
   end
end


initial begin
   @(posedge clk)  #`DEL  reset = 1'b1;
   #`CYCLE                reset = 1'b0;
   
   @(posedge clk)  #`DEL i=0;
    while (i < N_PAT) begin               
         b_in  = pat_mem[i];
         b[i]  = pat_mem[i];
         in_en = 1'b1;
         i=i+1;                  
      @(posedge clk); #`DEL; 
    end     
    in_en = 1'b0;  b_in=16'hz;
end


always @(posedge clk)begin
   if(loop <16)begin
      if(out_valid)begin
         x[loop]=x_out;
         loop=loop+1;
      end
   end
   else begin
         stop=1;
   end
end


initial begin
   @(posedge stop) 
     for (j=0;j<=15;j=j+1)begin
        if(x[j][31]==1) begin   x_f[j]=~x[j] +1'b1;    x_f[j] =-x_f[j]/65536;  end
        else            begin   x_f[j]= x[j];          x_f[j] = x_f[j]/65536;  end
     end
                          
     Mb[0 ]= 20*x_f[0 ]-13*x_f[1 ]+ 6*x_f[2 ]-   x_f[3 ];
     Mb[1 ]=-13*x_f[0 ]+20*x_f[1 ]-13*x_f[2 ]+ 6*x_f[3 ]-   x_f[4 ];
     Mb[2 ]=  6*x_f[0 ]-13*x_f[1 ]+20*x_f[2 ]-13*x_f[3 ]+ 6*x_f[4 ]-  x_f[5 ];      
     Mb[3 ]=   -x_f[0 ]+ 6*x_f[1 ]-13*x_f[2 ]+20*x_f[3 ]-13*x_f[4 ]+6*x_f[5 ]-x_f[6 ];      
     Mb[4 ]=   -x_f[1 ]+ 6*x_f[2 ]-13*x_f[3 ]+20*x_f[4 ]-13*x_f[5 ]+6*x_f[6 ]-x_f[7 ];
     Mb[5 ]=   -x_f[2 ]+ 6*x_f[3 ]-13*x_f[4 ]+20*x_f[5 ]-13*x_f[6 ]+6*x_f[7 ]-x_f[8 ];                    
     Mb[6 ]=   -x_f[3 ]+ 6*x_f[4 ]-13*x_f[5 ]+20*x_f[6 ]-13*x_f[7 ]+6*x_f[8 ]-x_f[9 ];
     Mb[7 ]=   -x_f[4 ]+ 6*x_f[5 ]-13*x_f[6 ]+20*x_f[7 ]-13*x_f[8 ]+6*x_f[9 ]-x_f[10];
     Mb[8 ]=   -x_f[5 ]+ 6*x_f[6 ]-13*x_f[7 ]+20*x_f[8 ]-13*x_f[9 ]+6*x_f[10]-x_f[11];
     Mb[9 ]=   -x_f[6 ]+ 6*x_f[7 ]-13*x_f[8 ]+20*x_f[9 ]-13*x_f[10]+6*x_f[11]-x_f[12];
     Mb[10]=   -x_f[7 ]+ 6*x_f[8 ]-13*x_f[9 ]+20*x_f[10]-13*x_f[11]+6*x_f[12]-x_f[13];
     Mb[11]=   -x_f[8 ]+ 6*x_f[9 ]-13*x_f[10]+20*x_f[11]-13*x_f[12]+6*x_f[13]-x_f[14];
     Mb[12]=   -x_f[9 ]+ 6*x_f[10]-13*x_f[11]+20*x_f[12]-13*x_f[13]+6*x_f[14]-x_f[15];     
     Mb[13]=   -x_f[10]+ 6*x_f[11]-13*x_f[12]+20*x_f[13]-13*x_f[14]+6*x_f[15];
     Mb[14]=   -x_f[11]+ 6*x_f[12]-13*x_f[13]+20*x_f[14]-13*x_f[15];
     Mb[15]=   -x_f[12]+ 6*x_f[13]-13*x_f[14]+20*x_f[15];   
        
     SquareError = 0;        
     
     for(j=0; j<=15; j=j+1)begin     	  
       	if(b[j][15]==1)begin 
       		b_tmp= ~b[j]+1;
       		temp = b_tmp;
       		error= temp + Mb[j];
       	end
       	else begin
       		error = Mb[j] - b[j];
       	end
       	//$display(" Loop=%d    error= %.15f  \n", j, error);
     	  SquareError = SquareError + error*error;
     end
                   
     $display("-----------------------------------------------------\n");
     $display("        Your Output           Golden X\n");
     $display("  X1:     %.10f           3357.0527331891  \n", x_f[0 ]);
     $display("  X2:     %.10f           3331.6573214124  \n", x_f[1 ]);
     $display("  X3:     %.10f           -358.9862207599  \n", x_f[2 ]);
     $display("  X4:     %.10f           -732.4078391379  \n", x_f[3 ]);
     $display("  X5:     %.10f           1445.8347318405  \n", x_f[4 ]);
     $display("  X6:     %.10f           3809.3571054117  \n", x_f[5 ]);
     $display("  X7:     %.10f           3275.8464009486  \n", x_f[6 ]);
     $display("  X8:     %.10f          -2304.1420650291  \n", x_f[7 ]);
     $display("  X9:     %.10f          -5725.0258222666  \n", x_f[8 ]);
     $display(" X10:     %.10f          -3237.6062094197  \n", x_f[9 ]);
     $display(" X11:     %.10f           3156.1618206622  \n", x_f[10]);
     $display(" X12:     %.10f           4247.9033467564  \n", x_f[11]);
     $display(" X13:     %.10f           1984.8291218781  \n", x_f[12]);
     $display(" X14:     %.10f           1028.3354905648  \n", x_f[13]);
     $display(" X15:     %.10f           1055.5861912423  \n", x_f[14]);
     $display(" X16:     %.10f            959.5718332319  \n", x_f[15]);          
     $display("-----------------------------------------------------\n");
     $display("So Your Error Ratio=  %.15f\n", SquareError);
     $display("-----------------------------------------------------\n");   
     
     error=SquareError;
     if(error<0.000001 && error!='hx && error!='hz)begin                           
         $display("Your Score Level: A \n");  
         $display("Congratulations! GSIM's Function Successfully!\n");
         $display("-------------------------PASS------------------------\n");
     end    
         
     else if(error>=0.000001 && error <0.000005 && error!='hx && error!='hz)begin
        $display("Your Score Level: B \n");
        $display("Congratulations! GSIM's Function Successfully!\n");
        $display("-------------------------PASS------------------------\n");
     end
     else if(error>=0.000005 && error <0.000010 && error!='hx && error!='hz)begin
        $display("Your Score Level: C \n");
        $display("Congratulations! GSIM's Function Successfully!\n");
        $display("-------------------------PASS------------------------\n");
     end 
     else if(error>=0.000010 && error <0.000050 && error!='hx && error!='hz)begin
        $display("Your Score Level: D \n");
        $display("Congratulations! GSIM's Function Successfully!\n");
        $display("-------------------------PASS------------------------\n");
     end 
        
     else if(error>=0.000050 && error <0.000100 && error!='hx && error!='hz)begin
        $display("Your Score Level: E \n");
        $display("Congratulations! GSIM's Function Successfully!\n");
        $display("-------------------------PASS------------------------\n");
     end     
     else if(error>=0.000100 && error <0.001000 && error!='hx && error!='hz)begin
        $display("Your Score Level: F \n");
        $display("Congratulations! GSIM's Function Successfully!\n");
        $display("-------------------------PASS------------------------\n");
     end 
     else if(error>=0.001000 && error <0.005000 && error!='hx && error!='hz)begin
        $display("Your Score Level: G \n");
        $display("Congratulations! GSIM's Function Successfully!\n");
        $display("-------------------------PASS------------------------\n");
     end 
     else if(error>=0.005000 && error <0.010000 && error!='hx && error!='hz)begin
        $display("Your Score Level: H \n");
        $display("Congratulations! GSIM's Function Successfully!\n");
        $display("-------------------------PASS------------------------\n");
     end 
     else if(error>=0.010000 && error <0.100000 && error!='hx && error!='hz)begin
        $display("Your Score Level: I \n");
        $display("Congratulations! GSIM's Function Successfully!\n");
        $display("-------------------------PASS------------------------\n");
     end 
     else if(error>=0.100000 && error <0.300000 && error!='hx && error!='hz)begin
        $display("Your Score Level: J \n");
        $display("Congratulations! GSIM's Function Successfully!\n");
        $display("-------------------------PASS------------------------\n");
     end 
     else begin
        $display("Your Score Level: K \n");                  
        $display("-------------   GSIM's Function Fail   -------------\n");
        $display("-------------------------Fail------------------------\n");
     end
      
      #(`CYCLE/2); $finish;
                       
end
   
endmodule

