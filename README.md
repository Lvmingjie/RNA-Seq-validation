

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

        Primer Size Sample1 Sample2 Sample3 Sample4 Sample5 Best_RNA-Seq_partner_product-size Transcripts Difference_Product-sizes Sample1 Sample2 Sample3 Sample4 Sample5 
        Hv29C 124 0.38 0.29 0.44 0.45 0.23 124 MSTRG.27957.11,MSTRG.27957.13,MSTRG.27957.15,MSTRG.27957.17,MSTRG.27957.18,MSTRG.27957.23,MSTRG.27957.4,MSTRG.27957.5 0 4.09128 4.09417 2.38327 9.74633 13.8822
        Hv29C 165 0.10 0.11 0.04 0.07 0.03 263 MSTRG.27957.12,MSTRG.27957.8,MSTRG.27957.9 98 0.160614 0.82305 1.12513 7.87256 4.71659
        Hv29C 174 0.51 0.60 0.51 0.48 0.74 174 MSTRG.27957.10,MSTRG.27957.16,MSTRG.27957.1,MSTRG.27957.20,MSTRG.27957.2,MSTRG.27957.3 0 5.09522 6.48277 8.71021 7.88991 11.0326

        Hv43C 228 0.03 0.01 0.00 0.00 0.00 357 MSTRG.18690.14 129 0 0.171198 0 0.365108 0.407714
        Hv43C 251 0.02 0.02 0.00 0.00 0.00 251 MSTRG.18690.7 0 9.36595 0.725006 1.36634 2.90935 2.21342
        Hv43C 263 0.16 0.15 0.00 0.00 0.00 263 MSTRG.18690.1 0 0 6.78275 5.09532 9.40176 12.9536
        Hv43C 388 0.45 0.51 0.00 0.00 0.00 383 MSTRG.18690.5,MSTRG.18690.9 5 15.903 27.5811 32.1096 17.6603 28.5778
        Hv43C 391 0.09 0.08 0.00 0.00 0.00 391 MSTRG.18690.3 0 8.07575 45.1946 37.6792 40.3015 35.8467
        Hv43C 403 0.19 0.17 0.00 0.00 0.00 395 MSTRG.18690.4 8 1.44373 9.41506 8.12082 8.26985 8.58011
        Hv43C 540 0.06 0.06 0.00 0.00 0.00 540 MSTRG.18690.12 0 0.693011 13.468 12.1186 10.6488 7.64003 

        Hv101C 209 0.25 0.27 0.30 0.26 0.28 209 MSTRG.29262.2 0 4.5132 0.836455 1.74505 9.55399 4.08724
        Hv101C 214 0.75 0.73 0.70 0.74 0.72 214 MSTRG.29262.1,MSTRG.29262.3 0 20.1313 27.9218 26.1369 37.7437 39.5129
        Hv104C 147 0.12 0.00 0.50 0.05 0.10 240 MSTRG.5011.4gene,MSTRG.5013.4 93 8.62283 9.84764 4.30267 9.76752 14.1962
        Hv104C 236 0.04 0.62 0.06 0.04 0.12 236 MSTRG.5011.3,MSTRG.5013.3 0 1.51951e-05 4.72146e-06 5.44597 1.1775 0.967522
        Hv104C 244 0.17 0.07 0.09 0.15 0.19 244 MSTRG.5011.2,MSTRG.5013.2 0 3.38378 1.57966 2.1378 1.83716 2.36712
        Hv104C 251 0.67 0.31 0.36 0.76 0.60 251 MSTRG.5011.1,MSTRG.5013.1 0 3.43897 5.0858 5.55545 10.5445 3.370


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




