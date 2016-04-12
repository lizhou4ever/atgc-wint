## Phytophthora cinnamomi repeats ##

**1** Input Data Compilation
```
cat Phytophthora_cinnamomi_IGA_Lib_Set_P1.F Phytophthora_cinnamomi_IGA_Lib_Set_P1.R > Phytophthora_cinnamomi_library_SRR097634.10M.seqs

cat Phytophthora_cinnamomi_IGA_Lib_Set_P[1234].[FR] > Phytophthora_cinnamomi_library_SRR097634.40M.seqs
```

**2** Finding of most abundant 40nt long K-mers (fragments)
```
cut -c11-50 Phytophthora_cinnamomi_library_SRR097634.40M.seqs | sort | uniq -c | sort -n -r > Phytophthora_cinnamomi_library_SRR097634.K-mer.40nt
```

**3** Selection of top 1000 abundant fragments
```
head -1000 Phytophthora_cinnamomi_library_SRR097634.K-mer.40nt > Phytophthora_cinnamomi_library_SRR097634.K-mer.Top.1K
```

**4** Removing leading numbers
```
perl -p -i -e 's/.* //' Phytophthora_cinnamomi_library_SRR097634.K-mer.Top.1K
```

**5** SeqExter run with abundant fragments
```
tclsh8.4 seqexter_r59.tcl Phytophthora_cinnamomi_library_SRR097634.10M.seqs Phytophthora_cinnamomi_library_Top1K.OUT FILE Phytophthora_cinnamomi_library_SRR097634.K-mer.Top.1K 10000000 75 P
ROC_01 LOOP_SINGLE > Phytophthora_cinnamomi_library_Top1K.Log
```

**6** Alignments validation and filtering
```
....... _A_     0003640007X373737749190000009XX700000X0X0X0000000X000000000XX000X0X00XX000X0X0X000X9000110090190X900X000000090  __126__
....... _T_     8391347X9300000730019191919X100009XXX000X00XX00X0000XX00X0X000X00000000X000X0009900009001000000000900090092001  __126__
....... _G_     07161220000007300350000009000003900000X000000000000000XX0X000X0000000000XX0000000900X0998000000000090X09X00000  __126__
....... _C_     200000000007300000000009100000000000000000X00XX0X0XX00000000000X0X0XX00000000X00100000000990X90900000000018X09  __126__
....... _N_     00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000  __126__
....... ALL     cehjklnnooooopppppqqqqqrrrrssssssttttttttttttttttttttttttttttttttttttttttttttssssrrrrrqqqqqqpppoooooonmkkjifec  __126__
******* ***     ***********************************^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^***********************************  __126__
####### CNS     tgtgantTtaAcagataagatatctgtTaAAagtTTTAGATACTTCCTCACCTTGGTGTAAGTCACACCAATGGATACAttgAaGtgggccaCcacAatgAGtgGtcCac  __126__
####### QLT     +@+!!-@X+@X@@@@@@@?++++++++X+XX@++XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX+++X+X+++++++X+++X+++XX++X++X++  __126__


....... _A_     0XX00XX00X0000XXX00XXXX00XX000000XX00X0X0XXX000XX00X00X000000X0X00X0XX000X0X0X0X0XXX000XXXXX00000XXXXXX00XXXXX  __127__
....... _T_     000X000XX00X00000XX00000X00X00X0000XX00000000X000000XX000X0XX00000000000X00000X00000X000000000X0X000000XX00000  __127__
....... _G_     0000X00000X0XX000000000X00000X0XX00000X00000X0000XX0000000X000X0XX00000X0000000000000X0000000X0000000000000000  __127__
....... _C_     X000000000000000000000000000X00000000000X00000X00000000XX0000000000X00X000X0X000X00000X00000X00X00000000000000  __127__
....... _N_     00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000  __127__
....... ALL     ehjkmooooppppqqqqrrrrrsssttttttuuuuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuuutttsssrrrrrqqqqppppoooooomlkjgc  __127__
******* ***     ***********************************^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^***********************************  __127__
####### CNS     CAATGAATTAGTGGAAATTAAAAGTAATCGTGGAATTAGACAAAGTCAAGGATTACCTGTTAGAGGACAACGTACACATACAAATGCAAAAACGTCTAAAAAATTAAAAA  __127__
####### QLT     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  __127__
```

**7** Downstream assembly with CAP3