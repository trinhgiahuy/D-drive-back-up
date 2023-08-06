onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_traffic_light/clk
add wave -noupdate -format Logic /tb_traffic_light/rst_n
add wave -noupdate -format Logic /tb_traffic_light/red_req_to_duv
add wave -noupdate -format Logic /tb_traffic_light/green_req_to_duv
add wave -noupdate -divider {DUV FSM}
add wave -noupdate -format Literal /tb_traffic_light/r_y_g_from_duv
add wave -noupdate -format Literal /tb_traffic_light/duv/curr_state_r
add wave -noupdate -format Literal /tb_traffic_light/duv/yellow_cnt_r
add wave -noupdate -divider {TB logic}
add wave -noupdate -format Literal /tb_traffic_light/prev_color_r
add wave -noupdate -format Literal /tb_traffic_light/color_cnt_r
add wave -noupdate -format Literal /tb_traffic_light/mod_cnt_r
add wave -noupdate -format Literal /tb_traffic_light/yellow_cnt_r
add wave -noupdate -format Literal /tb_traffic_light/in_ctrl_r
add wave -noupdate -format Logic /tb_traffic_light/req_opposite_r
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2406 ns} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {206 ns}
