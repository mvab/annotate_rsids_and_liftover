#!/bin/bash

#### Workflow for performing LiftOver of genome build (37<->38) ####
# to run:
# ./02_liftover_GWAS.sh /path/to/your/GWAS.txt.gz /path/to/refdata/ 38

# Get arguments 
input_GWAS=$1 # GWAS file (from previous step or separate file);
              # provide full path; assumes no dots in file name except the ones separating the extension (e.g. ".txt.gz")
              # GWAS file is expected to be in a standard REGENIE output (see README)

ref_data_dir=$2 # can be refdata/ folder where 00_download_ref_data_liftover.sh saved file or your own location
current_build=$3 # starting build; if 38, it will be converted to 37; if 37, it will be converted to 38


# Separate GWAS file basename and extension
basename="${input_GWAS%%.*}"
extension="${input_GWAS#$basename}" 


## Perform lifover in the specified direction
#module load R-bundle-Packages/4.3.2-20240227-gfbf-2023a (for use on Exeter servers only - uncomment)

if [[ "$current_build" == 38 ]]; then 
    echo "---------- Running R script to perform liftover build 38 -> build 37 ---------- "
    Rscript 02_liftover_helper.R "$current_build" "$ref_data_dir" "$input_GWAS" "$basename"_b37.txt.gz

elif [[ "$current_build" == 37 ]]; then 
    echo "---------- Running R script to perform liftover build 37 -> build 38 ---------- "
    Rscript 02_liftover_helper.R "$current_build" "$ref_data_dir" "$input_GWAS" "$basename"_b38.txt.gz
else 
    echo "No or incorrect build specified; options: 38 or 37"
fi