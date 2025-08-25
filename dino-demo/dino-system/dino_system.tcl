# qsys scripting (.tcl) file for dino_system
package require -exact qsys 16.0

create_system {dino_system}

set_project_property DEVICE_FAMILY {MAX 10}
set_project_property DEVICE {10M50DAF484C7G}
set_project_property HIDE_FROM_IP_CATALOG {false}

# Instances and instance parameters
# (disabled instances are intentionally culled)
add_instance altpll_0 altpll 20.1
set_instance_parameter_value altpll_0 {AVALON_USE_SEPARATE_SYSCLK} {NO}
set_instance_parameter_value altpll_0 {BANDWIDTH} {}
set_instance_parameter_value altpll_0 {BANDWIDTH_TYPE} {AUTO}
set_instance_parameter_value altpll_0 {CLK0_DIVIDE_BY} {5}
set_instance_parameter_value altpll_0 {CLK0_DUTY_CYCLE} {50}
set_instance_parameter_value altpll_0 {CLK0_MULTIPLY_BY} {6}
set_instance_parameter_value altpll_0 {CLK0_PHASE_SHIFT} {0}
set_instance_parameter_value altpll_0 {CLK1_DIVIDE_BY} {5}
set_instance_parameter_value altpll_0 {CLK1_DUTY_CYCLE} {50}
set_instance_parameter_value altpll_0 {CLK1_MULTIPLY_BY} {6}
set_instance_parameter_value altpll_0 {CLK1_PHASE_SHIFT} {0}
set_instance_parameter_value altpll_0 {CLK2_DIVIDE_BY} {2}
set_instance_parameter_value altpll_0 {CLK2_DUTY_CYCLE} {50}
set_instance_parameter_value altpll_0 {CLK2_MULTIPLY_BY} {1}
set_instance_parameter_value altpll_0 {CLK2_PHASE_SHIFT} {0}
set_instance_parameter_value altpll_0 {CLK3_DIVIDE_BY} {}
set_instance_parameter_value altpll_0 {CLK3_DUTY_CYCLE} {}
set_instance_parameter_value altpll_0 {CLK3_MULTIPLY_BY} {}
set_instance_parameter_value altpll_0 {CLK3_PHASE_SHIFT} {}
set_instance_parameter_value altpll_0 {CLK4_DIVIDE_BY} {}
set_instance_parameter_value altpll_0 {CLK4_DUTY_CYCLE} {}
set_instance_parameter_value altpll_0 {CLK4_MULTIPLY_BY} {}
set_instance_parameter_value altpll_0 {CLK4_PHASE_SHIFT} {}
set_instance_parameter_value altpll_0 {CLK5_DIVIDE_BY} {}
set_instance_parameter_value altpll_0 {CLK5_DUTY_CYCLE} {}
set_instance_parameter_value altpll_0 {CLK5_MULTIPLY_BY} {}
set_instance_parameter_value altpll_0 {CLK5_PHASE_SHIFT} {}
set_instance_parameter_value altpll_0 {CLK6_DIVIDE_BY} {}
set_instance_parameter_value altpll_0 {CLK6_DUTY_CYCLE} {}
set_instance_parameter_value altpll_0 {CLK6_MULTIPLY_BY} {}
set_instance_parameter_value altpll_0 {CLK6_PHASE_SHIFT} {}
set_instance_parameter_value altpll_0 {CLK7_DIVIDE_BY} {}
set_instance_parameter_value altpll_0 {CLK7_DUTY_CYCLE} {}
set_instance_parameter_value altpll_0 {CLK7_MULTIPLY_BY} {}
set_instance_parameter_value altpll_0 {CLK7_PHASE_SHIFT} {}
set_instance_parameter_value altpll_0 {CLK8_DIVIDE_BY} {}
set_instance_parameter_value altpll_0 {CLK8_DUTY_CYCLE} {}
set_instance_parameter_value altpll_0 {CLK8_MULTIPLY_BY} {}
set_instance_parameter_value altpll_0 {CLK8_PHASE_SHIFT} {}
set_instance_parameter_value altpll_0 {CLK9_DIVIDE_BY} {}
set_instance_parameter_value altpll_0 {CLK9_DUTY_CYCLE} {}
set_instance_parameter_value altpll_0 {CLK9_MULTIPLY_BY} {}
set_instance_parameter_value altpll_0 {CLK9_PHASE_SHIFT} {}
set_instance_parameter_value altpll_0 {COMPENSATE_CLOCK} {CLK0}
set_instance_parameter_value altpll_0 {DOWN_SPREAD} {}
set_instance_parameter_value altpll_0 {DPA_DIVIDER} {}
set_instance_parameter_value altpll_0 {DPA_DIVIDE_BY} {}
set_instance_parameter_value altpll_0 {DPA_MULTIPLY_BY} {}
set_instance_parameter_value altpll_0 {ENABLE_SWITCH_OVER_COUNTER} {}
set_instance_parameter_value altpll_0 {EXTCLK0_DIVIDE_BY} {}
set_instance_parameter_value altpll_0 {EXTCLK0_DUTY_CYCLE} {}
set_instance_parameter_value altpll_0 {EXTCLK0_MULTIPLY_BY} {}
set_instance_parameter_value altpll_0 {EXTCLK0_PHASE_SHIFT} {}
set_instance_parameter_value altpll_0 {EXTCLK1_DIVIDE_BY} {}
set_instance_parameter_value altpll_0 {EXTCLK1_DUTY_CYCLE} {}
set_instance_parameter_value altpll_0 {EXTCLK1_MULTIPLY_BY} {}
set_instance_parameter_value altpll_0 {EXTCLK1_PHASE_SHIFT} {}
set_instance_parameter_value altpll_0 {EXTCLK2_DIVIDE_BY} {}
set_instance_parameter_value altpll_0 {EXTCLK2_DUTY_CYCLE} {}
set_instance_parameter_value altpll_0 {EXTCLK2_MULTIPLY_BY} {}
set_instance_parameter_value altpll_0 {EXTCLK2_PHASE_SHIFT} {}
set_instance_parameter_value altpll_0 {EXTCLK3_DIVIDE_BY} {}
set_instance_parameter_value altpll_0 {EXTCLK3_DUTY_CYCLE} {}
set_instance_parameter_value altpll_0 {EXTCLK3_MULTIPLY_BY} {}
set_instance_parameter_value altpll_0 {EXTCLK3_PHASE_SHIFT} {}
set_instance_parameter_value altpll_0 {FEEDBACK_SOURCE} {}
set_instance_parameter_value altpll_0 {GATE_LOCK_COUNTER} {}
set_instance_parameter_value altpll_0 {GATE_LOCK_SIGNAL} {}
set_instance_parameter_value altpll_0 {HIDDEN_CONSTANTS} {CT#CLK2_DIVIDE_BY 2 CT#PORT_clk5 PORT_UNUSED CT#PORT_clk4 PORT_UNUSED CT#PORT_clk3 PORT_UNUSED CT#PORT_clk2 PORT_USED CT#PORT_clk1 PORT_USED CT#PORT_clk0 PORT_USED CT#CLK0_MULTIPLY_BY 6 CT#PORT_SCANWRITE PORT_UNUSED CT#PORT_SCANACLR PORT_UNUSED CT#PORT_PFDENA PORT_UNUSED CT#PORT_PLLENA PORT_UNUSED CT#PORT_SCANDATA PORT_UNUSED CT#PORT_SCANCLKENA PORT_UNUSED CT#WIDTH_CLOCK 5 CT#PORT_SCANDATAOUT PORT_UNUSED CT#LPM_TYPE altpll CT#PLL_TYPE AUTO CT#CLK0_PHASE_SHIFT 0 CT#CLK1_DUTY_CYCLE 50 CT#PORT_PHASEDONE PORT_UNUSED CT#OPERATION_MODE NORMAL CT#PORT_CONFIGUPDATE PORT_UNUSED CT#CLK1_MULTIPLY_BY 6 CT#COMPENSATE_CLOCK CLK0 CT#PORT_CLKSWITCH PORT_UNUSED CT#INCLK0_INPUT_FREQUENCY 20000 CT#PORT_SCANDONE PORT_UNUSED CT#PORT_CLKLOSS PORT_UNUSED CT#PORT_INCLK1 PORT_UNUSED CT#AVALON_USE_SEPARATE_SYSCLK NO CT#PORT_INCLK0 PORT_USED CT#PORT_clkena5 PORT_UNUSED CT#PORT_clkena4 PORT_UNUSED CT#PORT_clkena3 PORT_UNUSED CT#PORT_clkena2 PORT_UNUSED CT#PORT_clkena1 PORT_UNUSED CT#PORT_clkena0 PORT_UNUSED CT#CLK1_PHASE_SHIFT 0 CT#PORT_ARESET PORT_USED CT#BANDWIDTH_TYPE AUTO CT#CLK2_MULTIPLY_BY 1 CT#INTENDED_DEVICE_FAMILY {MAX 10} CT#PORT_SCANREAD PORT_UNUSED CT#CLK2_DUTY_CYCLE 50 CT#PORT_PHASESTEP PORT_UNUSED CT#PORT_SCANCLK PORT_UNUSED CT#PORT_CLKBAD1 PORT_UNUSED CT#PORT_CLKBAD0 PORT_UNUSED CT#PORT_FBIN PORT_UNUSED CT#PORT_PHASEUPDOWN PORT_UNUSED CT#PORT_extclk3 PORT_UNUSED CT#PORT_extclk2 PORT_UNUSED CT#PORT_extclk1 PORT_UNUSED CT#PORT_PHASECOUNTERSELECT PORT_UNUSED CT#PORT_extclk0 PORT_UNUSED CT#PORT_ACTIVECLOCK PORT_UNUSED CT#CLK2_PHASE_SHIFT 0 CT#CLK0_DUTY_CYCLE 50 CT#CLK0_DIVIDE_BY 5 CT#CLK1_DIVIDE_BY 5 CT#PORT_LOCKED PORT_USED}
set_instance_parameter_value altpll_0 {HIDDEN_CUSTOM_ELABORATION} {altpll_avalon_elaboration}
set_instance_parameter_value altpll_0 {HIDDEN_CUSTOM_POST_EDIT} {altpll_avalon_post_edit}
set_instance_parameter_value altpll_0 {HIDDEN_IF_PORTS} {IF#phasecounterselect {input 3} IF#locked {output 0} IF#reset {input 0} IF#clk {input 0} IF#phaseupdown {input 0} IF#scandone {output 0} IF#readdata {output 32} IF#write {input 0} IF#scanclk {input 0} IF#phasedone {output 0} IF#c4 {output 0} IF#c3 {output 0} IF#address {input 2} IF#c2 {output 0} IF#c1 {output 0} IF#c0 {output 0} IF#writedata {input 32} IF#read {input 0} IF#areset {input 0} IF#scanclkena {input 0} IF#scandataout {output 0} IF#configupdate {input 0} IF#phasestep {input 0} IF#scandata {input 0}}
set_instance_parameter_value altpll_0 {HIDDEN_IS_FIRST_EDIT} {0}
set_instance_parameter_value altpll_0 {HIDDEN_IS_NUMERIC} {IN#WIDTH_CLOCK 1 IN#CLK0_DUTY_CYCLE 1 IN#CLK2_DIVIDE_BY 1 IN#PLL_TARGET_HARCOPY_CHECK 1 IN#CLK1_MULTIPLY_BY 1 IN#SWITCHOVER_COUNT_EDIT 1 IN#INCLK0_INPUT_FREQUENCY 1 IN#PLL_LVDS_PLL_CHECK 1 IN#PLL_AUTOPLL_CHECK 1 IN#PLL_FASTPLL_CHECK 1 IN#CLK1_DUTY_CYCLE 1 IN#PLL_ENHPLL_CHECK 1 IN#CLK2_MULTIPLY_BY 1 IN#DIV_FACTOR2 1 IN#DIV_FACTOR1 1 IN#DIV_FACTOR0 1 IN#LVDS_MODE_DATA_RATE_DIRTY 1 IN#CLK2_DUTY_CYCLE 1 IN#GLOCK_COUNTER_EDIT 1 IN#CLK0_DIVIDE_BY 1 IN#MULT_FACTOR2 1 IN#MULT_FACTOR1 1 IN#MULT_FACTOR0 1 IN#CLK0_MULTIPLY_BY 1 IN#USE_MIL_SPEED_GRADE 1 IN#CLK1_DIVIDE_BY 1}
set_instance_parameter_value altpll_0 {HIDDEN_MF_PORTS} {MF#areset 1 MF#clk 1 MF#locked 1 MF#inclk 1}
set_instance_parameter_value altpll_0 {HIDDEN_PRIVATES} {PT#GLOCKED_FEATURE_ENABLED 0 PT#SPREAD_FEATURE_ENABLED 0 PT#BANDWIDTH_FREQ_UNIT MHz PT#CUR_DEDICATED_CLK c0 PT#INCLK0_FREQ_EDIT 20000.000 PT#BANDWIDTH_PRESET Low PT#PLL_LVDS_PLL_CHECK 0 PT#BANDWIDTH_USE_PRESET 0 PT#AVALON_USE_SEPARATE_SYSCLK NO PT#PLL_ENHPLL_CHECK 0 PT#OUTPUT_FREQ_UNIT2 MHz PT#OUTPUT_FREQ_UNIT1 MHz PT#OUTPUT_FREQ_UNIT0 MHz PT#PHASE_RECONFIG_FEATURE_ENABLED 1 PT#CREATE_CLKBAD_CHECK 0 PT#CLKSWITCH_CHECK 0 PT#INCLK1_FREQ_EDIT 100.000 PT#NORMAL_MODE_RADIO 1 PT#SRC_SYNCH_COMP_RADIO 0 PT#PLL_ARESET_CHECK 1 PT#LONG_SCAN_RADIO 1 PT#SCAN_FEATURE_ENABLED 1 PT#USE_CLK2 1 PT#PHASE_RECONFIG_INPUTS_CHECK 0 PT#USE_CLK1 1 PT#USE_CLK0 1 PT#PRIMARY_CLK_COMBO inclk0 PT#BANDWIDTH 1.000 PT#GLOCKED_COUNTER_EDIT_CHANGED 1 PT#PLL_FASTPLL_CHECK 0 PT#SPREAD_FREQ_UNIT KHz PT#PLL_AUTOPLL_CHECK 1 PT#LVDS_PHASE_SHIFT_UNIT2 ps PT#LVDS_PHASE_SHIFT_UNIT1 ps PT#OUTPUT_FREQ_MODE2 0 PT#LVDS_PHASE_SHIFT_UNIT0 ps PT#OUTPUT_FREQ_MODE1 0 PT#SWITCHOVER_FEATURE_ENABLED 0 PT#MIG_DEVICE_SPEED_GRADE Any PT#OUTPUT_FREQ_MODE0 0 PT#BANDWIDTH_FEATURE_ENABLED 1 PT#INCLK0_FREQ_UNIT_COMBO ps PT#ZERO_DELAY_RADIO 0 PT#OUTPUT_FREQ2 25.00000000 PT#OUTPUT_FREQ1 60.00000000 PT#OUTPUT_FREQ0 60.00000000 PT#SHORT_SCAN_RADIO 0 PT#LVDS_MODE_DATA_RATE_DIRTY 0 PT#CUR_FBIN_CLK c0 PT#PLL_ADVANCED_PARAM_CHECK 0 PT#CLKBAD_SWITCHOVER_CHECK 0 PT#PHASE_SHIFT_STEP_ENABLED_CHECK 0 PT#DEVICE_SPEED_GRADE Any PT#PLL_FBMIMIC_CHECK 0 PT#LVDS_MODE_DATA_RATE {Not Available} PT#LOCKED_OUTPUT_CHECK 1 PT#SPREAD_PERCENT 0.500 PT#PHASE_SHIFT2 0.00000000 PT#PHASE_SHIFT1 0.00000000 PT#DIV_FACTOR2 2 PT#PHASE_SHIFT0 0.00000000 PT#DIV_FACTOR1 5 PT#DIV_FACTOR0 5 PT#CNX_NO_COMPENSATE_RADIO 0 PT#USE_CLKENA2 0 PT#USE_CLKENA1 0 PT#USE_CLKENA0 0 PT#CREATE_INCLK1_CHECK 0 PT#GLOCK_COUNTER_EDIT 1048575 PT#INCLK1_FREQ_UNIT_COMBO MHz PT#EFF_OUTPUT_FREQ_VALUE2 25.000000 PT#EFF_OUTPUT_FREQ_VALUE1 60.000000 PT#EFF_OUTPUT_FREQ_VALUE0 60.000000 PT#SPREAD_FREQ 50.000 PT#USE_MIL_SPEED_GRADE 0 PT#EXPLICIT_SWITCHOVER_COUNTER 0 PT#STICKY_CLK4 0 PT#STICKY_CLK3 0 PT#STICKY_CLK2 1 PT#STICKY_CLK1 1 PT#STICKY_CLK0 1 PT#EXT_FEEDBACK_RADIO 0 PT#MIRROR_CLK2 0 PT#MIRROR_CLK1 0 PT#MIRROR_CLK0 0 PT#SWITCHOVER_COUNT_EDIT 1 PT#SELF_RESET_LOCK_LOSS 0 PT#PLL_PFDENA_CHECK 0 PT#INT_FEEDBACK__MODE_RADIO 1 PT#INCLK1_FREQ_EDIT_CHANGED 1 PT#CLKLOSS_CHECK 0 PT#SYNTH_WRAPPER_GEN_POSTFIX 0 PT#PHASE_SHIFT_UNIT2 ps PT#PHASE_SHIFT_UNIT1 ps PT#PHASE_SHIFT_UNIT0 ps PT#BANDWIDTH_USE_AUTO 1 PT#HAS_MANUAL_SWITCHOVER 1 PT#MULT_FACTOR2 1 PT#MULT_FACTOR1 6 PT#MULT_FACTOR0 6 PT#SPREAD_USE 0 PT#GLOCKED_MODE_CHECK 0 PT#DUTY_CYCLE2 50.00000000 PT#DUTY_CYCLE1 50.00000000 PT#SACN_INPUTS_CHECK 0 PT#DUTY_CYCLE0 50.00000000 PT#INTENDED_DEVICE_FAMILY {MAX 10} PT#PLL_TARGET_HARCOPY_CHECK 0 PT#INCLK1_FREQ_UNIT_CHANGED 1 PT#RECONFIG_FILE ALTPLL1755249445789354.mif PT#ACTIVECLK_CHECK 0}
set_instance_parameter_value altpll_0 {HIDDEN_USED_PORTS} {UP#locked used UP#c2 used UP#c1 used UP#c0 used UP#areset used UP#inclk0 used}
set_instance_parameter_value altpll_0 {INCLK0_INPUT_FREQUENCY} {20000}
set_instance_parameter_value altpll_0 {INCLK1_INPUT_FREQUENCY} {}
set_instance_parameter_value altpll_0 {INTENDED_DEVICE_FAMILY} {MAX 10}
set_instance_parameter_value altpll_0 {INVALID_LOCK_MULTIPLIER} {}
set_instance_parameter_value altpll_0 {LOCK_HIGH} {}
set_instance_parameter_value altpll_0 {LOCK_LOW} {}
set_instance_parameter_value altpll_0 {OPERATION_MODE} {NORMAL}
set_instance_parameter_value altpll_0 {PLL_TYPE} {AUTO}
set_instance_parameter_value altpll_0 {PORT_ACTIVECLOCK} {PORT_UNUSED}
set_instance_parameter_value altpll_0 {PORT_ARESET} {PORT_USED}
set_instance_parameter_value altpll_0 {PORT_CLKBAD0} {PORT_UNUSED}
set_instance_parameter_value altpll_0 {PORT_CLKBAD1} {PORT_UNUSED}
set_instance_parameter_value altpll_0 {PORT_CLKLOSS} {PORT_UNUSED}
set_instance_parameter_value altpll_0 {PORT_CLKSWITCH} {PORT_UNUSED}
set_instance_parameter_value altpll_0 {PORT_CONFIGUPDATE} {PORT_UNUSED}
set_instance_parameter_value altpll_0 {PORT_ENABLE0} {}
set_instance_parameter_value altpll_0 {PORT_ENABLE1} {}
set_instance_parameter_value altpll_0 {PORT_FBIN} {PORT_UNUSED}
set_instance_parameter_value altpll_0 {PORT_FBOUT} {}
set_instance_parameter_value altpll_0 {PORT_INCLK0} {PORT_USED}
set_instance_parameter_value altpll_0 {PORT_INCLK1} {PORT_UNUSED}
set_instance_parameter_value altpll_0 {PORT_LOCKED} {PORT_USED}
set_instance_parameter_value altpll_0 {PORT_PFDENA} {PORT_UNUSED}
set_instance_parameter_value altpll_0 {PORT_PHASECOUNTERSELECT} {PORT_UNUSED}
set_instance_parameter_value altpll_0 {PORT_PHASEDONE} {PORT_UNUSED}
set_instance_parameter_value altpll_0 {PORT_PHASESTEP} {PORT_UNUSED}
set_instance_parameter_value altpll_0 {PORT_PHASEUPDOWN} {PORT_UNUSED}
set_instance_parameter_value altpll_0 {PORT_PLLENA} {PORT_UNUSED}
set_instance_parameter_value altpll_0 {PORT_SCANACLR} {PORT_UNUSED}
set_instance_parameter_value altpll_0 {PORT_SCANCLK} {PORT_UNUSED}
set_instance_parameter_value altpll_0 {PORT_SCANCLKENA} {PORT_UNUSED}
set_instance_parameter_value altpll_0 {PORT_SCANDATA} {PORT_UNUSED}
set_instance_parameter_value altpll_0 {PORT_SCANDATAOUT} {PORT_UNUSED}
set_instance_parameter_value altpll_0 {PORT_SCANDONE} {PORT_UNUSED}
set_instance_parameter_value altpll_0 {PORT_SCANREAD} {PORT_UNUSED}
set_instance_parameter_value altpll_0 {PORT_SCANWRITE} {PORT_UNUSED}
set_instance_parameter_value altpll_0 {PORT_SCLKOUT0} {}
set_instance_parameter_value altpll_0 {PORT_SCLKOUT1} {}
set_instance_parameter_value altpll_0 {PORT_VCOOVERRANGE} {}
set_instance_parameter_value altpll_0 {PORT_VCOUNDERRANGE} {}
set_instance_parameter_value altpll_0 {PORT_clk0} {PORT_USED}
set_instance_parameter_value altpll_0 {PORT_clk1} {PORT_USED}
set_instance_parameter_value altpll_0 {PORT_clk2} {PORT_USED}
set_instance_parameter_value altpll_0 {PORT_clk3} {PORT_UNUSED}
set_instance_parameter_value altpll_0 {PORT_clk4} {PORT_UNUSED}
set_instance_parameter_value altpll_0 {PORT_clk5} {PORT_UNUSED}
set_instance_parameter_value altpll_0 {PORT_clk6} {}
set_instance_parameter_value altpll_0 {PORT_clk7} {}
set_instance_parameter_value altpll_0 {PORT_clk8} {}
set_instance_parameter_value altpll_0 {PORT_clk9} {}
set_instance_parameter_value altpll_0 {PORT_clkena0} {PORT_UNUSED}
set_instance_parameter_value altpll_0 {PORT_clkena1} {PORT_UNUSED}
set_instance_parameter_value altpll_0 {PORT_clkena2} {PORT_UNUSED}
set_instance_parameter_value altpll_0 {PORT_clkena3} {PORT_UNUSED}
set_instance_parameter_value altpll_0 {PORT_clkena4} {PORT_UNUSED}
set_instance_parameter_value altpll_0 {PORT_clkena5} {PORT_UNUSED}
set_instance_parameter_value altpll_0 {PORT_extclk0} {PORT_UNUSED}
set_instance_parameter_value altpll_0 {PORT_extclk1} {PORT_UNUSED}
set_instance_parameter_value altpll_0 {PORT_extclk2} {PORT_UNUSED}
set_instance_parameter_value altpll_0 {PORT_extclk3} {PORT_UNUSED}
set_instance_parameter_value altpll_0 {PORT_extclkena0} {}
set_instance_parameter_value altpll_0 {PORT_extclkena1} {}
set_instance_parameter_value altpll_0 {PORT_extclkena2} {}
set_instance_parameter_value altpll_0 {PORT_extclkena3} {}
set_instance_parameter_value altpll_0 {PRIMARY_CLOCK} {}
set_instance_parameter_value altpll_0 {QUALIFY_CONF_DONE} {}
set_instance_parameter_value altpll_0 {SCAN_CHAIN} {}
set_instance_parameter_value altpll_0 {SCAN_CHAIN_MIF_FILE} {}
set_instance_parameter_value altpll_0 {SCLKOUT0_PHASE_SHIFT} {}
set_instance_parameter_value altpll_0 {SCLKOUT1_PHASE_SHIFT} {}
set_instance_parameter_value altpll_0 {SELF_RESET_ON_GATED_LOSS_LOCK} {}
set_instance_parameter_value altpll_0 {SELF_RESET_ON_LOSS_LOCK} {}
set_instance_parameter_value altpll_0 {SKIP_VCO} {}
set_instance_parameter_value altpll_0 {SPREAD_FREQUENCY} {}
set_instance_parameter_value altpll_0 {SWITCH_OVER_COUNTER} {}
set_instance_parameter_value altpll_0 {SWITCH_OVER_ON_GATED_LOCK} {}
set_instance_parameter_value altpll_0 {SWITCH_OVER_ON_LOSSCLK} {}
set_instance_parameter_value altpll_0 {SWITCH_OVER_TYPE} {}
set_instance_parameter_value altpll_0 {USING_FBMIMICBIDIR_PORT} {}
set_instance_parameter_value altpll_0 {VALID_LOCK_MULTIPLIER} {}
set_instance_parameter_value altpll_0 {VCO_DIVIDE_BY} {}
set_instance_parameter_value altpll_0 {VCO_FREQUENCY_CONTROL} {}
set_instance_parameter_value altpll_0 {VCO_MULTIPLY_BY} {}
set_instance_parameter_value altpll_0 {VCO_PHASE_SHIFT_STEP} {}
set_instance_parameter_value altpll_0 {WIDTH_CLOCK} {5}
set_instance_parameter_value altpll_0 {WIDTH_PHASECOUNTERSELECT} {}

add_instance clk_0 clock_source 20.1
set_instance_parameter_value clk_0 {clockFrequency} {50000000.0}
set_instance_parameter_value clk_0 {clockFrequencyKnown} {1}
set_instance_parameter_value clk_0 {resetSynchronousEdges} {NONE}

add_instance framebuffer_writer_0 framebuffer_writer 1.0
set_instance_parameter_value framebuffer_writer_0 {MM_START_ADDRESS} {67108864}

add_instance graphics_instruction_0 graphics_instruction 1.0

add_instance graphics_line_0 graphics_line 1.0

add_instance graphics_rect_fill_0 graphics_rect_fill 1.0

add_instance graphics_rect_move_0 graphics_rect_move 1.0
set_instance_parameter_value graphics_rect_move_0 {MAX_PENDING_READS} {50}
set_instance_parameter_value graphics_rect_move_0 {MM_START_ADDRESS} {67108864}

add_instance jtag_uart_0 altera_avalon_jtag_uart 20.1
set_instance_parameter_value jtag_uart_0 {allowMultipleConnections} {0}
set_instance_parameter_value jtag_uart_0 {hubInstanceID} {0}
set_instance_parameter_value jtag_uart_0 {readBufferDepth} {64}
set_instance_parameter_value jtag_uart_0 {readIRQThreshold} {8}
set_instance_parameter_value jtag_uart_0 {simInputCharacterStream} {}
set_instance_parameter_value jtag_uart_0 {simInteractiveOptions} {NO_INTERACTIVE_WINDOWS}
set_instance_parameter_value jtag_uart_0 {useRegistersForReadBuffer} {0}
set_instance_parameter_value jtag_uart_0 {useRegistersForWriteBuffer} {0}
set_instance_parameter_value jtag_uart_0 {useRelativePathForSimFile} {0}
set_instance_parameter_value jtag_uart_0 {writeBufferDepth} {64}
set_instance_parameter_value jtag_uart_0 {writeIRQThreshold} {8}

add_instance mm_clock_crossing_bridge_0 altera_avalon_mm_clock_crossing_bridge 20.1
set_instance_parameter_value mm_clock_crossing_bridge_0 {ADDRESS_UNITS} {SYMBOLS}
set_instance_parameter_value mm_clock_crossing_bridge_0 {ADDRESS_WIDTH} {32}
set_instance_parameter_value mm_clock_crossing_bridge_0 {COMMAND_FIFO_DEPTH} {4}
set_instance_parameter_value mm_clock_crossing_bridge_0 {DATA_WIDTH} {32}
set_instance_parameter_value mm_clock_crossing_bridge_0 {MASTER_SYNC_DEPTH} {2}
set_instance_parameter_value mm_clock_crossing_bridge_0 {MAX_BURST_SIZE} {1}
set_instance_parameter_value mm_clock_crossing_bridge_0 {RESPONSE_FIFO_DEPTH} {4}
set_instance_parameter_value mm_clock_crossing_bridge_0 {SLAVE_SYNC_DEPTH} {2}
set_instance_parameter_value mm_clock_crossing_bridge_0 {SYMBOL_WIDTH} {8}
set_instance_parameter_value mm_clock_crossing_bridge_0 {USE_AUTO_ADDRESS_WIDTH} {0}

add_instance nios2_gen2_0 altera_nios2_gen2 20.1
set_instance_parameter_value nios2_gen2_0 {bht_ramBlockType} {Automatic}
set_instance_parameter_value nios2_gen2_0 {breakOffset} {32}
set_instance_parameter_value nios2_gen2_0 {breakSlave} {None}
set_instance_parameter_value nios2_gen2_0 {cdx_enabled} {0}
set_instance_parameter_value nios2_gen2_0 {cpuArchRev} {1}
set_instance_parameter_value nios2_gen2_0 {cpuID} {0}
set_instance_parameter_value nios2_gen2_0 {cpuReset} {0}
set_instance_parameter_value nios2_gen2_0 {data_master_high_performance_paddr_base} {0}
set_instance_parameter_value nios2_gen2_0 {data_master_high_performance_paddr_size} {0.0}
set_instance_parameter_value nios2_gen2_0 {data_master_paddr_base} {0}
set_instance_parameter_value nios2_gen2_0 {data_master_paddr_size} {0.0}
set_instance_parameter_value nios2_gen2_0 {dcache_bursts} {false}
set_instance_parameter_value nios2_gen2_0 {dcache_numTCDM} {0}
set_instance_parameter_value nios2_gen2_0 {dcache_ramBlockType} {Automatic}
set_instance_parameter_value nios2_gen2_0 {dcache_size} {0}
set_instance_parameter_value nios2_gen2_0 {dcache_tagramBlockType} {Automatic}
set_instance_parameter_value nios2_gen2_0 {dcache_victim_buf_impl} {ram}
set_instance_parameter_value nios2_gen2_0 {debug_OCIOnchipTrace} {_128}
set_instance_parameter_value nios2_gen2_0 {debug_assignJtagInstanceID} {0}
set_instance_parameter_value nios2_gen2_0 {debug_datatrigger} {0}
set_instance_parameter_value nios2_gen2_0 {debug_debugReqSignals} {0}
set_instance_parameter_value nios2_gen2_0 {debug_enabled} {1}
set_instance_parameter_value nios2_gen2_0 {debug_hwbreakpoint} {2}
set_instance_parameter_value nios2_gen2_0 {debug_jtagInstanceID} {0}
set_instance_parameter_value nios2_gen2_0 {debug_traceStorage} {onchip_trace}
set_instance_parameter_value nios2_gen2_0 {debug_traceType} {none}
set_instance_parameter_value nios2_gen2_0 {debug_triggerArming} {1}
set_instance_parameter_value nios2_gen2_0 {dividerType} {no_div}
set_instance_parameter_value nios2_gen2_0 {exceptionOffset} {32}
set_instance_parameter_value nios2_gen2_0 {exceptionSlave} {onchip_memory2_0.s1}
set_instance_parameter_value nios2_gen2_0 {fa_cache_line} {2}
set_instance_parameter_value nios2_gen2_0 {fa_cache_linesize} {0}
set_instance_parameter_value nios2_gen2_0 {flash_instruction_master_paddr_base} {0}
set_instance_parameter_value nios2_gen2_0 {flash_instruction_master_paddr_size} {0.0}
set_instance_parameter_value nios2_gen2_0 {icache_burstType} {None}
set_instance_parameter_value nios2_gen2_0 {icache_numTCIM} {0}
set_instance_parameter_value nios2_gen2_0 {icache_ramBlockType} {Automatic}
set_instance_parameter_value nios2_gen2_0 {icache_size} {0}
set_instance_parameter_value nios2_gen2_0 {icache_tagramBlockType} {Automatic}
set_instance_parameter_value nios2_gen2_0 {impl} {Tiny}
set_instance_parameter_value nios2_gen2_0 {instruction_master_high_performance_paddr_base} {0}
set_instance_parameter_value nios2_gen2_0 {instruction_master_high_performance_paddr_size} {0.0}
set_instance_parameter_value nios2_gen2_0 {instruction_master_paddr_base} {0}
set_instance_parameter_value nios2_gen2_0 {instruction_master_paddr_size} {0.0}
set_instance_parameter_value nios2_gen2_0 {io_regionbase} {0}
set_instance_parameter_value nios2_gen2_0 {io_regionsize} {0}
set_instance_parameter_value nios2_gen2_0 {master_addr_map} {0}
set_instance_parameter_value nios2_gen2_0 {mmu_TLBMissExcOffset} {0}
set_instance_parameter_value nios2_gen2_0 {mmu_TLBMissExcSlave} {None}
set_instance_parameter_value nios2_gen2_0 {mmu_autoAssignTlbPtrSz} {1}
set_instance_parameter_value nios2_gen2_0 {mmu_enabled} {0}
set_instance_parameter_value nios2_gen2_0 {mmu_processIDNumBits} {8}
set_instance_parameter_value nios2_gen2_0 {mmu_ramBlockType} {Automatic}
set_instance_parameter_value nios2_gen2_0 {mmu_tlbNumWays} {16}
set_instance_parameter_value nios2_gen2_0 {mmu_tlbPtrSz} {7}
set_instance_parameter_value nios2_gen2_0 {mmu_udtlbNumEntries} {6}
set_instance_parameter_value nios2_gen2_0 {mmu_uitlbNumEntries} {4}
set_instance_parameter_value nios2_gen2_0 {mpu_enabled} {0}
set_instance_parameter_value nios2_gen2_0 {mpu_minDataRegionSize} {12}
set_instance_parameter_value nios2_gen2_0 {mpu_minInstRegionSize} {12}
set_instance_parameter_value nios2_gen2_0 {mpu_numOfDataRegion} {8}
set_instance_parameter_value nios2_gen2_0 {mpu_numOfInstRegion} {8}
set_instance_parameter_value nios2_gen2_0 {mpu_useLimit} {0}
set_instance_parameter_value nios2_gen2_0 {mpx_enabled} {0}
set_instance_parameter_value nios2_gen2_0 {mul_32_impl} {2}
set_instance_parameter_value nios2_gen2_0 {mul_64_impl} {0}
set_instance_parameter_value nios2_gen2_0 {mul_shift_choice} {0}
set_instance_parameter_value nios2_gen2_0 {ocimem_ramBlockType} {Automatic}
set_instance_parameter_value nios2_gen2_0 {ocimem_ramInit} {0}
set_instance_parameter_value nios2_gen2_0 {regfile_ramBlockType} {Automatic}
set_instance_parameter_value nios2_gen2_0 {register_file_por} {0}
set_instance_parameter_value nios2_gen2_0 {resetOffset} {0}
set_instance_parameter_value nios2_gen2_0 {resetSlave} {onchip_memory2_0.s1}
set_instance_parameter_value nios2_gen2_0 {resetrequest_enabled} {1}
set_instance_parameter_value nios2_gen2_0 {setting_HBreakTest} {0}
set_instance_parameter_value nios2_gen2_0 {setting_HDLSimCachesCleared} {1}
set_instance_parameter_value nios2_gen2_0 {setting_activateMonitors} {1}
set_instance_parameter_value nios2_gen2_0 {setting_activateTestEndChecker} {0}
set_instance_parameter_value nios2_gen2_0 {setting_activateTrace} {0}
set_instance_parameter_value nios2_gen2_0 {setting_allow_break_inst} {0}
set_instance_parameter_value nios2_gen2_0 {setting_alwaysEncrypt} {1}
set_instance_parameter_value nios2_gen2_0 {setting_asic_add_scan_mode_input} {0}
set_instance_parameter_value nios2_gen2_0 {setting_asic_enabled} {0}
set_instance_parameter_value nios2_gen2_0 {setting_asic_synopsys_translate_on_off} {0}
set_instance_parameter_value nios2_gen2_0 {setting_asic_third_party_synthesis} {0}
set_instance_parameter_value nios2_gen2_0 {setting_avalonDebugPortPresent} {0}
set_instance_parameter_value nios2_gen2_0 {setting_bhtPtrSz} {8}
set_instance_parameter_value nios2_gen2_0 {setting_bigEndian} {0}
set_instance_parameter_value nios2_gen2_0 {setting_branchpredictiontype} {Dynamic}
set_instance_parameter_value nios2_gen2_0 {setting_breakslaveoveride} {0}
set_instance_parameter_value nios2_gen2_0 {setting_clearXBitsLDNonBypass} {1}
set_instance_parameter_value nios2_gen2_0 {setting_dc_ecc_present} {1}
set_instance_parameter_value nios2_gen2_0 {setting_disable_tmr_inj} {0}
set_instance_parameter_value nios2_gen2_0 {setting_disableocitrace} {0}
set_instance_parameter_value nios2_gen2_0 {setting_dtcm_ecc_present} {1}
set_instance_parameter_value nios2_gen2_0 {setting_ecc_present} {0}
set_instance_parameter_value nios2_gen2_0 {setting_ecc_sim_test_ports} {0}
set_instance_parameter_value nios2_gen2_0 {setting_exportHostDebugPort} {0}
set_instance_parameter_value nios2_gen2_0 {setting_exportPCB} {0}
set_instance_parameter_value nios2_gen2_0 {setting_export_large_RAMs} {0}
set_instance_parameter_value nios2_gen2_0 {setting_exportdebuginfo} {0}
set_instance_parameter_value nios2_gen2_0 {setting_exportvectors} {0}
set_instance_parameter_value nios2_gen2_0 {setting_fast_register_read} {0}
set_instance_parameter_value nios2_gen2_0 {setting_ic_ecc_present} {1}
set_instance_parameter_value nios2_gen2_0 {setting_interruptControllerType} {Internal}
set_instance_parameter_value nios2_gen2_0 {setting_itcm_ecc_present} {1}
set_instance_parameter_value nios2_gen2_0 {setting_mmu_ecc_present} {1}
set_instance_parameter_value nios2_gen2_0 {setting_oci_export_jtag_signals} {0}
set_instance_parameter_value nios2_gen2_0 {setting_oci_version} {1}
set_instance_parameter_value nios2_gen2_0 {setting_preciseIllegalMemAccessException} {0}
set_instance_parameter_value nios2_gen2_0 {setting_removeRAMinit} {0}
set_instance_parameter_value nios2_gen2_0 {setting_rf_ecc_present} {1}
set_instance_parameter_value nios2_gen2_0 {setting_shadowRegisterSets} {0}
set_instance_parameter_value nios2_gen2_0 {setting_showInternalSettings} {0}
set_instance_parameter_value nios2_gen2_0 {setting_showUnpublishedSettings} {0}
set_instance_parameter_value nios2_gen2_0 {setting_support31bitdcachebypass} {1}
set_instance_parameter_value nios2_gen2_0 {setting_tmr_output_disable} {0}
set_instance_parameter_value nios2_gen2_0 {setting_usedesignware} {0}
set_instance_parameter_value nios2_gen2_0 {shift_rot_impl} {1}
set_instance_parameter_value nios2_gen2_0 {tightly_coupled_data_master_0_paddr_base} {0}
set_instance_parameter_value nios2_gen2_0 {tightly_coupled_data_master_0_paddr_size} {0.0}
set_instance_parameter_value nios2_gen2_0 {tightly_coupled_data_master_1_paddr_base} {0}
set_instance_parameter_value nios2_gen2_0 {tightly_coupled_data_master_1_paddr_size} {0.0}
set_instance_parameter_value nios2_gen2_0 {tightly_coupled_data_master_2_paddr_base} {0}
set_instance_parameter_value nios2_gen2_0 {tightly_coupled_data_master_2_paddr_size} {0.0}
set_instance_parameter_value nios2_gen2_0 {tightly_coupled_data_master_3_paddr_base} {0}
set_instance_parameter_value nios2_gen2_0 {tightly_coupled_data_master_3_paddr_size} {0.0}
set_instance_parameter_value nios2_gen2_0 {tightly_coupled_instruction_master_0_paddr_base} {0}
set_instance_parameter_value nios2_gen2_0 {tightly_coupled_instruction_master_0_paddr_size} {0.0}
set_instance_parameter_value nios2_gen2_0 {tightly_coupled_instruction_master_1_paddr_base} {0}
set_instance_parameter_value nios2_gen2_0 {tightly_coupled_instruction_master_1_paddr_size} {0.0}
set_instance_parameter_value nios2_gen2_0 {tightly_coupled_instruction_master_2_paddr_base} {0}
set_instance_parameter_value nios2_gen2_0 {tightly_coupled_instruction_master_2_paddr_size} {0.0}
set_instance_parameter_value nios2_gen2_0 {tightly_coupled_instruction_master_3_paddr_base} {0}
set_instance_parameter_value nios2_gen2_0 {tightly_coupled_instruction_master_3_paddr_size} {0.0}
set_instance_parameter_value nios2_gen2_0 {tmr_enabled} {0}
set_instance_parameter_value nios2_gen2_0 {tracefilename} {}
set_instance_parameter_value nios2_gen2_0 {userDefinedSettings} {}

add_instance onchip_memory2_0 altera_avalon_onchip_memory2 20.1
set_instance_parameter_value onchip_memory2_0 {allowInSystemMemoryContentEditor} {0}
set_instance_parameter_value onchip_memory2_0 {blockType} {AUTO}
set_instance_parameter_value onchip_memory2_0 {copyInitFile} {0}
set_instance_parameter_value onchip_memory2_0 {dataWidth} {32}
set_instance_parameter_value onchip_memory2_0 {dataWidth2} {32}
set_instance_parameter_value onchip_memory2_0 {dualPort} {0}
set_instance_parameter_value onchip_memory2_0 {ecc_enabled} {0}
set_instance_parameter_value onchip_memory2_0 {enPRInitMode} {0}
set_instance_parameter_value onchip_memory2_0 {enableDiffWidth} {0}
set_instance_parameter_value onchip_memory2_0 {initMemContent} {0}
set_instance_parameter_value onchip_memory2_0 {initializationFileName} {onchip_mem.hex}
set_instance_parameter_value onchip_memory2_0 {instanceID} {NONE}
set_instance_parameter_value onchip_memory2_0 {memorySize} {32768.0}
set_instance_parameter_value onchip_memory2_0 {readDuringWriteMode} {DONT_CARE}
set_instance_parameter_value onchip_memory2_0 {resetrequest_enabled} {1}
set_instance_parameter_value onchip_memory2_0 {simAllowMRAMContentsFile} {0}
set_instance_parameter_value onchip_memory2_0 {simMemInitOnlyFilename} {0}
set_instance_parameter_value onchip_memory2_0 {singleClockOperation} {0}
set_instance_parameter_value onchip_memory2_0 {slave1Latency} {1}
set_instance_parameter_value onchip_memory2_0 {slave2Latency} {1}
set_instance_parameter_value onchip_memory2_0 {useNonDefaultInitFile} {0}
set_instance_parameter_value onchip_memory2_0 {useShallowMemBlocks} {0}
set_instance_parameter_value onchip_memory2_0 {writable} {1}

add_instance pio_0 altera_avalon_pio 20.1
set_instance_parameter_value pio_0 {bitClearingEdgeCapReg} {0}
set_instance_parameter_value pio_0 {bitModifyingOutReg} {0}
set_instance_parameter_value pio_0 {captureEdge} {0}
set_instance_parameter_value pio_0 {direction} {Input}
set_instance_parameter_value pio_0 {edgeType} {RISING}
set_instance_parameter_value pio_0 {generateIRQ} {0}
set_instance_parameter_value pio_0 {irqType} {LEVEL}
set_instance_parameter_value pio_0 {resetValue} {0.0}
set_instance_parameter_value pio_0 {simDoTestBenchWiring} {0}
set_instance_parameter_value pio_0 {simDrivenValue} {0.0}
set_instance_parameter_value pio_0 {width} {1}

add_instance pixel_multiplexer_0 multiplexer 20.1
set_instance_parameter_value pixel_multiplexer_0 {bitsPerSymbol} {8}
set_instance_parameter_value pixel_multiplexer_0 {errorWidth} {0}
set_instance_parameter_value pixel_multiplexer_0 {numInputInterfaces} {3}
set_instance_parameter_value pixel_multiplexer_0 {outChannelWidth} {2}
set_instance_parameter_value pixel_multiplexer_0 {packetScheduling} {0}
set_instance_parameter_value pixel_multiplexer_0 {schedulingSize} {1}
set_instance_parameter_value pixel_multiplexer_0 {symbolsPerBeat} {6}
set_instance_parameter_value pixel_multiplexer_0 {useHighBitsOfChannel} {1}
set_instance_parameter_value pixel_multiplexer_0 {usePackets} {0}

add_instance sdram_controller_0 altera_avalon_new_sdram_controller 20.1
set_instance_parameter_value sdram_controller_0 {TAC} {5.4}
set_instance_parameter_value sdram_controller_0 {TMRD} {3.0}
set_instance_parameter_value sdram_controller_0 {TRCD} {15.0}
set_instance_parameter_value sdram_controller_0 {TRFC} {70.0}
set_instance_parameter_value sdram_controller_0 {TRP} {15.0}
set_instance_parameter_value sdram_controller_0 {TWR} {14.0}
set_instance_parameter_value sdram_controller_0 {casLatency} {3}
set_instance_parameter_value sdram_controller_0 {columnWidth} {10}
set_instance_parameter_value sdram_controller_0 {dataWidth} {16}
set_instance_parameter_value sdram_controller_0 {generateSimulationModel} {1}
set_instance_parameter_value sdram_controller_0 {initNOPDelay} {0.0}
set_instance_parameter_value sdram_controller_0 {initRefreshCommands} {2}
set_instance_parameter_value sdram_controller_0 {masteredTristateBridgeSlave} {0}
set_instance_parameter_value sdram_controller_0 {model} {single_Micron_MT48LC4M32B2_7_chip}
set_instance_parameter_value sdram_controller_0 {numberOfBanks} {4}
set_instance_parameter_value sdram_controller_0 {numberOfChipSelects} {1}
set_instance_parameter_value sdram_controller_0 {pinsSharedViaTriState} {0}
set_instance_parameter_value sdram_controller_0 {powerUpDelay} {100.0}
set_instance_parameter_value sdram_controller_0 {refreshPeriod} {7.8125}
set_instance_parameter_value sdram_controller_0 {registerDataIn} {1}
set_instance_parameter_value sdram_controller_0 {rowWidth} {13}

add_instance seg7_number_display_0 seg7_number_display 1.0
set_instance_parameter_value seg7_number_display_0 {BCD_DIGITS} {6}
set_instance_parameter_value seg7_number_display_0 {BINARY_DATA_WIDTH} {32}
set_instance_parameter_value seg7_number_display_0 {CSR_ADDR_WIDTH} {4}
set_instance_parameter_value seg7_number_display_0 {CSR_DATA_WIDTH} {32}

add_instance st_clock_crossing_bridge_0 altera_avalon_dc_fifo 20.1
set_instance_parameter_value st_clock_crossing_bridge_0 {BITS_PER_SYMBOL} {8}
set_instance_parameter_value st_clock_crossing_bridge_0 {CHANNEL_WIDTH} {0}
set_instance_parameter_value st_clock_crossing_bridge_0 {ENABLE_EXPLICIT_MAXCHANNEL} {0}
set_instance_parameter_value st_clock_crossing_bridge_0 {ERROR_WIDTH} {0}
set_instance_parameter_value st_clock_crossing_bridge_0 {EXPLICIT_MAXCHANNEL} {0}
set_instance_parameter_value st_clock_crossing_bridge_0 {FIFO_DEPTH} {16}
set_instance_parameter_value st_clock_crossing_bridge_0 {RD_SYNC_DEPTH} {2}
set_instance_parameter_value st_clock_crossing_bridge_0 {SYMBOLS_PER_BEAT} {2}
set_instance_parameter_value st_clock_crossing_bridge_0 {USE_IN_FILL_LEVEL} {0}
set_instance_parameter_value st_clock_crossing_bridge_0 {USE_OUT_FILL_LEVEL} {0}
set_instance_parameter_value st_clock_crossing_bridge_0 {USE_PACKETS} {1}
set_instance_parameter_value st_clock_crossing_bridge_0 {WR_SYNC_DEPTH} {2}

add_instance sysid_qsys_0 altera_avalon_sysid_qsys 20.1
set_instance_parameter_value sysid_qsys_0 {id} {268435457}

add_instance timer_0 altera_avalon_timer 20.1
set_instance_parameter_value timer_0 {alwaysRun} {0}
set_instance_parameter_value timer_0 {counterSize} {32}
set_instance_parameter_value timer_0 {fixedPeriod} {0}
set_instance_parameter_value timer_0 {period} {10}
set_instance_parameter_value timer_0 {periodUnits} {MSEC}
set_instance_parameter_value timer_0 {resetOutput} {0}
set_instance_parameter_value timer_0 {snapshot} {1}
set_instance_parameter_value timer_0 {timeoutPulseOutput} {0}
set_instance_parameter_value timer_0 {watchdogPulse} {2}

add_instance timer_1 altera_avalon_timer 20.1
set_instance_parameter_value timer_1 {alwaysRun} {0}
set_instance_parameter_value timer_1 {counterSize} {32}
set_instance_parameter_value timer_1 {fixedPeriod} {0}
set_instance_parameter_value timer_1 {period} {10}
set_instance_parameter_value timer_1 {periodUnits} {MSEC}
set_instance_parameter_value timer_1 {resetOutput} {0}
set_instance_parameter_value timer_1 {snapshot} {1}
set_instance_parameter_value timer_1 {timeoutPulseOutput} {0}
set_instance_parameter_value timer_1 {watchdogPulse} {2}

add_instance vga_display_0 vga_display 1.0
set_instance_parameter_value vga_display_0 {MM_CSR_START_ADDRESS} {0}
set_instance_parameter_value vga_display_0 {ST_DATA_WIDTH} {16}

add_instance vga_frame_buffer_mux_0 vga_frame_buffer_mux 1.0
set_instance_parameter_value vga_frame_buffer_mux_0 {MM_CSR_ADDRESS_SOURCE0} {192}
set_instance_parameter_value vga_frame_buffer_mux_0 {MM_CSR_ADDRESS_SOURCE1} {128}
set_instance_parameter_value vga_frame_buffer_mux_0 {MM_CSR_ADDRESS_SOURCE2} {64}
set_instance_parameter_value vga_frame_buffer_mux_0 {MM_CSR_ADDRESS_SOURCE3} {256}

add_instance vga_frame_buffer_stream_0 vga_frame_buffer_stream 1.0
set_instance_parameter_value vga_frame_buffer_stream_0 {MM_START_ADDRESS} {67108864}

add_instance vga_sprite_stream_1 vga_sprite_stream 1.0
set_instance_parameter_value vga_sprite_stream_1 {MM_START_ADDRESS} {67108864}
set_instance_parameter_value vga_sprite_stream_1 {SPRITE_HEIGHT} {48}
set_instance_parameter_value vga_sprite_stream_1 {SPRITE_WIDTH} {48}

add_instance vga_sprite_stream_2 vga_sprite_stream 1.0
set_instance_parameter_value vga_sprite_stream_2 {MM_START_ADDRESS} {67108864}
set_instance_parameter_value vga_sprite_stream_2 {SPRITE_HEIGHT} {48}
set_instance_parameter_value vga_sprite_stream_2 {SPRITE_WIDTH} {48}

add_instance vga_sprite_stream_3 vga_sprite_stream 1.0
set_instance_parameter_value vga_sprite_stream_3 {MM_START_ADDRESS} {67108864}
set_instance_parameter_value vga_sprite_stream_3 {SPRITE_HEIGHT} {48}
set_instance_parameter_value vga_sprite_stream_3 {SPRITE_WIDTH} {48}

# exported interfaces
add_interface button conduit end
set_interface_property button EXPORT_OF pio_0.external_connection
add_interface clk clock sink
set_interface_property clk EXPORT_OF clk_0.clk_in
add_interface reset reset sink
set_interface_property reset EXPORT_OF clk_0.clk_in_reset
add_interface sdram conduit end
set_interface_property sdram EXPORT_OF sdram_controller_0.wire
add_interface sdram_clk clock source
set_interface_property sdram_clk EXPORT_OF altpll_0.c1
add_interface seg7_display conduit end
set_interface_property seg7_display EXPORT_OF seg7_number_display_0.seg7_display
add_interface vga_connector conduit end
set_interface_property vga_connector EXPORT_OF vga_display_0.vga_connector

# connections and connection parameters
add_connection altpll_0.c0 framebuffer_writer_0.clock

add_connection altpll_0.c0 graphics_instruction_0.clock

add_connection altpll_0.c0 graphics_line_0.clock

add_connection altpll_0.c0 graphics_rect_fill_0.clock

add_connection altpll_0.c0 graphics_rect_move_0.clock

add_connection altpll_0.c0 jtag_uart_0.clk

add_connection altpll_0.c0 mm_clock_crossing_bridge_0.m0_clk

add_connection altpll_0.c0 nios2_gen2_0.clk

add_connection altpll_0.c0 onchip_memory2_0.clk1

add_connection altpll_0.c0 pio_0.clk

add_connection altpll_0.c0 pixel_multiplexer_0.clk

add_connection altpll_0.c0 sdram_controller_0.clk

add_connection altpll_0.c0 seg7_number_display_0.clock

add_connection altpll_0.c0 st_clock_crossing_bridge_0.in_clk

add_connection altpll_0.c0 sysid_qsys_0.clk

add_connection altpll_0.c0 timer_0.clk

add_connection altpll_0.c0 timer_1.clk

add_connection altpll_0.c0 vga_frame_buffer_mux_0.clock

add_connection altpll_0.c0 vga_frame_buffer_stream_0.clock

add_connection altpll_0.c0 vga_sprite_stream_1.clock

add_connection altpll_0.c0 vga_sprite_stream_2.clock

add_connection altpll_0.c0 vga_sprite_stream_3.clock

add_connection altpll_0.c2 mm_clock_crossing_bridge_0.s0_clk

add_connection altpll_0.c2 st_clock_crossing_bridge_0.out_clk

add_connection altpll_0.c2 vga_display_0.clock

add_connection clk_0.clk altpll_0.inclk_interface

add_connection clk_0.clk_reset altpll_0.inclk_interface_reset

add_connection clk_0.clk_reset framebuffer_writer_0.reset

add_connection clk_0.clk_reset graphics_instruction_0.reset

add_connection clk_0.clk_reset graphics_line_0.reset

add_connection clk_0.clk_reset graphics_rect_fill_0.reset

add_connection clk_0.clk_reset graphics_rect_move_0.reset

add_connection clk_0.clk_reset jtag_uart_0.reset

add_connection clk_0.clk_reset mm_clock_crossing_bridge_0.m0_reset

add_connection clk_0.clk_reset mm_clock_crossing_bridge_0.s0_reset

add_connection clk_0.clk_reset nios2_gen2_0.reset

add_connection clk_0.clk_reset onchip_memory2_0.reset1

add_connection clk_0.clk_reset pio_0.reset

add_connection clk_0.clk_reset pixel_multiplexer_0.reset

add_connection clk_0.clk_reset sdram_controller_0.reset

add_connection clk_0.clk_reset seg7_number_display_0.reset

add_connection clk_0.clk_reset st_clock_crossing_bridge_0.in_clk_reset

add_connection clk_0.clk_reset st_clock_crossing_bridge_0.out_clk_reset

add_connection clk_0.clk_reset sysid_qsys_0.reset

add_connection clk_0.clk_reset timer_0.reset

add_connection clk_0.clk_reset timer_1.reset

add_connection clk_0.clk_reset vga_display_0.reset

add_connection clk_0.clk_reset vga_frame_buffer_mux_0.reset

add_connection clk_0.clk_reset vga_frame_buffer_stream_0.reset

add_connection clk_0.clk_reset vga_sprite_stream_1.reset

add_connection clk_0.clk_reset vga_sprite_stream_2.reset

add_connection clk_0.clk_reset vga_sprite_stream_3.reset

add_connection framebuffer_writer_0.mm_master_memory sdram_controller_0.s1
set_connection_parameter_value framebuffer_writer_0.mm_master_memory/sdram_controller_0.s1 arbitrationPriority {3}
set_connection_parameter_value framebuffer_writer_0.mm_master_memory/sdram_controller_0.s1 baseAddress {0x04000000}
set_connection_parameter_value framebuffer_writer_0.mm_master_memory/sdram_controller_0.s1 defaultConnection {0}

add_connection graphics_line_0.op_ctrl graphics_instruction_0.line_op_ctrl
set_connection_parameter_value graphics_line_0.op_ctrl/graphics_instruction_0.line_op_ctrl endPort {}
set_connection_parameter_value graphics_line_0.op_ctrl/graphics_instruction_0.line_op_ctrl endPortLSB {0}
set_connection_parameter_value graphics_line_0.op_ctrl/graphics_instruction_0.line_op_ctrl startPort {}
set_connection_parameter_value graphics_line_0.op_ctrl/graphics_instruction_0.line_op_ctrl startPortLSB {0}
set_connection_parameter_value graphics_line_0.op_ctrl/graphics_instruction_0.line_op_ctrl width {0}

add_connection graphics_line_0.pixel_source pixel_multiplexer_0.in0

add_connection graphics_rect_fill_0.op_ctrl graphics_instruction_0.rect_fill_op_ctrl
set_connection_parameter_value graphics_rect_fill_0.op_ctrl/graphics_instruction_0.rect_fill_op_ctrl endPort {}
set_connection_parameter_value graphics_rect_fill_0.op_ctrl/graphics_instruction_0.rect_fill_op_ctrl endPortLSB {0}
set_connection_parameter_value graphics_rect_fill_0.op_ctrl/graphics_instruction_0.rect_fill_op_ctrl startPort {}
set_connection_parameter_value graphics_rect_fill_0.op_ctrl/graphics_instruction_0.rect_fill_op_ctrl startPortLSB {0}
set_connection_parameter_value graphics_rect_fill_0.op_ctrl/graphics_instruction_0.rect_fill_op_ctrl width {0}

add_connection graphics_rect_fill_0.pixel_source pixel_multiplexer_0.in1

add_connection graphics_rect_move_0.mm_master_sdram sdram_controller_0.s1
set_connection_parameter_value graphics_rect_move_0.mm_master_sdram/sdram_controller_0.s1 arbitrationPriority {7}
set_connection_parameter_value graphics_rect_move_0.mm_master_sdram/sdram_controller_0.s1 baseAddress {0x04000000}
set_connection_parameter_value graphics_rect_move_0.mm_master_sdram/sdram_controller_0.s1 defaultConnection {0}

add_connection graphics_rect_move_0.op_ctrl graphics_instruction_0.rect_move_op_ctrl
set_connection_parameter_value graphics_rect_move_0.op_ctrl/graphics_instruction_0.rect_move_op_ctrl endPort {}
set_connection_parameter_value graphics_rect_move_0.op_ctrl/graphics_instruction_0.rect_move_op_ctrl endPortLSB {0}
set_connection_parameter_value graphics_rect_move_0.op_ctrl/graphics_instruction_0.rect_move_op_ctrl startPort {}
set_connection_parameter_value graphics_rect_move_0.op_ctrl/graphics_instruction_0.rect_move_op_ctrl startPortLSB {0}
set_connection_parameter_value graphics_rect_move_0.op_ctrl/graphics_instruction_0.rect_move_op_ctrl width {0}

add_connection graphics_rect_move_0.pixel_source pixel_multiplexer_0.in2

add_connection mm_clock_crossing_bridge_0.m0 vga_frame_buffer_mux_0.mm_slave_csr
set_connection_parameter_value mm_clock_crossing_bridge_0.m0/vga_frame_buffer_mux_0.mm_slave_csr arbitrationPriority {1}
set_connection_parameter_value mm_clock_crossing_bridge_0.m0/vga_frame_buffer_mux_0.mm_slave_csr baseAddress {0x0000}
set_connection_parameter_value mm_clock_crossing_bridge_0.m0/vga_frame_buffer_mux_0.mm_slave_csr defaultConnection {0}

add_connection nios2_gen2_0.custom_instruction_master graphics_instruction_0.nios_custom_instruction_slave
set_connection_parameter_value nios2_gen2_0.custom_instruction_master/graphics_instruction_0.nios_custom_instruction_slave CIName {graphics_instruction_0}
set_connection_parameter_value nios2_gen2_0.custom_instruction_master/graphics_instruction_0.nios_custom_instruction_slave CINameUpgrade {}
set_connection_parameter_value nios2_gen2_0.custom_instruction_master/graphics_instruction_0.nios_custom_instruction_slave arbitrationPriority {1}
set_connection_parameter_value nios2_gen2_0.custom_instruction_master/graphics_instruction_0.nios_custom_instruction_slave baseAddress {0.0}
set_connection_parameter_value nios2_gen2_0.custom_instruction_master/graphics_instruction_0.nios_custom_instruction_slave opcodeExtensionUpgrade {-1}

add_connection nios2_gen2_0.data_master graphics_line_0.mm_slave_csr
set_connection_parameter_value nios2_gen2_0.data_master/graphics_line_0.mm_slave_csr arbitrationPriority {1}
set_connection_parameter_value nios2_gen2_0.data_master/graphics_line_0.mm_slave_csr baseAddress {0x0180}
set_connection_parameter_value nios2_gen2_0.data_master/graphics_line_0.mm_slave_csr defaultConnection {0}

add_connection nios2_gen2_0.data_master graphics_rect_fill_0.mm_slave_csr
set_connection_parameter_value nios2_gen2_0.data_master/graphics_rect_fill_0.mm_slave_csr arbitrationPriority {1}
set_connection_parameter_value nios2_gen2_0.data_master/graphics_rect_fill_0.mm_slave_csr baseAddress {0x0140}
set_connection_parameter_value nios2_gen2_0.data_master/graphics_rect_fill_0.mm_slave_csr defaultConnection {0}

add_connection nios2_gen2_0.data_master graphics_rect_move_0.mm_slave_csr
set_connection_parameter_value nios2_gen2_0.data_master/graphics_rect_move_0.mm_slave_csr arbitrationPriority {1}
set_connection_parameter_value nios2_gen2_0.data_master/graphics_rect_move_0.mm_slave_csr baseAddress {0x00c0}
set_connection_parameter_value nios2_gen2_0.data_master/graphics_rect_move_0.mm_slave_csr defaultConnection {0}

add_connection nios2_gen2_0.data_master jtag_uart_0.avalon_jtag_slave
set_connection_parameter_value nios2_gen2_0.data_master/jtag_uart_0.avalon_jtag_slave arbitrationPriority {1}
set_connection_parameter_value nios2_gen2_0.data_master/jtag_uart_0.avalon_jtag_slave baseAddress {0x0218}
set_connection_parameter_value nios2_gen2_0.data_master/jtag_uart_0.avalon_jtag_slave defaultConnection {0}

add_connection nios2_gen2_0.data_master nios2_gen2_0.debug_mem_slave
set_connection_parameter_value nios2_gen2_0.data_master/nios2_gen2_0.debug_mem_slave arbitrationPriority {1}
set_connection_parameter_value nios2_gen2_0.data_master/nios2_gen2_0.debug_mem_slave baseAddress {0x1000}
set_connection_parameter_value nios2_gen2_0.data_master/nios2_gen2_0.debug_mem_slave defaultConnection {0}

add_connection nios2_gen2_0.data_master onchip_memory2_0.s1
set_connection_parameter_value nios2_gen2_0.data_master/onchip_memory2_0.s1 arbitrationPriority {1}
set_connection_parameter_value nios2_gen2_0.data_master/onchip_memory2_0.s1 baseAddress {0x00010000}
set_connection_parameter_value nios2_gen2_0.data_master/onchip_memory2_0.s1 defaultConnection {0}

add_connection nios2_gen2_0.data_master pio_0.s1
set_connection_parameter_value nios2_gen2_0.data_master/pio_0.s1 arbitrationPriority {1}
set_connection_parameter_value nios2_gen2_0.data_master/pio_0.s1 baseAddress {0x0200}
set_connection_parameter_value nios2_gen2_0.data_master/pio_0.s1 defaultConnection {0}

add_connection nios2_gen2_0.data_master sdram_controller_0.s1
set_connection_parameter_value nios2_gen2_0.data_master/sdram_controller_0.s1 arbitrationPriority {2}
set_connection_parameter_value nios2_gen2_0.data_master/sdram_controller_0.s1 baseAddress {0x04000000}
set_connection_parameter_value nios2_gen2_0.data_master/sdram_controller_0.s1 defaultConnection {0}

add_connection nios2_gen2_0.data_master seg7_number_display_0.mm_slave_csr
set_connection_parameter_value nios2_gen2_0.data_master/seg7_number_display_0.mm_slave_csr arbitrationPriority {1}
set_connection_parameter_value nios2_gen2_0.data_master/seg7_number_display_0.mm_slave_csr baseAddress {0x0000}
set_connection_parameter_value nios2_gen2_0.data_master/seg7_number_display_0.mm_slave_csr defaultConnection {0}

add_connection nios2_gen2_0.data_master sysid_qsys_0.control_slave
set_connection_parameter_value nios2_gen2_0.data_master/sysid_qsys_0.control_slave arbitrationPriority {1}
set_connection_parameter_value nios2_gen2_0.data_master/sysid_qsys_0.control_slave baseAddress {0x0210}
set_connection_parameter_value nios2_gen2_0.data_master/sysid_qsys_0.control_slave defaultConnection {0}

add_connection nios2_gen2_0.data_master timer_0.s1
set_connection_parameter_value nios2_gen2_0.data_master/timer_0.s1 arbitrationPriority {1}
set_connection_parameter_value nios2_gen2_0.data_master/timer_0.s1 baseAddress {0x01e0}
set_connection_parameter_value nios2_gen2_0.data_master/timer_0.s1 defaultConnection {0}

add_connection nios2_gen2_0.data_master timer_1.s1
set_connection_parameter_value nios2_gen2_0.data_master/timer_1.s1 arbitrationPriority {1}
set_connection_parameter_value nios2_gen2_0.data_master/timer_1.s1 baseAddress {0x01c0}
set_connection_parameter_value nios2_gen2_0.data_master/timer_1.s1 defaultConnection {0}

add_connection nios2_gen2_0.data_master vga_sprite_stream_1.mm_slave_csr
set_connection_parameter_value nios2_gen2_0.data_master/vga_sprite_stream_1.mm_slave_csr arbitrationPriority {1}
set_connection_parameter_value nios2_gen2_0.data_master/vga_sprite_stream_1.mm_slave_csr baseAddress {0x0080}
set_connection_parameter_value nios2_gen2_0.data_master/vga_sprite_stream_1.mm_slave_csr defaultConnection {0}

add_connection nios2_gen2_0.data_master vga_sprite_stream_2.mm_slave_csr
set_connection_parameter_value nios2_gen2_0.data_master/vga_sprite_stream_2.mm_slave_csr arbitrationPriority {1}
set_connection_parameter_value nios2_gen2_0.data_master/vga_sprite_stream_2.mm_slave_csr baseAddress {0x0040}
set_connection_parameter_value nios2_gen2_0.data_master/vga_sprite_stream_2.mm_slave_csr defaultConnection {0}

add_connection nios2_gen2_0.data_master vga_sprite_stream_3.mm_slave_csr
set_connection_parameter_value nios2_gen2_0.data_master/vga_sprite_stream_3.mm_slave_csr arbitrationPriority {1}
set_connection_parameter_value nios2_gen2_0.data_master/vga_sprite_stream_3.mm_slave_csr baseAddress {0x0100}
set_connection_parameter_value nios2_gen2_0.data_master/vga_sprite_stream_3.mm_slave_csr defaultConnection {0}

add_connection nios2_gen2_0.debug_reset_request altpll_0.inclk_interface_reset

add_connection nios2_gen2_0.debug_reset_request framebuffer_writer_0.reset

add_connection nios2_gen2_0.debug_reset_request graphics_instruction_0.reset

add_connection nios2_gen2_0.debug_reset_request graphics_line_0.reset

add_connection nios2_gen2_0.debug_reset_request graphics_rect_fill_0.reset

add_connection nios2_gen2_0.debug_reset_request graphics_rect_move_0.reset

add_connection nios2_gen2_0.debug_reset_request jtag_uart_0.reset

add_connection nios2_gen2_0.debug_reset_request mm_clock_crossing_bridge_0.m0_reset

add_connection nios2_gen2_0.debug_reset_request mm_clock_crossing_bridge_0.s0_reset

add_connection nios2_gen2_0.debug_reset_request nios2_gen2_0.reset

add_connection nios2_gen2_0.debug_reset_request onchip_memory2_0.reset1

add_connection nios2_gen2_0.debug_reset_request pio_0.reset

add_connection nios2_gen2_0.debug_reset_request pixel_multiplexer_0.reset

add_connection nios2_gen2_0.debug_reset_request sdram_controller_0.reset

add_connection nios2_gen2_0.debug_reset_request seg7_number_display_0.reset

add_connection nios2_gen2_0.debug_reset_request st_clock_crossing_bridge_0.in_clk_reset

add_connection nios2_gen2_0.debug_reset_request st_clock_crossing_bridge_0.out_clk_reset

add_connection nios2_gen2_0.debug_reset_request sysid_qsys_0.reset

add_connection nios2_gen2_0.debug_reset_request timer_0.reset

add_connection nios2_gen2_0.debug_reset_request timer_1.reset

add_connection nios2_gen2_0.debug_reset_request vga_display_0.reset

add_connection nios2_gen2_0.debug_reset_request vga_frame_buffer_mux_0.reset

add_connection nios2_gen2_0.debug_reset_request vga_frame_buffer_stream_0.reset

add_connection nios2_gen2_0.debug_reset_request vga_sprite_stream_1.reset

add_connection nios2_gen2_0.debug_reset_request vga_sprite_stream_2.reset

add_connection nios2_gen2_0.debug_reset_request vga_sprite_stream_3.reset

add_connection nios2_gen2_0.instruction_master nios2_gen2_0.debug_mem_slave
set_connection_parameter_value nios2_gen2_0.instruction_master/nios2_gen2_0.debug_mem_slave arbitrationPriority {1}
set_connection_parameter_value nios2_gen2_0.instruction_master/nios2_gen2_0.debug_mem_slave baseAddress {0x1000}
set_connection_parameter_value nios2_gen2_0.instruction_master/nios2_gen2_0.debug_mem_slave defaultConnection {0}

add_connection nios2_gen2_0.instruction_master onchip_memory2_0.s1
set_connection_parameter_value nios2_gen2_0.instruction_master/onchip_memory2_0.s1 arbitrationPriority {1}
set_connection_parameter_value nios2_gen2_0.instruction_master/onchip_memory2_0.s1 baseAddress {0x00010000}
set_connection_parameter_value nios2_gen2_0.instruction_master/onchip_memory2_0.s1 defaultConnection {0}

add_connection nios2_gen2_0.instruction_master sdram_controller_0.s1
set_connection_parameter_value nios2_gen2_0.instruction_master/sdram_controller_0.s1 arbitrationPriority {1}
set_connection_parameter_value nios2_gen2_0.instruction_master/sdram_controller_0.s1 baseAddress {0x04000000}
set_connection_parameter_value nios2_gen2_0.instruction_master/sdram_controller_0.s1 defaultConnection {0}

add_connection nios2_gen2_0.irq jtag_uart_0.irq
set_connection_parameter_value nios2_gen2_0.irq/jtag_uart_0.irq irqNumber {1}

add_connection nios2_gen2_0.irq timer_0.irq
set_connection_parameter_value nios2_gen2_0.irq/timer_0.irq irqNumber {0}

add_connection nios2_gen2_0.irq timer_1.irq
set_connection_parameter_value nios2_gen2_0.irq/timer_1.irq irqNumber {2}

add_connection pixel_multiplexer_0.out framebuffer_writer_0.pixel_sink

add_connection st_clock_crossing_bridge_0.out vga_display_0.framebuffer_sink

add_connection vga_display_0.mm_master_csr mm_clock_crossing_bridge_0.s0
set_connection_parameter_value vga_display_0.mm_master_csr/mm_clock_crossing_bridge_0.s0 arbitrationPriority {1}
set_connection_parameter_value vga_display_0.mm_master_csr/mm_clock_crossing_bridge_0.s0 baseAddress {0x0000}
set_connection_parameter_value vga_display_0.mm_master_csr/mm_clock_crossing_bridge_0.s0 defaultConnection {0}

add_connection vga_frame_buffer_mux_0.mm_master_csr vga_frame_buffer_stream_0.mm_slave_csr
set_connection_parameter_value vga_frame_buffer_mux_0.mm_master_csr/vga_frame_buffer_stream_0.mm_slave_csr arbitrationPriority {1}
set_connection_parameter_value vga_frame_buffer_mux_0.mm_master_csr/vga_frame_buffer_stream_0.mm_slave_csr baseAddress {0x00c0}
set_connection_parameter_value vga_frame_buffer_mux_0.mm_master_csr/vga_frame_buffer_stream_0.mm_slave_csr defaultConnection {0}

add_connection vga_frame_buffer_mux_0.mm_master_csr vga_sprite_stream_1.mm_slave_csr
set_connection_parameter_value vga_frame_buffer_mux_0.mm_master_csr/vga_sprite_stream_1.mm_slave_csr arbitrationPriority {1}
set_connection_parameter_value vga_frame_buffer_mux_0.mm_master_csr/vga_sprite_stream_1.mm_slave_csr baseAddress {0x0080}
set_connection_parameter_value vga_frame_buffer_mux_0.mm_master_csr/vga_sprite_stream_1.mm_slave_csr defaultConnection {0}

add_connection vga_frame_buffer_mux_0.mm_master_csr vga_sprite_stream_2.mm_slave_csr
set_connection_parameter_value vga_frame_buffer_mux_0.mm_master_csr/vga_sprite_stream_2.mm_slave_csr arbitrationPriority {1}
set_connection_parameter_value vga_frame_buffer_mux_0.mm_master_csr/vga_sprite_stream_2.mm_slave_csr baseAddress {0x0040}
set_connection_parameter_value vga_frame_buffer_mux_0.mm_master_csr/vga_sprite_stream_2.mm_slave_csr defaultConnection {0}

add_connection vga_frame_buffer_mux_0.mm_master_csr vga_sprite_stream_3.mm_slave_csr
set_connection_parameter_value vga_frame_buffer_mux_0.mm_master_csr/vga_sprite_stream_3.mm_slave_csr arbitrationPriority {1}
set_connection_parameter_value vga_frame_buffer_mux_0.mm_master_csr/vga_sprite_stream_3.mm_slave_csr baseAddress {0x0100}
set_connection_parameter_value vga_frame_buffer_mux_0.mm_master_csr/vga_sprite_stream_3.mm_slave_csr defaultConnection {0}

add_connection vga_frame_buffer_mux_0.st_source st_clock_crossing_bridge_0.in

add_connection vga_frame_buffer_stream_0.framebuffer_source vga_frame_buffer_mux_0.st_sink0

add_connection vga_frame_buffer_stream_0.mm_master_sdram sdram_controller_0.s1
set_connection_parameter_value vga_frame_buffer_stream_0.mm_master_sdram/sdram_controller_0.s1 arbitrationPriority {8}
set_connection_parameter_value vga_frame_buffer_stream_0.mm_master_sdram/sdram_controller_0.s1 baseAddress {0x04000000}
set_connection_parameter_value vga_frame_buffer_stream_0.mm_master_sdram/sdram_controller_0.s1 defaultConnection {0}

add_connection vga_sprite_stream_1.framebuffer_source vga_frame_buffer_mux_0.st_sink1

add_connection vga_sprite_stream_1.mm_master_sdram onchip_memory2_0.s1
set_connection_parameter_value vga_sprite_stream_1.mm_master_sdram/onchip_memory2_0.s1 arbitrationPriority {1}
set_connection_parameter_value vga_sprite_stream_1.mm_master_sdram/onchip_memory2_0.s1 baseAddress {0x00010000}
set_connection_parameter_value vga_sprite_stream_1.mm_master_sdram/onchip_memory2_0.s1 defaultConnection {0}

add_connection vga_sprite_stream_1.mm_master_sdram sdram_controller_0.s1
set_connection_parameter_value vga_sprite_stream_1.mm_master_sdram/sdram_controller_0.s1 arbitrationPriority {6}
set_connection_parameter_value vga_sprite_stream_1.mm_master_sdram/sdram_controller_0.s1 baseAddress {0x04000000}
set_connection_parameter_value vga_sprite_stream_1.mm_master_sdram/sdram_controller_0.s1 defaultConnection {0}

add_connection vga_sprite_stream_2.framebuffer_source vga_frame_buffer_mux_0.st_sink2

add_connection vga_sprite_stream_2.mm_master_sdram onchip_memory2_0.s1
set_connection_parameter_value vga_sprite_stream_2.mm_master_sdram/onchip_memory2_0.s1 arbitrationPriority {1}
set_connection_parameter_value vga_sprite_stream_2.mm_master_sdram/onchip_memory2_0.s1 baseAddress {0x00010000}
set_connection_parameter_value vga_sprite_stream_2.mm_master_sdram/onchip_memory2_0.s1 defaultConnection {0}

add_connection vga_sprite_stream_2.mm_master_sdram sdram_controller_0.s1
set_connection_parameter_value vga_sprite_stream_2.mm_master_sdram/sdram_controller_0.s1 arbitrationPriority {5}
set_connection_parameter_value vga_sprite_stream_2.mm_master_sdram/sdram_controller_0.s1 baseAddress {0x04000000}
set_connection_parameter_value vga_sprite_stream_2.mm_master_sdram/sdram_controller_0.s1 defaultConnection {0}

add_connection vga_sprite_stream_3.framebuffer_source vga_frame_buffer_mux_0.st_sink3

add_connection vga_sprite_stream_3.mm_master_sdram onchip_memory2_0.s1
set_connection_parameter_value vga_sprite_stream_3.mm_master_sdram/onchip_memory2_0.s1 arbitrationPriority {1}
set_connection_parameter_value vga_sprite_stream_3.mm_master_sdram/onchip_memory2_0.s1 baseAddress {0x00010000}
set_connection_parameter_value vga_sprite_stream_3.mm_master_sdram/onchip_memory2_0.s1 defaultConnection {0}

add_connection vga_sprite_stream_3.mm_master_sdram sdram_controller_0.s1
set_connection_parameter_value vga_sprite_stream_3.mm_master_sdram/sdram_controller_0.s1 arbitrationPriority {4}
set_connection_parameter_value vga_sprite_stream_3.mm_master_sdram/sdram_controller_0.s1 baseAddress {0x04000000}
set_connection_parameter_value vga_sprite_stream_3.mm_master_sdram/sdram_controller_0.s1 defaultConnection {0}

# interconnect requirements
set_interconnect_requirement {$system} {qsys_mm.clockCrossingAdapter} {HANDSHAKE}
set_interconnect_requirement {$system} {qsys_mm.enableEccProtection} {FALSE}
set_interconnect_requirement {$system} {qsys_mm.enableInstrumentation} {TRUE}
set_interconnect_requirement {$system} {qsys_mm.insertDefaultSlave} {FALSE}
set_interconnect_requirement {$system} {qsys_mm.maxAdditionalLatency} {0}
set_interconnect_requirement {graphics_line_0.mm_slave_csr} {qsys_mm.insertPerformanceMonitor} {FALSE}
set_interconnect_requirement {jtag_master_0.master} {qsys_mm.insertPerformanceMonitor} {FALSE}
set_interconnect_requirement {mm_interconnect_0|router_004.src/nios2_gen2_0_instruction_master_limiter.cmd_sink} {qsys_mm.postTransform.pipelineCount} {0}
set_interconnect_requirement {nios2_gen2_0.data_master} {qsys_mm.insertPerformanceMonitor} {FALSE}
set_interconnect_requirement {onchip_memory2_0.s1} {qsys_mm.insertPerformanceMonitor} {FALSE}
set_interconnect_requirement {sdram_controller_0.s1} {qsys_mm.arbitrationScheme} {fixed-priority}
set_interconnect_requirement {sdram_controller_0.s1} {qsys_mm.insertPerformanceMonitor} {FALSE}
set_interconnect_requirement {sysid_qsys_0.control_slave} {qsys_mm.insertPerformanceMonitor} {FALSE}

save_system {dino_system.qsys}
