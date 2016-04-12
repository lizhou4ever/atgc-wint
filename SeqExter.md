#SeqExter - DNA string search and alignment

## SeqExter Usage ##

```
Program usage:

Program usage:
Input_File[0],  Output_File[1],  Query_Input_Type[2],  String_or_FileName[3],
 Max_Seqs_Load[4],  Align_Len[5],  Procedure_ID[6],  Number_of_Iterations[7]

example to run the program in the interactive mode:
 my_input   my_output   STRING   _STDIN_   12000000  120    PROC_01   LOOP_SINGLE

example for the single string query:
 my_input   my_output   STRING   ATGCATGC  12000000  120    PROC_01   LOOP_NESTED

example for multiple query strings in file:
 my_input   my_output    FILE    my_query  12000000  120    PROC_01   LOOP_SINGLE
```

## Example alignments ##

`*`.Xassy file:
```
OLD KEY:   CCGGTCCGCGATCTCGGACGCGGACGGCATCCATG
NEW KEY:   TCGGACGCGGACGGCATCCATGGATCGCGCGCCGC

........        _A_     0000X00000X0000X000X000X00000000000300010410000000202000000210000073X306200     __122__
........        _T_     X000000000000000X000X000X00000000000001000000000000000001800004996000600000     __122__
........        _G_     00XX00X0XX00XX0000000XX000X0X0X00X02782911919191998X79501097952013310101020     __122__
........        _C_     0X000X0X000X00X00XX000000X0X0X0XX0X53271951919291100115X82111541010600X388X     __122__
........        _N_     000000000000000000000000000000000000000000000000000000000000000000000000000     __122__
........        ALL     eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedddddddcccccccccbbbbbaaaaaa98888654     __122__
********        ***     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^****************************************     __122__
########        CNS     TCGGACGCGGACGGCATCCATGGATCGCGCGCCGCcggcgccgcgcgcgggGggcCctgggcntttacAtCaccC     __122__
########        QLT     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX?@+@++?+++++++++X@+?X+++@+?-++!@-X-X-++X     __122__
```


`*`.Tails file:
```
........        _A_     000X000009000X000X000000X6X0000000000X000000X00000X0000X000X000X00000000000300010410000000202000000210000073X306200     __122__
........        _T_     0X009X000000X000000XX0000401000X000100X0X000000000000000X000X000X00000000000001000000000000000001800004996000600000     __122__
........        _G_     0000000XX0XX0000X0X0000000000XX000X0X00000XX00X0XX00XX0000000XX000X0X0X00X02782911919191998X79501097952013310101020     __122__
........        _C_     X0X010X0010000XX00000XXX0009X000XX09000X0X000X0X000X00X00XX000000X0X0X0XX0X53271951919291100115X82111541010600X388X     __122__
........        _N_     0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000     __122__
........        ALL     3346889aaaabbbbbbbbbbccccdddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedddddddcccccccccbbbbbaaaaaa98888654     __122__
********        ***     ****************************************^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^****************************************     __122__
########        CNS     CTCAtTCGGaGGTACCGAGTTCCCAaAcCGGTCCGcGATCTCGGACGCGGACGGCATCCATGGATCGCGCGCCGCcggcgccgcgcgcgggGggcCctgggcntttacAtCaccC     __122__
########        QLT     XXXX+XXXX+XXXXXXXXXXXXXXX!X+XXXXXXX+XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX?@+@++?+++++++++X@+?X+++@+?-++!@-X-X-++X     __122__
```

## Alignment depth one letter code ##

| **depth range** | **1L-code** |
|:----------------|:------------|
| 1               | 1           |
| 2               | 2           |
| 3               | 3           |
| 4               | 4           |
| 5               | 5           |
| 6               | 6           |
| 7               | 7           |
| 8               | 8           |
| 9               | 9           |
| 10 - 20         | a           |
| 20 - 30         | b           |
| 30 - 40         | c           |
| 40 - 50         | d           |
| 50 - 60         | e           |
| 60 - 70         | f           |
| 70 - 80         | g           |
| 80 - 90         | h           |
| 90 - 100        | i           |
| 100 - 120       | j           |
| 120 - 140       | k           |
| 140 - 160       | l           |
| 160 - 180       | m           |
| 180 - 200       | n           |
| 200 - 300       | o           |
| 300 - 400       | p           |
| 400 - 500       | q           |
| 500 - 600       | r           |
| 600 - 700       | s           |
| 700 - 800       | t           |
| 800 - 900       | u           |
| 900 - 1000      | v           |
| 1000 - 2000     | w           |
| 2000 - 3000     | O           |
| 3000 - 4000     | P           |
| 4000 - 5000     | Q           |
| 5000 - 6000     | R           |
| 6000 - 7000     | S           |
| 7000 - 8000     | T           |
| 8000 - 9000     | U           |
| 9000 - 10000    | V           |
| 10000 - 30000   | W           |
| 30000 - 60000   | X           |
| 60000 - 100000  | Y           |
| 100000 - .....  | Z           |

## Consensus default quality scores ##

| **identity (IDNT)** | **depth cutoff** | **Q-code** |
|:--------------------|:-----------------|:-----------|
| 1.0 = IDNT          | 3                | X          |
| 0.8 <= IDNT         | 3                | +          |
| 0.7 <= IDNT         | 10               | @          |
| 0.6 <= IDNT         | 10               | !          |
| 0.5 <= IDNT         | 10               | ?          |
| 0.5 > IDNT          | 1                | -          |
| NO DATA             | -                | .          |

## SeqExter output files ##

  * out.Log – log file with run progress info (number of items, time, search status)
  * .out.Search – complete list of all items (strings) found upon search
  * .out.Summary – count of all perfect matches per iteration (search)
  * .out.Tails – two-sided extended consensus with detailed depth and quality info
  * .out.Tails.tab - two-sided extended consensus in tab-delimited format
  * .out.TrimL – alignment trimmed at left side
  * .out.TrimR – alignment trimmed at right side
  * .out.UniSeqs – consensus based on the analysis of left-trimmed alignment (processed TrimL data)
  * .out.Xassy – summary of all generated consensuses on UniSeqs file