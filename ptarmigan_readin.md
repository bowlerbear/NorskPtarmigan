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
## Error in str(mydata): object 'mydata' not found
```

#Explore whether our calculated distances deviate from the reported distances


```
## Error in summary(mydata$avvik): object 'mydata' not found
```

```
## Error in hist(mydata$avvik): object 'mydata' not found
```

```
## Error in hist(mydata$LinjeAvstand): object 'mydata' not found
```

```
## Error in hist(mydata$N_dist): object 'mydata' not found
```


#Explore the counts


```
## Error in hist(mydata$AntallHann): object 'mydata' not found
```

```
## Error in hist(mydata$AntallHunn): object 'mydata' not found
```

```
## Error in hist(mydata$AntallKylling): object 'mydata' not found
```

```
## Error in hist(mydata$AntallUkjent): object 'mydata' not found
```

```
## Error in summary(mydata$AntallUkjent): object 'mydata' not found
```

```
## Error in mydata$AntallUkjent[mydata$AntallUkjent > 100] <- 0: object 'mydata' not found
```


#Clean the time data


```
## Error in eval(expr, envir, enclos): object 'mydata' not found
```

```
## Error in as.Date(mydata$Date, format = "%Y-%m-%d"): object 'mydata' not found
```

```
## Error in year(mydata$Date): object 'mydata' not found
```

```
## Error in month(mydata$Date): object 'mydata' not found
```

```
## Error in unique(mydata$Year): object 'mydata' not found
```

```
## Error in unique(mydata$month): object 'mydata' not found
```

```
## Error in eval(expr, envir, enclos): object 'mydata' not found
```

```
## Error in eval(expr, envir, enclos): object 'mydata' not found
```

```
## Error in eval(expr, envir, enclos): object 'mydata' not found
```

```
## Error in lapply(X = X, FUN = FUN, ...): object 'mydata' not found
```

```
## Error in lapply(X = X, FUN = FUN, ...): object 'mydata' not found
```

```
## Error in eval(expr, envir, enclos): object 'mydata' not found
```

```
## Error in table(mydata$month): object 'mydata' not found
```

#Look at the species and flushing methods


```
## Error in table(mydata$FK_ArtId): object 'mydata' not found
```

```
## Error in table(mydata$FK_OppfluktId): object 'mydata' not found
```

#Look at the spatial clustering


```
## Error in unique(mydata[, c("TakseringID", "LinjeID", "Fylkesnavn", "Kommunenavn", : object 'mydata' not found
```

```
## Error in lapply(tempDF, factor): object 'tempDF' not found
```

```
## Error in str(tempDF): object 'tempDF' not found
```

```
## Error in trim(mydata$Fylkesnavn): object 'mydata' not found
```

```
## Error in trim(mydata$Kommunenavn): object 'mydata' not found
```


#Check all are aktiv?


```
## Error in table(mydata$Aktiv): object 'mydata' not found
```

```
## Error in subset(mydata, Aktiv == 0): object 'mydata' not found
```

```
## Error in summary(tempDF$AntallHunn): object 'tempDF' not found
```


#Estimate the effective strip width, on average


```
## Error in eval(expr, envir, enclos): object 'mydata' not found
```

```
## Error in eval(expr, envir, enclos): object 'myDistances' not found
```

```
## Error in summary(myDistances): object 'myDistances' not found
```

```
## Error in quantile(myDistances, 0.95, na.rm = T): object 'myDistances' not found
```

```
## Error in myDistances[myDistances > 200] <- NA: object 'myDistances' not found
```

```
## Error in eval(expr, envir, enclos): object 'myDistances' not found
```

```
## Error in inherits(dist, "data.frame"): object 'myDistances' not found
```

```
## Error in plot(fit): object 'fit' not found
```


#Example of the trends in abundance (just based on positive observations)


```
## Error in eval(expr, envir, enclos): object 'mydata' not found
```

```
## Error in eval(expr, envir, enclos): object 'mydata' not found
```

```
## Error in eval(expr, envir, enclos): object 'mydata' not found
```

```
## Error in subset(mydataSummmary, Latitude > 50 & Latitude < 75): object 'mydataSummmary' not found
```














