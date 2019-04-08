# RNA-Seq-validation

Author: Paulo Flores : 2019

Contact: Paulo.Flores@hutton.ac.uk / paulorapazote@gmail.com

RNA-Seq will be validated with High-Resolution RTPCR data

# Description of the algorithm

This algorithm (HR-RTPCR_RNA-Seq_Comparison.sh) is a collection of 7 small bash shell scripts that associate HR-RT PCR data with a transcriptome previously quantified with SALMON.

Individual modules description:

Module 1 : Blast generates a transcriptome database with the transcriptome supplied in fasta format; The primers sequence are blasted (blastn) to the previous database;

Module 2 :

Module 3 :

Module 4 :

Module 5 :

Module 6 :

Module 7 :

# Tools and steps needed before running the script:

Before running the HR-RTPCR_RNA-Seq_Comparison.sh algorithm is necessary to run SALMON, a pseudo alignment tool (algorithm tested with version 0.8.2).

Also, it is necessary ncbi blast tool (algorithm tested with version ncbi-blast-2.2.28+)

# Input Files:

1. transcriptome.fasta file, this file should contain the transcript sequences in fasta format. The transcript headers shouldn't contain empty spaces. It must be edited the line 20 (path to the folder where is the transcriptome) and line 22 (transcriptome file name) in the algorithm to identify the folder location and correct name you are using.

2. PPrimersSequences.fasta, this file should contain the primer sequences in fasta format. Each pair of primers (reverse and forward) should have similar name but ending with different terminations: _R (reverse) and _F (forward), example - Hv43_R and Hv43_R.   
3. rtPCR_productsAndProportions.txt (must be located in the same folder where you run the algorithm), tab-delimited text file containing (1) primer names without _R or _F termination (previous example - Hv43 and Hv43), (2) HR-RT PCR product size (the computed nucleotide distance between primer pairs), (3) and following columns - individual sample proportions of each product primer:

Primer 	Size	SAMPLE1	SAMPLE2	SAMPLE3	SAMPLE4	SAMPLE5

Hv43C	228	0.03	0.01	0.00	0.00	0.00

Hv43C	251	0.02	0.02	0.00	0.00	0.00

Hv43C	263	0.16	0.15	0.00	0.00	0.00

Hv43C	388	0.45	0.51	0.00	0.00	0.00

Hv43C	391	0.09	0.08	0.00	0.00	0.00

Hv43C	403	0.19	0.17	0.00	0.00	0.00

Hv43C	540	0.06	0.06	0.00	0.00	0.00

4. Location of Salmon output
# Output Files:
Complete-PrimerBestPairs-data.txt file contains the principal results
FileWithAllSampleTPMs.txt contains the list of transcripts and TPM per sample (clustered)
Other_files folder contains intermediate files
# Running the algorithm
bash ./HR-RTPCR_RNA-Seq_Comparison.sh
