require(hunspell)

# spearman brown extension formula
sp_brown = function(p,n) n*p / (1 + (n - 1) * p) 

# upper matrix
upper = function(x) x[upper.tri(x)]

# obtain cosine
get_cosine = function(x, norm = FALSE) {
  nam  = rownames(x)
  cos = arma_cosine(x)
  if(norm == TRUE){
    cos[cos>1] = 1
    cos = 1-acos(cos)/pi}
  rownames(cos) = colnames(cos) = nam
  cos}

