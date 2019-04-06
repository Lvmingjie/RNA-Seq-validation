#!/bin/bash
#$ -pe smp 4
#



#################################################################################################################################################
######################################################################################################################################### Script1
# Script to:
# 1- Generate a transcriptome DB ;
# 2- Blastn the Primers against the DB;

	
	#### Generation of a  DB
	##################################
	###
	###Files names and paths:
	DataBaseDB="Transcriptome_DB"
	BlastN_Output="Primers_vs_AllTranscripts.txt"
	PathToFastaTranscriptomeFile="/Path/to/.../.../TranscriptomeFolder"
	PathToFastaPrimersFile="/Path/to/.../.../PrimersFolder"
	TranscriptomeFileName="Transcriptome.fasta" 
	## Transcriptome.fasta file, the transcript headers should not contain empty spaces 
	
	#
	##
	## Primers fasta file (PrimersSequences): 
	PrimersFileName="PrimersSequences.fasta" # the primer names must end with "_R" (reverse) and "_F" (forward) and must form pairs with the same name (example: >Primer101_R ; >Primer101_F
	PathToSamplesFolder="/Path/to/.../.../Salmon/QuantificationFolder" 
	#
	NameSalmonFiles="quant.sf" ## Value at column 4 (quant.sf file)
	rtPCRInput="rtPCR_productsAndProportions.txt"  ## ## Header: "Primer 	Size	INF2	LEAF	EMBRYO	INF1	NODE"
	## The previous file must be in the folder where the script is ran
	
	###
	echo "Blast, Creating a DB,  running... Script1"
	###
	date
	###
	### Run Blast to generate DB
	###  /Path/to/.../.../ncbi-blast-2.2.28+
	/Path/to/.../.../ncbi-blast-2.2.28+/bin/makeblastdb -in $PathToFastaTranscriptomeFile/$TranscriptomeFileName -out $DataBaseDB -dbtype nucl
	

	#### Run Blastn  - Primers against transcriptome database
	echo "Blasting..."
	date	
	###			
	###			
	/Path/to/.../.../ncbi-blast-2.2.28+/bin/blastn -task blastn-short -num_threads 4 -query $PathToFastaPrimersFile/$PrimersFileName \
-db $DataBaseDB -out ./$BlastN_Output -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen salltitles qcovs qcovhsp"  
	
	### Remove database
	rm Transcriptome_DB.n*
	
	## Create a table with the list of primers, without extension "_F"/"_R" (pair of primers)
	grep ">" $PathToFastaPrimersFile/$PrimersFileName|sed 's/_F//g'|sed 's/_R//g'|sed 's/>//g'|sort|uniq > ListOfPairOfPrimers.txt
	

	
echo "End...Script1"
date



#################################################################################################################################################
######################################################################################################################################### Script2
echo "Running... Script2"
date

# Script to:
# 3- Filter the output of blastn, selecting only 100% matches (columns - 3,16 and 17); 
# 4- Report Primers without 100% matches (both primers), file with matches and without matches
# 5- Identify (based on the previous point data) transcripts with perfect matches (both primers) and the problematic cases;

#BlastN_Output="Primers_vs_AllTranscripts.txt"  ##


## 3
########################
awk '$3==100 && $16==100 && $17==100 {print $0}' $BlastN_Output > PrimersBlast100match.txt


## 4  ## 
#######################

		#input files:
		#PrimersBlast100match.txt
		#ListOfPairOfPrimers.txt
		# 
		file="./ListOfPairOfPrimers.txt"
		
		while IFS= read -r line
		do
 
		# display $line or do something with $line
		printf '%s\n' "$line"   

		grep "$line" PrimersBlast100match.txt > ProvisoryFileXXX1.txt

		## if  ## Check if the file is empty or not
		if [ -s ProvisoryFileXXX1.txt ]
			then
			echo "$line" > Default-NO-EmptyFile1.txt 
			cat Default-NO-EmptyFile1.txt >> ListOfPrimersWithMatches.txt #not empty
			else
			echo "$line No Match" > DefaultEmptyFile1.txt
			cat DefaultEmptyFile1.txt >> ListOfPrimersWith-NO-Matches.txt #empty
		fi
		## end if
	done <"$file"
	rm Default*
	rm ProvisoryFileXXX1.txt
	
## 5
#######################
# Problematic Matches: when a primer aligns in more than one position in the same transcript:
grep "_R" PrimersBlast100match.txt|awk '{print $1,$2}'|sort|uniq -c|awk '$1>1 {print $0}' > ProblematicMatches_R.txt
grep "_F" PrimersBlast100match.txt|awk '{print $1,$2}'|sort|uniq -c|awk '$1>1 {print $0}' > ProblematicMatches_F.txt

###


# Good Matches: when a primer aligns in a unique position in the transcript:
grep "_F" PrimersBlast100match.txt|awk '{print $1,$2}'|sort|uniq -c|awk '$1==1 {print $2,$3}'|sed 's/_F//g' > GoodMatches_F.txt
grep "_R" PrimersBlast100match.txt|awk '{print $1,$2}'|sort|uniq -c|awk '$1==1 {print $2,$3}'|sed 's/_R//g' > GoodMatches_R.txt

# Perfect pair Matches per transcript: a perfect R/F pair; Lonely Match: only 1 primer (R or F) aligns to the transcript; Multiple Matches: verification just in case...
cat GoodMatches_F.txt GoodMatches_R.txt|sort|uniq -c|awk '$1==2 {print $0}' > Perfect_R-F_Matches.txt
PrimersWithPerfectMatches=$(cat Perfect_R-F_Matches.txt|awk '{print $2}'|sort|uniq|wc -l|awk '{print $1}')
echo "Primer pairs that bind perfectly to at least 1 transcript : $PrimersWithPerfectMatches" 
cat GoodMatches_F.txt GoodMatches_R.txt|sort|uniq -c|awk '$1==1 {print $0}' > Lonely_R-F_Matches.txt
cat GoodMatches_F.txt GoodMatches_R.txt|sort|uniq -c|awk '$1>2 {print $0}' > Multiple_R-F_Matches.txt

# List of primers with perfect cases:
cat Perfect_R-F_Matches.txt|awk '{print $2}'|sort|uniq > Perfect_R-F_Matches-Primers.txt
echo "Primers with results:"
wc -l Perfect_R-F_Matches-Primers.txt

### 
awk '{print $2}' Perfect_R-F_Matches.txt|sort|uniq -c|awk '$1>1 {print $1,$2}' >PrimersThatBindManyTrancripts.txt
#######

# Transcripts associated with perfect R/F matches: some transcripts are present more than once at the Perfect_R-F_Matches-Transcripts.txt file !
awk '{print $3}' Perfect_R-F_Matches.txt > Perfect_R-F_Matches-Transcripts1.txt
TranscriptsWithPerfectMatches1=$(wc -l Perfect_R-F_Matches-Transcripts1.txt|awk '{print $1}')

##
awk '{print $3}' Perfect_R-F_Matches.txt|sort|uniq > Perfect_R-F_Matches-Transcripts.txt
TranscriptsWithPerfectMatches=$(wc -l Perfect_R-F_Matches-Transcripts.txt|awk '{print $1}')

echo "Number of total transcripts (some are twice) where primers bind perfectly: $TranscriptsWithPerfectMatches1" 
echo "Number of unique transcripts where primers bind perfectly: $TranscriptsWithPerfectMatches"
echo "End...script2"
date



#################################################################################################################################################
######################################################################################################################################### Script3
echo "Running... Script3"
date

# Script to:
# 6- To extract the TPM values from all samples, based on the list of transcripts where the primers bind perfectly; 
# 
# 

## 6
########################



		#input files:
		#Perfect_R-F_Matches-Transcripts.txt
		#Path to the samples Folders
		# 
		
		## Iterate over each folder at a time:
		
		################ 123

	######

## extract all the filenames to an array
## List the folders with the Samples
files1=`ls -p $PathToSamplesFolder |grep "/"`

for i in $files1  ## Create a loop to read all samples;
do  ## do 1
	## Remove the slash "/" from the variable
	fileNameNoExt=`basename $i /`
	
        echo " folder -- $i -- $fileNameNoExt"

				file2="./Perfect_R-F_Matches-Transcripts.txt" ## file2   ###### 

		while IFS= read -r line2
		do ## do 2   ### while loop to grep each transcript in the sample
		
		# display $line or do something with $line
		printf '%s\n' "$line2"   

		grep "$line2" $PathToSamplesFolder/$fileNameNoExt/$NameSalmonFiles|awk '{print $4}' >> $fileNameNoExt"-LevelExpression.txt"  ## TPMs from quant.sf file, column 4 with TPM value


#
	done <"$file2" ## end do 2  ## end file2
			## Add the header to each column with TPMs values:
			echo "$fileNameNoExt" > HeaderSampleName.txt ## create header file
			cat HeaderSampleName.txt $fileNameNoExt"-LevelExpression.txt" >$fileNameNoExt"-LevelExpression_.txt" ## Create a new file with the header
			rm $fileNameNoExt"-LevelExpression.txt" ## Delete the old one

done ## end do 1

echo "Transcripts" > HeaderTranscripts.txt  ## Header of the transcripts column
cat HeaderTranscripts.txt Perfect_R-F_Matches-Transcripts.txt > TranscriptsColumn.txt
paste TranscriptsColumn.txt *LevelExpression_.txt > FileWithAllSampleTPMs.txt ## File with All samples and TPM values

echo "End...script3"
date

#################################################################################################################################################
######################################################################################################################################### Script4
echo "Running... Script4"
date

# Script to:
# 7- Grep in the blastn results the perfect transcripts; 
# 8- Calculate the RNA-Seq products length;
# 


## 7
######################## grep Perfect_R-F_Matches-Transcripts.txt over PrimersBlast100match.txt

		#input files:
		
		## Using the primers first
		# Perfect_R-F_Matches-Primers.txt
		
		## file2a start loop
		file2a="Perfect_R-F_Matches-Primers.txt"
		while IFS= read -r line2a
		do ## do 2a   ### while loop to grep each primer to its set of transcripts
		
		## identify the set of transcripts to each primer
		printf '%s\n' "-- primer $line2a"
		grep "$line2a" Perfect_R-F_Matches.txt| awk '{print $3}' > Perfect_R-F_Matches-Transcripts-provisory7a.txt
		
		#PrimersBlast100match.txt (text with all blastn data - 100%/100%/100% matches)
		#Perfect_R-F_Matches-Transcripts.txt / Perfect_R-F_Matches-Transcripts_.txt  ### 

				file3="./Perfect_R-F_Matches-Transcripts-provisory7a.txt"  ### version 4
		while IFS= read -r line3
		do ## do 3   ### while loop to grep each transcript in the sample
		
		# display $line or do something with $line
		printf '%s\n' "$line3"   

		##
		## Just the Blastn data form the perfect transcripts
			grep "$line2a" PrimersBlast100match.txt|grep "$line3" > PrimersBlast100match-Perfect_Transcripts-provisory7b.txt
		#################### product length calculations: start  # 
		
		##
		PrimerCode8=$(cat PrimersBlast100match-Perfect_Transcripts-provisory7b.txt|head -1|awk '{print $1}'|sed 's/_R//g'|sed 's/_F//g')  ## The extension "_R" / "_F" were removed;
		
		## Transcript:
		TranscriptName8=$(cat PrimersBlast100match-Perfect_Transcripts-provisory7b.txt|head -1|awk '{print $2}')
		
		## Maximum coordinate:
		MaximumCoordinate8=$(cat PrimersBlast100match-Perfect_Transcripts-provisory7b.txt|awk '{print $9,$10}'|head -2|xargs -n1|sort -n|tail -1)
		
		## Minimum coordinate:
		MinimumCoordinate8=$(cat PrimersBlast100match-Perfect_Transcripts-provisory7b.txt|awk '{print $9,$10}'|head -2|xargs -n1|sort -n|head -1)
		 
		## Product length:
		ProductLength8=$(($MaximumCoordinate8-$MinimumCoordinate8+1))  ###
		printf '%s\n' "$PrimerCode8 --- $TranscriptName8 --- $MaximumCoordinate8 --- $MinimumCoordinate8 --- $ProductLength8" #
		
		# Store the data:
		echo "$PrimerCode8 $TranscriptName8  $ProductLength8" > Provisory8a.txt
		cat Provisory8a.txt >> ListProductLengts-perTranscript.txt
		
		 ####
		 ## List of primers that bind more than 1 gene: (three lines below)
		 cat ListProductLengts-perTranscript.txt|sed 's/gene=/ /g'|awk '{print $1,$3}'|sort|uniq > PrimersWithMultipleGenes-All.txt
		 cat ListProductLengts-perTranscript.txt|sed 's/gene=/ /g'|awk '{print $1,$3}'|sort|uniq|awk '{print $1}'|sort|uniq -c >PrimersWithMultipleGenes-All-quantified.txt
		 cat ListProductLengts-perTranscript.txt|sed 's/gene=/ /g'|awk '{print $1,$3}'|sort|uniq|awk '{print $1}'|sort|uniq -c|awk '$1>1 {print $0}' >PrimersWithMultipleGenes-All-transcripts.txt
		 
		 ####
		
		################### product length calculations: end  ##
#
	done <"$file3" ## end do 3  ## end file3
	
	done <"$file2a" ## end do 2a  ## end file2a
	## file2a end loop
	
	rm Perfect_R-F_Matches-Transcripts-provisory7a.txt PrimersBlast100match-Perfect_Transcripts-provisory7b.txt
	rm Provisory8*
	
## 8


echo "End...script4"
date



#################################################################################################################################################
######################################################################################################################################### Script5
echo "Running... Script5"
date

# Script to:
# 9- Obtain the list of unique primers (without _R or _F extension); 
# 10-Cluster the product length (identify the transcript with the same product length;
# 

## 9
######################## List of Unique primers based on ListProductLengts-perTranscript.txt



		#input files:
		#ListProductLengts-perTranscript.txt
		cat ListProductLengts-perTranscript.txt|awk '{print $1}'|sort|uniq > ListPrimers_Clean_Unique.txt


## 10
######################## Clustering transcripts with the same product length:

		#input files:
		#ListPrimers_Clean_Unique.txt 
		#ListProductLengts-perTranscript.txt

				file5="./ListPrimers_Clean_Unique.txt" ## file5

		while IFS= read -r line5
		do ## do 5   ### while loop to grep each transcript in the sample
		
		# display $line or do something with $line
		printf '%s\n' "$line5"   

		grep "$line5" ListProductLengts-perTranscript.txt > Provisory10.txt  ##  file with the product lengths per primer
		
		# Create a file with unique product lengths:
		cat Provisory10.txt|awk '{print $3}'|sort|uniq > Provisory10-PLengths.txt
		
		## create a while loop to deal with each product length:
		
		########### ## file6
			file6="./Provisory10-PLengths.txt" ## file6  ## Read the Product lengths
			while IFS= read -r line6
			do ## do 6   ### 
			printf '%s\n' "$line6"   
			
			awk '$3 ~ /'$line6'/ {print $0}' Provisory10.txt > Provisory10-Clustering.txt
			
				# Primer code = $line5
				# Product Length = $line6
				# Transcripts = column2 of Provisory10-Clustering.txt
				awk '{print $2}' Provisory10-Clustering.txt > Provisory10-Transcripts.txt
				# Transpose the transcripts with the same product length, split by comma
				TranscriptsTransposed=$(sed -e :a -e '{N; s/\n/,/g; ta}' Provisory10-Transcripts.txt)
				printf '%s\n' "$line5 == $line6 == $TranscriptsTransposed"
				
				####### Start:Identify the levels of expression of each transcript and equally cluster (sum) the levels of expression per sample
					########### ## file7
						file7="./Provisory10-Transcripts.txt" ## file7  ## Read the transcript names
						while IFS= read -r line7
						do ## do 7   ### 
						printf '%s\n' "$line7 = = ="
						grep "$line7" FileWithAllSampleTPMs.txt >> Provisory10-TranscriptsClustered.txt
						
						done <"$file7"
						
						# Removing the first column - transcript names;
						awk '{$1=""; sub("  ", " "); print}' Provisory10-TranscriptsClustered.txt > Provisory10-TranscriptsClustered2.txt
						## Summing up all lines to obtain the total level of expression per sample
						ColumnSum=$(awk 'BEGIN{FS=OFS=" "} NR>0{for (i=1;i<=NF;i++) a[i]+=$i} END{for (i=1;i<=NF;i++) printf a[i] OFS; printf "\n"}' Provisory10-TranscriptsClustered2.txt)
						
						# Storing all important data (primers, product length, transcripts, clustered levels of expression)
						echo "$line5 $line6 $TranscriptsTransposed $ColumnSum" > Provisory10-AlldataPerPrimer.txt 
						cat Provisory10-AlldataPerPrimer.txt >> ListAllDataClusteredPerPrimer.txt
						
						rm Provisory10-TranscriptsClustered.txt Provisory10-TranscriptsClustered2.txt
			    ####### End:Identify the levels of expression of each transcript and equally cluster (sum) the levels of expression per sample
			
			done <"$file6"
		########### ## End file6
		
		
		
	done <"$file5" ## end do 5  ## end file5
	rm Provisory10*


echo "End...script5"
date

#################################################################################################################################################
######################################################################################################################################### Script6
echo "Running... Script6"
date

# Script to:
# 11- Compare the RNA-Seq and rtPCR product lengths and find the best matches 
# 
# 


## 11
######################## Compare the RNA-Seq and rtPCR product lengths and find the best matches

# ##

		#input files:
		#ListAllDataClusteredPerPrimer_.txt  ##
		#$rtPCR-Input ## Header: "Primer 	Size	INF2	LEAF	EMBRYO	INF1	NODE"

		
		
## Create a list of rtPCR primers (unique primers)
 awk '{print $1}' $rtPCRInput | sed 1d|sort|uniq > rtPCR-ListOfPrimers.txt

  ##### Grep (search) each primer in both datasets (RNA-Seq and rtPCR) to create all combinations of primers between both:
   ########### ## file8
			file8="./rtPCR-ListOfPrimers.txt" ## file8  ## Read list of unique primers
			while IFS= read -r line8
			do ## do 8   ### 
			printf '%s\n' "$line8"
			 ## Grep rtPCR
			 grep "$line8" $rtPCRInput|awk '{print $2}' > Provisory11-rtPCR-primer.txt ## rtPCR data, just the product lengths
			 ## Grep RNA-Seq
			 grep "$line8" ListAllDataClusteredPerPrimer.txt|awk '{print $2,$3}' > Provisory11-RNA-Seq-primer.txt ## Products, Transcripts ## 
			
			##### Case of Provisory11-RNA-Seq-primer.txt empty:
			if [ -s Provisory11-RNA-Seq-primer.txt ]
			then
			echo "Provisory11-RNA-Seq-primer.txt file not empty -- $line8" #not empty
			else
			echo "Provisory11-RNA-Seq-primer.txt file empty!!! -- $line8" #empty
			echo "0 TCONS-unknown"> Provisory11-RNA-Seq-primer.txt #empty
			fi
			##### End Case of Provisory11-RNA-Seq-primer.txt empty
			
			
			printf '%s\n' "---------=="
			head Provisory11-rtPCR-primer.txt
			printf '%s\n' "+-"
			head Provisory11-RNA-Seq-primer.txt
			printf '%s\n' "---------++"
			  ############ Create all combinations with both files
				## Loop RNA-Seq primers   loop 9
				file9="./Provisory11-RNA-Seq-primer.txt" ## file9  ## RNA-Seq products
				while IFS= read -r line9
				do ## do 9   ### 
				printf '%s\n' "$line9"
						## rtPCR products # loop 10
						file10="./Provisory11-rtPCR-primer.txt" ## file10  ## rtPCR products
						while IFS= read -r line10
						do ## do 10   ### 
						printf '%s\n' "$line10"
						echo "$line9 $line10  $line8" >> Provisory11-RNA-Seq-rtPCRline.txt  ## RNA-Seq data - rtPCR data - Primer
						   ## end loop 10
						done <"$file10" ## End loop 10
				done <"$file9" ## End loop 9
				############### Choose the best combinations
				## Count the best possible number of pairs (the minimum number of produt lengths in RNA-Seq or rtPCR) ## if RNA-Seq has 3 Prod and rtPCR 2 then the value is 2
				PossibleNumberOfBestPairs=$(wc -l Provisory11-rtPCR-primer.txt Provisory11-RNA-Seq-primer.txt|head -2|awk '{print $1}'|sort -n|head -1)
				## Based on the file Provisory11-RNA-Seq-rtPCRline.txt:
				# Solve the issue of negative values (negative differences between product lengths) to allow sorting
				cat Provisory11-RNA-Seq-rtPCRline.txt|awk '{print $1,$2,$3,$1-$3,$4}'|awk '$4<0 {print $1,$2,$3,$4*-1,$5}' >Provisory11-RNA-Seq-rtPCRline-Neg.txt
				cat Provisory11-RNA-Seq-rtPCRline.txt|awk '{print $1,$2,$3,$1-$3,$4}'|awk '$4>=0 {print $1,$2,$3,$4,$5}' >Provisory11-RNA-Seq-rtPCRline-Pos.txt
				## Sort the differences of the product lengths (Column 4)
				cat Provisory11-RNA-Seq-rtPCRline-Neg.txt Provisory11-RNA-Seq-rtPCRline-Pos.txt|sort -n -k 4,4 >Provisory11-RNA-Seq-rtPCRline-Abs.txt # File with all combinations sorted by the absolute differences of product lengths;
					### Loop Start to choose best pairs
						END=$PossibleNumberOfBestPairs
						for ((x=1;x<=END;x++)); do ## For loop
						echo "$x"
						## Store the first value:
						head -1 Provisory11-RNA-Seq-rtPCRline-Abs.txt >> BestPairs-RNA-Seq_VS_rtPCR.txt
						
						##### test
						printf '%s\n' "--1111111 $x"
						head Provisory11-RNA-Seq-rtPCRline-Abs.txt
						printf '%s\n' "--2222222"
						##### end test
						
						## Store the product lengths of first line in variables and exclude them:
						ProductToExclude1=$(awk '{print $1}' Provisory11-RNA-Seq-rtPCRline-Abs.txt|head -1)
						ProductToExclude2=$(awk '{print $3}' Provisory11-RNA-Seq-rtPCRline-Abs.txt|head -1)
						## Exclude the lines containing the product lengths that are part of the best pair: 
						
						awk '$1 != '$ProductToExclude1' && $3 != '$ProductToExclude2' {print $0}' Provisory11-RNA-Seq-rtPCRline-Abs.txt > Provisory11-LineExclusions.txt
						
						##### test2
						#
						head Provisory11-LineExclusions.txt
						#
						##### end test2
						
						mv Provisory11-LineExclusions.txt Provisory11-RNA-Seq-rtPCRline-Abs.txt
						##### test3
						#
						head Provisory11-RNA-Seq-rtPCRline-Abs.txt
						#
						##### end test3
						done ## End For Loop              Provisory11-RNA-Seq-rtPCRline-Abs.txt    
					
					### Loop End to choose best pairs
				############### End Choose the best combinations
				
							####### Before start working the next primer Round, Report the RNA-Seq transcripts orphans (not included in the Best Pairs file)
							## Create a file with the transcripts possibly included in the tail of BestPairs-RNA-Seq_VS_rtPCR.txt, however if there is a "TCONS-unknown" then there is no orphans to this primer
							tail -$PossibleNumberOfBestPairs BestPairs-RNA-Seq_VS_rtPCR.txt|awk '{print $2}' >Provisory11-ListTranscriptsBestPairs.txt
							LastLineProvisory11=$(tail -1 Provisory11-ListTranscriptsBestPairs.txt)
								## If last line Provisory11-ListTranscriptsBestPairs.txt different from "TCONS-unknown" then store the possible orphans
								## Also Check the difference of Best possible pairs and all possible (i.e if RNA-Seq has 2 products and rtPCR has equal number then there is no orphans)
								MaximumNumberOfPairs=$(wc -l Provisory11-RNA-Seq-primer.txt|awk '{print $1}')
								if [ "$LastLineProvisory11" != "TCONS-unknown" -a "$MaximumNumberOfPairs" -gt "$PossibleNumberOfBestPairs" ];
									then # identify and store the transcript orphans
										## while loop to empty the file Provisory11-RNA-Seq-primer.txt
										file11="./Provisory11-ListTranscriptsBestPairs.txt" ## file11  ## Transcripts present at Best Pairs file to this primer
										while IFS= read -r line11
										do ## do 11   ### 
										printf '%s\n' "$line11 not orphan transcript"
										grep -v $line11 Provisory11-RNA-Seq-primer.txt > Provisory11-RNA-Seq-primer2.txt
										mv Provisory11-RNA-Seq-primer2.txt Provisory11-RNA-Seq-primer.txt
										done <"$file11"
											## Add Rna-Seq Levels of Expression per sample:
												# Just the list of Transcripts:
													awk '{print $2}' Provisory11-RNA-Seq-primer.txt > Provisory11-RNA-Seq-primer-OrphanTranscripts.txt
													## while loop to add levels of Expression Orphan transcripts
													file12="./Provisory11-RNA-Seq-primer-OrphanTranscripts.txt" ## file12  ## Transcripts Orphans
													while IFS= read -r line12
													do ## do 12   ### 
													printf '%s\n' "$line12  orphan transcripts"
													grep "$line12" ListAllDataClusteredPerPrimer.txt >> Provisory11-RNA-Seq-LevelsExp-OrphanTranscripts.txt
													done <"$file12"
													## Add the levels of expression
													paste Provisory11-RNA-Seq-primer.txt Provisory11-RNA-Seq-LevelsExp-OrphanTranscripts.txt > Provisory11-RNA-Seq-LevelsExp-OrphanTranscripts2.txt
													rm Provisory11-RNA-Seq-LevelsExp-OrphanTranscripts.txt
													## End while loop to add levels of Expression Orphan transcripts
											## Store the list of orphans transcripts
											echo "$line8 :" > Provisory11-HeaderPrimer.txt 
											cat Provisory11-HeaderPrimer.txt Provisory11-RNA-Seq-LevelsExp-OrphanTranscripts2.txt >> Orphan-Transcripts-List.txt
										## End while loop to empty the file Provisory11-RNA-Seq-primer.txt
										
									fi
									
							####### End: Before start working the next primer Round, Report the RNA-Seq transcripts orphans (not included in the Best Pairs file)
				rm Provisory11-*
			  ############ End: Create all combinations with both files
			done <"$file8"
   ########### ## End file8
 
 
 
echo "End...script6"
date



#################################################################################################################################################
######################################################################################################################################### Script7
echo "Running... Script7"
date


# Script to:
# 12- To introduce all initial primer (rtPCR) information on the file Best pairs list (add the proportions and the orphan primers (rtPCR data that has no RNA-Seq partner) 
# 12B- Also add the RNA-Seq Levels of expression of each group of clustered transcripts
# 


## 12
######################## To introduce all initial primer (rtPCR) information on the file Best pairs list (add the proportions and the orphan primers (rtPCR data that has no RNA-Seq partner)


		#input files:
		#BestPairs-RNA-Seq_VS_rtPCR.txt
		#$rtPCR-Input ## Header: "Primer 	Size	INF2	LEAF	EMBRYO	INF1	NODE"
		#ListAllDataClusteredPerPrimer.txt
		
		
		sed 1d $rtPCRInput > Initial-rtPCR-data-WithoutHeader.txt
		## while loop to read each initial primer
		file13="./Initial-rtPCR-data-WithoutHeader.txt" ## file12  ## Initial primer (rtPCR) data
		while IFS= read -r line13
		do ## do 13   ### 
		printf '%s\n' "$line13  rtPCR primers data"
		## Split the line13 with a array
		stringarray=($line13)
		PrimerCode=${stringarray[0]}
		ProductSize=${stringarray[1]}
		PrimerProportions=${stringarray[@]:2:100} # All line information less the primer name and product size (excluding the first two columns)
		#
		
		## Try to identify the primer and product size in the BestPairs-RNA-Seq_VS_rtPCR.txt file
		grep "$PrimerCode" BestPairs-RNA-Seq_VS_rtPCR.txt| awk '$3== '$ProductSize' {print $0}' > Provisory12-PrimerBestPairs-data.txt
		printf '%s\n' "--------------------- "
		head Provisory12-PrimerBestPairs-data.txt
		printf '%s\n' "+++++++++++++++++++++ "
				## Check if the file Provisory12-PrimerBestPairs-data.txt is empty
					if [ -s Provisory12-PrimerBestPairs-data.txt ]
					then
					## Not empty:
						PossibleTCONSunknown=$(awk '{print $2}' Provisory12-PrimerBestPairs-data.txt)  ## Column 2 could occupied by "TCONS-unknown" if the Provisory11-RNA-Seq-primer.txt was empty
						printf '%s\n' "---------   $PossibleTCONSunknown ------------ "
						if [ "$PossibleTCONSunknown" == "TCONS-unknown" ];
									then # in case of "TCONS-unknown"
										echo "$PrimerCode $ProductSize $PrimerProportions 1000 TCONS-unknown 1000 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0" >> Complete-PrimerBestPairs-data.txt #
									else ## else a valid case
										######## valid case
											## Extract RNA-Seq levels of expression
											###
											ValidBestPartner=$(grep "$PossibleTCONSunknown" ListAllDataClusteredPerPrimer.txt|grep "$PrimerCode") 
											###
											## Transcript Names clustered  ##
											printf '%s\n' "+++++++++++   $ValidBestPartner +++++++++++++ "
											
											DifferenceProductSizes=$(awk '{print $4}' Provisory12-PrimerBestPairs-data.txt)
											printf '%s\n' "+++++++££££££++++   $DifferenceProductSizes +++++++££££++++++ "
													## Split the ValidBestPartner with a array
													stringarrayB=($ValidBestPartner)
													printf '%s\n' "+++++++££££££++++   $ValidBestPartner  TTTTTTTTTTTTTTTTTTT "
													TranscriptsClustered=${stringarrayB[2]}
													
													ProductSizeRNASeqPartner=${stringarrayB[1]}
													
													RNASeqLevelsExpression=${stringarrayB[@]:3:100} # All line information less the primer name, product size and Transcript names (excluding the first three columns)
													echo "$PrimerCode $ProductSize $PrimerProportions $ProductSizeRNASeqPartner $PossibleTCONSunknown $DifferenceProductSizes $RNASeqLevelsExpression" >>Complete-PrimerBestPairs-data.txt
										######## End: valid case
									fi
					## End Not empty
					else  # empty
					echo "$PrimerCode $ProductSize $PrimerProportions 1000 Unknown-Partner 1000 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0" >> Complete-PrimerBestPairs-data.txt #empty
					fi
				## End Check if the file Provisory12-PrimerBestPairs-data.txt is empty
		
		done <"$file13"
		## End: while loop to read each initial primer

############################# Add the header to the Complete-PrimerBestPairs-data.txt file
## First columns (rtPCR input):
head -1 $rtPCRInput > HeadEr-rtPCR.txt
## Next 3 columns (RNA-Seq partners):
echo "Best_RNA-Seq_partner_product-size Transcripts Difference_Product-sizes" > HeadEr-RNA-Seq.txt
## Header Samples - Levels expression
head -1 FileWithAllSampleTPMs.txt|awk '{$1=""; print $0}' > HeadEr-TPMs.txt ## First select the first line, after remove the first column (transcripts), not necessary

paste HeadEr-rtPCR.txt	HeadEr-RNA-Seq.txt	HeadEr-TPMs.txt > HeadEr-All.txt
expand HeadEr-All.txt >HeadEr-All_.txt ## converts tabs into spaces
cat HeadEr-All_.txt Complete-PrimerBestPairs-data.txt|sed 's/  */ /g' > Complete-PrimerBestPairs-data1.txt  ## the sed commands converts multi-spaces into one space (header issue)
mv Complete-PrimerBestPairs-data1.txt Complete-PrimerBestPairs-data.txt
############################# Delete the files produced
rm Provisory*

mkdir Expression_files

mv *LevelExpression_.txt ./Expression_files
mv Header* ./Expression_files

mkdir Other_files
mv HeadEr* ./Other_files
mv *List* ./Other_files
mv Initial-rtPCR-data-WithoutHeader.txt ./Other_files
mv *Matches* ./Other_files
mv Primers* ./Other_files
mv TranscriptsColumn.txt ./Other_files
mv BestPairs-RNA-Seq_VS_rtPCR.txt ./Other_files


echo "End...script7"
date



#################################################################################################################################################
######################################################################################################################################### The End... (for now)
