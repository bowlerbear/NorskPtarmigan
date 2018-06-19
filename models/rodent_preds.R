setwd("/data/home/diana.bowler/NorskPtarmigan/models")
#distance model
cat("
    model{

    #######################################
    #model the probability to see a rodent#
    #######################################

    #priors
    int.r ~ dnorm(0,0.001) 

    #random line effect
    line.r.sd ~ dunif(0,10)
    line.r.tau <- pow(line.r.sd,-2)
    for(j in 1:n.Lines){
      random.r.line[j] ~ dnorm(0,line.r.tau)
    }
    
    #random time effect
    year.r.sd ~ dunif(0,10)
    year.r.tau <- pow(year.r.sd,-2)
    for(t in 1:n.Years){
    random.r.year[t] ~ dnorm(0,year.r.tau)
    }

    #random site2 effect
    site2.r.sd ~ dunif(0,10)
    site2.r.tau <- pow(site2.r.sd,-2)
    for(j in 1:n.Sites2){
      random.r.site2[j] ~ dnorm(0,site2.r.tau)
    }

    #random site2/year effect
    year.site2.r.sd ~ dunif(0,10)
    year.site2.r.tau <- pow(year.site2.r.sd,-2)
    for(j in 1:n.Sites2){
      for(t in 1:n.Years){
        random.r.site2.year[j,t] ~ dnorm(0,year.site2.r.tau)
      }
    }
    
    #random site effect
    site.r.sd ~ dunif(0,10)
    site.r.tau <- pow(site.r.sd,-2)
    for(j in 1:n.Sites){
      random.r.site[j] ~ dnorm(0,site.r.tau)
    }

    #random site/year effect
    year.site.r.sd ~ dunif(0,10)
    year.site.r.tau <- pow(year.site.r.sd,-2)
    for(j in 1:n.Sites){
      for(t in 1:n.Years){
        random.r.site.year[j,t] ~ dnorm(0,year.site.r.tau)
      }
    }

    for(j in 1:n.Lines){
      for(t in 1:n.Years){

    #observation model
    rodentData[j,t] ~ dbern(rodentPresence[j,t])

    #ecological model
    logit(rodentPresence[j,t]) <- int.r + 
                            random.r.line[j] + 
                            random.r.year[t] + 
                            random.r.site[site[j]]+ 
                            random.r.site2[site2[j]] +
                            random.r.site2.year[site2[j],t]+
                            random.r.site.year[site[j],t]
      }
    }

    }
    ",fill=TRUE,file="rodent_preds.txt")
