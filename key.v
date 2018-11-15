module key(clk,reset,up,up_key_press,down_key_press);
input clk;
input reset;
input up;
output reg up_key_press;
output reg down_key_press;

parameter T = 30'd10_000_00;  //控制方块移动速度

//////////   up 按键   /////////////
reg [30:0] counter;
reg [30:0] counter2;
always@(posedge clk,negedge reset )
begin
     if(!reset)
        begin
            counter <= 0;
            counter2 <= 0;
            up_key_press <= 0;
            down_key_press <= 0;
         end
     else
        begin
            if(up)
                begin
                    if(counter <= T)          //防止其反应过快 
                        begin
                            counter = counter + 1'b1+ 1'b1;
                            up_key_press <= 0;
                        end
                    else
                        begin
                            counter <= 0;
                            up_key_press <= 1;
                        end
                end
             else  //下降按钮(其实是自动下) 
                begin
                    if(counter2 <= T)
                        begin
                            counter2 = counter2 + 1'b1+ 1'b1;
                            down_key_press <= 0;
                        end
                    else
                        begin
                            counter2 <= 0;
                            down_key_press <= 1;
                        end
                end
        end
end

endmodule
