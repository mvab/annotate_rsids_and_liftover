 #!/bin/bash

# Download chain files need for performing GWAS liftover;
# Specify the starting build: ./00_download_ref_data_liftover.sh 38


mkdir -p refdata

build_needed=$1

if [[ "$build_needed" == 38 ]]; then 
    echo "Downloading chain file for liftOver in the 38 -> 37 direction"
    wget -c https://hgdownload.soe.ucsc.edu/goldenPath/hg38/liftOver/hg38ToHg19.over.chain.gz  -O refdata/hg38ToHg19.over.chain.gz
    gunzip refdata/hg38ToHg19.over.chain.gz 
elif [[ "$build_needed" == 37 ]]; then 
    echo "Downloading chain file for liftOver in the 37 -> 38 direction"
    wget -c https://hgdownload.cse.ucsc.edu/goldenpath/hg19/liftOver/hg19ToHg38.over.chain.gz -O refdata/hg19ToHg38.over.chain.gz
    gunzip refdata/hg19ToHg38.over.chain.gz
else 
    echo "No or incorrect build specified; options: 38 or 37"
fi