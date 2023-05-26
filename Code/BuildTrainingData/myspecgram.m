
function  [sg,freq_vector,time] = myspecgram(signal,nfft,Fs,Overlap)
% [sg,freq_vector,time] = myspecgram(signal,NFFT,Fs,hanning(NFFT),floor(NFFT*OVERLAP));
% FFT peak spectrogram of signal  (example sinus amplitude 1   = 0 dB after fft).
%   signal - input signal, 
%   Fs - Sampling frequency (Hz).
%   nfft - FFT window size
%   Overlap - buffer overlap % (between 0 and 0.95)
dt = 1/Fs;
signal = signal(:);
samples = length(signal);
% fill signal with zeros if its length is lower than nfft
if samples<nfft
    s_tmp = zeros(nfft,1);
    s_tmp((1:samples)) = signal;
    signal = s_tmp;
    samples = nfft;
end
% window : hanning
window = hanning(nfft);
window = window(:);
%    compute fft with overlap 
 offset = fix((1-Overlap)*nfft);
 spectnum = 1+ fix((samples-nfft)/offset); % Number of windows
%     % for info is equivalent to : 
%     noverlap = Overlap*nfft;
%     spectnum = fix((samples-noverlap)/(nfft-noverlap));	% Number of windows
    % main loop
    sg = [];
    for i=1:spectnum
        start = (i-1)*offset;
        sw = signal((1+start):(start+nfft)).*window;
        sg = [sg (abs(fft(sw))*4/nfft)];     % X=fft(x.*hanning(N))*4/N; % hanning only 
        time(i) = (start+nfft/2)*dt; % time defined as in the middle of the data buffer
    end
% one sidded fft spectrum  % Select first half 
    if rem(nfft,2)    % nfft odd
        select = (1:(nfft+1)/2)';
    else
        select = (1:nfft/2+1)';
    end
    
sg = sg(select,:);
freq_vector = (select - 1)*Fs/nfft;
end 