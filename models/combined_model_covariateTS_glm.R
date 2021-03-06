
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
    #mu.df[i] <- b.df.0 

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
        #pred.sig[j,t] <- exp(b.df.0)
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
                                      random.gs.line[detectionLine[i]] 
    }

    #using this model, get predicted group size for each line and year
    for(t in 1:n.Years){
      for(j in 1:n.Lines){
        log(predGroupSize[j,t]) <- int.gs + random.gs.year[t] + random.gs.line[j]
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

    #random site2 and time effect
    s2year.d.sd ~ dunif(0,10)
    s2year.d.tau <- pow(s2year.d.sd,-2)
    for(j in 1:n.Sites2){
      for(t in 1:n.Years){
        random.d.s2year[j,t] ~ dnorm(0,s2year.d.tau)
      }
    }

  #overdispersion
    obs.d.sd ~ dunif(0,10)
    obs.d.tau <- pow(obs.d.sd,-2)
    for(j in 1:n.Lines){
      for(t in 1:n.Years){
        random.d.obs[j,t] ~ dnorm(0,obs.d.tau)
      }
    }
    

    #slopes
    beta.auto ~ dunif(-2,2)
    beta.covariateS ~ dnorm(0,0.001)
    #beta.covariateS2 ~ dnorm(0,0.001)
    beta.covariateT ~ dnorm(0,0.001)

    #Observation model:
    for(j in 1:n.Lines){
      for(t in 1:n.Years){
        NuIndivs[j,t] ~ dpois(expNuIndivs[j,t])

    #State model
      #linear predictor on density
        log(expNuIndivs[j,t]) <- int.d + 
                            random.d.line[j] + 
                            beta.covariateS * spatialMatrix[j] + 
                            beta.covariateT * temporalMatrix[j,t] +
                            random.d.site[site[j]]+
                            random.d.obs[j,t]+
                            log(TransectLength[j,t])
                            
      }
    }


   #calculate the Bayesian p-value
    for(j in 1:n.Lines){
      for(t in 1:n.Years){
        expNuIndivs.new[j,t] ~ dpois(expNuIndivs[j,t])      
      }
    }

    }
    ",fill=TRUE,file="combined_model_covariateTS_glm.txt")
