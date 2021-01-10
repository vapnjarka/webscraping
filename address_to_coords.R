rm(list=ls())



setwd("D:/REGEBBI_PROJEKTEK/gisr")


install.packages("urltools")

library(plyr)
library(dplyr)
library(stringr)
library(urltools)

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

#select duplicates based on coord. 
gyor$koord<-paste(gyor$wgs_x,gyor$wgs_y, sep=" ")

#csak 2 db
dup<-subset(gyor, gyor$koord %in% gyor$koord[duplicated(gyor$koord)])
dup<-dup[order(dup$egyben2),]

#unique rows (Remove duplicates)
gyor2<-gyor[!duplicated(gyor$koord), ]
gyor2<-gyor2[order(gyor2$egyben2),]


#install.packages("jsonlite")
library(jsonlite)

#install.packages("urltools")
library(urltools)

gyor2$tcim<-NA
gyor2$tker<-NA

library("stringr")


system.time(  
  for (i in 1:nrow(gyor2)){
    url<-paste0("https://terkepem.hu/routecalc/geocode/?search=",gyor2$wgs_x[i],"%20", gyor2$wgs_y[i])
    x <- fromJSON(url)
    if (x$error!="NA" && x$addresses[["district"]]=="") {
      gyor2$tcim[i]<-x$addresses[1]}
    if (x$error!="NA" && x$addresses[["district"]]!=""){
      gyor2$tcim[i]<-paste(x$addresses[["zip"]], x$addresses[["city"]], x$addresses[["streetname"]], x$addresses[["hnum"]])  
      gyor2$tker[i]<-x$addresses[["district"]]
      }
})