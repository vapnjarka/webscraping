# web scraping

Various cases where data from the web were utilized to solve problems.

1, Identifying addresses based on coordinates: address_to_coords.R
------------------------------------------------------------------
used R packages: jsonlite & urltools

The webpage terkepem.hu answers the requests by sending information in json format. To get addresses for batch coordinates, the loop sending on-by-one the url of coordinates as requests to the terkepem.hu server, then the responses in json has been attached to the original data frames' appropriate rows.

2, Geo coding (get coordinates to addresses): coords_to_an_address.R
--------------------------------------------------------------------
used R packages: jsonlite & urltools

The webpage terkepem.hu answers the requests by sending information in json format. To geo coding, the loop sending on-by-one the url of addresses as requests to the terkepem.hu server, then the responses in json has been attached to the original data frames' appropriate rows.

3, Save statistics from the official Hungarian COVID19 info site:korona_webscraping.R
-------------------------------------------------------------------------------------
used R packages: tidyverse, rvest & googlesheets4

Read html code and save html nodes from the koronavirus.gov.hu. Select only relevant html objects and download into a data frame the variable names, the value of the variable and the date of request. Save the date frame into a local csv, and into an on-line google sheet.

4, Tagging photos with google vision API: rlabeling.R
-----------------------------------------------------
used R packages: tidyverse, googleCloudVisionR, googleAuthR

Tagging hundreds of photos by using googles' vision API and its label detection feature. Uploading the images one-by-one with the help of a loop and get all of the tags/descriptions of the image. (For safety, current row has been bound and saved in a csv, not to loose data if connection fails.) Filter fortags higher than a given score (to choose only relevant tags) and join my own dictionary which can help to correspond and aggregate tags. Compile a batch file for create tag named directories and copy the given image into directories with its tag names. Compile a batch file to save tag information into to the images' exif data.
