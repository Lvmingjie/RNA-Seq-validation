# RNA-Seq-validation

Author: Paulo Flores
 
2019
 
Contact: Paulo.Flores@hutton.ac.uk / paulorapazote@gmail.com

RNA-Seq will be validated with High-Resolution RTPCR data

Description of the algorithm

This algorithm is a collection of 7 small Bash Shell scripts that associates HR-RT PCR data with a transcriptome previously quantified with Salmon.

Individual modules description:

Module 1 : Blast generates a transcriptome database with the transcriptome supplied in fasta format; The primers sequence are blasted (blastn) to the previous database;

Module 2 :

Module 3 :

Module 4 :

Module 5 :

Module 6 :

Module 7 :

Tools and steps needed before running the script:

Before running the algoritm is necessary to run Salmon, a pseudo alignment tool (algorithm tested with version 0.8.2).

Also, it is necessary ncbi blast tool (algorithm tested with version ncbi-blast-2.2.28+)

Input Files:

transcriptome.fasta file

PPrimersSequences.fasta

rtPCR_productsAndProportions.txt (must be located in the same folder where you run the algorithm)

Location of Salmon output

Output Files:

Complete-PrimerBestPairs-data.txt file contains the principal results

FileWithAllSampleTPMs.txt contains the list of transcripts and TPM per sample (clustered)

Other_files folder contains intermediate files

Running the algorithm

bash ./HR-RTPCR_RNA-Seq_Comparison.sh
