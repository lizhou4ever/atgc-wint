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
	global dna_string_direction	; # direction of DNA string - FORWARD or REVERSE
	global interactive_mode		; # interactive or command line query input
	global initial_time			; # program start time
	global live_string			; # inpuit stdin
	global loop_status			; # multiple or single iteration
	global max_array_item		; # size of the array with strings from input file
	global max_query_item		; # size of the array with query strings
	global mod_value			; # delay in next step in milliseconds to read debugging messages
	global proc_id				; # procedure ID
	global query_file			; # file with query strings
	global query_string			; # query string
	global query_type			; # query in file or stdin
	global query_array			; # array with multiple queries form query input file
	global reverse_compl		; # reverse-complement DNA string conversion
	global sleep_time			; # time interval for debugging purpose
	global trimL_query_array	; # array with LEFT trimmed search strings
	global trimR_query_array	; # array with RIGHT trimmed search strings
	global valid_commands_list	; # list of commands for interactive dialog
	global valid_commands_array	; # array of commands for interactive dialog
	global upper_case			; # convert text input data to upper case
	
	if { $query_type == "STRING"} {
		set query_string $query_input
		set query_file   "___none___"
	}
	if { $query_type == "FILE"} {
		set query_file   $query_input
		# set query_string "___none___"
		set query_string ""
	}
	
	set interactive_mode "FALSE"
	if { $query_input == "_STDIN_" } {
		set interactive_mode "TRUE"
		set query_file   "___none___"
	}
	
	set upper_case "TRUE"
	# set upper_case "FALSE"
	
	set reverse_compl "TRUE"
	# set reverse_compl "FALSE"
	
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

proc Run_Selected_Proc_Batch { } {
	
	global proc_id
	global query_array
	global query_string
	global max_query_item
	
	set i 1 
	while { $i <= $max_query_item } {
		set query_string $query_array($i)
		if { $proc_id == "PROC_01" } {
			Run_Proc_01
		}
		
		if { $proc_id == "PROC_02" } {
			Run_Proc_02
		}
		incr i
	}
	
}

proc SeqExter {argv} {
	
	global interactive_mode
	global loop_status
	global mod_value
	global proc_id
	global query_type
	global query_file
	global sleep_time
	
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
	
	Set_Initial_Time
	
	Read_Input_File
	
	if { $interactive_mode == "TRUE" && $query_file == "___none___" } {
		Set_Dialog_Commands
		Read_StdIn_Data
	}
	
	if { $interactive_mode == "FALSE" && $query_file == "___none___" } {
		Run_Selected_Proc
	}
	
	if { $interactive_mode == "FALSE" && $query_file != "___none___" } {
		Read_Query_File
		Run_Selected_Proc_Batch
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

proc Set_Initial_Time { } {
	
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

proc Read_Query_File { } {
	
	global query_file	; # query file name
	global file_in_2	; # query file channel
	
	set file_in_2 [open $query_file  "r"]
	
	set q 0 
	while {[gets $file_in_2 current_line] >= 0} {
		incr q
		set current_query $current_line
		Create_Query_Data_Array $q $current_query
	}
	close $file_in_2
	
}

proc Create_Query_Data_Array { q current_query } {
	
	global query_array
	global max_query_item
	
	set query_array($q) $current_query
	set max_query_item $q
	
	set log_message " $q query strings processed "
	Print_Log_Message $log_message
	
}

proc Open_Files { input_file file_out_base } {
	
	global file_in_1	; # input file channel
	global file_out0	; # log file channel
	global file_out1	; # output file 1
	global file_out2	; # output file 2 - trim left alignment
	global file_out3	; # output file 3 - trim right alignment
	
	set file_name_0 $file_out_base\.Log
	set file_name_1 $file_out_base\.Search
	set file_name_2 $file_out_base\.TrimL
	set file_name_3 $file_out_base\.TrimR
	
	set file_in_1 [open $input_file  "r"]
	set file_out0 [open $file_name_0 "w"]
	set file_out1 [open $file_name_1 "w"]
	set file_out2 [open $file_name_2 "w"]
	set file_out3 [open $file_name_3 "w"]
	
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
	
	global query_string
	global reverse_compl
	global dna_string_direction
	
	if { $reverse_compl == "FALSE" } {
		set dna_string_direction "FRW"
		Run_String_Analysis_01
	}
	
	if { $reverse_compl == "TRUE" } {
		set dna_string_direction "FRW"
		Run_String_Analysis_01			; # First Round of Search - FORWARD DNA string
		set string_frw $query_string
		set string_rev_compl [Reverse_Complement_String $string_frw]
		set query_string $string_rev_compl
		set dna_string_direction "REV"
		Run_String_Analysis_01			; # Second Round of Search REVERSE DNA string
	}
	
}

proc Reverse_Complement_String { string_frw } {
	
	global sleep_time
	
	### set string_rev [string reverse $string_frw]		; # Tcl version 8.5
	
	set string_rev {}
	set i [string length $string_frw]
	while {$i > 0} {
		append string_rev [string index $string_frw [incr i -1]]
	}
	
	set string_rev_compl [string map { A T G C C G T A } $string_rev]
	
	# puts $string_frw				; # Degugging
	# puts $string_rev_compl		; # Debugging
	# after $sleep_time				; # Debugging
	return $string_rev_compl
	
}

proc Run_String_Analysis_01 { } {
	
	global dna_string_direction
	global interactive_mode
	global basic_data_array
	global max_array_item
	global query_string
	global sleep_time
	global trimL_query_array
	global trimR_query_array
	global file_out2
	global file_out3
	
	foreach key [array names trimL_query_array] { unset trimL_query_array($key) }
	foreach key [array names trimR_query_array] { unset trimR_query_array($key) }
	
	if { $query_string == "" } {
		Read_Query_String
		break
	}
	
	set current_time [Check_Current_Time]
	set log_message " START $current_time | String Analysis 01 | $dna_string_direction | $query_string "
	Print_Log_Message $log_message
	Print_Query_Data_Log $log_message
	
	set query_length [string length $query_string]
	
	set i 1 
	set q 0 
	while { $i <= $max_array_item } {
		set current_string $basic_data_array($i)
		set find_query [string first $query_string $current_string]
		if { $find_query != -1 } {
			incr q
			set current_time [Check_Current_Time]
			set id [Format_Key_Value $i]
			set query_data_log "$id $dna_string_direction $current_string $query_string $find_query $q"
			Print_Query_Data_Log $query_data_log
			set trim_left  [Get_Left_Trimmed_String  $current_string $find_query $query_length]
			set trim_right [Get_Right_Trimmed_String $current_string $find_query $query_length]
			Print_Left_Alignment  $trim_left  $id
			Print_Right_Alignment $trim_right $id
			set trimL_query_array($id) $trim_left
			set trimR_query_array($id) $trim_right
			set log_message " $q out of $i found within $max_array_item items  |  $current_time "
			Print_Log_Message $log_message
		}
		incr i
	}
	
	set current_time [Check_Current_Time]
	set log_message "  END  $current_time | String Analysis 01 | $dna_string_direction | $query_string "
	puts $file_out2 "-----------------------------------------"
	puts $file_out3 "-----------------------------------------"
	Print_Log_Message $log_message
	Print_Query_Data_Log $log_message
	after $sleep_time
	
	if { $interactive_mode == "TRUE" } {
		Read_StdIn_Data
		break
	}
	
}

proc Get_Left_Trimmed_String  { current_string query_match query_length } {
	
	global dna_string_direction
	
	### CASE 1 - FORWARD direction
	if { $dna_string_direction == "FRW" } {
		set x_pos $query_match
		set trim_left [string range $current_string $x_pos end]
	}
	
	### CASE 2 - REVERSE direction
	if { $dna_string_direction == "REV" } {
		set x_pos [expr $query_match + $query_length - 1]
		set trim_left [string range $current_string 0 $x_pos]
		set string_frw $trim_left
		set string_rev_compl [Reverse_Complement_String $string_frw]
		set trim_left $string_rev_compl
	}
	
	return $trim_left
	
}

proc Get_Right_Trimmed_String { current_string query_match query_length } {
	
	global dna_string_direction
	
	### CASE 1 - FORWARD direction
	if { $dna_string_direction == "FRW" } {
		set x_pos [expr $query_match + $query_length - 1]
		set trim_right [string range $current_string 0 $x_pos]
	}
	
	### CASE 2 - REVERSE direction
	if { $dna_string_direction == "REV" } {
		set x_pos $query_match
		set trim_right [string range $current_string $x_pos end]
		set string_frw $trim_right
		set string_rev_compl [Reverse_Complement_String $string_frw]
		set trim_right $string_rev_compl
	}
	
	return $trim_right
	
}

proc Print_Left_Alignment  { trim_left id } {
	
	global dna_string_direction
	global file_out2
	
	puts "TRIM_ALIGN_LEFT   $id\t$dna_string_direction\t$trim_left"
	puts $file_out2 "$id\t$dna_string_direction\t$trim_left"
	
}

proc Print_Right_Alignment { trim_right id } {
	
	global dna_string_direction
	global file_out3
	
	puts "TRIM_ALIGN_RIGHT $id\t$dna_string_direction\t$trim_right"
	puts $file_out3 "$id\t$dna_string_direction\t$trim_right"
	
}

proc Format_Key_Value { i } {
	
	global max_array_item
	
	set max_id_len [string length $max_array_item]
	set id $i
	set id_len [string length $id]
	while { $id_len < $max_id_len } {
		set id "0$id"
		set id_len [string length $id]
		# puts $id;			Debugging
		# puts $id_len;		Debugging
	}
	
	return $id
	
}

proc Run_Proc_02 { } {
	Run_String_Analysis_02
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
	global file_out2
	global file_out3
	
	close $file_in_1
	close $file_out0
	close $file_out1
	close $file_out2
	close $file_out3
	
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
	puts "my_input   my_output    FILE    my_query   10000   1000   PROC_01   LOOP_SINGLE       "
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

