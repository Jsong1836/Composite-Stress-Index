# Composite-Stress-Index

This index was calculated by following the general method of the European Central Bank's Composite 
index of systemic stress index available on European Central bank's statistical warehouse as CISS. Data import
process is automatized by "Quantmod" and "Qunadl" where there are three main data sources (Fred, Yahoo, Quandl). 
Since these data sources are free, this function can be used with different source of financial stress that 
users think more efficient in order to capture financial stress. The main difference from the ECB's calculation, 
this index includes commodity market as a source of financial stress. 

"S" symbol indicate a segment of financial market as follows:

"S1" : Money market
"S2" : Bond market
"S3" : Equity market
"S4": Financial intermediaries
"S5": Forex market 
"S6": Commodity market 

For now, 3 sub-indexes of stress for each market are selected based on correlation and impulse response analysis (VAR, VECM). Hence, 3 sub-indexes of 
6 segments of financial market requires 18 sub-indexes by following rules:

1. data avaiability, preferably daily or weekly 
2. sub-indexes are constructed in a way that their correlation becomes high during a high market stress period and they can represent market-wide developments. A good example is Libor or Euribor that skyrocketed in August 2007 that can be viewed as a money market dysfunction.
3. all sub-indexes have sufficiently long historical data for statistical robustess.

The main issue to calculate the composite stress index is data availability. Since european indexes start from 1999 and a series of crisis is rare events, it is hard to define when a crisis actually begun. Therefore, 2 or 3 regimes-switch models are used to recognize these regime changes. Because of ths index's statistical design, a high market stress can distort the previous shape, which can be interpreted as higher market stress than historical market stress. 

One of important element of calculating the index is weights assigned on each market. Here, weights on each market are equaully assigned (0.167). As it is discussed in the ECB's paper, differents weight do not modify the general shape of the index, but it surely affects some market stress to prevail. For example, in our dataset, which 
starts from 2003, eqaul weighted index shows Subprime crisis and European debt crisis are relatively high compare to other crisis. However, the index calculated by assigning more weights on equity and forex market puts the European debt crisis on the same level as the 2016 chinese market crash. In absence of a bechmark to compare the goodness of the index, 


