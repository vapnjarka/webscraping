rm(list = ls())
setwd("c:/Users/Asus/Downloads/tmp")
setwd("D:/taggelni2018b/a")
Sys.setenv("GCV_AUTH_FILE" = "c:/Users/Asus/Downloads/My Project 35455-4b1e72294756.json")

#install.packages("tidyverse")
#install.packages("googleCloudVisionR")
#install.packages("googleAuthR")
#install.packages("fs") #file system operations
library("tidyverse")
library("googleCloudVisionR")
library("googleAuthR")
library("fs")


gar_auth_service("c:/Users/Asus/Downloads/My Project 35455-4b1e72294756.json")


#set first the working directory
setwd("c:/Users/Asus/Downloads/tmp")
getwd()

#following have to be in the wd for the tagging
#1, images

#following have to be in the wd after the tagging
#1, the csv after tagging (tagged.csv)
#2, szotar3.csv

#save all file names of a given directory into a list
#only jpg-s: $ means end of the string
# \\. needed because need to escape . as a special regexp char
#ignore case, becasue jpg and JPG both are needed
listn<-list.files(getwd(), pattern="\\.jpg$", ignore.case=T) #name
listp<-list.files(getwd(), full.names = TRUE, pattern="\\.jpg$", ignore.case=T ) #path

#initialize output df and csv (to have the column names)
df2<-data.frame(image_path=character(),mid=character(),description=character(),
    score=numeric(), topicality=numeric(),feature=character(),filename=character())
#write.table(df2, file="tagged.csv", sep=";", row.names = F)
df2<-data.frame()


#loop for all the files in the folder to get the tag from google vision
for(i in 1:length(listn)){
  xx<-gcv_get_image_annotations(
    imagePaths = listp[i],
    feature = "LABEL_DETECTION") 
  xx<-data.frame(xx, filename=listn[i])
  df2<-bind_rows(df2,xx)
  write.table(xx, file="tagged_tmp.csv", sep=";", append=TRUE, row.names = F, col.names=F)
  i<-i+1 
}  

warnings()

df2<-read.csv("tagged_tmp.csv", header=T, sep =";" )

#clear columns only for rows without tags
df2[is.na(df2$score)==T,"feature"] <- NA # empty feature col
df2[is.na(df2$score)==T,"filename"] <- df2[is.na(df2$score)==T,"description"] #copy filename (what is in descr) into filename
df2[is.na(df2$score)==T,"description"] <- NA #empty desc col
df2[is.na(df2$score),] #control


#save the widest result
write.table(df2 %>% select(filename, image_path, score, description), file="tagged.csv", na="", sep=";", append=TRUE, row.names = F)


#import the saved csv for work anytime
#condition: it has to be in the wd
df3<-read.csv("tagged.csv", header=T, sep=";")

#select where score>=0.7
mydata<-df3 %>% select(image_path, filename, score, description) %>% filter(score>=0.7)

#select where score>=0.9
#mydata<-df3 %>% select(image_path, filename, score, description) %>% filter(score>=0.9)
#select where score>=0.8 & score<0.9
#mydata<-df3 %>% select(image_path, filename, score, description) %>% filter(score>=0.8 & score<0.9 )
#select where score>=0.7 & score<0.8
#mydata<-df3 %>% select(image_path, filename, score, description) %>% filter(score>=0.7 & score<0.8 )

#change space to underscore, coma to nothing
mydata$description <- gsub(' ', '_', mydata$description) 
mydata$description <- gsub(',', '', mydata$description) 

#import dictionary/translator 
dict<-read.csv("szotar4.csv", sep =";" )

merged<-merge(mydata, dict, by.x="description", by.y="Original", all.x=TRUE)
#merge2 <-merge %>% drop_na()
#most ne dobjuk ki az na-s sorokat, hanem akkor a descriptionbe menjenek:
#uj oszlop:dir
#elotte char-re kell tenni a Hungarian oszlopot Factorrol:
merged[] <- lapply(merged, as.character)
merged$dir<-ifelse(is.na(merged$Hungarian), merged$description, merged$Hungarian)


################################################################
#filter only mopszika tags, neither "a"
merged<-merged[(is.na(merged$Hungarian)==F) & (merged$Hungarian!='a'),]



#make the file distinct
merged<-merged %>% distinct(filename, dir, .keep_all = T)



#3. for make directories -based on Hungarian, if missing, then based on description
mkdir_output<- merged %>% distinct("mkdir", dir)
mkdir_output<- cbind(mkdir_output[2],mkdir_output[1])
write.table(mkdir_output, file="c:/Users/Asus/Rlabel/mkdircopy.bat", quote = FALSE, row.names = F, col.names=F)


#3. copy command - based on dir. append to the existing mkdirorsi.bat
copy_output<- merged %>% distinct("copy", filename, dir)
copy_output<- cbind(copy_output[3],copy_output[1],copy_output[2])
write.table(copy_output, file="c:/Users/Asus/Rlabel/mkdircopy.bat" , quote = FALSE, append=TRUE, row.names = F, col.names=F)


dir_create("tag", merged$dir) #inside tag folder, all the dirs of the merge dir column


#copy files into to the dirs
#example: file.copy("c:/Users/Asus/Downloads/tmp/DSC_3037.JPG", "Architecture" )
my_files<-as.character(merged$image_path)
new_dirs<- as.character(merged$dir)
setwd("c:/Users/Asus/Downloads/tmp/tag")

for(file in 1:length(my_files)){
  file.copy(my_files[file], new_dirs[file])
  }

##############################
#here comes the manual work
##############################


#read folders and their files into a df (after manual check)- absolute file path
revised<-data.frame(x=list.files(getwd(), recursive=TRUE)) #


#extract file name into separate column: begin from the last occurrance of /
#revised2<-revised %>% add_column(file=sub("^.+/","",revised$x))
#extract dir name into separate column: between 5th and 6th occurrance of /
#revised2<-revised %>% add_column(dir=sub("*([^/]*/){5}([^/]+).*","\\2",revised$x))

#extract file name into separate column: after /
#revised2<-revised %>% add_column(file=sub("^.+/","",revised$x))
#extract dir name into separate column: before /
#revised2<-revised %>% add_column(dir=sub("/.*","",revised$x))


#extract folder name, and file name into separate columns
revised2<-revised %>% add_column(command="exiftool -keywords+=", dir=sub("/.*","",revised$x),
                                 file=sub("^.+/","",revised$x))

options(useFancyQuotes = FALSE)
revised2[,3]<-dQuote(revised2[,3])
revised3<-paste0(revised2[,2],revised2[,3])

#write final exif commands into a bat
write.table(revised2[,2:4], file="exif.bat" , row.names = F, col.names=F, quote = FALSE)



#clean up
setwd("c:/Users/Asus/Downloads/tmp")

