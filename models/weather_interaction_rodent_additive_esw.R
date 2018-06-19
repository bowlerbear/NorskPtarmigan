setwd("/data/home/diana.bowler/NorskPtarmigan/models")
#distance model
cat("
    model{
    #Model of total density

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
    beta.covariate_rodT ~ dnorm(0,0.001)
    beta.covariate_rodTL ~ dnorm(0,0.001)
    #interaction
    beta.covariate_int ~ dnorm(0,0.001)

    #ESW
    
    for(j in 1:n.Lines){
      for(t in 1:n.Years){
        ESW.tau[j,t]<-pow(ESW.sd[j,t],-2)
        predESW[j,t] ~ dnorm(ESW.mean[j,t],ESW.tau[j,t])
      }
    }


    #Observation model:

    #Priors on the first year of density
    for(j in 1:n.Lines){
        NuIndivs[j,1] ~ dpois(expNuIndivs[j,1])
        expNuIndivs[j,1] <- Density[j,1] * TransectLength[j,1]/1000 * (predESW[j,1]/1000) * 2
        Density[j,1] ~ dpois(priorDensity1[j])
    }

   #for remaining years
    for(j in 1:n.Lines){
      for(t in 2:n.Years){
        NuIndivs[j,t] ~ dpois(expNuIndivs[j,t])
        expNuIndivs[j,t] <- predDensity[j,t] * TransectLength[j,t]/1000 * (predESW[j,t]/1000) * 2
        predDensity[j,t] ~ dpois(Density[j,t])

    #linear predictor on density
        log(Density[j,t]) <- int.d +
                            beta.auto * (log(Density[j,t-1])) +
                            random.d.line[j] + 
                            random.d.site2[site2[j]] + 
                            random.d.obs[j,t] +
                            beta.covariateS * spatialMatrix1[j] + 
                            #beta.covariateS2 * spatialMatrix1_2[j] + 
                            beta.covariateT * temporalMatrix1[j,t] +
                            beta.covariate_rodT * temporalMatrix2[j,t] +
                            beta.covariate_rodTL * temporalMatrix2[j,t-1] +
                            beta.covariate_int * spatialMatrix1[j] * temporalMatrix1[j,t] 
      }
    }

  
    #calculate the Bayesian p-value
    #e <- 0.0001
    #for(j in 1:n.Lines){
    #  for(t in 1:n.Years){
    #    chi2[j,t] <- pow((NuIndivs[j,t] - expNuIndivs[j,t]),2) / (sqrt(expNuIndivs[j,t])+e)
    #    expNuIndivs.new[j,t] ~ dpois(expNuIndivs[j,t]) 
    #    chi2.new[j,t] <- pow((expNuIndivs.new[j,t] - expNuIndivs[j,t]),2) / (sqrt(expNuIndivs[j,t])+e) # exp
    #  }
    #}
    
    # Add up discrepancy measures for entire data set
    #for(t in 1:n.Years){
    #  fit.t[t] <- sum(chi2[,t])                     
    #  fit.new.t[t] <- sum(chi2.new[,t])             
    #}
    #fit <- sum(fit.t)
    #fit.new <- sum(fit.new.t)

    #predicted effects along a climatic gradient
    #for(i in 1:n.Preds){
    #  preds[i] <- beta.covariateT + beta.covariate_int* climaticGradient[i]
    #}

    }
    ",fill=TRUE,file="weather_interaction_rodent_additive_esw.txt")
