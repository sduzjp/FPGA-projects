`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ɽ����ѧ
// Engineer: �ܽ�ƽ
// 
// Create Date: 2020/07/30 12:53:11
// Design Name: 
// Module Name: vga2
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: ʵ��VGAͼ����ʾ֮�������������������̸�ͨ��������������ͼ����ʾ
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module vga2(clk,switch,disp_RGB,hsync,vsync);
    input  clk;     //ϵͳ����ʱ��100MHz
    input  [1:0]switch;
    output [2:0]disp_RGB;    //VGA�������
    output  hsync;     //VGA��ͬ���ź�
    output  vsync;    //VGA��ͬ���ź�
    reg [9:0] hcount;     //VGA��ɨ�������
    reg [9:0] vcount;     //VGA��ɨ�������
    reg [2:0] data;     //VGA���͵�����
    reg [2:0] h_dat;    //VGA���͵���ͬ������    
    reg [2:0] v_dat;    //VGA���͵���ͬ������

    reg   flag;
    wire  hcount_ov;
    wire  vcount_ov;
    wire  dat_act;
    wire  hsync;
    wire  vsync;
    reg  vga_clk=0; //VGAʱ���ź�
    reg  cnt_clk=0; //��Ƶ����
    
    //VGA�С���ɨ��ʱ�������
    parameter hsync_end   = 10'd95,
               hdat_begin  = 10'd143,
               hdat_end  = 10'd783,
               hpixel_end  = 10'd799,
               vsync_end  = 10'd1,
               vdat_begin  = 10'd34,
               vdat_end  = 10'd514,
               vline_end  = 10'd524;


    always @(posedge clk)
        begin
            if(cnt_clk==1)
                begin
                vga_clk <= ~vga_clk;
                cnt_clk<=0;
                end
            else
                cnt_clk<=cnt_clk+1;   
        end

//************************VGA��������*******************************
//��ɨ��     
    always @(posedge vga_clk)
    begin
        if (hcount_ov)
            hcount <= 10'd0;
        else
            hcount <= hcount + 10'd1;
    end
    assign hcount_ov = (hcount == hpixel_end);
    
//��ɨ��
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
    assign  vcount_ov = (vcount == vline_end);
    
//���ݡ�ͬ���ź���
    assign dat_act =((hcount >= hdat_begin) && (hcount < hdat_end))
             && ((vcount >= vdat_begin) && (vcount < vdat_end));
    assign hsync = (hcount > hsync_end);
    assign vsync = (vcount > vsync_end);
    assign disp_RGB = (dat_act) ?  data : 3'h00;      

//************************��ʾ���ݴ�������*******************************
//ͼƬ��ʾ��ʱ������
/*always @(posedge vga_clk)
begin
flag <= vcount_ov;
if(vcount_ov && ~flag)
  timer <= timer + 1'b1;
end
*/
    always @(posedge vga_clk)
    begin
        case(switch[1:0])
          2'd0: data <= h_dat;      //ѡ������
          2'd1: data <= v_dat;      //ѡ��������
          2'd2: data <= (v_dat ^ h_dat); //���������������λ������һ�����̸�
          2'd3: data <= (v_dat ~^ h_dat); //���������������λͬ�������һ�����̸�
        endcase
    end

    always @(posedge vga_clk)  //���������
    begin
        if(vcount < 94)
            h_dat <= 3'h7;        //��
        else if(vcount < 154)
            h_dat <= 3'h6;   //��
        else if(vcount < 214)
            h_dat <= 3'h5;   //��
        else if(vcount < 274)
            h_dat <= 3'h4;    //��
        else if(vcount < 334)
            h_dat <= 3'h3;   //��
        else if(vcount < 394)
            h_dat <= 3'h2;   //��
        else if(vcount < 454)
            h_dat <= 3'h1;   //��
        else
            h_dat <= 3'h0;   //��
    end

    always @(posedge vga_clk)  //����������
    begin
        if(hcount < 223)
            v_dat <= 3'h7;      //��   
        else if(hcount < 303)
            v_dat <= 3'h6;   //��
        else if(hcount < 383)
            v_dat <= 3'h5;   //��
        else if(hcount < 463)
            v_dat <= 3'h4;    //��
        else if(hcount < 543)
            v_dat <= 3'h3;   //��
        else if(hcount < 623)
            v_dat <= 3'h2;   //��
        else if(hcount < 703)
            v_dat <= 3'h1;   //��
        else
            v_dat <= 3'h0;   //��
    end
endmodule