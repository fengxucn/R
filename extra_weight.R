#!/usr/bin/env Rscript
library("optparse")
library(data.table)

option_list = list(
  make_option(c("-r", "--rdata"), type="character", default=NULL, 
              help="rdata file name  [default= %default]", metavar="character"),
  make_option(c("-v", "--vcfdata"), type="character", default=NULL, 
              help="vcf data file name  [default= %default]", metavar="character"),
  make_option(c("-e", "--extra"), type="character", default="~/extra.csv", 
              help="extra output file name or path  [default= %default]", metavar="character"),
  make_option(c("-w", "--weight"), type="character", default="~/weight.csv", 
              help="weight output file name or path  [default= %default]", metavar="character")
); 
 
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

if (is.null(opt$rdata) || is.null(opt$vcfdata)){
  print_help(opt_parser)
  stop("At least two arguments must be supplied (rdata and cvfdata).n", call.=FALSE)
}

rdata <- opt$rdata
vcfdata <- opt$vcfdata
output_extra <- opt$extra
output_weight <- opt$weight

message("generate the extra data...")
load(rdata)
d1 = info[,c(1,1,5,4)]
df = data.frame(d1)
names(df) <- c("gene", "genename","R2","n.snps")
write.csv(df, file = output_extra,row.names=FALSE)
message("extra data ready")

message("loading vcf data...")
vcf <- fread(vcfdata)
d1 = vcf[,c(3,4,5)]
d2<- data.frame(d1)

message("generate the weight data...")
df1 <- do.call(rbind, NET)
df2 = data.frame(df1)
df3 = merge(df2, d2, by.x="SNP.RS.ID", by.y="V3")
df3$x <- paste(df3$SNP.chromosome,df3$SNP.basepair.position,sep=":")
result = df3[,c(9,6,3,7,8)]
names(result) <- c("rsid", "gene","weight","ref_allele","eff_allele")
write.csv(result, file = output_weight,row.names=FALSE)
message("weight data ready")
