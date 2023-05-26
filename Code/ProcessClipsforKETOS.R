# PAMpal simple example 
# Its on CRAN. Yay!
# install.packages('PAMpal')
# Sometimes I fix things and theyre only available on the GitHub version
# Right now there are some things that run a lot faster on teh GitHub version
# so I recommend installing that.
# updated 22-12-6 to include loop for PG event adding w/PAMmisc

rm(list=ls())
#devtools::install_github('TaikiSan21/PAMpal')

library(PAMpal)
library(lubridate)
library(PAMmisc)
library(stringr)
#source('timeEventFunctions.R')


# Start by creating a "PAMpalSettings" object. This keeps track of what data
# you want to process and what processing you want to apply to it.

# Change paths below to your DB and binary folder. Can just be the 
# highest level binary folder for that drift - it will add all files
# within that folder recursively through subfolders.

# This will also ask you to type in some parameters for calculations
# in your console. You can just hit ENTER to accept defaults for all
# of these, they aren't relevant to the GPL calculations only for clicks.

dbLoc = 'E:/DATA/GPL_HB_GRAY/DATABASES/GPL_HB_Gray_PG2_02_07_ADRIFT_019.sqlite3'
binLoc = 'E:/DATA/GPL_HB_GRAY/BINARY/ADRIFT_019'
recLoc = 'E:/RECORDINGS/ADRIFT_019_CENSOR_12kHz/'


pps <- PAMpalSettings(db = dbLoc,
                      binaries = binLoc,
                      # these parameters are only for the click detector - can ignroe
                      sr_hz='auto',
                      filterfrom_khz=0,
                      filterto_khz=NULL,
                      winLen_sec=.0025)

# Now tell it to process your data. Id is optional and serves no function,
# but can be useful to tell data apart at a later point in time. Here
# mode = 'recording' tells it how to organize your data. Most of the time
# we are working with data that have been marked manually into events, 
# so PAMpal wants to organize things into events. mode='db' uses the events
# in the database, and only processes the detectoins you've marked out.
# In this case we just want to process everything, which is what 
# mode='recording' does. It will group them into events by recording file. 


# Soundtrap Pattern
nameStringPattern = '\\d{12}'
nameStringFormat ='%y%m%d%H%M%OS'
lubradiateFormat ="ymdHMS"


data <- processPgDetections(pps, mode='recording', id='Humpback007')
# And here's how you can get the detections information out of "data"
# as a dataframe. Time column is "UTC", other columns are stuff it
# measured.
# Now we can add the wav files to this data. You might get a warning about
# "startSample", its safe to ignore that.
data <- addRecordings(data, folder= recLoc)

gplDf <- getGPLData(data)

data <- processPgDetections(pps, mode='recording', id='Humpback007')
# And here's how you can get the detections information out of "data"
# as a dataframe. Time column is "UTC", other columns are stuff it
# measured.
# Now we can add the wav files to this data. You might get a warning about
# "startSample", its safe to ignore that.
data <- addRecordings(data, folder= recLoc)

gplDf <- getGPLData(data)

gplkeepidx = which(abs(gplDf$freqMean-1000)<200)

datasamall = data[gplkeepidx]


###########
writeEventClips(datasamall, buffer = c(-2,2), 
                outDir = 'C:/Users/kaitlin.palmer/Desktop/KetosMinke/Training Data/NegativeClips',
                mode = 'detection',fixLength = TRUE)

clipNames = list.files(path = 'C:/Users/kaitlin.palmer/Desktop/KetosMinke/Training Data/NegativeClips',
                       pattern = '.wav')

aa = parseEventClipName(clipNames)


#############################################
# Modify the raven log for consistant clip sizes
# Load file list and annotation log
Ravenlog = read.table('C:/Users/kaitlin.palmer/Documents/GitHub/BlueWhaleAKetosModel/Raven_BlueACall_Annotations/CCES_2018_Drift_07_BlueACalls_modified.txt',
                      sep="\t", header=TRUE, check.names = FALSE)
centerTime = (Ravenlog$`End Time (s)`+Ravenlog$`Begin Time (s)`)/2

# Create 10 second clips

fs =500
startSec=c()
totalDuration =10

for(ii in 1:nrow(Ravenlog)){
  
  # 1) Call at start of file, only augment from center 
  if(Ravenlog$`Beg File Samp (samples)`[ii]<(fs)){
    
    # sample from start
    startSec = c(startSec, Ravenlog$`Begin Time (s)`[ii])
    
    # if there is more than five seconds, take another sampe
    if(Ravenlog$`Delta Time (s)`[ii]>(totalDuration/2)){
      startSec = c(startSec, Ravenlog$`Begin Time (s)`[ii]+3)
    }
    
    
  } else if(
  
  # 2) If call is at the end of the log
  ((Ravenlog$`End File Samp (samples)`[ii])/fs>totalDuration)){
    startSec = c(startSec, Ravenlog$`End Time (s)`[ii]-totalDuration)
    
    # if there is more than five seconds, take another sample
    if(Ravenlog$`Delta Time (s)`[ii]>(totalDuration/2)){
      startSec = c(startSec, Ravenlog$`End Time (s)`[ii]-7)
    }
    
  }else{
    # 3) Call is not near boundaries
  startSec=c(startSec,
             Ravenlog$`Begin Time (s)`[ii]-1,
             centerTime[ii],
             Ravenlog$`End Time (s)`[ii]-7)
  
  print('center')
  }

  print(ii)
  
  
}
endSec = startSec+totalDuration

selectionTableOut = data.frame(Selection = 1:length(endSec),
                               View= 'Spectrogram 1',
                               Channel = 1,
                               beginTime = startSec,
                               endTime = endSec,
                               lowf= 40, 
                               highf=120)
colnames(selectionTableOut)<-colnames(Ravenlog)[1:7]

write.table(x = selectionTableOut, 
            file = 'C:/Users/kaitlin.palmer/Documents/GitHub/BlueWhaleAKetosModel/Raven_BlueACall_Annotations/NNSamples_03.txt',
              sep="\t", quote = FALSE,row.names = FALSE)


