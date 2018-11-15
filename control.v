module control( clk,reset, disp_RGB,hc,vc,dat_act,up_key_press,down_key_press,RGB_Bird,addr_BIRD,addr_G,addr_GG,addr_BEGIN,addr_WIN,addr_SCORE,RGB_BEGIN,RGB_G,BEGIN,RGB_GG,RGB_WIN,RGB_SCORE );
            input clk; 
            input reset;
            input dat_act;
            input [9:0]hc,vc;
            input up_key_press;
            input down_key_press;
            input [2:0]RGB_Bird;
            input [2:0]RGB_G;
            input [2:0]RGB_BEGIN;
            input [2:0]RGB_GG;
            input [2:0]RGB_SCORE;
            input [2:0]RGB_WIN;
            input BEGIN;
            
            output [10:0]addr_BIRD;
            output  [12:0]addr_G;
            output  [15:0]addr_BEGIN;
            output  [14:0]addr_GG;
            output  [12:0]addr_WIN;
            output  [13:0]addr_SCORE;

            output [2:0]disp_RGB;
            
            reg [2:0]data;
            reg vga_clk=0;
            reg cnt_clk=0; 
            reg Bg = 1;
            reg GG = 0;
            reg [4:0]score;
            reg win = 0;
            
            reg [10:0]addr_BIRD;
            reg  [12:0]addr_G;
            reg  [15:0]addr_BEGIN;
            reg  [14:0]addr_GG;
            reg  [12:0]addr_WIN;
            reg  [13:0]addr_SCORE;
            
            
            reg  ad;
  
            always @(posedge clk)
            begin
                if(cnt_clk == 1)
                begin
                    vga_clk <= ~vga_clk;
                    cnt_clk <= 0;
                 end
                else
                    cnt_clk <= cnt_clk +1;
            end
            //定义正方形小块的边长
            parameter border = 40;
            //定义挡板的宽度
            parameter ban = 30;
            //定义挡板的长度
            parameter long = 200;
            //定义挡板的间隔
            parameter magin = 160;
            //定义conter的长度

   
            //VGA扫描，画出挡板和方块，并设置挡板移动的移动变量push
            reg [10:0] push,push1,push2,push3;
            reg stop;//用于停止游戏
            
            //小方块移动数据存储器
            parameter move_x = 50; //方块的初始位置
            reg [9:0]move_y;
            
///////          随机数     //////////
 reg [7:0] rand_num;
parameter seed = 8'b1111_1111;
always@(posedge clk or negedge reset)
begin
   if(!reset)
       rand_num  <= seed;
   else
       begin
           rand_num[0] <= rand_num[1] ;
           rand_num[1] <= rand_num[2] + rand_num[7];
           rand_num[2] <= rand_num[3] + rand_num[7];
           rand_num[3] <= rand_num[4] ;
           rand_num[4] <= rand_num[5] + rand_num[7];
           rand_num[5] <= rand_num[6] + rand_num[7];
           rand_num[6] <= rand_num[7] ;
           rand_num[7] <= rand_num[0] + rand_num[7];     
       end
end
wire [2:0]choose;
reg [8:0]type;
assign choose = {rand_num[3],rand_num[6],rand_num[2]};
always@(posedge clk )
begin
    case(choose) 
    0:type = 0;
    1:type = 40;
    2:type = 80;
    3:type = 120;
    4:type = 160;
    5:type = 200;
    6:type = 240;
    7:type = 280;
    default: type = 280;
    endcase
end
////////////////////////////////////////////////////////


////  板块移动速度控制   ////
reg move;
reg [32:0]counter;
reg [30:0]T_move;
always@(posedge clk,negedge reset)
begin
    if(!reset)
    begin
        T_move = 30'd10_000_00;
        counter <= 0;
        move <=0;
    end
    else
    begin
        if(counter >= T_move)
        begin
            move = 1;
            if(T_move == 100_000)
                T_move <=T_move;
            else
                T_move = T_move-10;
            counter = 0;
        end
        else 
        begin
            move = 0;
            if(!stop)
                counter= counter + 1;
            else
                counter = 0;
        end
    end
end
reg [8:0]rand,rand1,rand2,rand3;
always@(posedge clk or negedge reset)
begin
    if (!reset)
        begin
           push<=640;  //初始位置设定
           push1 <= 640+ magin;
           push2 <= 640 + magin + magin;
           push3 <= 640 + magin + magin + magin;
        end
else if (move)
    begin
        if(push == 0)
            begin
                 push <= 640;
                 rand <=type; //第一块板子的位置设定
            end
        else if(!Bg&&!GG)
            begin                        
                push <= push-1'b1;                                     
            end
         if(push1 == 0)
                begin
                     push1 <= 640;
                     rand1 <=type; //第二块板子的位置设定
                end
            else if(!Bg&&!GG)
                begin                        
                    push1 <= push1-1'b1;                                     
                end
        if(push2 == 0)
                    begin
                         push2 <= 640;
                         rand2 <=type; //第三块板子的位置设定
                    end
                else if(!Bg&&!GG)
                    begin                        
                        push2<= push2-1'b1;                                     
                    end
        if(push3 == 0)
                        begin
                             push3 <= 640;
                             rand3 <=type; 
                          //第四块板子的位置设定
                        end
                    else if(!Bg&&!GG)
                        begin                        
                            push3 <= push3-1'b1;                                     
                        end        
    end
    else
    begin
        push <= push;
        push1 <= push1;
        push2 <= push2;
        push3 <= push3;
    end
end


wire die1,die2,die3,die4,die5;
//游戏失败定义

assign die1=((rand<move_y + border)&&(move_y < rand+long)&&(push < move_x+border) && (move_x < push + ban ));
assign die2=((rand1<move_y + border)&&(move_y < rand1+long)&&(push1 < move_x+border) && (move_x < push1 + ban ));
assign die3=((rand2<move_y + border)&&(move_y < rand2+long)&&(push2 < move_x+border) && (move_x < push2 + ban ));
assign die4=((rand3<move_y + border)&&(move_y < rand3+long)&&(push3 < move_x+border) && (move_x < push3 + ban ));
assign die5=((move_y + border)==480);


wire false;
assign false = die1||die2||die3||die4||die5;

//描述运动，“画图”
always@(posedge vga_clk,negedge reset)
begin

			if(!reset)
				begin 
					data <= 0;
					stop <= 0;
				
					
				end
			else if(Bg)
				begin
				data <= RGB_BEGIN; 
				end
			else if(win)	
				begin
				data <= RGB_WIN; 
				end
			else if(hc>=280&&hc<=360&&vc>=0&&vc<=40)
			begin
				data <= RGB_SCORE;
			end
			
			else if(GG)	
				begin
				data <= RGB_GG; 
				end
			else begin 
				   if (hc>move_x &&(hc<(move_x+border)&&(vc>move_y)&&(vc<move_y+border))) //小方块
					   begin
						   if(!false)
								begin
									data <= RGB_Bird; //黄色
									stop <= 0;
								end
						   else
								begin
									data <= 3'b100; //红色
									stop <=1;
								end
						end   
				  else
						if ((hc>push) && (hc<=push+ban) && (vc>=rand) && (vc<=rand+long))
							 begin
								 data <= RGB_G;//3'b010;//3'h2;  //第一根横条
							 end      
						else  if ((hc>push1) && (hc<=push1+ban) && (vc>=rand1) && (vc<=rand1+long))
								begin
								   data <= RGB_G;//3'b010;//3'h2;  //第二根横条
								end 
					    else  if ((hc>push2) && (hc<=push2+ban) && (vc>=rand2) && (vc<=rand2+long))
									 begin
										data <= RGB_G;//3'b010;//3'h2;  //第三根横条
									 end 
					    else  if ((hc>push3) && (hc<=push3+ban) && (vc>=rand3) && (vc<=rand3+long))
										  begin
										   data <= RGB_G;//3'b010;//3'h2;  //第四根横条
										  end                                                       
						else
											 data <= 0;
				end
			
end


///////       方块移动控制       ////////////
	always@(posedge clk or negedge reset)
    begin
        if (!reset)
            begin
               move_y <= 240;
            end
    else if (up_key_press&&!Bg)
        begin
            if(move_y == 0)
                begin
                     move_y <= move_y;
                end
            else
                begin                        
                    move_y <= move_y-1'b1;                                          
                end
        end
      else if (down_key_press&&!Bg)
            begin
                if(move_y>440)
                begin
                     move_y <= move_y;
                end
            else
                 begin    
                    move_y <= move_y+1'b1;    
                 end
            end 
end
// 信号输出
            always @ (posedge vga_clk )
			begin
		
			  if(dat_act&& hc<=320)
					  addr_BIRD   <=  (vc - move_y)*40 + hc - move_x;
			  else addr_BIRD <= 0;	
					  
			end    
			
			always @ (posedge vga_clk )
			begin
			  if(dat_act&& (hc>push) && (hc<=push+ban) && (vc>=rand) && (vc<=rand+long))
					  addr_G   <=  (vc - rand)*30 + hc - push;
			  else if(dat_act&& (hc>push1) && (hc<=push1+ban) && (vc>=rand1) && (vc<=rand1+long))
					  addr_G   <=  (vc - rand1)*30 + hc - push1;
			  else if(dat_act&& (hc>push2) && (hc<=push2+ban) && (vc>=rand2) && (vc<=rand2+long))
					  addr_G   <=  (vc - rand2)*30 + hc - push2;
			  else if(dat_act&& (hc>push3) && (hc<=push3+ban) && (vc>=rand3) && (vc<=rand3+long))
					  addr_G   <=  (vc - rand3)*30 + hc - push3;
			  else addr_G <= 0;			  
			end    
			
			always @ (posedge vga_clk )
			begin
			  if(GG)
			  begin
					if(dat_act&&vc>=190&&vc<=290&&hc>=220&&hc<=420)
						  addr_GG   <=  (vc-190)*200 + hc-220;
				  else addr_GG <= 0;
			  end			  
			end  
			
			always @ (posedge vga_clk )
			begin
			  if(Bg)
			  begin
				  if(dat_act&&vc>=140&&vc<=340&&hc>=160&&hc<=480)
						  addr_BEGIN   <=  (vc-140)*320 + hc-160;
				  else addr_BEGIN <= 0;
			  end			  
			end
			
			always @ (posedge vga_clk )
			begin
			  if((push <= move_x||push1 <= move_x||push2 <= move_x||push3 <= move_x)&&!ad)
			      begin
				  score <= score + 1'b1;
				  ad <= 1;
				  end
			 else if(push > move_x&&push1 > move_x&&push2 > move_x&&push3 > move_x) 
			     ad <= 0;
			 if(score == 30) 
				  begin 
					win <= 1;
                    
				  end
			 	
			  if(!reset)
			  begin
					win <= 0;
					score <= 0;
			  end
			end
			
			
			
			always @ (posedge vga_clk )
			begin
				if(win)
				begin
					if(dat_act&&vc>=190&&vc<=290&&hc>=220&&hc<=420)
						  addr_WIN   <=  (vc-190)*200 + hc-220;
				end
				else addr_WIN <= 0;
			end
			
			always @ (posedge vga_clk )
			begin
			  if(BEGIN)
			  begin
				Bg <= 0;
			  end  
			  if(!reset)
			  begin
				Bg <= 1;
			  end
			end 
			
			always @ (posedge vga_clk )
			begin
			  if(false)
			  begin
				GG <= 1;
			  end  
			  if(!reset)
			  begin
				GG <= 0;
			  end
			end 
			

	
			
			always @ (posedge vga_clk )
			begin
			  if(hc>=280&&hc<=320&&vc>=0&&vc<=40)
			  begin
				addr_SCORE <= hc-280+vc*400+score/10*40; //!Bg&&act&&hc>=120+score/10*40&&hc<=120+(score/10+1)*40
			  end  
			  else if(hc>=320&&hc<=360&&vc>=0&&vc<=40)
			  begin
				addr_SCORE <= hc-320+vc*400+score%10*40; //!Bg&&act&&hc>=120+score/10*40&&hc<=120+(score/10+1)*40
			  end 
			end 

assign disp_RGB = (dat_act) ? data : 3'h00;



endmodule