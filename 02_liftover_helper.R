suppressPackageStartupMessages(library(rtracklayer))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(vroom))
suppressPackageStartupMessages(library(tidyr))

# ----------------------------------------
# Process arguments
# ----------------------------------------
args <- commandArgs(trailingOnly = TRUE)
input_build <- as.numeric(args[1])
chain_files <- args[2] # refdata/ folder
gwas_file_in <- args[3]
print(paste0("Input GWAS in build ",input_build ,": ", gwas_file_in))
gwas_file_out <- args[4]
print(paste0("Output GWAS: ",gwas_file_out))

# ----------------------------------------
# Load the required chain file
# ----------------------------------------
if (input_build == 38) {
  chain <- paste0(chain_files, "hg38ToHg19.over.chain") # must be unzipped
} else if (input_build == 37) {
  chain <- paste0(chain_files, "hg19ToHg38.over.chain")
} else {
  stop("Wrong input build provided; options are 38 or 37")
}

# ----------------------------------------
# Read input GWAS data
# ----------------------------------------
paste("Reading data..")
gwas_file <- vroom(gwas_file_in,  show_col_types=F) %>%
	# rename if such cols exist:     
	rename_with(
        	~ case_when(
        	. == "CHROM" ~ "CHR",
        	. == "GENPOS" ~ "BP",
        	. == "POS" ~ "BP",
        	. == "ID" ~ "SNP",
        	TRUE ~ .)) %>%
	     dplyr::mutate(CHR = ifelse(CHR == 23, "X", CHR)) %>%             
             dplyr::mutate(P = 10^-(LOG10P))  


# ----------------------------------------
# Main function for liftover
# ----------------------------------------
liftover_genome <- function(GWAS, path_to_chain) {
  # based on code from:
  # https://github.com/RHReynolds/LDSCforRyten/blob/f915728dd8b387f5a1f29abd7bd4684a2b52e4ef/R/GWAS_formatting_functions.R#L11
  
  # Import chain file
  chain_file <- rtracklayer::import.chain(path_to_chain)
  
  # If GWAS CHR column does not have "chr" in name, add to allow liftover
  if (!stringr::str_detect(GWAS$CHR[1], "chr")) {
    GWAS <- GWAS %>%
      dplyr::mutate(CHR = stringr::str_c("chr", CHR))
  }
  
  # Convert GWAS to GRanges object
  GWAS_GR <- GenomicRanges::makeGRangesFromDataFrame(GWAS,
                                                     keep.extra.columns = TRUE,
                                                     ignore.strand = TRUE,
                                                     seqinfo = NULL,
                                                     seqnames.field = "CHR",
                                                     start.field = "BP",
                                                     end.field = "BP",
                                                     starts.in.df.are.0based = FALSE
  )
  
  GWAS_out <-
    rtracklayer::liftOver(GWAS_GR, chain_file) %>%
    unlist() %>%
    as.data.frame() %>%
    dplyr::rename(
      CHR = seqnames,
      BP = start
    ) %>%
    dplyr::select(-end, -width, -strand) %>%
    dplyr::mutate(CHR = stringr::str_replace(CHR, "chr", ""))
  
  return(GWAS_out)
}

# ----------------------------------------
# Liftover
# ----------------------------------------
paste("Doing liftover..")
if (input_build == 38) {
  gwas_file_lifted <- liftover_genome(GWAS = gwas_file, path_to_chain = chain) %>% dplyr::rename(POS = BP)
} else if (input_build == 37) {
  gwas_file_lifted <- liftover_genome(GWAS = gwas_file, path_to_chain = chain) %>% dplyr::rename(POS = BP)
}

# ----------------------------------------
# Tidy up and save
# ----------------------------------------
paste("Updating rsID and saving")

# identify and remove positions that got lifted incorrectly (e.g. position was not mapped in b37)
gwas_no_rs<- gwas_file_lifted %>% filter(!grepl("rs", SNP)) %>%  separate(SNP, into=c("chr", "pos"), sep=":", remove=F)

to_exclude_chr_mismatch <- gwas_no_rs %>% filter(CHR!=chr) # chr is diff between builds
to_exclude_not_lifted   <- gwas_no_rs %>% filter(CHR==chr & POS==pos)  # chr and pos exactly the same in two builds

paste("Excluding positions due to CHR mismatch after liftover: ", nrow(to_exclude_chr_mismatch))

# for missing rsids use chr:pos
gwas_file_lifted <- gwas_file_lifted %>%
  filter(!SNP %in% c(to_exclude_chr_mismatch$SNP)) %>%
  mutate(SNP = ifelse(grepl("rs", SNP), SNP, paste0(CHR, ":", POS))) 

vroom_write(gwas_file_lifted, gwas_file_out)
print("Finished liftover.")
