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

###########################################################
#                                                         #
# Basic version of the script reads FASTA or FASTQ file   #
# into memory, creates data array, and manipulates array  #
# according to Run_String_Analysis_01 function. It's easy #
# to add new functions, see Read_StdIn_Data and           #
# Check_StdIn_Data procedures                             #
#                                                         #
###########################################################

proc Set_Global_Parameters { } {
	
	global initial_time
	global sleep_time
	global live_string
	global query_string
	
	global basic_data_array
	global max_array_item
	
	set query_string ""
	
}

proc SeqExter {argv} {
	
	global sleep_time
	
	set input_file    [lindex $argv 0]
	set file_out_base [lindex $argv 1]
	set mod_value     [lindex $argv 2]
	set sleep_time    [lindex $argv 3]
	
	Set_Global_Parameters
	
	Open_Files $input_file $file_out_base
	
	Set_Intial_Time
	
	Read_Input_File $mod_value
	
	Read_StdIn_Data
	
	### Check_StdIn_Data
	
	Print_Final_Message
	
	Close_Files
	
}

proc Print_Log_Message { log_message } {
	
	global file_out0
	
	puts $log_message
	
	puts $file_out0 $log_message
	
}

proc Print_Query_Data_Log  { query_data_log } {
	
	global file_out1
	
	puts $file_out1 $query_data_log
	
}

proc Set_Intial_Time { } {

	global initial_time
	global sleep_time
	
	set initial_time [clock format [clock seconds]]
	
	set log_message "----------------------------------------------"
	Print_Log_Message $log_message
	set log_message " Initial Time:  $initial_time "
	Print_Log_Message $log_message
	set log_message "----------------------------------------------"
	Print_Log_Message $log_message
	
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
	global initial_time
	
	set l 0 
	set n 0 
	
	while {[gets $file_in_1 current_line] >= 0} {
		
		incr l
		######################################################################
		### Exception 01 - Read DNA strings only from FASTA or FASTQ files ###
		set line_exception "NO_EXCEPTION"
		set line_exception [Check_Line_for_Exception_01 $current_line]
		#######################################################################
		
		if { $line_exception == "NO_EXCEPTION" } {
			
			incr n
			
			Check_Mod_Status $l $n $mod_value
			
			Create_Basic_Data_Array $n $current_line
			
		}
	}
	set current_time [Check_Current_Time]
	set log_message " $n items processed out of $l  |  Init Time: $initial_time  Current Time: $current_time "
	Print_Log_Message $log_message
}

proc Check_Mod_Status { l n mod_value } {
	
	global initial_time
	
	set n_mod [expr fmod($n,$mod_value)]
	
	if { $n_mod == 0 } {
		set current_time [Check_Current_Time]
		set log_message " $n items processed out of $l  |  Init Time: $initial_time  Current Time: $current_time "
		Print_Log_Message $log_message
	}
	
}

proc Create_Basic_Data_Array { n current_line } {
	
	global basic_data_array
	global max_array_item
	
	set basic_data_array($n) $current_line
	set max_array_item $n
	
}

proc Read_StdIn_Data { } {
	
	global live_string
	
	puts ""
	puts " Enter Words/Commands \'Query\'\, \'Do_01\'\, \'Do_02\' or \'Exit\'\: "
	puts " Query - go to query string dialog   "
	puts " Do_01 will start string analysis 01 "
	puts " Do_02 will start string analysis 02 "
	puts " Exit will exit                      "
	puts ""
	gets stdin live_string
	
	Check_StdIn_Data
	
}

proc Check_StdIn_Data { } {
	
	global live_string
	
	while { $live_string != "Exit" && $live_string != "Do_01" && $live_string != "Do_02" && $live_string != "Query"} {
	
		puts " Ops! "
		Read_StdIn_Data
	}
	if { $live_string == "Exit" } {
		puts " Exit "
	}
	if { $live_string == "Query" } {
		puts "Query String Dialog"
		Read_Query_String
	}
	if { $live_string == "Do_01" } {
		puts "Do_01"
		Run_String_Analysis_01
	}
	if { $live_string == "Do_02" } {
		puts "Do_02"
		Run_String_Analysis_02
	}
}

proc Read_Query_String { } {

	global query_string
	set query_string ""
	
	puts ""
	puts " copy-paste or type Query String below, then press \'Enter\': "
	puts ""
	gets stdin query_string
	puts "                                 "
	puts "Query String is    $query_string "
	puts "                                 "
	puts "type   \'OK \'   -  to continue "
	puts " anything else back to dialog "
	gets stdin next_step
	while { $next_step != "OK" } {
		Read_Query_String
	}
	Read_StdIn_Data
}

proc Check_Line_for_Exception_01 { current_line } {
	
	set line_exception "NO_EXCEPTION"
	
	set first_char [string range $current_line 0 0]
	
	#### FASTA or FASTQ header ####
	if { $first_char == ">" || $first_char == "+" } {
		set line_exception "_EXCEPTION_"
	}
	#### EMPTY LINE ####
	if { $current_line == "" } {
		set line_exception "_EXCEPTION_"
	}
	return $line_exception
}

proc Run_String_Analysis_01 { } {
	
	global basic_data_array
	global max_array_item
	global query_string
	global sleep_time
	
	if { $query_string == "" } {
		Read_Query_String
	}
	
	set log_message " String Analysis 01 "
	Print_Log_Message $log_message
	
	set i 1 
	set q 0 
	while { $i <= $max_array_item } {
		set current_string $basic_data_array($i)
		set find_query [string first $query_string $current_string]
		if { $find_query != -1 } {
			incr q
			set query_data_log "$i $q $query_string $current_string $find_query"
			Print_Query_Data_Log $query_data_log
			set log_message " $q out of $i found within $max_array_item set "
			Print_Log_Message $log_message
		}
		incr i
	}
	after $sleep_time
	Read_StdIn_Data
	
}

proc Run_String_Analysis_02 { } {
	
	global basic_data_array
	global max_array_item
	global sleep_time
	
	set log_message " String Analysis 02 "
	Print_Log_Message $log_message
	
	### Comment it after implementation ###
	puts "  ... Not Implemented Yet ... "
	
	set live_string ""
	
	after $sleep_time
	Read_StdIn_Data
	
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
	
	global initial_time
	
	set current_time [Check_Current_Time]
	set log_message "                                  "
	Print_Log_Message $log_message
	set log_message " $initial_time  -  Program  Start "
	Print_Log_Message $log_message
	set log_message " $current_time  -  End of Program "
	Print_Log_Message $log_message
	set log_message "                                  "
	Print_Log_Message $log_message
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

