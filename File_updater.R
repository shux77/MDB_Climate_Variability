#Script to compare files with those on BOM website and save new data if there is an update. 
#14/06/2016 Elisa Jager

#Set MDB dataset or all stations (1 for MDB, 0 for all)
MDB <- 0

#directory variable declared (should maybe edit how main directory assigned so works across machines)
ifelse(MDB == 1, main_dir <- "H:/PhD Drop/Data/bom/acorn/MDB", main_dir <- "H:/PhD Drop/Data/bom/acorn")

#move into main directory
setwd(main_dir)

#loop for separate max and min data folders
for(j in 1:2){
  #set whether looking at max or min data
  ifelse(j == 1, dir_type <- "max", dir_type <- "min")
    
  #read in the list of station info (names and ID Numbers Primarily)
  ifelse( MDB == 1, name_file <- 'Station_Name_list_MDB.txt', name_file <- 'Station_Name_list.txt')
  name_list <- read.table(name_file, what = character, sep="\t", header= TRUE)
  
  #Run through each station in the list
  for(i in 1:(nrow(name_list))){
    # pull station name from the list file. 
    station_name <- toString(name_list[i,2])
    station_ID <- toString(name_list[i,1])
    ifelse(nchar(station_ID) == 4, station_ID <- paste("00",station_ID,sep=""), station_ID <- paste("0",station_ID,sep="")) #add zeros back which are cut in the read phase
    filename_local <- paste(station_name, ".txt",sep="")
    
    
    #move into specific station folder (requires folder to exist)
    setwd(file.path(main_dir,dir_type,station_name))
    
    #Read in Local data file. Separate variable for header and data
    data_local <- read.table(filename_local,skip=1,na.strings="99999.9")
    header_local <- read.table(filename_local,nrows= 1, header = FALSE)
    
    #Read in remote data file.
    filename_remote <- paste("http://www.bom.gov.au/climate/change/acorn/sat/data/acorn.sat.",dir_type, "T.", station_ID, ".daily.txt",sep="")
    data_remote <- read.table(filename_remote,skip=1,na.strings="99999.9")  #get the data from BOM website
    header_remote <- read.table(filename_remote, nrows= 1, header = FALSE)  #get the header of the data file
    
    # check if the two files are the same length
    if(length(data_remote[,1]) != length(data_local[,2]))
    {
      # if not the same then save new data file over the old one. Write header first then append with data.
      write.table(header_remote, filename_local,  col.names = FALSE, row.names = FALSE, quote = FALSE)
      write.table(data_remote,filename_local,col.names = FALSE, row.names = FALSE, append = TRUE, sep = "    ")
    }
    setwd("..")  # move back to data directory for stations (max or min)
  }
  setwd("..") # move back to main directory
}


