setwd("/data/home/diana.bowler/NorskPtarmigan/models")
#distance model
cat("
    model{

    #################
    #Detection model#
    #################
    pi <- 3.141593
    
    # priors for fixed effect parms for half-normal detection parm sigma
    b.df.0 ~ dunif(0,20)        
    b.group.size ~ dnorm(0,0.001)

    for( i in 1:N){
    #linear predictor
    mu.df[i] <- b.df.0 + b.group.size * detectionGroupSize[i] 
    
    # estimate of sd and var, given coeffs above
    sig.df[i] <- exp(mu.df[i])
    sig2.df[i] <- sig.df[i]*sig.df[i]
    
    # effective strip width
    esw[i] <- sqrt(pi * sig2.df[i] / 2) 
    f0[i] <- 1/esw[i] #assuming all detected on the line
    
    # LIKELIHOOD
    # using zeros trick
    y[i] ~ dunif(0,W) 
    L.f0[i] <- exp(-y[i]*y[i] / (2*sig2.df[i])) * 1/esw[i] #y are the distances
    nlogL.f0[i] <-  -log(L.f0[i])
    zeros.dist[i] ~ dpois(nlogL.f0[i])
    }

    #using this model and predicted group size (below), get predicted ESW for each line and year
    for(t in 1:n.Years){
      for(j in 1:n.Lines){
        pred.sig[j,t] <- exp(b.df.0+ b.group.size * log(predGroupSize[j,t]+1)) 
        pred.sig2[j,t] <- pow(pred.sig[j,t],2)
        predESW[j,t] <- sqrt(pi * pred.sig2[j,t] / 2)
      }
    }

    ##################
    #Group size model#
    ##################

    #priors
    int.gs ~ dnorm(0,0.001)    
    
    #random line effect
    line.sd ~ dunif(0,10)
    line.tau <- pow(line.sd,-2)
    for(j in 1:n.Lines){
      random.gs.line[j] ~ dnorm(0,line.tau)
    }
    
    #random site2 effect
    site2.sd ~ dunif(0,10)
    site2.tau <- pow(site2.sd,-2)
    for(j in 1:n.Sites2){
      random.gs.site2[j] ~ dnorm(0,site2.tau)
    }
    
    #random year effect
    year.sd ~ dunif(0,10)
    year.tau <- pow( year.sd,-2)
    for(t in 1:n.Years){
      random.gs.year[t] ~ dnorm(0, year.tau)
    }
    
    #random line/year effect
    line.year.sd ~ dunif(0,10)
    line.year.tau <- pow( line.year.sd,-2)
    for(j in 1:n.Lines){
      for(t in 1:n.Years){
        random.gs.line.year[j,t] ~ dnorm(0, line.year.tau)
      }
    }
    
    #random site2/year effect
    site2.year.sd ~ dunif(0,10)
    site2.year.tau <- pow(site2.year.sd,-2)
    for(j in 1:n.Sites2){
      for(t in 1:n.Years){
        random.gs.site2.year[j,t] ~ dnorm(0, site2.year.tau)
      }
    }
    
    #Model
    #for each detection, model group size
    for(i in 1:N){
      GroupSize[i] ~ dpois(expGroupSize[i])
      log(expGroupSize[i]) <- int.gs + random.gs.year[detectionYear[i]] + random.gs.line[detectionLine[i]] + 
                              random.gs.site2[detectionSite[i]]+
                              random.gs.line.year[detectionLine[i],detectionYear[i]] +
                              random.gs.site2.year[detectionSite[i],detectionYear[i]]
    }
    
    #using this model, get predicted group size for each line and year
    for(t in 1:n.Years){
      for(j in 1:n.Lines){
        log(predGroupSize[j,t]) <- int.gs + random.gs.year[t] + random.gs.line[j] + random.gs.site2[site2[j]]+
                                    random.gs.line.year[j,t] + random.gs.site2.year[site2[j],t]
      }
    }

    ########################
    #Model of total density#
    ########################

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
                            log(Density[j,t-1]) +
                            beta.auto * (log(Density[j,t-1])-1.75) +
                            random.d.line[j] + 
                            random.d.site2[site2[j]] + 
                            random.d.obs[j,t] +
                            beta.covariateS * spatialMatrix1[j] + 
                            beta.covariateS2 * spatialMatrix1_2[j] + 
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
    ",fill=TRUE,file="combined_model_weather_interaction_rodent_additive.txt")
