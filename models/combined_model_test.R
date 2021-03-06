setwd("/data/home/diana.bowler/NorskPtarmigan/models")
#distance model
cat("
    model{

    #intercept
    int.d ~ dnorm(0,0.001)    
    
    #random line effect
    line.d.sd ~ dunif(0,10)
    line.d.tau <- pow(line.d.sd,-2)
    for(j in 1:n.Lines){
    random.d.line[j] ~ dnorm(0,line.d.tau)
    }
    
    #random site effect
    site.d.sd ~ dunif(0,10)
    site.d.tau <- pow(site.d.sd,-2)
    for(j in 1:n.Sites){
      random.d.site[j] ~ dnorm(0,site.d.tau)
    }

    #random site2 effect
    site2.d.sd ~ dunif(0,10)
    site2.d.tau <- pow(site2.d.sd,-2)
    for(j in 1:n.Sites2){
      random.d.site2[j] ~ dnorm(0,site2.d.tau)
    }
    
    #random time effect
    year.d.sd ~ dunif(0,10)
    year.d.tau <- pow(year.d.sd,-2)
    for(t in 1:(n.Years-1)){
    random.d.year[t] ~ dnorm(0,year.d.tau)
    }

    #random site and time effect
    syear.d.sd ~ dunif(0,10)
    syear.d.tau <- pow(syear.d.sd,-2)
    for(j in 1:n.Sites){
      for(t in 2:n.Years){
        random.d.syear[j,t] ~ dnorm(0,syear.d.tau)
      }
    }

    #random site2 and time effect
    s2year.d.sd ~ dunif(0,10)
    s2year.d.tau <- pow(s2year.d.sd,-2)
    for(j in 1:n.Sites2){
      for(t in 2:n.Years){
        random.d.s2year[j,t] ~ dnorm(0,s2year.d.tau)
      }
    }

    #random obs  
    obs.d.sd ~ dunif(0,10)
    obs.d.tau <- pow(obs.d.sd,-2)
    for(j in 1:n.Lines){
      for(t in 2:n.Years){
        random.d.obs[j,t] ~ dnorm(0,obs.d.tau)
      }
    }


    #slopes
    beta.auto ~ dunif(-2,2)
    beta.covariateS ~ dnorm(0,0.001)
    beta.covariateS2 ~ dnorm(0,0.001)    
    beta.covariateT ~ dnorm(0,0.001)
    beta.covariate_int ~ dnorm(0,0.001)

    #Priors on the first year of density
    for(j in 1:n.Lines){
        NuIndivs[j,1] ~ dpois(expNuIndivs[j,1])
        expNuIndivs[j,1] <- Density[j,1] * TransectLength[j,1]/1000 * (110/1000) * 2
        Density[j,1] ~ dpois(priorDensity1[j])
    }

   #for remaining years
    for(j in 1:n.Lines){
      for(t in 2:n.Years){
        NuIndivs[j,t] ~ dpois(expNuIndivs[j,t])
        expNuIndivs[j,t] <- predDensity[j,t] * TransectLength[j,t]/1000 * (110/1000) * 2
        predDensity[j,t] ~ dpois(Density[j,t])  

        log(Density[j,t]) <- int.d +
                            log(Density[j,t-1]) +
                            beta.auto * (log(Density[j,t-1])-1.75) +
                            random.d.line[j] +
                            random.d.site2[site2[j]] +
                            random.d.obs[j,t]+
                            beta.covariateS * spatialMatrix1[j] +
                            beta.covariateS2 * spatialMatrix1_2[j] +  
                            beta.covariateT * temporalMatrix1[j,t] +
                            beta.covariate_int * spatialMatrix1[j] * temporalMatrix1[j,t] 
      }
    }


    }
    ",fill=TRUE,file="combined_model_test.txt")
