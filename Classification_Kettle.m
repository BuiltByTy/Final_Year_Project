close all, clear all, clc

% Code for trying to determine the DOA, using the far field method

% Written by Kevin Tighe
% last updated: 22/05/2019


% Import data to be classified
[y1,Fs] = audioread('D:\College\Project_Data\Audio\DATA\Building_1\M-01.wav');
[y2,Fs] = audioread('D:\College\Project_Data\Audio\DATA\Building_1\M-02.wav');
[y3,Fs] = audioread('D:\College\Project_Data\Audio\DATA\Building_1\M-03.wav');
[y4,Fs] = audioread('D:\College\Project_Data\Audio\DATA\Building_1\M-04.wav');
[y5,Fs] = audioread('D:\College\Project_Data\Audio\DATA\Building_1\M-05.wav');
[y6,Fs] = audioread('D:\College\Project_Data\Audio\DATA\Building_1\M-06.wav');
 
%import data to correlate with
[TurnOn, Fs1] = audioread('D:\College\Project_Data\Audio\DATA\Kettle_Data\TurnOn.wav');
[TurnOff, Fs2] = audioread('D:\College\Project_Data\Audio\DATA\Kettle_Data\TurnOff.wav');
TurnOff = TurnOff(1340:7445);

% Create the Time Axis
t =  linspace(0,length(y1)/Fs,length(y1));  
t2 =  linspace(0,length(TurnOn)/Fs,length(TurnOn));  
t3 =  linspace(0,length(TurnOff)/Fs,length(TurnOff));  

% Create the filter properties and the filter
n = 6;
fc = 35;
[b,a] = cheby2(n,40,fc/(Fs/2));

% apply filter onto signals
Z = filter(b,a,y1);
Zon = filter(b,a,TurnOn);
Zoff = filter(b,a,TurnOff);


% Normalize the entire set0
y = (Z-mean(Z))/std(Z);                                                   
TurnOn = (Zon-mean(Zon))/std(Zon);                                         
TurnOff = (Zoff-mean(Zoff))/std(Zoff);

% Plot the results
figure(1)
subplot(3,1,1)
plot(t,y)
grid on, grid minor
title('Signal Containing Activities')
xlabel('Time (Seconds)')
ylabel('Amplitude')
xlim([0, max(t)])
subplot(3,1,2)
plot(t2,TurnOn)
xlim([0, max(t2)])
grid on, grid minor
title('Signal Event Kettle Turning On')
xlabel('Time (Seconds)')
ylabel('Amplitude')
subplot(3,1,3)
plot(t3,TurnOff)
xlim([0, max(t3)])
grid on, grid minor
title('Signal Event Kettle Turning Off')
xlabel('Time (Seconds)')
ylabel('Amplitude')

% Cross Correlate the incoming signal with the two audio events
[corOn lagOn] = xcorr(y,TurnOn);
[corOff LagOff] = xcorr(y,TurnOff);


% plot the result of the Correlation
figure(2)
subplot(2,1,1)
plot(lagOn/Fs, corOn)%,lagOn/Fs)%, abs(corOn))
grid on, grid minor
xlim([0, max(lagOn/Fs)])
title('Signal Containing Activities Correlated Against Signal Event Kettle Turning On')
xlabel('Time (Seconds)')
ylabel('Correlation')
subplot(2,1,2)
plot(LagOff/Fs, corOff)%, LagOff/Fs)%, abs(corOff))
title('Signal Containing Activities Correlated Against Signal Event Kettle Turning Off')
xlabel('Time (Seconds)')
ylabel('Correlation')
grid on, grid minor
xlim([0, max(LagOff/Fs)])

%% Method 2 of Correlation.

% create a chunk
chunk = 2.^10;
N = length(y);
frame_len = chunk*10;                                % Create the frame size
num_frames = floor(N/frame_len)-1;                   % Calculatae the no. Frames needed

TurnOn = TurnOn.';                                   % Move Data arrangement for zero padding
TurnOff = TurnOff.';                                 % Move Data arrangement for zero padding

%Create the Data frames to be Correlated
TurnOnN = [zeros(1,2102) TurnOn zeros(1,2101)];
TurnOffN = [zeros(1,2067) TurnOff zeros(1,2067)];

TurnOnN = TurnOnN.';
TurnOffN = TurnOffN.';

% Plot the signals to be used for Cross Correlation
figure(3)
subplot(2,1,1)
plot(t2,TurnOn)
xlim([0, max(t2)])
grid on, grid minor
title('Signal Event Kettle Turning On')
xlabel('Time (Seconds)')
ylabel('Amplitude')
subplot(2,1,2)
plot(t3,TurnOff)
xlim([0, max(t3)])
grid on, grid minor
title('Signal Event Kettle Turning Off')
xlabel('Time (Seconds)')
ylabel('Amplitude')
% Create the frames

% Cross-Corrleate Each frame
for k = 1:num_frames
     
    % Frame odd moves up in full steps of 10
    frame_Live_odd  = y((k-1)*frame_len + 1:frame_len*k);
    
    frame_Live_even = y((k-0.5)*frame_len + 1:frame_len*(k+0.5));
    
    CorOn1(k) = sum(frame_Live_odd.*TurnOnN);
    CorOn2(k) = sum(frame_Live_even.*TurnOnN);
    CorOff1(k) = sum(frame_Live_odd.*TurnOffN);
    CorOff2(k) = sum(frame_Live_even.*TurnOffN);
end

CorOnAvg = abs(CorOn1+CorOn2/2);
CorOffAvg = abs(CorOff1+CorOff2/2);
Cor_axis = 1:length(CorOn1);
Cor_axis2 = 1:length(CorOn2);

figure(4)
subplot(2,1,1)
plot(Cor_axis,abs(CorOn1),Cor_axis, abs(CorOn2),Cor_axis,CorOnAvg)
legend('Correlation of Even Frame','Correlation of Odd Frames','Average Correlation')
grid on, grid minor
title('Correlation of Kettle Going on with Live Activites')
xlabel('Frame Number')
ylabel('Amplitude')
xlim([0 max(Cor_axis)])
subplot(2,1,2)
plot(Cor_axis2,abs(CorOff1),Cor_axis2, abs(CorOff2),Cor_axis2,CorOffAvg)
legend('Correlation of Even Frame','Correlation of Odd Frames','Average Correlation')
grid on, grid minor
xlim([0 max(Cor_axis2)])
title('Correlation of Kettle Going on with Live Activites')
xlabel('Frame Number')
ylabel('Amplitude')