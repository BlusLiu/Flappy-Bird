module VGA( clk,reset,hsync, vsync,hc,vc,dat_act);
            input clk; //系统输入时钟 100MHz
            input reset;

            output hsync; //VGA 行同步信号
            output vsync; //VGA 场同步信号
            output dat_act;
            output [9:0]hc ,vc; //转成640*480的模式
         

            
            reg [9:0] hcount; //VGA 行扫描计数器
            reg [9:0] vcount; //VGA 场扫描计数器

            reg flag;
            wire hcount_ov;
            wire vcount_ov;

            wire hsync;
            wire vsync;

            reg vga_clk=0;
            reg cnt_clk=0; //分频计数


            //VGA 行、场扫描时序参数表
            parameter hsync_end = 10'd95,
            hdat_begin = 10'd143,
            hdat_end = 10'd783,
            hpixel_end = 10'd799,

            vsync_end = 10'd1,
            vdat_begin = 10'd34,
            vdat_end = 10'd514,
            vline_end = 10'd524;


        //分频
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

  //************************VGA 驱动部分*******************************//行扫描

            always @(posedge vga_clk)
            begin
                if (hcount_ov)
                    hcount <= 10'd0;
                 else
                     hcount <= hcount + 10'd1;
            end
            assign hcount_ov = (hcount == hpixel_end);

            //场扫描
            always @(posedge vga_clk)
            begin
                if (hcount_ov)
                begin
                    if (vcount_ov)
                        vcount <= 10'd0;
                    else
                        vcount <= vcount + 10'd1;
                end
            end
            assign vcount_ov = (vcount == vline_end);

            //数据、同步信号输
            assign dat_act = ((hcount >= hdat_begin) && (hcount < hdat_end))&& ((vcount >= vdat_begin) && (vcount < vdat_end));
            assign hsync = (hcount > hsync_end);
            assign vsync = (vcount > vsync_end);
           
            //计数器转成640 x 480的样式，方便开发 
            assign hc = hcount - hdat_begin;
            assign vc = vcount - vdat_begin;
            
            
            

           
            
endmodule