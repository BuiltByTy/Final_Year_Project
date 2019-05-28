clear all, close all, clc

% Code for trying to determine the DOA, using the far field method

% Written by Kevin Tighe
% last updated: 24/05/2019


%{
[y1,Fs] = audioread('D:\Work\Personal\Documents\Final Year Project\Data_Set_1\18-02-2019-Quiet_Room_day\Exp_7_Quiet_Room_K1_3_Cups\Mic_01.wav');
[y2,Fs] = audioread('D:\Work\Personal\Documents\Final Year Project\Data_Set_1\18-02-2019-Quiet_Room_day\Exp_7_Quiet_Room_K1_3_Cups\Mic_02.wav');
[y3,Fs] = audioread('D:\Work\Personal\Documents\Final Year Project\Data_Set_1\18-02-2019-Quiet_Room_day\Exp_7_Quiet_Room_K1_3_Cups\Mic_03.wav');
[y4,Fs] = audioread('D:\Work\Personal\Documents\Final Year Project\Data_Set_1\18-02-2019-Quiet_Room_day\Exp_7_Quiet_Room_K1_3_Cups\Mic_04.wav');
[y5,Fs] = audioread('D:\Work\Personal\Documents\Final Year Project\Data_Set_1\18-02-2019-Quiet_Room_day\Exp_7_Quiet_Room_K1_3_Cups\Mic_05.wav');
[y6,Fs] = audioread('D:\Work\Personal\Documents\Final Year Project\Data_Set_1\18-02-2019-Quiet_Room_day\Exp_7_Quiet_Room_K1_3_Cups\Mic_06.wav');


[y1,Fs] = audioread('D:\College\Project_Data\Audio\DATA\Building_1\M-01.wav');
[y2,Fs] = audioread('D:\College\Project_Data\Audio\DATA\Building_1\M-02.wav');
[y3,Fs] = audioread('D:\College\Project_Data\Audio\DATA\Building_1\M-03.wav');
[y4,Fs] = audioread('D:\College\Project_Data\Audio\DATA\Building_1\M-04.wav');
[y5,Fs] = audioread('D:\College\Project_Data\Audio\DATA\Building_1\M-05.wav');
[y6,Fs] = audioread('D:\College\Project_Data\Audio\DATA\Building_1\M-06.wav');
 %}

% Kitchen event at 16kHz roughly 240 deg away
%{
[y1,Fs] = audioread('D:\Work\Personal\Documents\Final Year Project\Data_Set_1\Experimental Code\Another_Code\kettle_activities\kitchen_kettle_activities-01.wav');
[y2,Fs] = audioread('D:\Work\Personal\Documents\Final Year Project\Data_Set_1\Experimental Code\Another_Code\kettle_activities\kitchen_kettle_activities-02.wav');
[y3,Fs] = audioread('D:\Work\Personal\Documents\Final Year Project\Data_Set_1\Experimental Code\Another_Code\kettle_activities\kitchen_kettle_activities-03.wav');
[y4,Fs] = audioread('D:\Work\Personal\Documents\Final Year Project\Data_Set_1\Experimental Code\Another_Code\kettle_activities\kitchen_kettle_activities-04.wav');
[y5,Fs] = audioread('D:\Work\Personal\Documents\Final Year Project\Data_Set_1\Experimental Code\Another_Code\kettle_activities\kitchen_kettle_activities-05.wav');
[y6,Fs] = audioread('D:\Work\Personal\Documents\Final Year Project\Data_Set_1\Experimental Code\Another_Code\kettle_activities\kitchen_kettle_activities-06.wav');
%}

% Another kitchen test roughly 45 Deg away
[y1_16,Fs] = audioread('D:\College\Project_Data\Audio\AngleTest\M-01.wav');
[y2_16,Fs] = audioread('D:\College\Project_Data\Audio\AngleTest\M-02.wav');
[y3_16,Fs] = audioread('D:\College\Project_Data\Audio\AngleTest\M-03.wav');
[y4_16,Fs] = audioread('D:\College\Project_Data\Audio\AngleTest\M-04.wav');
[y5_16,Fs] = audioread('D:\College\Project_Data\Audio\AngleTest\M-05.wav');
[y6_16,Fs] = audioread('D:\College\Project_Data\Audio\AngleTest\M-06.wav');

%{
[y1_16,Fs] = audioread('D:\College\Project_Data\Audio\tone_check\16t\mic-01.wav');
[y2_16,Fs] = audioread('D:\College\Project_Data\Audio\tone_check\16t\mic-02.wav');
[y3_16,Fs] = audioread('D:\College\Project_Data\Audio\tone_check\16t\mic-03.wav');
[y4_16,Fs] = audioread('D:\College\Project_Data\Audio\tone_check\16t\mic-04.wav');
[y5_16,Fs] = audioread('D:\College\Project_Data\Audio\tone_check\16t\mic-05.wav');
[y6_16,Fs] = audioread('D:\College\Project_Data\Audio\tone_check\16t\mic-06.wav');
%}


c = 343;                                                                   % Speed of Sound
mic_d = 0.064;                                                             % Microphone distance
max_time = mic_d / c;                                                      % Maximum travel time between microphone groups

% Create the Segment of interest
%SegZ = [(k(i)-(chunk/2)):(k(i)+(chunk*14))];
seg = 678921:678921+16892;
seg16 = 86435-(2.^10*5):99519;
seg16k = 122000:129938;

% create mic_group to apply signal amonst all 6 channels
Mic_Group = [[y1_16(seg)],...
            [y2_16(seg)],...
            [y3_16(seg)],...
            [y4_16(seg)],...
            [y5_16(seg)],...
            [y6_16(seg)]];

plot(Mic_Group)
        
[COR(:,1), LAGS(:,1)] = xcorr(Mic_Group(:,1), Mic_Group(:,4));
[COR(:,2), LAGS(:,2)] = xcorr(Mic_Group(:,2), Mic_Group(:,5));
[COR(:,3), LAGS(:,3)] = xcorr(Mic_Group(:,3), Mic_Group(:,6));


[q,m] = max(COR);                                                          % Using Max to find the peaks of highest correlation

% calculate the TDOA
% Calculate the time difference between microphone groups
delta_T1 = LAGS(m(1))/Fs;
delta_T2 = LAGS(m(2))/Fs;
delta_T3 = LAGS(m(3))/Fs;

% Calculate the angle in radians
delta_1 = asin((delta_T1*c)/mic_d);
delta_2 = asin((delta_T2*c)/mic_d);
delta_3 = asin((delta_T3*c)/mic_d);

% Change it into deg
angle1 = delta_1*(180/pi());
angle2 = delta_2*(180/pi());
angle3 = delta_3*(180/pi());

% Disrecard any information from the microphones if above a certain
% treshold
if delta_T1>max_time
    angle1 = 0;
elseif delta_T2>max_time
    angle2 = 0;
elseif delta_T3>max_time
    andle3 = 0;0
elseif delta_T1<max_time
    angle1 = angle1 + 60;
elseif delta_T3<max_time
    andle3 = angle3 + 120;
end

DOA_Est = (angle1+angle2+angle3)
