# -*- coding: utf-8 -*-
"""
Created on Fri Apr 15 17:10:49 2022

@author: Asus
"""

import urllib.parse
import pandas as pd
import os
import time


#%%


os.chdir('C:/Users/Asus/python/ua_telep')

#split input excel into several excels
data_df = pd.read_excel('ua-list_kieg_kiev_ures_nelk.xlsx')
grouped_df = data_df.groupby('oblaszty_en')

for data in grouped_df.oblaszty_en:
    grouped_df.get_group(data[0]).to_excel("./oblaszty/"+data[0]+".xlsx")

  
#%%
#GET ENGLISH NAMES OF SETTLEMENTS

# assign directory
input_directory = './oblaszty/'
output_directory = './oblaszty2/'
 
# iterate over files in that directory
for filename in os.listdir(input_directory):
    ua_list=pd.read_excel(input_directory+filename) 

    #insert new col
    ua_list["telep_en"] = ""   


    start_time = time.time()


    for j in range(0,ua_list.shape[0]):
        
        
        #get the Cyrillic settlement name
        i=urllib.parse.quote(ua_list['telepules'][j]) 
    
        #send request
        url="http://nominatim.openstreetmap.org/search/"+i+"?format=json&addressdetails=1&accept-language=en"
        #get respond
        df = pd.read_json(url)
        
        if df.shape[0]!=0: #if there at least on row
            #subsetting:where type=admin and oblaszty is the same...
            df2 = df.loc[((df['type']=='administrative') | (df['class']=='place')) & (df['address'].apply(lambda x: x.get('state'))==ua_list['oblaszty_en'][j])]
            if df2.shape[0]!=0: #if there at least on row
                ua_list['telep_en'][j]=df2['display_name'].str.split(',').str.get(0).values[0]
            else: #if no rows remained, take any Ukrainian match
                df2 = df.loc[((df['type']=='administrative') | (df['class']=='place')) & (df['address'].apply(lambda x: x.get('country'))=='Ukraine')]
                if df2.shape[0]!=0: #if there at least on row
                    ua_list['telep_en'][j]=df2['display_name'].str.split(',').str.get(0).values[0]
                else: #if no Ukrainian match -> 999
                    ua_list['telep_en'][j]='999'
        else: 
             ua_list['telep_en'][j]='999'
            
        #save result in every 100 rows and at the end        
        if ((str(j).endswith('00',len(str(j))-2)) | (j==ua_list.shape[0]-1)):
            ua_list.to_excel(output_directory+filename) 
            print(j)
    
    print(filename+":--- %s seconds ---" % (time.time() - start_time))  


#%%
#merge 26 files

#create empty df
df_merged=pd.DataFrame()

#merge loop
for filename in os.listdir('./oblaszty2_kesz/'):
    #print(filename)
    df = pd.read_excel('./oblaszty2_kesz/'+filename)
    df_merged=df_merged.append(df)
    
#save result
df_merged.to_excel('ua_list_en.xlsx')

#%%
#Hungarian queries

# assign directory
input_directory = './oblaszty/'
output_directory = './oblaszty2/'
 
# iterate over files in that directory
for filename in os.listdir(input_directory):
    ua_list=pd.read_excel(input_directory+filename) 

    #insert new col
    ua_list["telep_hu"] = ""   


    start_time = time.time()


    for j in range(0,ua_list.shape[0]):
        
        
        #get the Cyrillic settlement name
        i=urllib.parse.quote(ua_list['telepules'][j]) 
    
        #send request
        url2="http://nominatim.openstreetmap.org/search/"+i+"?format=json&addressdetails=1&accept-language=hu"
        #get respond in Hungarian
        df = pd.read_json(url2)
        
        if df.shape[0]!=0: #if there at least on row
            #subsetting:where type=admin and oblaszty is the same...
            df2 = df.loc[((df['type']=='administrative') | (df['class']=='place')) & (df['address'].apply(lambda x: x.get('state'))==ua_list['oblaszty_hu'][j])]
            if df2.shape[0]!=0: #if there at least on row
                ua_list['telep_hu'][j]=df2['display_name'].str.split(',').str.get(0).values[0]
            else: #if no rows remained, take any Ukrainian match
                df2 = df.loc[((df['type']=='administrative') | (df['class']=='place')) & (df['address'].apply(lambda x: x.get('country'))=='Ukraine')]
                if df2.shape[0]!=0: #if there at least on row
                    ua_list['telep_hu'][j]=df2['display_name'].str.split(',').str.get(0).values[0]
                else: #if no Ukrainian match -> 999
                    ua_list['telep_hu'][j]='999'
        else: 
             ua_list['telep_hu'][j]='999'
            
                
            
        if ((str(j).endswith('00',len(str(j))-2)) | (j==ua_list.shape[0]-1)):
            #save result:
            ua_list.to_excel(output_directory+filename) 
            print(j)
    
    print(filename+":--- %s seconds ---" % (time.time() - start_time))  

     
