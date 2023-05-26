% Code used to prepare audio clips for ketos. Positive clips came from
% raven selection tables ann negative exampels came from Pamguard GPL
% detections exported using Pampal
clear all; clc

% Data folders
PosExamplesLoc = 'C:\Users\kaitlin.palmer\Desktop\KetosMinke\Training Data\TruePositiveClipsRAW';
NegExamplesLoc = 'C:\Users\kaitlin.palmer\Desktop\KetosMinke\Training Data\NegativeClips'

% Output folders
trainFolder ='C:\Users\kaitlin.palmer\Desktop\KetosMinke\Training Data\TP12khz\TrainTrim';
valFolder= 'C:\Users\kaitlin.palmer\Desktop\KetosMinke\Training Data\TP12khz\ValTrim';


% Step through the positive examples, record the name if 10 seconds long
% copy to either the train or the validate folder
posSamps = dir(fullfile(PosExamplesLoc,'\**\*.wav'));
negSamps = dir(fullfile(NegExamplesLoc,'\**\*.wav'));

trainFiles=[];
trainLables =[];
valFiles={};
valLabels =[];

% Intended lengh of clips
maxDur =4;% seconds
fsOut =12000;
badData=[];
%% Positive samples first
for ii=1:length(posSamps)

    [yy, fs] = audioread(fullfile(posSamps(ii).folder, posSamps(ii).name) );

    % Data at least 10 seconds, write to train or validate
    if (length(yy)>=(fs*maxDur))

        % Cool, long enough to write now check the sample rate
        if(fs>fsOut)

            [p,q] = rat(fsOut / fs);
            yy = resample(yy, p,q);

        end

        % Write data to the train or validate folder
        if(rem(ii, 5) ~=0)
            outloc =fullfile(trainFolder, posSamps(ii).name);
            trainLables=[trainLables,1];
            trainFiles=[trainFiles;  {posSamps(ii).name}];
        else
            outloc = fullfile(valFolder, posSamps(ii).name);
            valLabels=[valLabels; 1];
            valFiles=[valFiles;  {posSamps(ii).name}];
            
        end

        % Trim the audio
        disp(length(yy)/fsOut)
        yy = yy(1:fsOut*maxDur,:);

        audiowrite(outloc, yy,fsOut);

    else
        badData = [badData, ii];
    end
    %disp(ii)
end
%% Mix a random selection of the negative and positive audio files to make

% Adjusted positive files
adjDataloc ='C:\Users\kaitlin.palmer\Desktop\KetosMinke\Training Data\TruePositiveClipsRAW';
posSamps = dir(fullfile(adjDataloc,'\**\*.wav'));

% index of negative samples
n =length(posSamps)*3;

idxSig = repmat(1:n/3,[1,3]);

% Negative Examples
for ii=1:n

    % random SNR
    multiplier = datasample(2:.5:4,1);

    % Load the signal and the noise
    [yySig, fs] = audioread(fullfile(posSamps(idxSig(ii)).folder, posSamps(idxSig(ii)).name));

    % Trim/resample signal
    if(fs>fsOut)
        [p,q] = rat(fsOut / fs);
        yySig = resample(yySig, p,q);
    end
    yySig=yySig(1:fsOut*4);


    % If harp data pull from soundtrap noise and visa versa
    if(contains(posSamps(idxSig(ii)).name, 'HARP'))
        idxNoise = datasample(1:15289, 1, 'Replace',true);
    else
        idxNoise = datasample(15290:15703, 1, 'Replace',true);
    end

    [yyNosie, fs] = audioread(fullfile(negSamps(idxNoise).folder,...
        negSamps(idxNoise).name));

    %Trim/resample noise as before
    if(fs>fsOut)
        [p,q] = rat(fsOut / fs);
        yyNosie = resample(yyNosie, p,q);

    end
    yyNosie=yyNosie(1:fsOut*4);
    yyAug = (yyNosie+yySig*multiplier)/multiplier+1;

    % Send to train or validate

    % Write data to the train or validate folder
    if(rem(ii, 5) ~=0)
        outloc =fullfile(trainFolder, ['Augment_',num2str(ii),'_',posSamps(idxSig(ii)).name]);
        trainLables=[trainLables,1];
        trainFiles=[trainFiles;  {['Augment_',num2str(ii),'_',posSamps(idxSig(ii)).name]}];
    else
        outloc = fullfile(valFolder, ['Augment_',num2str(ii),'_',posSamps(idxSig(ii)).name]);
        valFiles=[valFiles;  {['Augment_',num2str(ii),'_',posSamps(idxSig(ii)).name]}];
        valLabels=[valLabels; 1];
    end


    audiowrite(outloc, yy,fsOut);
    disp(ii)
end

%% Now do the negative examples

% Figure out how many positive samples there are and flesh out the rest
% with random detections

nNeg =  length(trainFiles)+length(valFiles)-500

negidx = [15284:length(negSamps), datasample(1:15283, nNeg, 'Replace',false)];

negSub=negSamps(negidx,:);

% Negative Examples
for ii=1:length(negSub)

    [yy, fs] = audioread(fullfile(negSub(ii).folder, negSub(ii).name) );

    % Data at least 4 seconds, write to train or validate
    if (length(yy)>=fs*4)

        % Cool, long enough to write now check the sample rate
        if(fs>fsOut)
            [p,q] = rat(fsOut / fs);
            yy = resample(yy, p,q);

        end

        if(rem(ii, 5) ~=0)
            outloc = fullfile(trainFolder, negSub(ii).name);
            trainFiles=[trainFiles;  {negSub(ii).name}];
            trainLables=[trainLables,0];

        else
            outloc = fullfile(valFolder, negSub(ii).name);
            valFiles=[valFiles;  {negSub(ii).name}];
            valLabels=[valLabels;0];
        end

        audiowrite(outloc, yy(1:fsOut*4), fsOut);
    end
    disp(ii)
end


%% File list

% Create the CSV files for the train and validate
trainCSV =  table()
trainCSV.sound_file  = trainFiles;
trainCSV.label = trainLables';
                 

valCSV = table();
valCSV.sound_file  = valFiles;
valCSV.label = valLabels;

trainCSV= sortrows(trainCSV,'label');
valCSV = sortrows(valCSV,'label');

[~,idx]=unique(trainCSV,'rows','first');
trainCSVtrim=trainCSV(sort(idx),:);

[~,idx]=unique(valCSV,'rows','first');
valCSVtrim=valCSV(sort(idx),:);

%%

writetable(trainCSV,'C:\Users\kaitlin.palmer\Desktop\KetosMinke\Training Data\TP12khz\TrainMinkeTrimmed.csv' )

writetable(valCSV,'C:\Users\kaitlin.palmer\Desktop\KetosMinke\Training Data\TP12khz\ValMinkeTrimmed.csv' )