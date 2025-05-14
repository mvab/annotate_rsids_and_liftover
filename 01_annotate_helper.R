suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(vroom))
suppressPackageStartupMessages(library(readr))
suppressPackageStartupMessages(library(tidyr))

# ----------------------------------------
# Process arguments
# ----------------------------------------

args <- commandArgs(trailingOnly = TRUE)
rsid_subset_file <- args[1] # "tmp_files/chr_pos_list_w_rsid_split.txt"
gwas_file_in <- args[2]
print(paste0("Input GWAS to annotate: ",gwas_file_in))
gwas_file_out <- args[3]
print(paste0("Output GWAS with rsIDs: ",gwas_file_out))

# ----------------------------------------
# Read and tidy data (GWAS and annotation)
# ----------------------------------------

print("Reading and processing GWAS data ..")
gwas_data <- vroom::vroom(gwas_file_in,
    col_select = c(ID, CHROM, GENPOS, A1FREQ, ALLELE0, ALLELE1, BETA, SE, LOG10P), show_col_types=F) %>%
  dplyr::rename("CHR" = "CHROM", "POS" = "GENPOS") %>%
  dplyr::mutate(P = 10^-(LOG10P)) %>%
  dplyr::mutate(CHR = ifelse(CHR == 23, "X", CHR)) %>%
  dplyr::mutate(chr_pos = paste0(CHR, ":", POS))

print("Reading and processing rsID annotation data ..")
annot <- vroom::vroom(rsid_subset_file, col_names = c("SNP", "CHR", "POS", "ALLELE0", "ALLELE1"), show_col_types=F)
# tidy up multiallelic varaints (they are listed in a signle row e.g A:TA,TAA,TAAA - this will split them into multiple rows)
annot <- annot %>% tidyr::separate_rows(ALLELE1, sep = ",") 

# ----------------------------------------
# Merging annotation data
# ----------------------------------------

print("Merging annotation file ..")
#  merge by the same or opposite alleles to capture all SNPs
gwas_data_merged <- gwas_data %>%
  dplyr::left_join(annot %>% select(SNP, CHR, POS, ALLELE0, ALLELE1),
    by = c("CHR" = "CHR", "POS" = "POS", "ALLELE0" = "ALLELE0", "ALLELE1" = "ALLELE1")
  ) %>%
  dplyr::rename(SNP1 = SNP) %>%
  dplyr::left_join(annot %>% select(SNP, CHR, POS, ALLELE0, ALLELE1),
    by = c("CHR" = "CHR", "POS" = "POS", "ALLELE0" = "ALLELE1", "ALLELE1" = "ALLELE0")
  ) %>%
  dplyr::rename(SNP2 = SNP)

# ----------------------------------------
# Tidying up and saving
# ----------------------------------------
print("Tidying up ..")
gwas_data_merged <- gwas_data_merged %>%
  dplyr::select(-ID, -chr_pos) %>%
  dplyr::mutate(SNP = coalesce(SNP1, SNP2)) %>%
  dplyr::select(SNP, everything(), -SNP1, -SNP2) %>%
  dplyr::mutate(SNP = ifelse(is.na(SNP), paste0(CHR, ":", POS), SNP)) %>% # if rs missing, use chr:pos
  dplyr::distinct()
print(head(gwas_data_merged))

print("Saving ..")
vroom::vroom_write(gwas_data2, file = gwas_file_out)

print("Finished adding rsID annotation to your GWAS. Yay!")