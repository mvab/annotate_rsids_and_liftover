 #!/bin/bash

# Download dbSNP ref data that contains chr:pos -> rsid mapping;
# This refdata will be used to annotate a GWAS that does not contain rsIDs
# ./00_download_ref_data_annotation.sh 38 157

# load bcftools  (Exeter users only)
module load BCFtools/1.10.2-GCC-9.3.0


mkdir -p refdata

build_needed=$1
dbSNP_version="${2:-157}" # v157 will be used as default if nothing is specifed

## 1) Download specified annotation data
if [[ "$build_needed" == 38 && "$dbSNP_version" == 151 ]]; then
    echo "Downloading dbSNP data (version $dbSNP_version) for build $build_needed (VCF format)"
#    wget -c https://ftp.ncbi.nlm.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/00-All.vcf.gz -O refdata/00-All_b38.vcf.gz

elif [[ "$build_needed" == 37 && "$dbSNP_version" == 151 ]]; then
    echo "Downloading dbSNP data (version $dbSNP_version) for build $build_needed (VCF format)"
#    wget -c https://ftp.ncbi.nlm.nih.gov/snp/organisms/human_9606_b151_GRCh37p13/VCF/00-All.vcf.gz -O refdata/00-All_b37.vcf.gz


elif [[ "$build_needed" == 38 && "$dbSNP_version" == 157 ]]; then
    echo "Downloading dbSNP data (version $dbSNP_version) for build $build_needed (VCF format)"
#    wget -c https://ftp.ncbi.nih.gov/snp/archive/b157/VCF/GCF_000001405.40.gz -O refdata/00-All_b38_unprocessed.vcf.gz
#    wget -c https://ftp.ncbi.nih.gov/snp/archive/b157/VCF/GCF_000001405.40.gz.tbi -O refdata/00-All_b38_unprocessed.vcf.gz.tbi

elif [[ "$build_needed" == 37 && "$dbSNP_version" == 157 ]]; then
    echo "Downloading dbSNP data (version $dbSNP_version) for build $build_needed (VCF format)"
#    wget -c https://ftp.ncbi.nih.gov/snp/archive/b157/VCF/GCF_000001405.25.gz -O refdata/00-All_b37_unprocessed.vcf.gz
#    wget -c https://ftp.ncbi.nih.gov/snp/archive/b157/VCF/GCF_000001405.25.gz.tbi -O refdata/00-All_b37_unprocessed.vcf.gz.tbi

else
    echo "[ERROR] Invalid build: $build_needed (expected 37 or 38) or Invalid dbSNP version: $dbSNP_version (expected 151 or 157)"
    exit 1
fi
echo "=== done ==="


## 2) Re-process chr col in dbSNP 157 data

if [[ "$dbSNP_version" == 157 ]]; then

     if [[  -f refdata/00-All_b"$build_needed"_unprocessed.vcf.gz ]]; then
         echo "Updating CHR column in dbSNP data (version $dbSNP_version) for build $build_needed"
         bcftools annotate -h supplementary/header_fix.txt --rename-chrs supplementary/b"$build_needed"_chr_annot.txt refdata/00-All_b"$build_needed"_unprocessed.vcf.gz -O z -o refdata/00-All_b"$build_needed".vcf.gz
     else
 	 echo "[ERROR] Missing unprocessed files for dbSNP v157 data. Can't proceed. "
         exit 1
     fi

elif [[ "$dbSNP_version" == 151 ]]; then
      # nothing to do for this version
      echo " "
fi

echo "=== done ==="

## 3) Extracting the required cols for the annotation

# extract only required columns:  rsid, chr:pos, chr:pos:ref:alt
# NB the alt column contains multiallelic data stored per row comma-separated : e.g. could be C,G or TA,TAA
echo "Extracting the required annotation columns from dbSNP data (version $dbSNP_version) for build $build_needed"
#zcat refdata/00-All_b"$build_needed".vcf.gz | grep -v "#" | awk -v OFS='\t' '{print $3, $1":"$2, $1":"$2":"$4":"$5}'  > refdata/dbSNP"$dbSNP_version"_refdata_build"$build_needed".txt # this method outputs less
bcftools query -f '%ID\t%CHROM:%POS\t%CHROM:%POS:%REF:%ALT\n' refdata/00-All_b"$build_needed".vcf.gz  > refdata/dbSNP"$dbSNP_version"_refdata_build"$build_needed".txt

# optionally remove the original data to save space
# rm refdata/*.vcf.gz*

echo "=== done ==="
