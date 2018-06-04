
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
    b.time ~ dnorm(0,0.001)

    #random line effect
    line.det.sd ~ dunif(0,10)
    line.det.tau <- pow(line.det.sd,-2)
    for(j in 1:N){
      random.det.line[j] ~ dnorm(0,line.det.tau)
    }

    for( i in 1:N){
    #linear predictor
    mu.df[i] <- b.df.0 
    #mu.df[i] <- b.df.0 + b.group.size * detectionGroupSize[i] + random.det.line[detectionLine[i]]
    #mu.df[i] <- b.df.0 + b.group.size * detectionGroupSize[i] 
    #                    + b.time * Time[i] + random.det.line[detectionLine[i]]

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

    }
    ",fill=TRUE,file="detection_model.txt")
