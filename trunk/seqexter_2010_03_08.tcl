#!/usr/bin/tcl

###########################################################
#                                                         #
#                        SEQEXTER                         #
#                                                         #
#                    Alexander  Kozik                     #
#                                                         #
#                    Copyright   2010                     #
#                                                         #
###########################################################

proc SeqExter {argv} {
	
	global initial_time
	global sleep_time
	global live_string
	
	set input_file    [lindex $argv 0]
	set file_out_base [lindex $argv 1]
	set mod_value     [lindex $argv 2]
	set sleep_time    [lindex $argv 3]
	
	Set_Intial_Time
	
	Open_Files $input_file $file_out_base
	
	Read_Input_File $mod_value
	
	Read_StdIn_Data
	
	Check_StdIn_Data
	
	Close_Files
	
	Print_Final_Message
	
}

proc Set_Intial_Time { } {

	global initial_time
	global sleep_time
	
	set initial_time [clock format [clock seconds]]
	
	puts " Initial Time:  $initial_time "
	
	### return $initial_time
	
	after $sleep_time
	
}

proc Check_Current_Time { } {
	
	set current_time [clock format [clock seconds]]
	
	return $current_time
	
}

proc Open_Files { input_file file_out_base } {
	
	global file_in_1	; # Input File
	global file_out0	; # Log File 
	global file_out1	; # Output File 1
	
	set file_name_0 $file_out_base\.Log
	set file_name_1 $file_out_base\.Out
	
	set file_in_1 [open $input_file  "r"]
	set file_out0 [open $file_name_0 "w"]
	set file_out1 [open $file_name_1 "w"]
	
}

proc Read_Input_File { mod_value } {
	
	global file_in_1
	
	set n 1 
	
	while {[gets $file_in_1 current_line] >= 0} {
	
		Check_Mod_Status $n $mod_value
	
		Create_Basic_Data_Array $n $current_line
	
		incr n
	
	}
}

proc Check_Mod_Status { n mod_value } {
	
	global initial_time
	
	set n_mod [expr fmod($n,$mod_value)]
		if { $n_mod == 0 } {
		set current_time [Check_Current_Time]
		puts " $n  lines processed  |  Init Time: $initial_time  Current Time: $current_time "
	}
	
}

proc Create_Basic_Data_Array { n current_line } {
	
	global basic_data_array
	
	set basic_data_array($n) $current_line
	
}

proc Close_Files { } {
	
	global file_in_1	; # Input File
	global file_out0	; # Log File 
	global file_out1	; # Output File 1
	
	close $file_in_1
	close $file_out0
	close $file_out1
	
}

proc Read_StdIn_Data { } {
	
	global live_string
	
	puts ""
	puts " Enter Yes or No\: "
	puts ""
	gets stdin live_string
	
}

proc Check_StdIn_Data { } {
	
	global live_string
	
	while { $live_string != "Yes" && $live_string != "No"} {
		puts " Ops! "
		Read_StdIn_Data
	
	if { $live_string == "Yes" } {
		puts " Dah! "
	}
	if { $live_string == "No" } {
		puts " Net! "
	}
	
	}
}

proc Print_Final_Message { } {
	
	puts "                                  "
	puts "  +----------------------------+  "
	puts "  |  Well Done - Enjoy Output  |  "
	puts "  +----------------------------+  "
	puts "                                  "
	
}

if {$argc != 4} {
	puts "Program usage:"
	puts "Input_File,  Output_File,  Mod_Value, Sleep_Time"
} else {
	SeqExter $argv
}

