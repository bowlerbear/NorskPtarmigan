
#distance model
cat("
    model{

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
    
    #random site2 effect
    site.sd ~ dunif(0,10)
    site.tau <- pow(site.sd,-2)
    for(t in 1:n.Sites2){
      random.gs.site2[t] ~ dnorm(0,site.tau)
    }

    #random line/year effects
    line.year.sd ~ dunif(0,10)
    line.year.tau <- pow(line.year.sd,-2)
    for(j in 1:n.LineYear){
      random.gs.line.year[j] ~ dnorm(0,line.year.tau)
    }

    #random site2/year effects
    site.year.sd ~ dunif(0,10)
    site.year.tau <- pow(site.year.sd,-2)
    for(j in 1:n.SiteYear){
      random.gs.site2.year[j] ~ dnorm(0,site.year.tau)
    }

    #Model
    #for each detection, model group size
    for(i in 1:N){
    
    GroupSize[i] ~ dpois(expGroupSize[i])
    log(expGroupSize[i]) <- int.gs + 
                            random.gs.year[detectionYear[i]]+ 
                            random.gs.line[detectionLine[i]]+
                            random.gs.site2[detectionSite[i]]+
                            random.gs.site2.year[detectionSiteYear[i]]
    
    }

    for(t in 1:n.Years){
      randomSY2[t] <- mean(random.gs.site2.year[detectionYear[t]])
    }
    for(j in 1:n.Sites2){
      randomSY3[j] <- mean(random.gs.site2.year[detectionSite[j]])
    }

    #using this model, get predicted group size for each line and year
    for(t in 1:n.Years){
      for(j in 1:n.Lines){
        log(predGroupSize[j,t]) <- int.gs + 
                                    random.gs.year[t]+ 
                                    random.gs.line[j]+
                                    random.gs.site2[site2[j]]
                                    #random.gs.site2.year[t,site2[j]]
     }
    }

    }
    ",fill=TRUE,file="group_size_model.txt")
