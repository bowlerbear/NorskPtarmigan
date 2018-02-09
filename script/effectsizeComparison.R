#read in each output file, extract the coefficients and divide by the standard error of the associated variable

load("out1_springOnset.RData")
out1$summary[grepl("beta",row.names(out1$summary)),]

load("out1_springTemp.RData")
out1$summary[grepl("beta",row.names(out1$summary)),]

load("out1_juneTemp.RData")
out1$summary[grepl("beta",row.names(out1$summary)),]

load("out1_winterTemp.RData")
out1$summary[grepl("beta",row.names(out1$summary)),]

load("out1_rodent.RData")
out1$summary[grepl("beta",row.names(out1$summary)),]

load("out1_ROS.RData")
out1$summary[grepl("beta",row.names(out1$summary)),]

load("out1_winterOnset.RData")
out1$summary[grepl("beta",row.names(out1$summary)),]