close all, clear all, clc

% Import data to be classified
[y1,Fs] = audioread('D:\College\Project_Data\Audio\DATA\Building_1\M-01.wav');
[y2,Fs] = audioread('D:\College\Project_Data\Audio\DATA\Building_1\M-02.wav');
[y3,Fs] = audioread('D:\College\Project_Data\Audio\DATA\Building_1\M-03.wav');
[y4,Fs] = audioread('D:\College\Project_Data\Audio\DATA\Building_1\M-04.wav');
[y5,Fs] = audioread('D:\College\Project_Data\Audio\DATA\Building_1\M-05.wav');
[y6,Fs] = audioread('D:\College\Project_Data\Audio\DATA\Building_1\M-06.wav');
 
%import data to correlate with
[ToastOn, Fs1] = audioread('D:\College\Project_Data\Audio\DATA\Toaster_Data\TurnOn.wav');
[ToastOff, Fs2] = audioread('D:\College\Project_Data\Audio\DATA\Toaster_Data\TurnOff.wav');
ToastOff = ToastOff(5517:14079);

% Create the Time Axis
t =  linspace(0,length(y1)/Fs,length(y1));  
t2 =  linspace(0,length(ToastOn)/Fs,length(ToastOn));  
t3 =  linspace(0,length(ToastOff)/Fs,length(ToastOff));  


n = 6;
fc = 35;
[b,a] = cheby2(n,40,fc/(Fs/2));
y = filter(b,a,y1);
ToastOn = filter(b,a,ToastOn);
ToastOff = filter(b,a,ToastOff);

%{
y = (Z-mean(Z))/std(Z);                                                    % Normalize the entire set
ToastOn = (Zon-mean(Zon))/std(Zon);                                        % Normalize the entire
ToastOff = (Zoff-mean(Zoff))/std(Zoff);
%}
figure(1)
subplot(3,1,1)
plot(t,y)
grid on, grid minor
title('Signal Containing Activities')
xlabel('Time (Seconds)')
ylabel('Amplitude')
xlim([0, max(t)])
subplot(3,1,2)
plot(t2,ToastOn)
xlim([0, max(t2)])
grid on, grid minor
title('Signal Event Toaster Turning On')
xlabel('Time (Seconds)')
ylabel('Amplitude')
subplot(3,1,3)
plot(t3,ToastOff)
xlim([0, max(t3)])
grid on, grid minor
title('Signal Event Toaster Turning Off')
xlabel('Time (Seconds)')
ylabel('Amplitude')


[corOn lagOn] = xcorr(y,ToastOn);
[corOff LagOff] = xcorr(y,ToastOff);

%CorEnvOn = envelope(corOn,Fs,'peak');
%CorEnvOff = envelope(corOff,80,'peak');

% plot the result of the Correlation
figure(2)
subplot(2,1,1)
plot(lagOn/Fs, corOn)
grid on, grid minor
xlim([0, max(lagOn/Fs)])
title('Signal Containing Activities Correlated Against Signal Event Toaster Turning On (Method 1)')
xlabel('Time (Seconds)')
ylabel('Correlation')
subplot(2,1,2)
plot(LagOff/Fs, corOff)
title('Signal Containing Activities Correlated Against Signal Event Toaster Turning Off (Method 1)')
xlabel('Time (Seconds)')
ylabel('Correlation')
grid on, grid minor
xlim([0, max(LagOff/Fs)])

%% Method 2 of Correlation.

chunk = 2.^10;
N = length(y);
frame_len = chunk*10;
num_frames = floor(N/frame_len)-1;

ToastOn = ToastOn.';
ToastOff = ToastOff.';
%Create the Data Points to be Correlated with
ToastOnN = [zeros(1,2468) ToastOn zeros(1,2468)];
ToastOffN = [zeros(1,838) ToastOff zeros(1,839)];

ToastOnN = ToastOnN.';
ToastOffN = ToastOffN.';


figure(3)
subplot(2,1,1)
plot(t2,ToastOn)
xlim([0, max(t2)])
grid on, grid minor
title('Signal Event Toaster Turning On')
xlabel('Time (Seconds)')
ylabel('Amplitude')
subplot(2,1,2)
plot(t3,ToastOff)
xlim([0, max(t3)])
grid on, grid minor
title('Signal Event Toaster Turning Off')
xlabel('Time (Seconds)')
ylabel('Amplitude')
% Create the frames


for k = 1:num_frames
     
    frame_Live_odd  = y((k-1)*frame_len + 1:frame_len*k);
    
    frame_Live_even = y((k-0.5)*frame_len + 1:frame_len*(k+0.5));
    
    CorOn1(k) = sum(frame_Live_odd.*ToastOnN);
    CorOn2(k) = sum(frame_Live_even.*ToastOnN);
    CorOff1(k) = sum(frame_Live_odd.*ToastOffN);
    CorOff2(k) = sum(frame_Live_even.*ToastOffN);
end

CorOnAvg = abs(CorOn1+CorOn2/2);
CorOffAvg = abs(CorOff1+CorOff2/2);
Cor_axis = 1:length(CorOn1);
Cor_axis2 = 1:length(CorOn2);

figure(4)
subplot(2,1,1)
plot(Cor_axis,abs(CorOn1),Cor_axis,abs(CorOn2),Cor_axis,CorOnAvg)
legend('Correlation of Even Frame','Correlation of Odd Frames','Average Correlation')
grid on, grid minor
title('Correlation of Toaster being Turned On with Live Activites (Method 2)')
xlabel('Frame Number')
ylabel('Correlation')
xlim([0 max(Cor_axis)])
subplot(2,1,2)
plot(Cor_axis2,abs(CorOff1),Cor_axis2,abs(CorOff2),Cor_axis2,CorOffAvg)
legend('Correlation of Even Frame','Correlation of Odd Frames','Average Correlation')
grid on, grid minor
xlim([0 max(Cor_axis2)])
title('Correlation of Toaster Turning off with Live Activites (Method 2)')
xlabel('Frame Number')
ylabel('Correlation')