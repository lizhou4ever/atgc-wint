#!/usr/bin/tcl

###########################################################
#                                                         #
#                        SEQEXTER                         #
#                                                         #
#                    Alexander  Kozik                     #
#                                                         #
#                Copyright   2010   2011                  #
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
# Run_String_Analysis_01 function finds all perfect       #
# matches in input file for a query, builds alignment and #
# consensus. Basically, it reads input file into memory,  #
# runs query, generates alignments. It can be used for    #
# DNA sequence walking, to build long consensus based on  #
# analysis of short DNA strings.                          #
#                                                         #
###########################################################

proc Set_Global_Parameters { query_input } {
	
	global basic_data_array		; # array with strings from input file
	global consensus_chain		; # consensus - chain summary of seeded alignment
	global dna_string_direction	; # direction of DNA string - FORWARD or REVERSE
	global interactive_mode		; # interactive or command line query input
	global initial_time			; # program start time
	global index_fasta_file		; # FASTA file with indexed IDs - TRUE or FALSE
	global live_string			; # inpuit stdin
	global loop_status			; # multiple or single iteration
	global max_align_length		; # alignment length - temporary solution
	global max_align_index		; # it is expr max_align_length - 1
	global max_array_item		; # size of the array with strings from input file
	global max_fasta_id_len		; # max FASTA ID length
	global max_query_item		; # size of the array with query strings
	global max_search_cycle		; # max number of search cycles
	global max_seqs_number		; # max number of sequences to load into memory
	global mod_value			; # delay in next step in milliseconds to read debugging messages
	global proc_id				; # procedure ID
	global query_count			; # count of processed queries
	global query_file			; # file with query strings
	global query_string			; # query string
	global query_type			; # query in file or stdin
	global query_array			; # array with multiple queries form query input file
	global reverse_compl		; # reverse-complement DNA string conversion
	global search_continue		; # search continue status - TRUE or FALSE
	global sleep_time			; # time interval for debugging purpose
	global trimL_query_array	; # array with LEFT trimmed search strings
	global trimR_query_array	; # array with RIGHT trimmed search strings
	global trimL_query_slist	; # list of arrays with strings for sorting
	global trimR_query_slist	; # list of arrays with strings for sorting
	global valid_commands_list	; # list of commands for interactive dialog
	global valid_commands_array	; # array of commands for interactive dialog
	global upper_case			; # convert text input data to upper case
	
	set upper_case "TRUE"
	# set upper_case "FALSE"
	
	set reverse_compl "TRUE"
	# set reverse_compl "FALSE"
	
	if { $query_type == "STRING"} {
		set query_string $query_input
		if { $upper_case == "TRUE" } {
			set query_string [string toupper $query_string]
		}
		set query_file   "___none___"
	}
	if { $query_type == "FILE"} {
		set query_file   $query_input
		set query_string ""
	}
	
	set interactive_mode "FALSE"
	if { $query_input == "_STDIN_" } {
		set interactive_mode "TRUE"
		set query_file   "___none___"
	}
	
	set query_count 0 
	
	set consensus_chain ""
	
	set search_continue "TRUE"
	
	set sleep_time 360 
	
	set max_search_cycle 100000			; # one hundred thousand : 100K
	
	set index_fasta_file "FALSE"
	# set index_fasta_file "TRUE"
	if { $index_fasta_file == "TRUE" } {
		set max_fasta_id_len [string length $max_seqs_number]
	}
	
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

proc Run_Nested_Search { } {
	
	global proc_id
	global max_search_cycle
	global query_string
	
	set c 1
	while { $c <= $max_search_cycle } {
		if { $proc_id == "PROC_01" } {
			Run_Proc_01
		}
		incr c
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
	global max_align_length
	global max_align_index
	global max_seqs_number
	global mod_value
	global proc_id
	global query_type
	global query_file
	global sleep_time
	
	set input_file        [lindex $argv 0]
	set file_out_base     [lindex $argv 1]
	set query_type        [lindex $argv 2]
	set query_input       [lindex $argv 3]
	set max_seqs_load     [lindex $argv 4]
	set max_align_length  [lindex $argv 5]
	set proc_id           [lindex $argv 6]
	set loop_status       [lindex $argv 7]
	
	set mod_value [expr $max_seqs_load/100]
	set max_seqs_number $max_seqs_load
	set max_align_index [expr $max_align_length - 1]
	
	Set_Global_Parameters $query_input
	
	Open_Files $input_file $file_out_base
	
	Set_Initial_Time
	
	Read_Input_File
	
	if { $interactive_mode == "TRUE" && $query_file == "___none___" } {
		Set_Dialog_Commands
		Read_StdIn_Data
	}
	
	if { $interactive_mode == "FALSE" && $query_file == "___none___" && $loop_status == "LOOP_SINGLE" } {
		Run_Selected_Proc
	}
	
	if { $interactive_mode == "FALSE" && $query_file == "___none___" && $loop_status == "LOOP_NESTED" } {
		Run_Nested_Search
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
	
}

proc Check_Current_Time { } {
	
	set current_time [clock format [clock seconds]]
	
	return $current_time
	
}

proc Read_Query_File { } {
	
	global query_file	; # query file name
	global file_in_2	; # query file channel
	
	set file_in_2 [open $query_file  "r"]
	
	set mod_q_val 100 
	
	puts "                     "
	puts "  READ  QUERY  FILE  "
	
	set q 0 
	while {[gets $file_in_2 current_line] >= 0} {
		incr q
		set current_query $current_line
		Create_Query_Data_Array $q $current_query
		Check_Mod_Status $q $q $mod_q_val
	}
	close $file_in_2
	puts "                     "
	
}

proc Create_Query_Data_Array { q current_query } {
	
	global query_array
	global max_query_item
	
	set query_array($q) $current_query
	set max_query_item $q
	
}

proc Open_Files { input_file file_out_base } {
	
	global proc_id
	global index_fasta_file
	
	global file_in_1	; # input file channel
	global file_out0	; # log file channel
	global file_out1	; # output file 1
	global file_out2	; # output file 2 - trim left alignment
	global file_out3	; # output file 3 - trim right alignment
	global file_out4	; # output file 4 - summary per query
	global file_out5	; # output file 5 - alignment data per iteration
	global file_out6	; # output file 6 - assembled consensus
	global file_out7	; # output file 7 - aligned tails on both sides of the extensions
	global file_out8	; # output file 8 - tab-delimited file with tail extensions
	global file_out9	; # indexed FASTA file
	
	set file_name_0 $file_out_base\.Log
	set file_name_1 $file_out_base\.Search
	set file_name_2 $file_out_base\.TrimL
	set file_name_3 $file_out_base\.TrimR
	set file_name_4 $file_out_base\.Summary
	set file_name_5 $file_out_base\.UniSeqs
	set file_name_6 $file_out_base\.Xassy
	set file_name_7 $file_out_base\.Tails
	set file_name_8 $file_out_base\.Tails\.tab
	
	set file_in_1 [open $input_file  "r"]
	set file_out0 [open $file_name_0 "w"]
	set file_out1 [open $file_name_1 "w"]
	set file_out2 [open $file_name_2 "w"]
	set file_out3 [open $file_name_3 "w"]
	set file_out4 [open $file_name_4 "w"]
	set file_out5 [open $file_name_5 "w"]
	set file_out6 [open $file_name_6 "w"]
	set file_out7 [open $file_name_7 "w"]
	set file_out8 [open $file_name_8 "w"]
	
	if { $index_fasta_file == "TRUE" } {
		set file_name_9 $file_out_base\.Index\.fa
		set file_out9 [open $file_name_9 "w"]
	}
	
}

proc Read_Input_File { } {
	
	global file_in_1
	global initial_time
	global mod_value
	global upper_case
	global max_seqs_number
	global index_fasta_file
	
	set l 0 
	set n 0 
	
	while {[gets $file_in_1 current_line] >= 0 && $n <= $max_seqs_number} {
		
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
			
			if { $index_fasta_file == "TRUE" } {
				Fasta_Indexed_File $n $current_data
			}
			
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
		Run_Proc_01
		Read_StdIn_Data
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
	
	global consensus_array_Count
	global consensus_array_TrimL	; # array of trimmed strings to generate consensus
	global consensus_array_TrimR
	global consensus_slist_TrimL	; # super-list of array items
	global consensus_slist_TrimR
	global consensus_chain
	global loop_status
	global query_count
	global query_string
	global reverse_compl
	global dna_string_direction
	
	### unset results of previous search for each array key
	set consensus_array_Count 0 
	foreach key [array names consensus_array_TrimL] { unset consensus_array_TrimL($key) }
	foreach key [array names consensus_array_TrimR] { unset consensus_array_TrimR($key) }
	set consensus_slist_TrimL { }
	set consensus_slist_TrimR { }
	
	if { $reverse_compl == "FALSE" } {
		incr query_count
		set dna_string_direction "FRW"
		if { $query_count == 1 } {
			set consensus_chain $query_string
		}
		Run_String_Analysis_01
	}
	
	if { $reverse_compl == "TRUE" } {
		incr query_count
		set dna_string_direction "FRW"
		if { $query_count == 1 } {
			set consensus_chain $query_string
		}
		Run_String_Analysis_01			; # First Round of Search - FORWARD DNA string
		set string_frw $query_string
		set string_rev_compl [Reverse_Complement_String $string_frw]
		set query_string $string_rev_compl
		set dna_string_direction "REV"
		Run_String_Analysis_01			; # Second Round of Search REVERSE DNA string
	}
	
	### COUNT ALL MATCHES - FORWARD and REVERSE ###
	set query_length [string length $query_string]
	set dummy_dash [string repeat "-" $query_length]
	set query_summary_log "$query_count\tALL\t$dummy_dash\t$consensus_array_Count"
	Print_Query_Sumary $query_summary_log
	
	Process_Consensus $query_length
	
	if { $loop_status == "LOOP_NESTED" } {
		Start_New_Seqexter_Loop
	}
}

proc Start_New_Seqexter_Loop { } {

	global query_string
	global new_seqs_key

	if { $new_seqs_key != "NO_NEW_KEY_FOUND" && $new_seqs_key != "DUPLICATION_FOUND" } {
		set query_string $new_seqs_key
	}
	if { $new_seqs_key == "NO_NEW_KEY_FOUND" || $new_seqs_key == "DUPLICATION_FOUND" } {
		New_Key_Loop_Terminator
	}
}

proc New_Key_Loop_Terminator { } {
	puts " ... EXIT ... "
	exit
}

proc Print_Alignment_Data_in_File { current_consensus_L current_consensus_R query_index_string query_length } {
	
	global file_out5
	global file_out6
	global file_out7
	global file_out8
	global max_array_item
	global max_align_length
	global atgc_Consensus
	global atgc_Quality
	global consensus_slist_TrimL
	global consensus_slist_TrimR
	
	### KEY HIGHLIGHT IN ALIGNMENT ###
	set key_start_pos [expr $max_align_length - $query_length -1]
	
	set dummy_id_len  [string length $max_array_item]
	set dummy_id      [string repeat "." $dummy_id_len]
	set dummy_star    [string repeat "*" $dummy_id_len]
	set dummy_cons    [string repeat "#" $dummy_id_len]
	set dummy_seqs    [string repeat "*" $max_align_length]
	set dummy_seqs_T  [string range $dummy_seqs 0 $key_start_pos]
	set dummy_key     [string repeat "^" $query_length]
	
	### ONLY LEFT-TRIM ALIGNMENT IS USED FOR SEQUENCE WALKING ###
	puts "   LEFT-TRIM ALIGNMENT   "
	foreach item $consensus_slist_TrimL {
		puts $file_out5 $item
		puts $item
	}
	
	set fract_A_string_L [lindex $current_consensus_L 0]
	set fract_T_string_L [lindex $current_consensus_L 1]
	set fract_G_string_L [lindex $current_consensus_L 2]
	set fract_C_string_L [lindex $current_consensus_L 3]
	set fract_N_string_L [lindex $current_consensus_L 4]
	set all_ATGC_count_L [lindex $current_consensus_L 5]
	set atgc_Consensus_L [lindex $current_consensus_L 6]
	set atgc_Quality_L   [lindex $current_consensus_L 7]
	
	#####  FOR CONSENSUS EXTENSION #####
	set atgc_Consensus $atgc_Consensus_L
	set atgc_Quality $atgc_Quality_L
	####################################
	
	set data_A_  "$dummy_id\t_A_\t$fract_A_string_L\t$query_index_string" 
	set data_T_  "$dummy_id\t_T_\t$fract_T_string_L\t$query_index_string" 
	set data_G_  "$dummy_id\t_G_\t$fract_G_string_L\t$query_index_string" 
	set data_C_  "$dummy_id\t_C_\t$fract_C_string_L\t$query_index_string" 
	set data_N_  "$dummy_id\t_N_\t$fract_N_string_L\t$query_index_string" 
	set data_all "$dummy_id\tALL\t$all_ATGC_count_L\t$query_index_string" 
	set data_S_  "$dummy_star\t***\t$dummy_key$dummy_seqs_T\t$query_index_string"
	set data_con "$dummy_cons\tCNS\t$atgc_Consensus_L\t$query_index_string"
	set data_Q_  "$dummy_cons\tQLT\t$atgc_Quality_L\t$query_index_string"
	
	puts  $data_A_
	puts  $data_T_
	puts  $data_G_
	puts  $data_C_
	puts  $data_N_
	puts  data_all
	puts  $data_S_
	puts  $data_con
	puts  $data_Q_
	
	puts $file_out5 $data_A_
	puts $file_out5 $data_T_
	puts $file_out5 $data_G_
	puts $file_out5 $data_C_
	puts $file_out5 $data_N_
	puts $file_out5 $data_all
	puts $file_out5 $data_S_
	puts $file_out5 $data_con
	puts $file_out5 $data_Q_
	puts $file_out5 ""
	puts $file_out5 ""
	
	puts $file_out6 $data_A_
	puts $file_out6 $data_T_
	puts $file_out6 $data_G_
	puts $file_out6 $data_C_
	puts $file_out6 $data_N_
	puts $file_out6 $data_all
	puts $file_out6 $data_S_
	puts $file_out6 $data_con
	puts $file_out6 $data_Q_
	puts $file_out6 ""
	puts $file_out6 ""
	
	set fract_A_string_R [lindex $current_consensus_R 0]
	set fract_T_string_R [lindex $current_consensus_R 1]
	set fract_G_string_R [lindex $current_consensus_R 2]
	set fract_C_string_R [lindex $current_consensus_R 3]
	set fract_N_string_R [lindex $current_consensus_R 4]
	set all_ATGC_count_R [lindex $current_consensus_R 5]
	set atgc_Consensus_R [lindex $current_consensus_R 6]
	set atgc_Quality_R   [lindex $current_consensus_R 7]
	
	set fract_A_string_T [string range $fract_A_string_R 0 $key_start_pos]
	set fract_T_string_T [string range $fract_T_string_R 0 $key_start_pos]
	set fract_G_string_T [string range $fract_G_string_R 0 $key_start_pos]
	set fract_C_string_T [string range $fract_C_string_R 0 $key_start_pos]
	set fract_N_string_T [string range $fract_N_string_R 0 $key_start_pos]
	set all_ATGC_count_T [string range $all_ATGC_count_R 0 $key_start_pos]
	set atgc_Consensus_T [string range $atgc_Consensus_R 0 $key_start_pos]
	set atgc_Quality_T   [string range $atgc_Quality_R   0 $key_start_pos]
	
	set tdata_A_  "$dummy_id\t_A_\t$fract_A_string_T$fract_A_string_L\t$query_index_string" 
	set tdata_T_  "$dummy_id\t_T_\t$fract_T_string_T$fract_T_string_L\t$query_index_string" 
	set tdata_G_  "$dummy_id\t_G_\t$fract_G_string_T$fract_G_string_L\t$query_index_string" 
	set tdata_C_  "$dummy_id\t_C_\t$fract_C_string_T$fract_C_string_L\t$query_index_string" 
	set tdata_N_  "$dummy_id\t_N_\t$fract_N_string_T$fract_N_string_L\t$query_index_string" 
	set tdata_all "$dummy_id\tALL\t$all_ATGC_count_T$all_ATGC_count_L\t$query_index_string" 
	set tdata_S_  "$dummy_star\t***\t$dummy_seqs_T$dummy_key$dummy_seqs_T\t$query_index_string"
	set tdata_con "$dummy_cons\tCNS\t$atgc_Consensus_T$atgc_Consensus_L\t$query_index_string"
	set tdata_Q_  "$dummy_cons\tQLT\t$atgc_Quality_T$atgc_Quality_L\t$query_index_string"
	
	puts $file_out7 $tdata_A_
	puts $file_out7 $tdata_T_
	puts $file_out7 $tdata_G_
	puts $file_out7 $tdata_C_
	puts $file_out7 $tdata_N_
	puts $file_out7 $tdata_all
	puts $file_out7 $tdata_S_
	puts $file_out7 $tdata_con
	puts $file_out7 $tdata_Q_
	puts $file_out7 ""
	puts $file_out7 ""
	
	puts -nonewline $file_out8 "$query_index_string\t"
	puts -nonewline $file_out8 "$atgc_Consensus_T$atgc_Consensus_L\t"
	puts $file_out8             $atgc_Quality_T$atgc_Quality_L
	
}

proc Fine_Quality_Trimming { plus_quality_string } {

	# regsub -all {\?.*} $plus_quality_string "" plus_quality_string	; # WEAK CONDITION
	regsub -all {\?\?.*} $plus_quality_string "" plus_quality_string
	# regsub -all {\!.*} $plus_quality_string "" plus_quality_string	; # MEDIUM CONDITION
	# regsub -all {\!\!.*} $plus_quality_string "" plus_quality_string
	regsub -all {\!\!\!.*} $plus_quality_string "" plus_quality_string
	# regsub -all {\@.*} $plus_quality_string "" plus_quality_string
	regsub -all {\?\!\!.*} $plus_quality_string "" plus_quality_string
	regsub -all {\!\?\!.*} $plus_quality_string "" plus_quality_string
	regsub -all {\!\!\?.*} $plus_quality_string "" plus_quality_string
	regsub -all {\?\!\?.*} $plus_quality_string "" plus_quality_string
	return $plus_quality_string
	
}

proc Process_Consensus { query_length } {
	
	global consensus_chain
	global dna_string_direction
	global file_out5
	global file_out6
	global consensus_slist_TrimL
	global consensus_slist_TrimR
	global query_count
	global query_string
	global new_seqs_key
	global upper_case
	global loop_status
	global reverse_compl
	global atgc_Consensus
	global atgc_Quality
	
	set query_index_string "__$query_count\__"
	
	##  SORT ITEMS IN LEFT-TRIM AND RIGHT-TRIM ALIGNMENTS ##
	set consensus_slist_TrimL [lsort $consensus_slist_TrimL]
	set consensus_slist_TrimR [lsort $consensus_slist_TrimR]
	
	set current_consensus_L [Alignment_Analysis $consensus_slist_TrimL $query_length]
	set current_consensus_R [Alignment_Analysis $consensus_slist_TrimR $query_length]
	
	Print_Alignment_Data_in_File $current_consensus_L $current_consensus_R $query_index_string $query_length
	
	puts "                   "
	puts "    *CONSENSUS*    "
	puts "                   "
	
	#####################################################################################
	######################## TRIMMING VARIATIONS  START #################################
	### TRIMMING FOR LOW QUALITY REGION SHOULD BE ADJUSTED FOR ANY PARTICULAR PROJECT ###
	######          OBLIGATORY  TRIMMING  OF  REGIONS  WITH  NO  DATA              ######
	regsub -all {\..*} $atgc_Quality "" plus_quality_string
	regsub -all {\-.*} $plus_quality_string "" plus_quality_string
	######     FINE TRIMMING - SEE DETAILS IN Fine_Quality_Trimming PROCEDURE      ######
	set plus_quality_string [Fine_Quality_Trimming $plus_quality_string]
	######################## END OF TRIMMING VARIATIONS #################################
	#####################################################################################
	
	### NEW SEQEXTER KEY ###
	set old_key_len [string length $query_string]
	set plus_quality_length [string length $plus_quality_string]
	if { $loop_status == "LOOP_NESTED" } {
		### NEW KEY IS LONGER THAN OLD KEY ###
		if { $plus_quality_length > $old_key_len } {
			### DEFINE NEW KEY ###
			set key_start [expr $plus_quality_length - $old_key_len]
			set key_end [expr $plus_quality_length - 1]
			set new_seqs_key [string range $atgc_Consensus $key_start $key_end]
			if { $upper_case == "TRUE" } {
				set new_seqs_key [string toupper $new_seqs_key]
			}
			### CONSENSUS APPEND ###
			set cons_ext_start [expr $old_key_len - 0]
			set cons_ext_end [expr $plus_quality_length - 1]
			set new_ext_tail [string range $atgc_Consensus $cons_ext_start $cons_ext_end]
			set consensus_chain "$consensus_chain$new_ext_tail"
			set consensus_chain [string toupper $consensus_chain]
			set consensus_chain_length [string length $consensus_chain]
			set consensus_chain_gain [string length $new_ext_tail]
			### PRINT DATA IN FILE ###
			puts $file_out6 "                        "
			puts $file_out6 ">CONSENSUS$query_index_string  Length: $consensus_chain_length \[gain: $consensus_chain_gain\] "
			puts $file_out6 $consensus_chain
			puts $file_out6 "                        "
			### PRINT DATA ON SCREEN ###
			puts "                        "
			puts ">CONSENSUS$query_index_string  Length: $consensus_chain_length \[gain: $consensus_chain_gain\] "
			puts $consensus_chain
			puts "                        "
			### TEST FOR DUPLICATIONS / REPEATS ###
			set find_duplication_f [string first $new_seqs_key $consensus_chain]
			set find_duplication_l [string last  $new_seqs_key $consensus_chain]
			
			if { $find_duplication_f != $find_duplication_l } {
				set new_seqs_key "DUPLICATION_FOUND"
			}
		}
		### NEW KEY IS SHORT TO CONTINUE EXTENSION ###
		if { $plus_quality_length <= $old_key_len } {
			set new_seqs_key "NO_NEW_KEY_FOUND"
		}
		
		puts "     *NEW KEY*     "
		puts $new_seqs_key
		puts "                   "
		
		set old_key_string_frw $query_string
		if { $reverse_compl == "TRUE" } {
			set old_key_string_frw [Reverse_Complement_String $query_string]
		}
		
		puts $file_out6 "                        "
		puts $file_out6 "OLD KEY:   $old_key_string_frw"
		puts $file_out6 "NEW KEY:   $new_seqs_key"
		puts $file_out6 "                        "
	}
}

proc Alignment_Analysis { current_alignment query_length } {
	
	global max_align_length
	global consensus_array_Count
	
	####################    DEPTH CUTOFF VALUES    #################
	# FLEXIBLE PARAMETERS - CAN BE ADJUSTED FOR PARTICULAR PROJECT #
	set depth_cut_050 10
	set depth_cut_060 10
	set depth_cut_070 10
	set depth_cut_080  3
	set depth_cut_100  3
	
	### SET ZERO VALUES FOR ALL ALIGNMENT POSITIONS ###
	set p 0 		; # position on the alignment
	while { $p < $max_align_length } {
		set count_A_items($p) 0 
		set count_T_items($p) 0 
		set count_G_items($p) 0 
		set count_C_items($p) 0 
		set count_N_items($p) 0 
		set count_all_chr($p) 0 
		incr p
	}
	
	set s 0 
	while { $s < $consensus_array_Count } {
		set current_data [lindex $current_alignment $s]
		set current_seqs [lindex [split $current_data "\t"] 2]
		set p 0 
		while { $p < $max_align_length } {
			set current_item [string index $current_seqs $p]
			if { $current_item == "A" } {
				incr count_A_items($p)
				incr count_all_chr($p)
			}
			if { $current_item == "T" } {
				incr count_T_items($p)
				incr count_all_chr($p)
			}
			if { $current_item == "G" } {
				incr count_G_items($p)
				incr count_all_chr($p)
			}
			if { $current_item == "C" } {
				incr count_C_items($p)
				incr count_all_chr($p)
			}
			if { $current_item != "A" && $current_item != "T" && $current_item != "G" && $current_item != "C" && $current_item != "-"} {
				incr count_N_items($p)
				incr count_all_chr($p)
				puts " WARNING:  non-ATGC CHAR WAS FOUND !!! "
			}
			incr p
		}
		incr s
	}
	
	set string_A_fract {}
	set string_T_fract {}
	set string_G_fract {}
	set string_C_fract {}
	set string_N_fract {}
	set string_all_num {}
	set consensus_atgc {}
	set consensus_qual {}
	
	set p 0 
	while { $p < $max_align_length } {
		if { $count_all_chr($p) == 0 } {
			set fract_A "-"
			set fract_T "-"
			set fract_G "-"
			set fract_C "-"
			set fract_N "-"
			set all_num "-"
			set cons_ch "-"		; # CONSENSUS CHAR
			set cons_ql "."		; # CONSENSUS QUAL
		}
		if { $count_all_chr($p) > 0 } {
			set fract_A [expr round(($count_A_items($p))*10.0/$count_all_chr($p))]
			set fract_T [expr round(($count_T_items($p))*10.0/$count_all_chr($p))]
			set fract_G [expr round(($count_G_items($p))*10.0/$count_all_chr($p))]
			set fract_C [expr round(($count_C_items($p))*10.0/$count_all_chr($p))]
			set fract_N [expr round(($count_N_items($p))*10.0/$count_all_chr($p))]
			set cons_ch "n"
			set cons_ql "-"
			
			### CONSENSUS BY FRACTION ###
			if { $fract_A >= 5 } {
				set cons_ch "a"
			}
			if { $fract_T >= 5 } {
				set cons_ch "t"
			}
			if { $fract_G >= 5 } {
				set cons_ch "g"
			}
			if { $fract_C >= 5 } {
				set cons_ch "c"
			}
			
			####### CONSENSUS QUALITY ######
			
			### MAYBE 50% AND HIGHER ###
			if { $fract_A >= 5 && $count_all_chr($p) >= $depth_cut_050 } {
				set cons_ql "?"
			}
			if { $fract_T >= 5 && $count_all_chr($p) >= $depth_cut_050 } {
				set cons_ql "?"
			}
			if { $fract_G >= 5 && $count_all_chr($p) >= $depth_cut_050 } {
				set cons_ql "?"
			}
			if { $fract_C >= 5 && $count_all_chr($p) >= $depth_cut_050 } {
				set cons_ql "?"
			}
			
			### WEAK 60% AND HIGHER ###
			if { $fract_A >= 6 && $count_all_chr($p) >= $depth_cut_060 } {
				set cons_ql "!"
			}
			if { $fract_T >= 6 && $count_all_chr($p) >= $depth_cut_060 } {
				set cons_ql "!"
			}
			if { $fract_G >= 6 && $count_all_chr($p) >= $depth_cut_060 } {
				set cons_ql "!"
			}
			if { $fract_C >= 6 && $count_all_chr($p) >= $depth_cut_060 } {
				set cons_ql "!"
			}
			
			### MEDIUM 70% AND HIGHER ###
			if { $fract_A >= 7 && $count_all_chr($p) >= $depth_cut_070 } {
				set cons_ql "@"
			}
			if { $fract_T >= 7 && $count_all_chr($p) >= $depth_cut_070 } {
				set cons_ql "@"
			}
			if { $fract_G >= 7 && $count_all_chr($p) >= $depth_cut_070 } {
				set cons_ql "@"
			}
			if { $fract_C >= 7 && $count_all_chr($p) >= $depth_cut_070 } {
				set cons_ql "@"
			}
			
			### STRINGENT 80% AND HIGHER ###
			if { $fract_A >= 8 && $count_all_chr($p) >= $depth_cut_080 } {
				set cons_ql "+"
			}
			if { $fract_T >= 8 && $count_all_chr($p) >= $depth_cut_080 } {
				set cons_ql "+"
			}
			if { $fract_G >= 8 && $count_all_chr($p) >= $depth_cut_080 } {
				set cons_ql "+"
			}
			if { $fract_C >= 8 && $count_all_chr($p) >= $depth_cut_080 } {
				set cons_ql "+"
			}
			
			######## CONFIDENT 100% ########
			if { $fract_A == 10 && $count_all_chr($p) >= $depth_cut_100 } {
				set cons_ql "X"
			}
			if { $fract_T == 10 && $count_all_chr($p) >= $depth_cut_100 } {
				set cons_ql "X"
			}
			if { $fract_G == 10 && $count_all_chr($p) >= $depth_cut_100 } {
				set cons_ql "X"
			}
			if { $fract_C == 10 && $count_all_chr($p) >= $depth_cut_100 } {
				set cons_ql "X"
			}
			
			### ABSOLUTE DOMINATION ###
			if { $fract_A == 10 } {
				set fract_A "X"
				set cons_ch "A"
			}
			if { $fract_T == 10 } {
				set fract_T "X"
				set cons_ch "T"
			}
			if { $fract_G == 10 } {
				set fract_G "X"
				set cons_ch "G"
			}
			if { $fract_C == 10 } {
				set fract_C "X"
				set cons_ch "C"
			}
			
			### COUNT ALL A T G C CHARS ###
			set all_num $count_all_chr($p)
			### REPRESENT LARGE NUMBERS BY ONE LETTER CODE ###
			if { $count_all_chr($p) >= 10 } {
				set all_num "a"
			}
			if { $count_all_chr($p) >= 20 } {
				set all_num "b"
			}
			if { $count_all_chr($p) >= 30 } {
				set all_num "c"
			}
			if { $count_all_chr($p) >= 40 } {
				set all_num "d"
			}
			if { $count_all_chr($p) >= 50 } {
				set all_num "e"
			}
			if { $count_all_chr($p) >= 60 } {
				set all_num "f"
			}
			if { $count_all_chr($p) >= 70 } {
				set all_num "g"
			}
			if { $count_all_chr($p) >= 80 } {
				set all_num "h"
			}
			if { $count_all_chr($p) >= 90 } {
				set all_num "i"
			}
			if { $count_all_chr($p) >= 100 } {
				set all_num "j"
			}
			if { $count_all_chr($p) >= 120 } {
				set all_num "k"
			}
			if { $count_all_chr($p) >= 140 } {
				set all_num "l"
			}
			if { $count_all_chr($p) >= 160 } {
				set all_num "m"
			}
			if { $count_all_chr($p) >= 180 } {
				set all_num "n"
			}
			if { $count_all_chr($p) >= 200 } {
				set all_num "o"
			}
			if { $count_all_chr($p) >= 300 } {
				set all_num "p"
			}
			if { $count_all_chr($p) >= 400 } {
				set all_num "q"
			}
			if { $count_all_chr($p) >= 500 } {
				set all_num "r"
			}
			if { $count_all_chr($p) >= 600 } {
				set all_num "s"
			}
			if { $count_all_chr($p) >= 700 } {
				set all_num "t"
			}
			if { $count_all_chr($p) >= 800 } {
				set all_num "u"
			}
			if { $count_all_chr($p) >= 900 } {
				set all_num "v"
			}
			if { $count_all_chr($p) >= 1000 } {
				set all_num "w"
			}
			if { $count_all_chr($p) >= 2000 } {
				set all_num "O"
			}
			if { $count_all_chr($p) >= 3000 } {
				set all_num "P"
			}
			if { $count_all_chr($p) >= 4000 } {
				set all_num "Q"
			}
			if { $count_all_chr($p) >= 5000 } {
				set all_num "R"
			}
			if { $count_all_chr($p) >= 6000 } {
				set all_num "S"
			}
			if { $count_all_chr($p) >= 7000 } {
				set all_num "T"
			}
			if { $count_all_chr($p) >= 8000 } {
				set all_num "U"
			}
			if { $count_all_chr($p) >= 9000 } {
				set all_num "V"
			}
			if { $count_all_chr($p) >= 10000 } {
				set all_num "W"
			}
			if { $count_all_chr($p) >= 30000 } {
				set all_num "X"
			}
			if { $count_all_chr($p) >= 60000 } {
				set all_num "Y"
			}
			if { $count_all_chr($p) >= 100000 } {
				set all_num "Z"
			}
		}
		append string_A_fract $fract_A
		append string_T_fract $fract_T
		append string_G_fract $fract_G
		append string_C_fract $fract_C
		append string_N_fract $fract_N
		append string_all_num $all_num
		append consensus_atgc $cons_ch
		append consensus_qual $cons_ql
		incr p
	}
	
	set list_of_ATGC_fractions {}
	set list_of_ATGC_fractions [lappend list_of_ATGC_fractions $string_A_fract]
	set list_of_ATGC_fractions [lappend list_of_ATGC_fractions $string_T_fract]
	set list_of_ATGC_fractions [lappend list_of_ATGC_fractions $string_G_fract]
	set list_of_ATGC_fractions [lappend list_of_ATGC_fractions $string_C_fract]
	set list_of_ATGC_fractions [lappend list_of_ATGC_fractions $string_N_fract]
	set list_of_ATGC_fractions [lappend list_of_ATGC_fractions $string_all_num]
	set list_of_ATGC_fractions [lappend list_of_ATGC_fractions $consensus_atgc]
	set list_of_ATGC_fractions [lappend list_of_ATGC_fractions $consensus_qual]
	
	set current_consensus_X $list_of_ATGC_fractions
	return $current_consensus_X
	
}

proc Reverse_Complement_String { string_frw } {
	
	global sleep_time
	
	### set string_rev [string reverse $string_frw]		; # Tcl version 8.5
	
	set string_rev {}
	set i [string length $string_frw]
	while { $i > 0 } {
		append string_rev [string index $string_frw [incr i -1]]
	}
	
	set string_rev_compl [string map { A T G C C G T A } $string_rev]
	return $string_rev_compl
	
}

proc Run_String_Analysis_01 { } {
	
	global dna_string_direction
	global interactive_mode
	global basic_data_array
	global max_array_item
	global query_count
	global query_string
	global sleep_time
	global trimL_query_array
	global trimR_query_array
	global trimL_query_slist
	global trimR_query_slist
	global consensus_array_Count
	global consensus_array_TrimL
	global consensus_array_TrimR
	global consensus_slist_TrimL
	global consensus_slist_TrimR
	
	### UNSET ALL RESULTS OF PREVIOUS SEARCH ###
	foreach key [array names trimL_query_array] { unset trimL_query_array($key) }
	foreach key [array names trimR_query_array] { unset trimR_query_array($key) }
	set trimL_query_slist {}
	set trimR_query_slist {}
	
	### IF QUERY STRING IS EMPTY THEN ASK FOR INPUT ###
	if { $query_string == "" && $interactive_mode == "TRUE" } {
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
			incr consensus_array_Count
			set current_time [Check_Current_Time]
			set id [Format_Key_Value $i]
			set query_data_log "$id $dna_string_direction $current_string $query_string $find_query $q"
			Print_Query_Data_Log $query_data_log
			### TRIMMING TO THE START or END OF THE QUERY STRING ###
			set trim_left  [Get_Left_Trimmed_String  $current_string $find_query $query_length]
			set trim_right [Get_Right_Trimmed_String $current_string $find_query $query_length]
			### ALIGNMENT DATA STRING ###
			set query_index_string "__$query_count\__"
			set aln_string_l "$id\t$dna_string_direction\t$trim_left\t$query_index_string"
			set aln_string_r "$id\t$dna_string_direction\t$trim_right\t$query_index_string"
			### TRIMMED ALIGNMENT ARRAY ###
			set trimL_query_array($id) $aln_string_l
			set trimR_query_array($id) $aln_string_r
			set trimL_query_slist [lappend trimL_query_slist $trimL_query_array($id)]
			set trimR_query_slist [lappend trimR_query_slist $trimR_query_array($id)]
			### CONSENSUS ARRAY ###
			set consensus_array_TrimL($consensus_array_Count) $aln_string_l
			set consensus_array_TrimR($consensus_array_Count) $aln_string_r
			set consensus_slist_TrimL [lappend consensus_slist_TrimL $consensus_array_TrimL($consensus_array_Count)]
			set consensus_slist_TrimR [lappend consensus_slist_TrimR $consensus_array_TrimR($consensus_array_Count)]
			### LOG MESSAGE ###
			set log_message " $q out of $i found within $max_array_item items  |  $current_time "
			Print_Log_Message $log_message
		}
		incr i
	}
	
	Print_Left_Alignment  $q
	Print_Right_Alignment $q
	
	set query_summary_log "$query_count\t$dna_string_direction\t$query_string\t$q"
	Print_Query_Sumary $query_summary_log
	
	set current_time [Check_Current_Time]
	set log_message "  END  $current_time | String Analysis 01 | $dna_string_direction | $query_string "
	Print_Log_Message $log_message
	Print_Query_Data_Log $log_message
	
}

proc Print_Query_Sumary { query_summary_log } {
	
	global file_out4
	puts $file_out4 $query_summary_log
	
}

proc Get_Left_Trimmed_String  { current_string query_match query_length } {
	
	global dna_string_direction
	global max_align_length
	global max_align_index
	
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
	
	set left_length [string length $trim_left]
	while { $left_length < $max_align_length } {
		set trim_left "$trim_left\-"
		set left_length [string length $trim_left]
	}
	
	### LIMIT ALIGNMENT LENGTH TO MAX FIXED VALUE ###
	set trim_left [string range $trim_left 0 $max_align_index]
	return $trim_left
	
}

proc Get_Right_Trimmed_String { current_string query_match query_length } {
	
	global dna_string_direction
	global max_align_length
	global max_align_index
	
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
	
	set right_length [string length $trim_right]
	while { $right_length < $max_align_length } {
		set trim_right "\-$trim_right"
		set right_length [string length $trim_right]
	}
	
	set trim_right [string range $trim_right [expr $right_length - $max_align_index - 1] end]
	return $trim_right
	
}

proc Print_Left_Alignment  { q } {
	
	global trimL_query_slist
	global file_out2
	
	set trimL_query_slist [lsort $trimL_query_slist]
	foreach item $trimL_query_slist {
		puts $file_out2 $item
	}
	
	puts $file_out2 "************************************************"
	
}

proc Print_Right_Alignment { q } {
	
	global trimR_query_slist
	global file_out3
	
	set trimR_query_slist [lsort $trimR_query_slist]
	foreach item $trimR_query_slist {
		puts $file_out3 $item
	}
	
	puts $file_out3 "************************************************"
	
}

proc Fasta_Indexed_File { n current_data } {
	
	global file_out9
	global max_fasta_id_len
	
	set id $n
	set id_len [string length $id]
	while { $id_len < $max_fasta_id_len } {
		set id "0$id"
		set id_len [string length $id]
	}
	
	puts $file_out9 ">$id "
	puts $file_out9 $current_data
	
	
}

proc Format_Key_Value { i } {
	
	global max_array_item
	
	set max_id_len [string length $max_array_item]
	set id $i
	set id_len [string length $id]
	while { $id_len < $max_id_len } {
		set id "0$id"
		set id_len [string length $id]
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
	global file_out4
	global file_out5
	global file_out6
	global file_out7
	global file_out8
	global file_out9
	
	global index_fasta_file
	
	close $file_in_1
	close $file_out0
	close $file_out1
	close $file_out2
	close $file_out3
	close $file_out4
	close $file_out5
	close $file_out6
	close $file_out7
	close $file_out8
	
	if { $index_fasta_file == "TRUE" } {
		close $file_out9
	}
	
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
	puts " Max_Seqs_Load\[4\],  Align_Len\[5\],  Procedure_ID\[6\],  Number_of_Iterations\[7\]  "
	puts "                                                                                      "
	puts "example to run the program in the interactive mode:                                   "
	puts " my_input   my_output   STRING   _STDIN_   12000000  120    PROC_01   LOOP_SINGLE     "
	puts "                                                                                      "
	puts "example for the single string query:                                                  "
	puts " my_input   my_output   STRING   ATGCATGC  12000000  120    PROC_01   LOOP_NESTED     "
	puts "                                                                                      "
	puts "example for multiple query strings in file:                                           "
	puts " my_input   my_output    FILE    my_query  12000000  120    PROC_01   LOOP_SINGLE     "
	puts "                                                                                      "
} else {
	set query_type [lindex $argv 2]
	if { $query_type != "STRING" && $query_type != "FILE" } {
		puts "                                               "
		puts "    Query_Input_Type must be STRING or FILE    "
		puts "                                               "
		exit
	}
	set max_seqs_load [lindex $argv 4]
	set seq_mod [expr fmod($max_seqs_load, 100)]
	if { $seq_mod != 0 } {
		puts "                                                             "
		puts " Max Number of Sequences to process must be divisible by 100 "
		puts "                                                             "
		exit
	}
	set max_align_length [lindex $argv 5]
	if { $max_align_length < 40 || $max_align_length > 10000 } {
		puts "                                               "
		puts "  Max_Align_Length must be within 40 - 10000   "
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

