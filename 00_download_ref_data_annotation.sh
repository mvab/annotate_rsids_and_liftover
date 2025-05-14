 #!/bin/bash

# Download dbSNP ref data that contains chr:pos -> rsid mapping;
# This refdata will be used to annotate a GWAS that does not contain rsIDs

mkdir -p refdata


# download dbSNP data (version 151) for build 38 (VCF format)
#wget -c https://ftp.ncbi.nlm.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/00-All.vcf.gz -O refdata/00-All_b38.vcf.gz

# extract only required columns:  rsid, chr:pos, chr:pos:ref:alt
# NB the alt column contains multiallelic data stored per row comma-separated : e.g. could be C,G or TA,TAA
zless refdata/00-All_b38.vcf.gz | grep -v "#" | awk -v OFS='\t' '{print $3, $1":"$2, $1":"$2":"$4":"$5}'  > refdata/dbSNP151_refdata_build38.txt

# optionally remove the original data to save space
#rm refdata/00-All_b38.vcf.gz