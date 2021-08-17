
# Random Weight Generator 

wmat = function(iter){
  w_mat = matrix(sample.int(30, size = iter * 6, replace = TRUE), ncol = 6)
  for (i in 1:dim(w_mat)[1]){
    w_mat[i, ] = w_mat[i, ] / sum(w_mat[i, ])
  }
  wmat = round(w_mat, 2)
  return(wmat)
}

# HADAMARD Multiplication

hadamard = function(data, iter){
  mat_  = matrix(NA, nrow = dim(data)[1], ncol = 6 * iter)
  for (i in 1:dim(data)[1])
  {
    for (j in 1:iter)
    {
      mat_[i, ] = hadamard.prod(t(w_mat[j, ]), as.matrix(data[i, ]))
    }
  }
  return(mat_)
}

# CISS calculation

ciss = function(data, windows){
  roll_cor = roll::roll_cor(as.matrix(data), width = windows)
  value = array(NA, dim(roll_cor)[3])
  w_mat = wmat(iter = 1000)
  hadam = hadamard(data = data)
  for(i in 1:dim(roll_cor)[3] - windows){
    value[i] = t(hadam[i + windows, ]) %*% roll_cor[, , i + windows] %*% hadam[i + windows, ]
  }
  return(value)
}


