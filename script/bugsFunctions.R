#load libraries
library(unmarked)
library(rjags)
library(AHMbook)
library(R2WinBUGS)
library(jagsUI)
library(ggplot2)

# JAGS setting b/c otherwise JAGS cannot build a sampler, rec. by M. Plummer
set.factory("bugs::Conjugate", FALSE, type="sampler")

# Default parameters
ni <- 6000   ;   nb <- 2000   ;   nt <- 2   ;   nc <- 3