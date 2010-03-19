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

proc Set_Global_Parameters { query_input } {
	
	global basic_data_array		; # array with strings from input file
	global interactive_mode		; # interactive or command line query input
	global initial_time			; # program start time
	global live_string			; # inpuit stdin
	global loop_status			; # multiple or single iteration
	global max_array_item		; # size of the array with strings from input file
	global mod_value			; # delay in next step in milliseconds to read debugging messages
	global proc_id				; # procedure ID
	global query_string			; # query string
	global query_type			; # query in file or stdin
	global query_array			; # array with search results
	global sleep_time			; # time interval for debugging purpose
	global valid_commands_list	; # list of commands for interactive dialog
	global valid_commands_array	; # array of commands for interactive dialog
	global upper_case			; # convert text input data to upper case
	
	if { $query_type == "STRING"} {
		set query_string $query_input
		set query_file   "___none___"
	}
	if { $query_type == "FILE"} {
		set query_file   $query_input
		set query_string "___none___"
	}
	
	set interactive_mode "FALSE"
	if { $query_input == "_STDIN_" } {
		set interactive_mode "TRUE"
	}
	
	set upper_case "TRUE"
	# set upper_case "FALSE"
	
}

proc Set_Dialog_Commands { } {
	
	global valid_commands_list
	global valid_commands_array
	
	set valid_commands_list { "Query" "Proc_01" "Proc_02" "Exit" }
	# set valid_commands_list { "Query" "Proc_01" "Proc_02" "Proc_03" "Proc_04" "Proc_05" "Exit" }
	
	set valid_commands_array(Query)    " Input Query String "
	set valid_commands_array(Proc_01)  " Run Procedure 01 "
	set valid_commands_array(Proc_02)  " Run Procedure 02 "
	# set valid_commands_array(Proc_03)  " Run Procedure 03 "
	# set valid_commands_array(Proc_04)  " Run Procedure 04 "
	# set valid_commands_array(Proc_05)  " Run Procedure 05 "
	set valid_commands_array(Exit)     " Exit Program "
	
}

proc Run_Selected_Proc { } {
	
	global proc_id
	
	if { $proc_id == "PROC_01" } {
		Run_Proc_01
	}
	
	if { $proc_id == "PROC_02" } {
		Run_Proc_02
	}
	
}

proc SeqExter {argv} {
	
	global query_type
	global mod_value
	global sleep_time
	global proc_id
	global loop_status
	global proc_id
	global interactive_mode
	
	set input_file    [lindex $argv 0]
	set file_out_base [lindex $argv 1]
	set query_type    [lindex $argv 2]
	set query_input   [lindex $argv 3]
	set mod_value     [lindex $argv 4]
	set sleep_time    [lindex $argv 5]
	set proc_id       [lindex $argv 6]
	set loop_status   [lindex $argv 7]
	
	Set_Global_Parameters $query_input
	
	Open_Files $input_file $file_out_base
	
	Set_Intial_Time
	
	Read_Input_File
	
	if { $interactive_mode == "TRUE" } {
		Set_Dialog_Commands
		Read_StdIn_Data
	}
	
	if { $interactive_mode == "FALSE" } {
		Run_Selected_Proc
	}
	
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

proc Read_Input_File { } {
	
	global file_in_1
	global initial_time
	global mod_value
	global upper_case
	
	set l 0 
	set n 0 
	
	while {[gets $file_in_1 current_line] >= 0} {
		
		incr l
		############################################################################
		##  Exception 01 - Read DNA strings only, skipping FASTA or FASTQ headers ##
		set line_exception "NO_EXCEPTION"
		## Comment line below to read all data from input file without exceptions ##
		set line_exception [Check_Line_for_Exception_01 $current_line]
		#############################################################################
		
		if { $line_exception == "NO_EXCEPTION" } {
			
			incr n
			
			Check_Mod_Status $l $n $mod_value
			
			set current_data $current_line
			if { $upper_case == "TRUE" } {
				set current_data [string toupper $current_data]
			}
			
			Create_Basic_Data_Array $n $current_data
			
		}
	}
	set current_time [Check_Current_Time]
	set log_message "    Read Input File - Done    "
	Print_Log_Message $log_message
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

proc Create_Basic_Data_Array { n current_data } {
	
	global basic_data_array
	global max_array_item
	
	set basic_data_array($n) $current_data
	set max_array_item $n
	
}

proc Read_StdIn_Data { } {
	
	global valid_commands_list
	global valid_commands_array
	global live_string
	
	puts ""
	foreach item $valid_commands_list {
		puts "  type  $item  for  $valid_commands_array($item)  "
	}
	puts ""
	gets stdin live_string
	
	Check_StdIn_Data
	
}

proc Check_StdIn_Data { } {
	
	global valid_commands_list
	global valid_commands_array
	global live_string
	
	set is_it_valid [lsearch -exact $valid_commands_list $live_string]
	
	if { $live_string == "Exit" } {
		puts " Exit "
		Print_Final_Message
		exit
	} elseif { $live_string == "Query" } {
		puts " Query String Dialog "
		Read_Query_String
	} elseif { $live_string == "Proc_01" } {
		puts " Proc_01 "
		Run_String_Analysis_01
	} elseif { $live_string == "Proc_02" } {
		puts " Proc_02 "
		Run_String_Analysis_02
	} else {
		puts " Command not valid "
		Read_StdIn_Data
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
		break
	}
	if { $next_step == "OK" } {
		Read_StdIn_Data
		break
	}
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

proc Run_Proc_01 { } {
	Run_String_Analysis_01
}

proc Run_String_Analysis_01 { } {
	
	global interactive_mode
	global basic_data_array
	global max_array_item
	global query_string
	global sleep_time
	
	if { $query_string == "" } {
		Read_Query_String
		break
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
	
	if { $interactive_mode == "TRUE" } {
		Read_StdIn_Data
		break
	}
	
}

proc Run_Proc_01 { } {
	Run_String_Analysis_01
}

proc Run_String_Analysis_02 { } {
	
	global interactive_mode
	global basic_data_array
	global max_array_item
	global sleep_time
	
	set log_message " String Analysis 02 "
	Print_Log_Message $log_message
	
	### Comment it after implementation ###
	puts "  ... Not Implemented Yet ... "
	
	set live_string ""
	
	after $sleep_time
	
	if { $interactive_mode == "TRUE" } {
		Read_StdIn_Data
		break
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
	puts "  |    -=<*  THE  END  *>=-    |  "
	puts "  +----------------------------+  "
	puts "                                  "
	
}

if {$argc != 8} {
	puts "                                                                                      "
	puts "Program usage:                                                                        "
	puts "Input_File\[0\],  Output_File\[1\],  Query_Input_Type\[2\],  String_or_FileName\[3\], "
	puts "   Mod_Val\[4\],  Sleep_Interval\[5\],  Procedure_ID\[6\],  Number_of_Iterations\[7\] "
	puts "                                                                                      "
	puts "example to run the program in the interactive mode:                                   "
	puts "my_input   my_output   STRING   _STDIN_    10000   1000   PROC_01   LOOP_SINGLE       "
	puts "                                                                                      "
	puts "example for the single string query:                                                  "
	puts "my_input   my_output   STRING   ATGCATGC   10000   1000   PROC_01   LOOP_NESTED       "
	puts "                                                                                      "
	puts "example for multiple query strings in file:                                           "
	puts "my_input   my_output    FILE   query_file  10000   1000   PROC_01   LOOP_SINGLE       "
	puts "                                                                                      "
} else {
	set query_type [lindex $argv 2]
	if { $query_type != "STRING" && $query_type != "FILE" } {
		puts "                                               "
		puts "    Query_Input_Type must be STRING or FILE    "
		puts "                                               "
		exit
	}
	set proc_id [lindex $argv 6]
	if { $proc_id != "PROC_01" && $proc_id != "PROC_02" } {
		puts "                                               "
		puts "    Procedure_ID must be PROC_01 or PROC_02    "
		puts "                                               "
		exit
	}
	set loop_status [lindex $argv 7]
	if { $loop_status != "LOOP_SINGLE" && $loop_status != "LOOP_NESTED" } {
		puts "                                                         "
		puts " Number_of_Iterations must be LOOP_SINGLE or LOOP_NESTED "
		puts "                                                         "
		exit
	}
	
	SeqExter $argv
}

