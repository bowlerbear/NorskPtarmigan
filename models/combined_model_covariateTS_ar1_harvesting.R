
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
    
    #random time effect
    year.sd ~ dunif(0,10)
    year.tau <- pow(year.sd,-2)
    for(t in 1:n.Years){
    random.gs.year[t] ~ dnorm(0,year.tau)
    }

    #long-term trend with random site effects
    long.term.trend ~ dnorm(0,0.001)
    trend.line.sd ~ dunif(0,10)
    trend.line.tau <- pow(trend.line.sd,-2)
    for(j in 1:n.Lines){
      random.gs.trend.line[j] ~ dnorm(0,trend.line.tau)
    }


    #Model
    #for each detection, model group size
    for(i in 1:N){
      GroupSize[i] ~ dpois(expGroupSize[i])
      log(expGroupSize[i]) <- int.gs + random.gs.year[detectionYear[i]] + 
                                      random.gs.line[detectionLine[i]] +
                                      long.term.trend * detectionYear[i] +
                                      detectionYear[i] * random.gs.trend.line[detectionLine[i]]
    }

    #using this model, get predicted group size for each line and year
    for(t in 1:n.Years){
      for(j in 1:n.Lines){
        log(predGroupSize[j,t]) <- int.gs + random.gs.year[t] + random.gs.line[j] + 
                                    random.gs.trend.line[j] * t +
                                    long.term.trend * t
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

    #random time effect
    year.d.sd ~ dunif(0,10)
    year.d.tau <- pow(year.d.sd,-2)
    for(t in 1:n.Years){
    random.d.year[t] ~ dnorm(0,year.d.tau)
    }

    #random site and time effect
    syear.d.sd ~ dunif(0,10)
    syear.d.tau <- pow(syear.d.sd,-2)
    for(j in 1:n.Sites){
      for(t in 1:n.Years){
        random.d.syear[j,t] ~ dnorm(0,syear.d.tau)
      }
    }

    #Observation model:
    for(j in 1:n.Lines){
      for(t in 1:n.Years){
        NuIndivs[j,t] ~ dpois(expNuIndivs[j,t])
        expNuIndivs[j,t] <- (Density[j,t] * (TransectLength[j,t]/1000 * predESW[j,t]/1000 * 2))
      }}


    #Predict the harvested effort:
    
    int.harvest ~ dnorm(0,0.001)
    trend.harvest ~ dnorm(0,0.001)
    
    #random time effect
    year.h.sd ~ dunif(0,10)
    year.h.tau <- pow(year.h.sd,-2)
    for(t in 1:n.Years){
      random.harvest.year[t] ~ dnorm(0,year.h.tau)
    }

    #random line effect
    line.h.sd ~ dunif(0,10)
    line.h.tau <- pow(line.h.sd,-2)
    for(j in 1:n.Kommune){
      random.harvest.line[j] ~ dnorm(0,line.h.tau)
    }

  
    #random line/year effect
    line.year.h.sd ~ dunif(0,10)
    line.year.h.tau <- pow(line.year.h.sd,-2)
    for(j in 1:n.Kommune){
      for(t in 1:n.Years){
      random.harvest.line.year[j,t] ~ dnorm(0,line.year.h.tau)
      }
    }

    #the model
    #for(j in 1:n.Lines){
    #  for(t in 1:n.Years){
    #    harvestBag[j,t] ~ dpois(expHarvestBag[j,t])
    #    log(expHarvestBag[j,t]) <- int.harvest + 
    #                            trend.harvest * t + 
    #                            random.harvest.year[t] + 
    #                            random.harvest.line[Kommune[j]] +  
    #                            random.harvest.line.year[Kommune[j],t]  
    #
    #       expHarvestEffort[j,t] <- expHarvestBag[j,t]/countyArea[j]
    #    }
    # }

    #slopes
    beta.auto ~ dunif(0,1)
    harvest.effect ~ dnorm(0,0.001)

    #State model
    for(j in 1:n.Lines){
      for(t in 1:(n.Years-1)){
      
      #linear predictor on density
        log(Density[j,t+1]) <- int.d + 
                            beta.auto * log(Density[j,t]) +
                            harvest.effect * (harvestBag[j,t]/countyArea[j]/Density[j,t]) +
                            random.d.line[j] + random.d.year[t] + random.d.site[site[j]]
    }}

    #Priors on the first year of density
    for(j in 1:n.Lines){
        Density[j,1] ~ dpois(year1[j])
    }

  #calculate the Bayesian p-value
    e <- 0.0001
    for(j in 1:n.Lines){
      for(t in 1:n.Years){
    # Fit assessments: Chi-squared test statistic and posterior predictive check
    chi2[j,t] <- pow((NuIndivs[j,t] - expNuIndivs[j,t]),2) / (sqrt(expNuIndivs[j,t])+e)         # obs.
    expNuIndivs.new[j,t] ~ dpois(expNuIndivs[j,t])      # Replicate (new) data set
    chi2.new[j,t] <- pow((expNuIndivs.new[j,t] - expNuIndivs[j,t]),2) / (sqrt(expNuIndivs[j,t])+e) # exp
      }
    }

    # Add up discrepancy measures for entire data set
    for(t in 1:n.Years){
      fit.t[t] <- sum(chi2[,t])                     
      fit.new.t[t] <- sum(chi2.new[,t])             
    }

    fit <- sum(fit.t[])                     # Omnibus test statistic actual data
    fit.new <- sum(fit.new.t[])             # Omnibus test statistic replicate data


    }
    ",fill=TRUE,file="combined_model_covariateTS_ar1_harvesting.txt")
