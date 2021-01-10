rm(list=ls())


setwd("h:/_D MEGHAJTO/gisr")



library(plyr)
library(dplyr)
library(stringr)


#import txt
gyor <- as.data.frame(read.table("gyor.txt", header=T, sep =",", encoding="UTF-8")) 

#lower case to variable name
names(gyor)<-tolower(names(gyor))

#only relevant cols
gyor<-subset(gyor, select=c("objectid","kozseg","cim_egyben", "betutol", "wgs_x", "wgs_y"))

#egybecim
gyor<-cbind(gyor, "egyben"=paste(gyor$kozseg, gyor$cim_egyben, sep=" "))
gyor<-cbind(gyor, "egyben2"=paste(gyor$egyben, gyor$betutol, sep="/"))

gyor<-gyor[order(gyor$egyben2),]

#select duplicates, 
gyor$egyben2[duplicated(gyor$egyben2)]
dup<-subset(gyor, gyor$egyben2 %in% gyor$egyben2[duplicated(gyor$egyben2)])
dup<-dup[order(dup$egyben2),]

#unique rows (Remove duplicates)
gyor2<-gyor[!duplicated(gyor$egyben2), ]
gyor2<-gyor2[order(gyor2$egyben2),]


#install.packages("jsonlite")
library(jsonlite)

#install.packages("urltools")
library(urltools)

gyor2$tlat<-NA
gyor2$tlon<-NA

library("stringr")

system.time(  
for (i in 1:nrow(gyor2)){
  url<-url_encode(paste("https://terkepem.hu/routecalc/geocode/?search=",gyor2$egyben2[i]))
  x <- fromJSON(url)
  if (x$error!="NA") {
  gyor2$tlat[i]<-x$addresses$lat[1]
  gyor2$tlon[i]<-x$addresses$long[1] }
})
