all : test_regrotate test_ssegmuxor test_divider test_sseg \
        test_counter test_bcd test_register test_basys2 test_digits_to_7seg

test_digits_to_7seg : test_digits_to_7seg.o digits_to_7seg.o
	ghdl -m --ieee=synopsys -fexplicit $@

test_digits_to_7seg.o : test_digits_to_7seg.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<

digits_to_7seg.o : digits_to_7seg.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<

test_basys2 : test_basys2.o switch_to_led.o regrotate.o register.o divider.o
	ghdl -m --ieee=synopsys -fexplicit $@
#	ghdl -e --ieee=synopsys -fexplicit $@

test_basys2.o : test_basys2.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<

switch_to_led.o : switch_to_led.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<


test_regrotate : test_regrotate.o regrotate.o
	ghdl -m --ieee=synopsys -fexplicit $@
#	ghdl -e --ieee=synopsys -fexplicit $@

test_regrotate.o : test_regrotate.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<

regrotate.o : regrotate.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<


test_ssegmuxor : test_ssegmuxor.o ssegmuxor.o divider.o dbg.o
	ghdl -m --ieee=synopsys -fexplicit $@

#test_ssegmuxor : test_ssegmuxor.o ssegmuxor.o divider.o dbg.o
#	echo ghdl -e --ieee=synopsys -fexplicit $@

test_ssegmuxor.o : test_ssegmuxor.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<

ssegmuxor.o : ssegmuxor.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<


test_divider : test_divider.o divider.o
	ghdl -m --ieee=synopsys -fexplicit $@
#	ghdl -e --ieee=synopsys -fexplicit $@

test_divider.o : test_divider.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<

divider.o : divider.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<


test_sseg : test_sseg.o sevenseg.o
	ghdl -m --ieee=synopsys -fexplicit $@
#	ghdl -e --ieee=synopsys -fexplicit $@

test_sseg.o : test_sseg.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<

sevenseg.o : sevenseg.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<

SimpleSsegLedDemo.o : SimpleSsegLedDemo.vhd
	ghdl -a --ieee=synopsys -fexplicit $<


test_counter : test_counter.o counter.o
	ghdl -m --ieee=synopsys -fexplicit $@
#	ghdl -e --ieee=synopsys -fexplicit $@

counter.o : counter.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<

test_counter.o : test_counter.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<


test_bcd : test_bcd.o bcd.o
	ghdl -m --ieee=synopsys -fexplicit $@
#	ghdl -e --ieee=synopsys -fexplicit $@

test_bcd.o : test_bcd.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<

bcd.o : bcd.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<

test_register : test_register.o register.o
	ghdl -m --ieee=synopsys -fexplicit $@
#	ghdl -e --ieee=synopsys -fexplicit $@

register.o : register.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<

test_register.o : test_register.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<

dbg.o : dbg.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<

clean :
	ghdl --clean

