# GWAS rsid annotation and liftOver (code and readme - work in progress)



## Summary

This repo contains workflow / scripts for:
 
(1) annotating GWAS with rsIDs (e.g in regenie, when only CHR and GENPOS columns are present)

(2) performing liftover of genome build (38/37)


Annotation and liftover can be done as a part of one workflow or completely independently. 

## Workflow

*Please note:*

- remember to make all `.sh` files executable (`chmod 777 file.sh`)
- it is recommended to do this on a server, as it might be very slow in a local environment

### Obtaining genome reference data

Scripts in this section only need to be run once.

#### Data for annotation

Script to download dbSNP v151 in VCF format, and subset to only the required columns.

*To run:*

```
./00_download_ref_data_annotation.sh
```
 
*Output:*
`refdata/dbSNP151_refdata_build38.txt`

#### Data for Liftover

Script to download chain files for liftover. Must specify the starting genome build (38 or 37). 

*To run:*

```
./00_download_ref_data_liftover.sh 38 # specify build 38 or 37
```

*Output:*
`refdata/hg38ToHg19.over.chain` or `refdata/hg19ToHg38.over.chain`

### (1) Genome annotation

Script for performing rsID annotation; The main `.sh` script internally calls `.R` script:

```
├── 01_annotate_GWAS_with_rsids.sh
    └── 01_annotate_helper.R
```

_Assumptions:_

- The input GWAS file is in regenie format (column order and names - modify those in your file if needed before running the script):
`CHROM	GENPOS	ID	ALLELE0	ALLELE1	A1FREQ	INFO	N	TEST	BETA	SE	CHISQ	LOG10P	EXTRA`
- The input GWAS file name does not contain dots in the file name; only to separate the file extension:
	- `my_GWAS.txt.gz` - ok
	- `my.GWAS.txt.gz` - not ok

- If running on a server, make sure you load the necessary R module: (e.g. for Exeter, uncomment line 42 in `01_annotate_GWAS_with_rsids.sh`)

- The script accepts the reference annotation data (`refdata/dbSNP151_refdata_build38.txt`) generated earlier using `00_download_ref_data_annotation.sh`, so it assumes that the input GWAS data is in build 38

*To run:*

Provide _full paths_ to refdata and your GWAS:

```
./01_annotate_GWAS_with_rsids.sh /path/to/refdata/dbSNP151_refdata_build38.txt /path/to/your/GWAS.txt.gz
```

*Output:* `/path/to/your/GWAS_rsids.txt.gz`


### (2) Genome Liftover

Script for performing liftOver:

```
02_liftover_GWAS.sh
```



- If running on a server, make sure you load the necessary R module: (e.g. for Exeter, uncomment line 42 in `01_annotate_GWAS_with_rsids.sh`)


*Output:* `/path/to/your/GWAS_rsids_b37.txt.gz`
