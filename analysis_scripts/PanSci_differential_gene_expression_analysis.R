class_tpm <- function(cds, class_vector){
    cds.class.mean <- class_means(cds, class_vector)
    col.sum = Matrix::colSums(cds.class.mean)
    return(t((t(cds.class.mean)/col.sum) * 1e+06))
}


find_DE_cluster_batch_regressed_out <- function (cds, 
                                                 DE_conditions, 
                                                 core_number, 
                                                 reduced_Model_Formula_Str = "~ num_genes_expressed + Sex") 
{
    ## Ensure to load these packages
    ## suppressMessages(library(monocle))
    ## suppressMessages(library(dplyr))
    ## suppressMessages(library(tidyverse))
    ## suppressMessages(library(Matrix))
    
    ## Estimate the size factors for each cell to normalize for differences 
    ## in squencing depth across cells
    
    cds = estimateSizeFactors(cds)

    ## Identify the conditions or cell types used for classification
    cell_type = as.character(DE_conditions)
    
    cat("\nCalculate the top expressed cluster of each gene...")

    ## cds is first normalized by the size factors then calculate the TPM values for each gene
    ## across the different cell types/conditions. The output is a matrix where each column
    ## represents a cell type, and each row represents a gene, with values being the TPM 
    ## normalized expression levels
    cds_class_tpm <- class_tpm(cds, cell_type)

    ## Class_label is a list of cell types/conditions
    class_label = colnames(cds_class_tpm)

    ## Annotating each cell with its corresponding cell type
    pData(cds)$tmp = factor(cell_type)

    ## Identification of top expressed cell types for each gene
    top_2_cell_type <- do.call(rbind, apply(cds_class_tpm, 1, 
        function(expression_levels) {
            ordered_indices = order(expression_levels, decreasing = TRUE)
            ordered_expression_levels = expression_levels[ordered_indices]
            return(list(max.tissue = class_label[ordered_indices[1]], 
                        second.tissue = class_label[ordered_indices[2]],
                        max.expr = unname(ordered_expression_levels[1]), 
                        second.expr = unname(ordered_expression_levels[2]), 
                        fold.change = (unname(ordered_expression_levels[1]) + 0.01)/
                                      (unname(ordered_expression_levels[2]) + 0.01)))
        }))
    ## Construct a dataframes which contains information about the top and second top
    ## cell types for each gene, their respective expression levels, and the fold change
    ## between them.
    top2 <- as.data.frame(top_2_cell_type) %>% mutate(class = max.tissue)
    top2$gene_id = rownames(top_2_cell_type)
    top2$class = as.character(top2$class)
    top2$gene_id = as.character(top2$gene_id)
    
    cat("\nStart DE analysis for each cluster")

    ## Calculate the Gene count for each cells
    if (!("num_genes_expressed" %in% names(pData(cds)))) {
        cat("\nData does not have num_genes_expressed column, add detected gene number per cell column...\n")
        cds$num_genes_expressed = Matrix::colSums(exprs(cds) > 0)
    }

    ## Construct the full model formula - defines the how gene expression levels relate to
    ## experimental conditions, cell types, or other coveriates
    full_Model_Formula_Str = paste(reduced_Model_Formula_Str, "+ tmp", sep = "")

    ## Conduct the DE analysis using differentialGeneTest from Monocle2
    ## The reducedModelFormula defines the covariates need to be excluded
    ## It helfs to identify genes for which the excluded covariates significantly explain
    ## variabiliy in gene expression

    ### Monocle2 performs a statistical test (like the LRT) to compare the two models 
    ### for each gene. This test evaluates whether the inclusion of tmp significantly improves 
    ### the fit of the model to the data, which would indicate that the gene's expression is 
    ### significantly affected by tmp (cell types/conditions).
    
    DE.genes = differentialGeneTest(cds, fullModelFormulaStr = full_Model_Formula_Str,
        reducedModelFormulaStr = reduced_Model_Formula_Str, cores = core_number)

    ## Format DE analysis result
    DE.genes$gene_id = as.character(DE.genes$gene_id)
    DE.genes$gene_short_name = as.character(DE.genes$gene_short_name)
    
    cat("\n combine the DE genes and top tissues")
    
    ## Combining DE results with previously identified top expressed tissues for each gene
    rownames(top2) = top2$gene_id
    top2 = top2 %>% select(-gene_id)
    result = cbind(DE.genes, top2[rownames(DE.genes), ])
    result$qval = (as.numeric(as.character(result$qval)))

    ## Reformat the DE results
    result_2 = lapply(1:length(result), function(x) {
        unlist(result[[x]])
    })
    result_2 = as.data.frame(result_2)
    colnames(result_2) = names(result)
    return(result_2)
}