# GWAS rsid annotation and liftOver (code and readme - work in progress)


## Summary

This repo contains workflow / scripts for:
 
1) annotating GWAS with rsIDs (when only CHR and POS present)

2) performing liftover of genome build (38/37)



## Workflow

(remember to make all .sh file executable chmod 777)
### Obtain reference data

Scripts in this section only need to be run once.

- dbSNP data for annotation: `https://ftp.ncbi.nlm.nih.gov/snp/organisms/human_9606_b151_GRCh37p13/VCF/`

- chain files for liftover

```
00_download_ref_data_annotation.sh
00_download_ref_data_liftover.sh
```


`chmod 777 00_download_ref_data_annotation.sh` 
Only need to be run once - takes X mins; if run on sertver shared with collegues who would also use this workflow - use a sentralised location to store it

```
chmod 777 00_download_ref_data_liftover.sh
```

To run, specifying data to download:

```
./00_download_ref_data_liftover.sh 38
```
### Annotation

Script for performing rsID annotation; assumes the input data is in build 38.

```
├── 01_annotate_GWAS_with_rsids.sh
    └── 01_annotate_helper.R
```

Assumptions:

The input file is in regenie format (col order and names - modify those if needed before running the script)
`CHROM	GENPOS	ID	ALLELE0	ALLELE1	A1FREQ	INFO	N	TEST	BETA	SE	CHISQ	LOG10P	EXTRA`

If running on server, make sure you load the necessary R module: e.g. 
`module load R-bundle-Packages/4.3.2-20240227-gfbf-2023a`

GWAS file name does not contain dots (i.e `.`) in the file name; only to seprate extension:
    `my.GWAS.txt.gz` -not ok
    `my_GWAS.txt.gz` - ok
### Liftover

Script for performing liftOver:

```
02_liftover_GWAS.sh
```




