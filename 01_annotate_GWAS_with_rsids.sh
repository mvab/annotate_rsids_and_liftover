#!/bin/bash

#### Workflow for annotating GWAS with rsids from dbSNP ####
# to run:
# ./01_annotate_GWAS_with_rsids.sh /path/to/refdata/dbSNP151_refdata_build38.txt /path/to/your/GWAS.txt.gz

# Get arguments 
dbSNP_data=$1 # dbsnp ref file generated in the previous step
raw_file=$2 # GWAS file; provide full path; assumes no dots in file name except the ones separating the extension (e.g. ".txt.gz")
            # GWAS file is expected to be in a standard REGENIE output (see README)

# Separate GWAS file basename and extension
basename="${raw_file%%.*}"
extension="${raw_file#$basename}" 

mkdir -p tmp_files

# 1) Replace chr 23 in GWAS file with X, because dbSNP data contains it as X
echo "---------- Preparing GWAS ----------"
gunzip "$basename$extension" # unzip
awk '{ if ($1 != 23) { print }
       else if ($1 == 23) { $1 = "X"; print }
     }' "$basename".txt > tmp_files/tmp_file
gzip "$basename".txt # zip again

# 2) Extract chr:pos present in GWAS file from the dbSNP ref file
echo "---------- Extracting GWAS SNPs from dbSNP ref file ---------- "

# create a list of chr:pos to extract
awk 'NR > 1 { print $1, $2}' OFS=':' tmp_files/tmp_file | sort | uniq > tmp_files/chr_pos_list.txt

# extract the list from ref file
grep -Fwf tmp_files/chr_pos_list.txt  "$dbSNP_data" > tmp_files/chr_pos_list_w_rsid.txt

# split chr:pos:ref:alt into four columns in bash to save computing time in R
cat tmp_files/chr_pos_list_w_rsid.txt | cut -d $'\t' -f 1,3 --output-delimiter=$'\t' | tr ':' '\t' >  tmp_files/chr_pos_list_w_rsid_split.txt


# 3) in R, merge rsids to GWAS file # this step is slow ~ 15 mins
echo "---------- Running R script to annotate rsIDs ---------- "
#module load R-bundle-Packages/4.3.2-20240227-gfbf-2023a (for use on Exeter servers only - uncomment)
Rscript 01_annotate_helper.R tmp_files/chr_pos_list_w_rsid_split.txt "$basename$extension" "$basename"_rsids"$extension"
