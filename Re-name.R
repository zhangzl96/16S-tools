library(dplyr)

### 1-Rename OTUID in the feature table
feature.table <- read.table("../1_QiimeOutput/rarefied_feature-table.tsv",
                             row.names = 1, sep = "\t", header = TRUE)
## The file "rarefied_feature-table.tsv", constructed from biom file, needs to be modified：
# Remove first row"# Constructed from biom file"
# Remove the "#" and " " in the second row

idx <- order(rowSums(feature.table), decreasing = T)
feature.table <- feature.table[idx,]

oldID <- rownames(feature.table)
ASVID <- paste("ASV", 1:nrow(feature.table), sep = "")
id_map <- data.frame(oldID, ASVID)
write.table(id_map, "id_map.txt", sep = "\t", quote = FALSE,
            col.names = FALSE, row.names = FALSE)

feature.table <- cbind(ASVID, feature.table)
write.table(feature.table, "asv.txt", quote = FALSE,
            row.names = FALSE, col.names = TRUE, sep = "\t")

### 2-Rename feature ID in taxonomy table
tax <- read.delim("../1_QiimeOutput/taxonomy.tsv")
rownames(tax) <- tax$Feature.ID
names(ASVID) = oldID
newFeatureID <- ASVID[tax$Feature.ID]
tax$Feature.ID <- newFeatureID
tax_filtered <- tax[!is.na(tax$Feature.ID), ]
final_taxo <- data.frame(tax_filtered$Feature.ID, tax_filtered$Taxon)
colnames(final_taxo) <- c("ASVID", "Taxonomy")

write.table(final_taxo, "taxonomy.tsv", quote = FALSE,
            row.names = FALSE, col.names = TRUE, sep = "\t")


### 3-Rename the sequence ID in fasta file use Rename-seqs.py

### 4 Rename the IDs in tree file
id_map <- data.frame(oldID, ASVID)

# Import idmap.txt file
# id_map <- read.table("idmap.txt", header = FALSE, stringsAsFactors = FALSE)
colnames(id_map) <- c("oldID", "newID")

id_dict <- setNames(id_map$newID, id_map$oldID)

# Import roooted-tree file
test_data <- readLines("../1_QiimeOutput/rooted-tree.nwk")

# Rename ID
test_data_replaced <- sapply(test_data, function(line) {
  for (old_id in names(id_dict)) {
    line <- gsub(old_id, id_dict[old_id], line)
  }
  return(line)
})

# Save rooted-tree file with new ID
writeLines(test_data_replaced, "rooted-tree.nwk")


# Import unroooted-tree file
test_data <- readLines("../1_QiimeOutput/unrooted-tree.nwk")
# 替换oldID为newID
test_data_replaced <- sapply(test_data, function(line) {
  for (old_id in names(id_dict)) {
    line <- gsub(old_id, id_dict[old_id], line)
  }
  return(line)
})
# Save unrooted-tree file with new ID
writeLines(test_data_replaced, "unrooted-tree.nwk")