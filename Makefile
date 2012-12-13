#all : test_memory8bit
#all : clocksync test_fifo fifo_file
all : androids test_random
#all : test_rs232

%.o : %.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<

test_random : random.o test_random.o
	ghdl -m --ieee=synopsys -fexplicit $@

androids : androids.o register.o
	ghdl -m --ieee=synopsys -fexplicit $@

clocksync : clocksync.o d_ff.o
	ghdl -m --ieee=synopsys -fexplicit $@

fifo_file : d_ff.o fifo.o fifo_file.o
	ghdl -m --ieee=synopsys -fexplicit $@

test_rs232 : divider.o rs232.o test_rs232.o
	ghdl -m --ieee=synopsys -fexplicit $@

test_fifo : d_ff.o fifo.o test_fifo.o
	ghdl -m --ieee=synopsys -fexplicit $@

test_memory8bit : memory8bit.o test_memory8bit.o
	ghdl -m --ieee=synopsys -fexplicit $@

#memory8bit : memory8bit.o
#	ghdl -m --ieee=synopsys -fexplicit $@

filetst : filetst.o
	ghdl -m --ieee=synopsys -fexplicit $@

xall : test_regrotate test_ssegmuxor test_divider test_sseg \
        test_counter test_bcd test_register test_digits_to_7seg\
        test_money_to_7seg test_hex_to_7seg test_coin_counter\
        tb_edge_to_pulse test_ticket_display test_ticket_dispense\
        test_ticket_counter basys2 PS2_Keyboard

PS2_Keyboard : PS2_Keyboard.o
	ghdl -m --ieee=synopsys -fexplicit $@
PS2_Keyboard.o : PS2_Keyboard.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<

tb_edge_to_pulse : edge_to_pulse.o tb_Edge_to_Pulse.o
	ghdl -m --ieee=synopsys -fexplicit $@
tb_Edge_to_Pulse.o : tb_Edge_to_Pulse.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<
edge_to_pulse.o : edge_to_pulse.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<

test_vec : test_vec.o 
	ghdl -m --ieee=synopsys -fexplicit $@
test_vec.o : test_vec.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<

basys2 : subway_tickets.o digits_to_7seg.o basys2.o ticket_counter.o\
        ticket_dispense.o edge_to_pulse.o coin_counter.o ticket_display.o\
        money_to_7seg.o hex_to_7seg.o digits_to_7seg.o
	ghdl -m --ieee=synopsys -fexplicit $@
basys2.o : basys2.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<
subway_tickets.o : subway_tickets.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<

#test_basys2_mux : basys2_mux.o test_basys2_mux.o
#	ghdl -m --ieee=synopsys -fexplicit $@
#basys2_mux.o : basys2_mux.vhdl
#	ghdl -a --ieee=synopsys -fexplicit $<
#test_basys2_mux.o : test_basys2_mux.vhdl
#	ghdl -a --ieee=synopsys -fexplicit $<

test_ticket_dispense : ticketzones.o ticket_dispense.o \
                            test_ticket_dispense.o hex_to_7seg.o
	ghdl -m --ieee=synopsys -fexplicit $@
test_ticket_dispense.o : test_ticket_dispense.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<
ticket_dispense.o : ticket_dispense.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<


test_ticket_display : ticketzones.o ticket_display.o test_ticket_display.o \
                        hex_to_7seg.o edge_to_pulse.o
	ghdl -m --ieee=synopsys -fexplicit $@
test_ticket_display.o : test_ticket_display.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<
ticket_display.o : ticket_display.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<


test_ticket_counter : ticket_counter.o test_ticket_counter.o digits_to_7seg.o\
                    edge_to_pulse.o
	ghdl -m --ieee=synopsys -fexplicit $@
test_ticket_counter.o : test_ticket_counter.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<
ticket_counter.o : ticket_counter.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<


test_coin_counter : coin_counter.o test_coin_counter.o money_to_7seg.o\
                    edge_to_pulse.o
	ghdl -m --ieee=synopsys -fexplicit $@
test_coin_counter.o : test_coin_counter.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<
coin_counter.o : coin_counter.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<

test_alu_wrapper : opcodes.o alu_wrapper.o test_alu_wrapper.o
	ghdl -m --ieee=synopsys -fexplicit $@
test_alu_wrapper.o : test_alu_wrapper.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<
alu_wrapper.o : alu_wrapper.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<


test_alu : dbg.o opcodes.o alu.o test_alu.o
	ghdl -m --ieee=synopsys -fexplicit $@
test_alu.o : test_alu.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<
alu.o : alu.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<

ticketzones.o : ticketzones.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<

opcodes.o : opcodes.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<


test_switch_to_7seg : test_switch_to_7seg.o switch_to_7seg.o
	ghdl -m --ieee=synopsys -fexplicit $@

test_switch_to_7seg.o : test_switch_to_7seg.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<

switch_to_7seg.o : switch_to_7seg.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<
    

test_hex_to_7seg : bcd.o test_hex_to_7seg.o hex_to_7seg.o sevenseg.o\
                    ssegmuxor.o
	ghdl -m --ieee=synopsys -fexplicit $@

test_hex_to_7seg.o : test_hex_to_7seg.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<

hex_to_7seg.o : hex_to_7seg.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<


test_money_to_7seg : bcd.o test_money_to_7seg.o money_to_7seg.o sevenseg.o\
                    ssegmuxor.o
	ghdl -m --ieee=synopsys -fexplicit $@

test_money_to_7seg.o : test_money_to_7seg.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<

money_to_7seg.o : money_to_7seg.vhdl
	ghdl -a --ieee=synopsys -fexplicit $<


test_digits_to_7seg : bcd.o test_digits_to_7seg.o digits_to_7seg.o
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


test_ssegmuxor : dbg.o test_ssegmuxor.o ssegmuxor.o divider.o 
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
	ghdl --remove

