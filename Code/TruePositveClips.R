# True positive clips

#############################################
# Modify the raven log for consistant clip sizes
# Load file list and annotation log

RavenLogLoc = 'C:/Users/kaitlin.palmer/Documents/GitHub/BlueWhaleAKetosModel/Raven_BlueACall_Annotations/CCES_2018_Drift_07_BlueACalls_modified.txt'

Ravenlog = read.table(RavenLogLoc, sep="\t", 
                      header=TRUE, check.names = FALSE)
centerTime = (Ravenlog$`End Time (s)`+Ravenlog$`Begin Time (s)`)/2

# Create 4 second clips

fs =500 # update, should be 12khz I believe
startSec=c()
totalDuration = 4 # duration in seconds

for(ii in 1:nrow(Ravenlog)){
  
  # 1) Call at start of file, only augment from center 
  if(Ravenlog$`Beg File Samp (samples)`[ii]<(fs)){
    
    # sample from start
    startSec = c(startSec, Ravenlog$`Begin Time (s)`[ii])
    
    # if there is more than five seconds, take another sampe
    if(Ravenlog$`Delta Time (s)`[ii]>(totalDuration/2)){
      startSec = c(startSec, Ravenlog$`Begin Time (s)`[ii]+2)
    }
    
    
  } else if(
    
    # 2) If call is at the end of the log
    ((Ravenlog$`End File Samp (samples)`[ii])/fs>totalDuration)){
    startSec = c(startSec, Ravenlog$`End Time (s)`[ii]-totalDuration)
    
    # if there is more than 2 seconds, take another sample
    if(Ravenlog$`Delta Time (s)`[ii]>(totalDuration/2)){
      startSec = c(startSec, Ravenlog$`End Time (s)`[ii]-2)
    }
    
  }else{
    # 3) Call is not near boundaries
    startSec=c(startSec,
               Ravenlog$`Begin Time (s)`[ii]-1,
               centerTime[ii],
               Ravenlog$`End Time (s)`[ii]-1)
    
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
                               lowf= 40, # set reasonable low and high frequencies
                               highf=120)
colnames(selectionTableOut)<-colnames(Ravenlog)[1:7]

# Where write the table
ravenOutLoc = 'C:/Users/kaitlin.palmer/Documents/GitHub/BlueWhaleAKetosModel/Raven_BlueACall_Annotations/NNSamples_03.txt'
write.table(x = selectionTableOut, 
            file =ravenOutLoc,
            sep="\t", quote = FALSE,row.names = FALSE)

