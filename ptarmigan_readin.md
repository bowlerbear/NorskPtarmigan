---
title: "Ptarmigan analysis"
author: "Diana Bowler"
date: "16 oktober 2017"
output:
  word_document: default
  pdf_document: default
  html_document: default
---




##Access the database and retreive the data

Run the script to access the database and retreive the data


```
## Note: method with signature 'DBIConnection#character' chosen for function 'dbReadTable',
##  target signature 'JDBCConnection#character'.
##  "JDBCConnection#ANY" would also be valid
```

![plot of chunk unnamed-chunk-3](figure/unnamed-chunk-3-1.png)


##Explore the data

The data frame is called mydata

Remember this includes all species at the moment...


```
## 'data.frame':	42481 obs. of  40 variables:
##  $ TakseringID      : num  2 2 1659 1659 18053 ...
##  $ LinjeID          : num  1280 1280 1280 1280 1280 1280 1280 1280 1280 1280 ...
##  $ Fylkesnavn       : chr  "Finnmark            " "Finnmark            " "Finnmark            " "Finnmark            " ...
##  $ Fylkesnr         : chr  "20" "20" "20" "20" ...
##  $ Kommunenavn      : chr  "Måsøy                                             " "Måsøy                                             " "Måsøy                                             " "Måsøy                                             " ...
##  $ Rapporteringsniva: chr  "Vest Finnmark kyst" "Vest Finnmark kyst" "Vest Finnmark kyst" "Vest Finnmark kyst" ...
##  $ OmradeID         : num  481 481 481 481 481 481 481 481 481 481 ...
##  $ OmradeNavn       : chr  "Rolvsøy" "Rolvsøy" "Rolvsøy" "Rolvsøy" ...
##  $ Aktiv            : chr  "1" "1" "1" "1" ...
##  $ Dato             : chr  "2013-08-03" "2013-08-03" "2014-08-17" "2014-08-17" ...
##  $ LengdeTaksert    : num  2700 2700 2501 2501 2500 ...
##  $ StartKl          : chr  "14:00:00.0000000" "14:00:00.0000000" "10:47:00.0000000" "10:47:00.0000000" ...
##  $ SluttKl          : chr  "15:15:00.0000000" "15:15:00.0000000" "12:25:00.0000000" "12:25:00.0000000" ...
##  $ Temperatur       : num  20 20 9 9 13 13 13 13 13 12 ...
##  $ AntallHunder     : num  3 3 2 2 2 2 2 2 2 2 ...
##  $ SettSmagnager    : chr  "0" "0" "0" "0" ...
##  $ AntallTaksorer   : num  0 0 0 0 0 0 0 0 0 0 ...
##  $ FK_HundeForholdID: num  1 1 1 1 2 2 2 2 2 2 ...
##  $ FK_UTMSone       : num  0 0 35 35 35 35 35 35 35 35 ...
##  $ UTMNordStart     : num  0 0 7879200 7879200 7879200 ...
##  $ UTMOstStart      : num  0 0 392100 392100 392100 ...
##  $ UTMNordSlutt     : num  0 0 7881700 7881700 7881700 ...
##  $ UTMOstSlutt      : num  0 0 392100 392100 392100 ...
##  $ FK_NedborID      : num  4 4 1 1 3 3 3 3 3 4 ...
##  $ ObservasjonId    : num  1 2 3447 3452 33267 ...
##  $ Klokkeslett      : chr  "14:06:00.0000000" "14:13:00.0000000" "11:00:00.0000000" "11:05:00.0000000" ...
##  $ FK_OppfluktId    : num  1 2 1 1 1 2 2 2 1 2 ...
##  $ FK_ArtId         : num  1 1 1 1 1 1 1 1 1 1 ...
##  $ UTMOst           : num  392223 392258 392112 392123 392439 ...
##  $ UTMNord          : num  7879561 7879558 7879532 7879516 7879856 ...
##  $ AntallHann       : num  1 1 1 1 1 1 1 1 1 1 ...
##  $ AntallHunn       : num  1 1 0 0 1 0 0 1 1 1 ...
##  $ AntallKylling    : num  6 4 10 10 10 0 0 9 2 11 ...
##  $ LinjeAvstand     : num  90 110 15 20 339 191 98 29 309 30 ...
##  $ Latitude         : num  71 71 71 71 71 ...
##  $ Longitude        : num  24 24 24 24 24 ...
##  $ Aar              : num  2013 2013 2014 2014 2015 ...
##  $ AntallUkjent     : num  0 0 0 0 0 0 0 0 0 0 ...
##  $ N_dist           : int  122 157 11 22 338 190 97 97651 308 26 ...
##  $ avvik            : int  32 47 3 2 0 0 0 97622 0 3 ...
```

#Explore whether our calculated distances deviate from the reported distances


```
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
##       0       0       3   40480      44 7191000    4989
```

![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5-1.png)![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5-2.png)![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5-3.png)


#Explore the counts

![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6-1.png)![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6-2.png)![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6-3.png)![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6-4.png)

```
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
##   0.000   0.000   0.000   0.209   0.000 210.000    4763
```


#Clean the time data


```
##  [1] 2013 2014 2015 2016 2012 2017 2001 2002 2003 2004 2006 2011 2009 2010
## [15] 2008 2005 2007 2000 1999   NA
```

```
## [1]  8  9  7  1  2  3  6  5 NA
```

```
## 
##     1     2     3     5     6     7     8     9 
##   214     2     1     6     4    64 42026    28
```

#Look at the species and flushing methods


```
## 
##     1     2     3     4     5 
## 33489   672  1375  2150    32
```

```
## 
##     1     2     3     4 
## 27361  7789  1414  1131
```

#Look at the spatial clustering


```
## 'data.frame':	18057 obs. of  6 variables:
##  $ TakseringID      : Factor w/ 18057 levels "1","2","3","4",..: 2 1646 3654 5814 10882 12679 3 1667 3586 6842 ...
##  $ LinjeID          : Factor w/ 3496 levels "90","91","92",..: 862 862 862 862 862 862 865 865 865 865 ...
##  $ Fylkesnavn       : Factor w/ 16 levels "Akershus            ",..: 4 4 4 4 4 4 4 4 4 4 ...
##  $ Kommunenavn      : Factor w/ 89 levels "Åfjord                                            ",..: 39 39 39 39 39 39 39 39 39 39 ...
##  $ Rapporteringsniva: Factor w/ 107 levels "Åfjord","Ånabjør",..: 103 103 103 103 103 103 103 103 103 103 ...
##  $ OmradeNavn       : Factor w/ 206 levels "Afjord fjellstyre nord",..: 142 142 142 142 142 142 142 142 142 142 ...
```


#Check all are aktiv?


```
## 
##     0     1 
##  5427 37054
```

```
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
##  0.0000  0.0000  1.0000  0.7004  1.0000  5.0000     700
```


#Estimate the effective strip width, on average

   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
   0.00   25.00   60.00   83.06  118.00 1000.00 
![plot of chunk unnamed-chunk-11](figure/unnamed-chunk-11-1.png)


#Example of the trends in abundance (just based on positive observations)


```
## Error in eval(expr, envir, enclos): object 'Latitude' not found
```














