 #!/bin/bash

# Download dbSNP ref data that contains chr:pos -> rsid mapping;
# This refdata will be used to annotate a GWAS that does not contain rsIDs
# ./00_download_ref_data_annotation.sh 38

mkdir -p refdata

build_needed=$1

if [[ "$build_needed" == 38 ]]; then
    echo "Downloading dbSNP data (version 151) for build 38 (VCF format)"
    wget -c https://ftp.ncbi.nlm.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/00-All.vcf.gz -O refdata/00-All_b38.vcf.gz

    # extract only required columns:  rsid, chr:pos, chr:pos:ref:alt
    # NB the alt column contains multiallelic data stored per row comma-separated : e.g. could be C,G or TA,TAA
    zcat refdata/00-All_b38.vcf.gz | grep -v "#" | awk -v OFS='\t' '{print $3, $1":"$2, $1":"$2":"$4":"$5}'  > refdata/dbSNP151_refdata_build38.txt

    # optionally remove the original data to save space
    rm refdata/00-All_b38.vcf.gz

elif [[ "$build_needed" == 37 ]]; then
    echo "Downloading dbSNP data (version 151) for build 37 (VCF format)"
    wget -c https://ftp.ncbi.nlm.nih.gov/snp/organisms/human_9606_b151_GRCh37p13/VCF/00-All.vcf.gz -O refdata/00-All_b37.vcf.gz

    # extract only required columns:  rsid, chr:pos, chr:pos:ref:alt
    # NB the alt column contains multiallelic data stored per row comma-separated : e.g. could be C,G or TA,TAA
    zcat refdata/00-All_b37.vcf.gz | grep -v "#" | awk -v OFS='\t' '{print $3, $1":"$2, $1":"$2":"$4":"$5}'  > refdata/dbSNP151_refdata_build37.txt

    # optionally remove the original data to save space
    rm refdata/00-All_b37.vcf.gz

else
    echo "No or incorrect build specified; options: 38 or 37"
fi

