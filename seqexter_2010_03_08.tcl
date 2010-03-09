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

	set input_file    [lindex $argv 0]
	set file_out_base [lindex $argv 1]
	set mod_value     [lindex $argv 2]
	
	Open_Files $input_file $file_out_base
	
	Read_Input_File $mod_value
	
	Close_Files
	
	Print_Final_Message
	
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
	
		incr n
	
	}
}

proc Check_Mod_Status { n mod_value } {
	
	set n_mod [expr fmod($n,$mod_value)]
	if { $n_mod == 0 } {
	puts $n
	}
	
}

proc Close_Files { } {
	
	global file_in_1	; # Input File
	global file_out0	; # Log File 
	global file_out1	; # Output File 1
	
	close $file_in_1
	close $file_out0
	close $file_out1
	
}

proc Print_Final_Message { } {
	
	puts "                                  "
	puts "  +----------------------------+  "
	puts "  |  Well Done - Enjoy Output  |  "
	puts "  +----------------------------+  "
	puts "                                 "
	
}

if {$argc != 3} {
	puts "Program usage:"
	puts "Input_File,  Output_File,  Mod_Value"
} else {
	SeqExter $argv
}

