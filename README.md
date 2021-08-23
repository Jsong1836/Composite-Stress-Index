# Composite-Stress-Index

This index was calculated by following the general method of the European Central Bank's Composite 
index of systemic stress index available on European Central bank's statistical warehouse as CISS. Data import
process is automatized by "Quantmod" and "Qunadl" where there are three main data sources (Fred, Yahoo, Quandl). 
Since these data sources are free, this function can be used with different source of financial stress that 
users think more efficient in order to capture financial stress. The main difference from the ECB's calculation, 
this index includes commodity market as a source of financial stress. "S" symbol indicate a segment of financial market as follow:

"S1" : Money market
"S2" : Bond market
"S3" : Equity market
"S4": Financial intermediaries
"S5": Forex market 
"S6": Commodity market 

For now, 3 sub-index of stress for each market are selected based on correlation and impulse response analysis. 
