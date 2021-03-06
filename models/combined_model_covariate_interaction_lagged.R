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
    for(t in 1:(n.Years-1)){
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

    #slopes
    beta.auto ~ dunif(-2,2)
    #covariate 1
    beta.covariateS_cov1 ~ dnorm(0,0.001)
    beta.covariateS2_cov1 ~ dnorm(0,0.001)
    beta.covariateT_cov1 ~ dnorm(0,0.001)
    #covariate 2
    beta.covariateS_cov2 ~ dnorm(0,0.001)
    beta.covariateT_cov2 ~ dnorm(0,0.001)
    beta.covariateTL_cov2 ~ dnorm(0,0.001)
    #interaction
    beta.covariate_int ~ dnorm(0,0.001)
    beta.covariate_intL ~ dnorm(0,0.001)

    #Observation model:
    for(j in 1:n.Lines){
      for(t in 1:n.Years){
        NuIndivs[j,t] ~ dpois(expNuIndivs[j,t])
        expNuIndivs[j,t] <- (predDensity[j,t] * (TransectLength[j,t]/1000 * predESW[j,t]/1000 * 2))
        predDensity[j,t] ~ dpois(Density[j,t])  
      }}

    #State model
    for(j in 1:n.Lines){
      for(t in 1:(n.Years-1)){
      
      #linear predictor on density
        log(Density[j,t+1]) <- int.d + 
                            beta.auto * log(Density[j,t]) +
                            random.d.line[j] + 
                            random.d.site2[site2[j]] +
                            #random.d.year[t] +
                            beta.covariateS_cov1 * spatialMatrix1[j] + 
                            beta.covariateS2_cov1 * spatialMatrix1_2[j] + 
                            beta.covariateT_cov1 * temporalMatrix1[j,t+1] +
                            beta.covariateT_cov2 * temporalMatrix2[j,t+1] +
                            beta.covariateTL_cov2 * temporalMatrix2[j,t] +
                            beta.covariate_int * spatialMatrix1[j] * temporalMatrix2[j,t+1] +
                            beta.covariate_intL * spatialMatrix1[j] * temporalMatrix2[j,t]

      }}


    #Priors on the first year of density
    for(j in 1:n.Lines){
        Density[j,1] ~ dpois(year1[j]/0.6)
    }

    #model for missing data for rodent data
    int.rs ~ dnorm(0,0.001)
    int.rt ~ dnorm(0,0.001)
    tau.rs <- pow(sd.rs,-2)
    sd.rs ~ dunif(0,10)
    tau.rt <- pow(sd.rt,-2)
    sd.rt ~ dunif(0,10)

    for(j in 1:n.Lines){
          spatialMatrix2[j] ~ dnorm(spatialMatrix2.pred[j],tau.rs)
          spatialMatrix2.pred[j] <- int.rs +  random.r.site[site[j]]
      for(t in 1:n.Years){
          temporalMatrix2[j,t] ~ dnorm(temporalMatrix2.pred[j,t],tau.rt)
          temporalMatrix2.pred[j,t] <- int.rt + random.r.year[t] + random.r.syear[site[j],t]
      }
    }

    #random site and time effect
    syear.r.sd ~ dunif(0,10)
    syear.r.tau <- pow(syear.r.sd,-2)
    for(j in 1:n.Sites){
      for(t in 1:n.Years){
        random.r.syear[j,t] ~ dnorm(0,syear.r.tau)
      }
    }

    #random site effect
    site.r.sd ~ dunif(0,10)
    site.r.tau <- pow(site.r.sd,-2)
    for(j in 1:n.Sites){
      random.r.site[j] ~ dnorm(0,site.r.tau)
    }

    #random time effect
    year.r.sd ~ dunif(0,10)
    year.r.tau <- pow(year.r.sd,-2)
    for(t in 1:n.Years){
      random.r.year[t] ~ dnorm(0,year.r.tau)
    }

    #calculate the Bayesian p-value
    e <- 0.0001
    for(j in 1:n.Lines){
      for(t in 1:n.Years){
        chi2[j,t] <- pow((NuIndivs[j,t] - expNuIndivs[j,t]),2) / (sqrt(expNuIndivs[j,t])+e)
        expNuIndivs.new[j,t] ~ dpois(expNuIndivs[j,t]) 
        chi2.new[j,t] <- pow((expNuIndivs.new[j,t] - expNuIndivs[j,t]),2) / (sqrt(expNuIndivs[j,t])+e) # exp
      }
    }
    
    # Add up discrepancy measures for entire data set
    for(t in 1:n.Years){
      fit.t[t] <- sum(chi2[,t])                     
      fit.new.t[t] <- sum(chi2.new[,t])             
    }
    fit <- sum(fit.t[])
    fit.new <- sum(fit.new.t[])

    #only rodents
    for(j in 1:n.Lines){
      for(t in 1:(n.Years-1)){
      log(rDensity[j,t+1]) <- int.d + 
                            beta.auto * log(Density[j,t]) +
                            random.d.line[j] + 
                            beta.covariateS_cov2 * spatialMatrix2[j] + 
                            beta.covariateT_cov2 * temporalMatrix2[j,t+1]+
                            beta.covariateTL_cov2 * temporalMatrix2[j,t]

      }}

    #only with climate effect
    for(j in 1:n.Lines){
      for(t in 1:(n.Years-1)){
      log(cDensity[j,t+1]) <- int.d + 
                            beta.auto * log(Density[j,t]) +
                            random.d.line[j] + 
                            beta.covariateS_cov1 * spatialMatrix1[j] + 
                            beta.covariateT_cov1 * temporalMatrix1[j,t+1]

      }}

    
    #prediction of how direct effect of rodents changes with gradient
    for(i in 1:n.Preds){
      preds[i] <- beta.covariateT_cov2 + beta.covariate_int* climaticGradient[i]
    }

    #predictions of how lagged effects of rodents changes with gradient
    for(i in 1:n.Preds){
      predsL[i] <- beta.covariateTL_cov2 + beta.covariate_intL* climaticGradient[i]
    }

    }
    ",fill=TRUE,file="combined_model_covariate_interaction_lagged.txt")
