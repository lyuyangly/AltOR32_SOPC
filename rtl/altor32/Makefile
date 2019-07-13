#***********************************************************************************************
#   File		: Makefile
#   Author      : Lyu Yang
#   Date        : 2018-12-09
#   Description	: Makefile for iVerilog
#***********************************************************************************************

all: cmp vvp lxt

cmp:
	iverilog -g2005-sv -f filelist.f -o tb_top.vvp

vvp:
	vvp tb_top.vvp -fst -sdf-verbose -lxt2

lxt:
	gtkwave tb_top.lxt &

clean:
	@rm -rf tb_top.vvp tb_top.lxt
