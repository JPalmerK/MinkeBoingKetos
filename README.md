# [PAMGuard](https://www.pamguard.org/) Minke Whale Neural Network Detector built with [Meridian Ketos](https://meridian.cs.dal.ca/2015/04/12/ketos/) Pipeline 

![image](https://github.com/JPalmerK/MinkeBoingKetos/assets/28478110/c8a9ba01-894a-4b84-9ce6-2033f70fab14)
# Data
## Minke Detections

|    <br>Project/Instrument    	|    <br>Location    	|    <br>Sample   Rate Provided (khz)    	|    <br>Number    	|    <br>Annotators           	|
|------------------------------	|--------------------	|----------------------------------------	|------------------	|-----------------------------	|
|    <br>ADRIFT/PASCAL/CCES    	|    <br>Around…     	|    <br>12                              	|    <br>319*      	|    <br>Kourtney/Kaitlin     	|
|    <br>HICEAS                	|    <br>ETP/CA      	|    <br>12                              	|    <br>67        	|    <br>Shannon              	|
|    <br>S-267                 	|    <br>ETP/CA      	|    <br>12                              	|    <br>73        	|    <br>Shannon              	|
|    <br>STAR                  	|    <br>ETP/CA      	|    <br>12                              	|    <br>25        	|    <br>Shannon              	|
|    <br>HARP Longline         	|    <br>Hawaii      	|    <br>325                             	|    <br>391*      	|    <br>Anne/Erin/Kaitlin    	|





## Spectrogram Parameters
All data above 12khz were downsampled to 12khz. Additional paramaters are found in the associated JSON files (e.g. spec_configMinkeSpec.JSON)

## Negative Data (Not Minke Whale)
*	15000 Not Minke GPL detections (750hz-2khz) from 1 ADRIFT file
*	350 Hand annotations of HARP Background
*	Balanced for this approach
*	Representative of noise
*	Extracted from GPL detections drift 19
*	Manually annotated from noisy HARP data (background looks like target)

## Data Augmentation
As there were far more negative examples than positive examples, the positive examples were augmented by repatedly mixing them with background samplles. In this process each positive sample from a non-HARP instrument was mixed randomly with background from the HARP. Minke Boings recored on the HARP were mixed with background samples from ADRIFT. This process was repeated for all posive samples 3 times in addition to including the un-augmented clips.
![image](https://github.com/JPalmerK/MinkeBoingKetos/assets/28478110/4a497aa8-32ac-4cbc-a666-1e7d60eb1212)

## Train/Test Split
One fifth of the data were held out for testing. 

## PAMGuard
The final model was exported from PYTHON and has been successfully run in the PAMguard enviornment. PAMGuard settings file and trained model are retained in the models section


