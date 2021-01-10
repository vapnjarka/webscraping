#challange:
#to save daily statistics from koronavirus.gov.hu

rm(list = ls())

#working dir
setwd("c:/Users/Asus/Downloads/tmp")


#packages
install.packages("tidyverse")
install.packages("rvest")
install.packages("googlesheets4")


#loading packages
library("tidyverse")
library("rvest")
library("googlesheets4")


#read html 
mynode1 <- read_html(
  "https://koronavirus.gov.hu/") %>%
  html_nodes('.alittleHelpForYourAPI.hidden')

#use only the first list
mynode1<-mynode1[1]

#tmp variable to identify the given html object
uj<-as.list(paste(':nth-child(', 1:11, ')', sep = ""))

#an empty df
mydata<-data.frame()

#the loop to fill the data frame: saves the name of the variable, and the value of 
#the variable, saves the date as well
for(i in 1:11){
  tmp<-data.frame(
    cim=mynode1 %>% html_nodes(as.character(uj[i]))
    %>% html_attr("id"),
    szam= mynode1 %>% html_nodes(as.character(uj[i]))
    %>% html_text(),
    datum=Sys.time())
  mydata<-bind_rows(mydata,tmp)
  i<-i+1
}

#save into csv 
write.table(mydata, "saved.csv", sep=";", append=TRUE, row.names = F, col.names = F)

#auto-indentication to googlesheet
gs4_auth(email = "eszenyi.orsolya@gmail.com")

#save into googlesheet
sheet_append(sheets_find("covid19_hungary"), mydata)
