

# RNA-Seq-validation


<h1> fftftfff </h1>
<h2> fftftfff </h2>
<h3> fftftfff </h3>
<h4> fftftfff </h4>

Author: Paulo Flores : 2019

Contact: Paulo.Flores@hutton.ac.uk / paulorapazote@gmail.com

"RNA-Seq will be validated with High-Resolution HR-RTPCR data"

<h2> Description of the algorithm </h2>

This algorithm (HR-RTPCR_RNA-Seq_Comparison.sh) is a collection of 7 small bash shell scripts that associate HR-RTPCR data with a transcriptome previously quantified with SALMON.

<h2>Tools and steps needed before running the algorithm: </h2>

<p>Before running the HR-RTPCR_RNA-Seq_Comparison.sh algorithm was necessary to run SALMON, a pseudo alignment tool (algorithm tested with SALMON version 0.8.2). We aligned each of our RNA-Seq read samples to the reference transcriptome (transcriptome.fasta file) after index generation. Each SALMON output sample must be in a individual folder, line 29 of the algorithm contains the path to the folder where the samples are. 

Also, it is necessary ncbi blast tool (algorithm tested with version ncbi-blast-2.2.28+), path mentioned lines 42 and 50.

Threads, we run the algorithm with 4 threads (algorithm lines 2 and 50).<p/>

<h2> Input Files:</h2>

1. transcriptome.fasta file, this file contains the transcript sequences in fasta format. The transcript headers can not contain empty spaces. Algorithm lines 20 (path to the folder where is the transcriptome) and line 22 (transcriptome file name) identify the folder location and transcriptome fasta file name we used.

2. PrimersSequences.fasta, this file contains the primer sequences in fasta format. Each pair of primers (reverse and forward) have similar name but end with different terminations: _R (reverse) and _F (forward), example - Hv43_R and Hv43_F. 

3. rtPCR_productsAndProportions.txt (file located in the same folder where we run the algorithm), tab-delimited text file containing. Example of rtPCR_productsAndProportions.txt file:
        
        Primer Size Sample1 Sample2 Sample3 Sample4 Sample5

        Hv43	228	0.03	0.01	0.00	0.00	0.00

        Hv43	251	0.02	0.02	0.00	0.00	0.00

        Hv43	263	0.16	0.15	0.00	0.00	0.00

        Hv43	388	0.45	0.51	0.00	0.00	0.00

        Hv43	391	0.09	0.08	0.00	0.00	0.00

        Hv43	403	0.19	0.17	0.00	0.00	0.00

        Hv43	540	0.06	0.06	0.00	0.00	0.00 
      

 a) Column 1, primer names without _R or _F termination (example - Hv43); 

 b) Column 2, HR-RT PCR product size (the computed nucleotide distance between primer pairs);

 c) Columns 3, 4, ... - individual sample proportions of each primer product;


<h2> Output Files: </h2>

Complete-PrimerBestPairs-data.txt file contains the principal results, each line present the best transcripts and RNA-Seq products that are associated with each HR-RTPCR primer product:

        Primer Size INF2 LEAF EMBRYO INF1 NODE Best_RNA-Seq_partner_product-size Transcripts Difference_Product-sizes EMB_a EMB_b EMB_c INF1_a INF1_b INF1_c INF2_f INF2_g INF2_h LEA_a LEA_b LEA_c NOD_a NOD_b NOD_c
        Hv29C 124 0.38 0.29 0.44 0.45 0.23 124 MSTRG.27957.11gene=MSTRG.27957,MSTRG.27957.13gene=MSTRG.27957,MSTRG.27957.15gene=MSTRG.27957,MSTRG.27957.17gene=MSTRG.27957,MSTRG.27957.18gene=MSTRG.27957,MSTRG.27957.19gene=MSTRG.27957,MSTRG.27957.21gene=MSTRG.27957,MSTRG.27957.22gene=MSTRG.27957,MSTRG.27957.23gene=MSTRG.27957,MSTRG.27957.4gene=MSTRG.27957,MSTRG.27957.5gene=MSTRG.27957 0 4.09128 4.09417 2.38327 9.74633 13.8822 11.2032 11.4035 8.97263 8.76731 422.8 739.357 736.983 37.5039 328.473 71.9265
        Hv29C 165 0.10 0.11 0.04 0.07 0.03 263 MSTRG.27957.12gene=MSTRG.27957,MSTRG.27957.14gene=MSTRG.27957,MSTRG.27957.6gene=MSTRG.27957,MSTRG.27957.7gene=MSTRG.27957,MSTRG.27957.8gene=MSTRG.27957,MSTRG.27957.9gene=MSTRG.27957 98 0.160614 0.82305 1.12513 7.87256 4.71659 0 8.87231 2.15152 10.4036 101.288 218.36 159.169 7.66024 10.9552 9.39045
        Hv29C 174 0.51 0.60 0.51 0.48 0.74 174 MSTRG.27957.10gene=MSTRG.27957,MSTRG.27957.16gene=MSTRG.27957,MSTRG.27957.1gene=MSTRG.27957,MSTRG.27957.20gene=MSTRG.27957,MSTRG.27957.24gene=MSTRG.27957,MSTRG.27957.25gene=MSTRG.27957,MSTRG.27957.2gene=MSTRG.27957,MSTRG.27957.3gene=MSTRG.27957 0 5.09522 6.48277 8.71021 7.88991 11.0326 8.62305 8.49156 6.36716 11.3357 1345.98 2204.55 2635.53 136.514 141.979 229.153

        Hv43C 228 0.03 0.01 0.00 0.00 0.00 357 MSTRG.18690.14gene=MSTRG.18690 129 0 0.171198 0 0.365108 0.407714 0.275525 0.458577 0.359708 0.737344 0.086691 0.317926 0.412978 0.134152 0.207372 0.265805
        Hv43C 251 0.02 0.02 0.00 0.00 0.00 251 MSTRG.18690.7gene=MSTRG.18690 0 9.36595 0.725006 1.36634 2.90935 2.21342 4.39471 1.84761 2.32589 1.85658 2.45604 2.55507 4.57688 3.58125 21.4016 7.54349
        Hv43C 263 0.16 0.15 0.00 0.00 0.00 263 MSTRG.18690.1gene=MSTRG.18690 0 0 6.78275 5.09532 9.40176 12.9536 6.36082 13.5621 13.6476 11.0834 4.45519 4.02733 13.1525 1.58163 4.87729 5.76553
        Hv43C 388 0.45 0.51 0.00 0.00 0.00 383 MSTRG.18690.5gene=MSTRG.18690,MSTRG.18690.9gene=MSTRG.18690 5 15.903 27.5811 32.1096 17.6603 28.5778 34.4706 17.5067 8.01582 6.62618 21.3415 19.6601 1.33951 3.86513 0 0.680553
        Hv43C 391 0.09 0.08 0.00 0.00 0.00 391 MSTRG.18690.3gene=MSTRG.18690 0 8.07575 45.1946 37.6792 40.3015 35.8467 29.8566 74.2753 68.1402 58.677 41.5491 42.0362 41.1317 9.3214 8.01865 8.81654
        Hv43C 403 0.19 0.17 0.00 0.00 0.00 395 MSTRG.18690.4gene=MSTRG.18690 8 1.44373 9.41506 8.12082 8.26985 8.58011 6.79552 9.01278 15.5087 18.3622 5.43747 2.52853 8.79462 4.75882 3.53975 1.02349
        Hv43C 540 0.06 0.06 0.00 0.00 0.00 540 MSTRG.18690.12gene=MSTRG.18690 0 0.693011 13.468 12.1186 10.6488 7.64003 6.83093 11.4664 5.3075 12.477 12.4294 4.43563 4.66318 4.46533 1.07229 2.12793

        Hv101C 209 0.25 0.27 0.30 0.26 0.28 209 MSTRG.29262.2gene=MSTRG.29262 0 4.5132 0.836455 1.74505 9.55399 4.08724 7.62184 7.37136 6.20114 6.88347 2.06624 3.2371 0.638361 3.11743 4.44779 2.85087
        Hv101C 214 0.75 0.73 0.70 0.74 0.72 214 MSTRG.29262.1gene=MSTRG.29262,MSTRG.29262.3gene=MSTRG.29262 0 20.1313 27.9218 26.1369 37.7437 39.5129 31.4782 46.0335 41.3527 37.5883 25.4282 6.6419 9.20107 31.9718 30.6956 29.5695
        Hv104C 147 0.12 0.00 0.50 0.05 0.10 240 MSTRG.5011.4gene=MSTRG.5011,MSTRG.5013.4gene=MSTRG.5013 93 8.62283 9.84764 4.30267 9.76752 14.1962 13.0981 26.207 26.8976 20.1803 5.58791 2.94775 2.49404 20.204 42.5338 10.692
        Hv104C 236 0.04 0.62 0.06 0.04 0.12 236 MSTRG.5011.3gene=MSTRG.5011,MSTRG.5013.3gene=MSTRG.5013 0 1.51951e-05 4.72146e-06 5.44597 1.1775 0.967522 0 2.21915 0.931161 2.76518 0 0 0 0.393521 1.22675 0
        Hv104C 244 0.17 0.07 0.09 0.15 0.19 244 MSTRG.5011.2gene=MSTRG.5011,MSTRG.5013.2gene=MSTRG.5013 0 3.38378 1.57966 2.1378 1.83716 2.36712 2.47022 3.22636 4.50262 5.20089 1.09697 0 0.394431 1.70173 0.712299 0.452007
        Hv104C 251 0.67 0.31 0.36 0.76 0.60 251 MSTRG.5011.1gene=MSTRG.5011,MSTRG.5013.1gene=MSTRG.5013 0 3.43897 5.0858 5.55545 10.5445 10.1355 9.0628 15.8147 13.2039 14.2478 3.69662 0.826872 0.654205 7.5584 1.0551 2.00384


   a) Column "transcripts" present the RNA-Seq transcripts were the primers bound perfectly and the best product lenght available;

   b) Column "Best_RNA-Seq_partner_product-size" shows the most similar HR RTPCR product size;

   c) Column "Difference_Product-sizes" shows the numerical difference between the best (nearest) RNA-seq product;

   d) Columns after "Difference_Product-sizes" column present the clustered TPM values to each sample;


FileWithAllSampleTPMs.txt contains the list of transcripts and TPM (Transcript per Million) values per sample (clustered).


Other_files folder contains intermediate files.

<h2> Running the algorithm</h2>

bash ./HR-RTPCR_RNA-Seq_Comparison.sh

<h2> Description of the individual scripts (modules):</h2> 

Module 1 : Blast generates a transcriptome database with the transcriptome supplied in fasta format; The primers sequence are blasted (blastn) to the previous database;

Module 2 :

Module 3 :

Module 4 :

Module 5 :

Module 6 :

Module 7 :




