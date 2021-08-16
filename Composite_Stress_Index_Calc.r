library(tidyquant)
library(matrixcalc)
library(tibble)
library(timetk)
library(roll)

# Implementation of Composite index of systemic stress 
# Data import though various sources such as FRED, YFINANCE and QUNADL.
# Dependent packages: "caTools", "tibble", "tidyquant", "timetk", "matrixcalc"


### functions, will be used to calculate composite index

# CMAX Maximum Draw-down function 


cmax = function(x, windows){
  empty = rep(NA, length(x))
  for (i in 1:length(x) - windows)
  {
    empty[i] = (1 - x[i]) / max(x[i:i+windows])
  }
  return(empty)
}

# Random Weight Generator 
wmat = function(iter){
  w_mat = matrix(sample.int(30, size = iter * 6, replace = TRUE), ncol = 6)
  for (i in 1:dim(w_mat)[1]){
    w_mat[i, ] = w_mat[i, ] / sum(w_mat[i, ])
  }
  wmat = round(w_mat, 2)
  return(wmat)
}

# Log-return function 
returns = function(x){
  return(log(x) - log(lag(x)))
}

# Extracting epsilon function
idiosyncratique = function(x, y){
  model = lm(y ~ x)
  return(residuals(model))
}

# Normalize between 0 and 1
MinMaxScaler = function(x){
  return(((x - min(x))) / (max(x) - min(x)))
}

RealVol = function(x){
  realvol = sqrt(sum(returns(x)^2))
  return(realvol)
}

# In order to import data from FRED and QUANDL, provide a valid FRED and QUANDL API key.

### S1 Money Market 
# Effective Federal Funds Rate
# 3-Month London Inter-bank Offered Rate (LIBOR), based on U.S. Dollar
# 3-Month Treasury Constant Maturity Minus Federal Funds Rate 
# European Emergency Lending Facilitate
quantmod::getSymbols("DFF", src = "FRED") # s0 # risk free rate
quantmod::getSymbols("USD3MTD156N", src = "FRED") # S11
quantmod::getSymbols("ECBMLFR", src = "FRED") # S12
quantmod::getSymbols("T3MFF", src = "FRED") # S13

### S2 Bond Market
# TED SPREAD
# MOODYS Seasoned AAA Corporate Bond Minus Federal Funds Rate
# 10-Year Treasury Constant Maturity Minus 2-Year Treasury Constant Maturity 
quantmod::getSymbols("TEDRATE", src = "FRED") #S21
quantmod::getSymbols("AAAFF", src = "FRED") #s22
quantmod::getSymbols("T10Y2Y", src = "FRED") #s23

### S3 Equity Market
# NASDAQ
quantmod::getSymbols("NASDAQCOM", src = "FRED") #s31
#s32 Maximum draw-downs of 170 moving windows on NASDAQ
#s33 Bond (3 month bond yield) and Stock correlation 

### S4 Financial Intermediaries
# ICE BOFA Private Sector Financial Emerging Markets Corporate Plus Index Option-Adjusted Spread
# NASDAQ QFIN  
quantmod::getSymbols("BAMLEMFSFCRPIOAS", src = "FRED")
FinSector = Quandl::Quandl("NASDAQOMX/OFIN", type = "xts")

### S5 FOREX Market
# USD/EURO
# JPY/USD
# USD/GDP
quantmod::getSymbols("DEXUSEU", src = "FRED")
quantmod::getSymbols("DEXJPUS", src = "FRED")
quantmod::getSymbols("DEXUSUK", src = "FRED")

### S6 Commodities
# CBOE Gold ETF Volatility index
# Crude Oil Prices: West Texas Intermediate
# 10-Year Break even Inflation Rate
gold = Quandl::Quandl("LBMA/GOLD", type = "xts")
quantmod::getSymbols("DCOILWTICO", src = "FRED")
quantmod::getSymbols("T10YIE", src = "FRED")
### XTS to tibble and Data Transforming 

s11 = zoo::na.locf(timetk::tk_tbl(USD3MTD156N))
s11$USD3MTD156N = rollapply(s11$USD3MTD156N, width = 22, FUN = sd, fill = NA)
s12 = zoo::na.locf(timetk::tk_tbl(ECBMLFR))
s12$ECBMLFR = rollapply(s12$ECBMLFR, width = 22, FUN = sd, fill = NA)
s13 = zoo::na.locf(timetk::tk_tbl(T3MFF))
s13$T3MFF = abs(s13$T3MFF)

# Checking S1
#par(mfrow = c(3, 1))
#plot(s11$USD3MTD156N, type = "l")
#plot(s12$ECBMLFR, type = "l")
#plot(s13$T3MFF, type = "l")

s21 = zoo::na.locf(timetk::tk_tbl(TEDRATE))
s22 = zoo::na.locf(timetk::tk_tbl(AAAFF))
s22$AAAFF = rollapply(s22$AAAFF, width = 22, FUN = sd, fill = NA)
s23 = zoo::na.locf(timetk::tk_tbl(T10Y2Y))
s23$T10Y2Y = rollapply(s23$T10Y2Y, width = 22, FUN = sd, fill = NA)

# Checking S2

#plot(s21$TEDRATE, type = "l")
#plot(s22$AAAFF, type = "l")
#plot(s23$T10Y2Y, type = "l")

s31 = zoo::na.locf(timetk::tk_tbl(NASDAQCOM))
date_s31 = as.Date(s31$index)[2:length(s31)]
s31$NASDAQCOM = rollapply(returns(s31$NASDAQCOM), width = 22, FUN = sd, fill = NA)
date_s32 = as.Date(s31$index) # CMAX
s32 = dplyr::bind_cols(date_s32, cmax(s31$NASDAQCOM, windows = 170))
colnames(s32) = c("index", "cmax_s32")
s33_bis = dplyr::full_join(s13, s31, by = "index")
s33 = s33_bis %>%
  dplyr::mutate(roll = roll::roll_cor(T3MFF, NASDAQCOM, width = 22 * 12)) %>%
  dplyr::select(index, roll)

# Checking s3
#plot(s31$NASDAQCOM, type = "l")
#plot(s32$cmax_s32, type = "l")
#plot(s33$roll, type = "l")

s41 = zoo::na.locf(timetk::tk_tbl(BAMLEMFSFCRPIOAS))
s42 = zoo::na.locf(timetk::tk_tbl(FinSector))
date = as.Date(s42$index)
s42 = s42[, 1:2]
s42_bis1 = zoo::na.locf(timetk::tk_tbl(NASDAQCOM))
s42_bis1$NASDAQCOM = returns(s42_bis1$NASDAQCOM)
s42_bis = dplyr::full_join(s42_bis1, s42, by = "index")
s42_bis = zoo::na.locf(s42_bis)
date = as.Date(s42_bis$index)
s42$`Index Value` = rollapply(returns(s42$`Index Value`), width = 22, FUN = sd, fill = NA)
s43 = dplyr::bind_cols(date, idiosyncratique(x = s42_bis$`Index Value`, y = s42_bis$NASDAQCOM))
colnames(s43) = c("index", "extraret")

# Checking S4
#plot(s41$BAMLEMFSFCRPIOAS, type = "l")
#plot(s42$`Index Value`, type = "l")
#plot(s43$extraret, type = 'l')

s51 = zoo::na.locf(timetk::tk_tbl(DEXUSEU))
s51$DEXUSEU = rollapply(s51$DEXUSEU, width = 22, FUN = sd, fill = NA)
s52 = zoo::na.locf(timetk::tk_tbl(DEXJPUS))
s52$DEXJPUS = rollapply(s52$DEXJPUS, width = 22, FUN = sd, fill = NA)
s53 = zoo::na.locf(timetk::tk_tbl(DEXUSUK))
s53$DEXUSUK = rollapply(s53$DEXUSUK, width = 22, FUN = sd, fill = NA)

# Checking S5
#plot(s51$DEXUSEU, type = "l")
#plot(s52$DEXJPUS, type = "l")
#plot(s53$DEXUSUK, type = "l")

s61 = zoo::na.locf(timetk::tk_tbl(gold))[, 1:2]
s61$`USD (AM)` = rollapply(returns(s61$`USD (AM)`), width = 22, FUN = sd, fill = NA)
s62 = zoo::na.locf(timetk::tk_tbl(DCOILWTICO))
s62$DCOILWTICO = rollapply(s62$DCOILWTICO, width = 22, FUN = sd, fill = NA)
s63 = zoo::na.locf(timetk::tk_tbl(T10YIE))
s63$T10YIE = rollapply(s63$T10YIE, width = 22, FUN = sd, fill = NA)

# Checking S6
#plot(s61$`USD (AM)`, type = "l")
#plot(s62$DCOILWTICO, type = "l")
#plot(s63$T10YIE, type = "l")

# Merging data set 

s00 = dplyr::left_join(s11, s12)
s00 = dplyr::left_join(s00, s13)
s00 = dplyr::left_join(s00, s21)
s00 = dplyr::left_join(s00, s22)
s00 = dplyr::left_join(s00, s23)
s00 = dplyr::left_join(s00, s31)
s00 = dplyr::left_join(s00, s32)
s00 = dplyr::left_join(s00, s33)
s00 = dplyr::left_join(s00, s41)
s00 = dplyr::left_join(s00, s42)
s00 = dplyr::left_join(s00, s43)
s00 = dplyr::left_join(s00, s51)
s00 = dplyr::left_join(s00, s52)
s00 = dplyr::left_join(s00, s53)
s00 = dplyr::left_join(s00, s61)
s00 = dplyr::left_join(s00, s62)
s00 = dplyr::left_join(s00, s63)

colnames(s00) = c("date", "s11", "s12", "s13", 
                 "s21", "s22", "s23", 
                 "s31", "s32", "s33", 
                 "s41", "s42", "s43", 
                 "s51", "s52", "s53", 
                 "s61", "s62", "s63")


S00 = na.omit(zoo::na.locf(s00))
date = S00$date

S0 = subset(S00, select = -date)
ranked = apply(s0, 2, dplyr::dense_rank)

# Mean each markets
S1 = rowMeans(S0[, 1:3])
S2 = rowMeans(S0[, 4:6])
S3 = rowMeans(S0[, 7:9])
S4 = rowMeans(S0[, 10:12])
S5 = rowMeans(S0[, 13:15])
S6 = rowMeans(S0[, 16:18])

data = dplyr::bind_cols(date, S1, S2, S3, S4, S5, S6)
colnames(data) = c("date", "S1", "S2", "S3", "S4", "S5", "S6")

# Normalizing input data
mat = data[, 2:7]
data = tibble::as_tibble((apply(mat, 2, MinMaxScaler)))

# HADAMARD Multiplication
hadamard = function(){
  w = rep(1.6, 6)
  mat_  = matrix(NA, nrow = dim(data)[1], ncol = 6)
  for (i in 1:dim(data)[1])
      {
        mat_[i, ] = hadamard.prod(t(w), as.matrix(data[i, ]))
      }
  return(mat_)  
}

# HADAMARD Multiplication with random weight generator 

rhadamard = function(){
  empty_mat = matrix(NA, 1000, 6, 1000)
  w_mat = wmat(iter = 1000)
  for (i in 1: 1000){
  }
}

# CISS calculation

ciss = function(windows){
  roll_cor = roll::roll_cor(as.matrix(mat), width = windows)
  value = array(NA, dim(roll_cor)[3])
  w_mat = wmat(iter = 1000)
  hadam = hadamard()
  for(i in 1:dim(roll_cor)[3] - windows){
    value[i] = t(hadam[i + windows, ]) %*% roll_cor[, , i + windows] %*% hadam[i + windows, ]
  }
  return(value)
}

index = dplyr::bind_cols(as.Date(date), ciss(windows = 5))
plot(index, xlab = "time", ylab = "Stress index", type = "l")
