clear all
clc;

%Radar Specifications
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Frequency of operation = 77GHz
% Max Range = 200m
% Range Resolution = 1 m
% Max Velocity = 100 m/s
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%speed of light = 3e8
c = 3e8; %speed of light 

%User Defined Range and Velocity of target
%TODO : define the target's initial position and velocity. Note : Velocity remains contant
%fs = 77e9;
R = 100; % initial seed of the target
v =  -20; %speed of target

%FMCW Waveform Generation
% *%TODO* :
%Design the FMCW waveform by giving the specs of each of its parameters.
% Calculate the Bandwidth (B), Chirp Time (Tchirp) and Slope (slope) of the FMCW
% chirp using the requirements above.
Rmax = 200 ; % max range
Dres = 1 ; % range resolution
Vmax = 100; % max speed

B  =  c / 2*Dres; % sweep bandwidth
Tchirp = 5.5 * 2 * Rmax /c ; 
%Operating carrier frequency of Radar 
fc= 77e9;             %carrier freq

slop  = B / Tchirp ;
                                                          
%The number of chirps in one sequence. Its ideal to have 2^ value for the ease of running the FFT
%for Doppler Estimation. 
Nd=128;                   % #of doppler cells OR #of sent periods % number of chirps

%The number of samples on each chirp. 
Nr=1024;                  %for length of time OR # of range cells

% Timestamp for running the displacement scenario for every sample on each
% chirp
t=linspace(0,Nd*Tchirp,Nr*Nd); %total time for samples


%Creating the vectors for Tx, Rx and Mix based on the total samples input.
Tx=zeros(1,length(t)); %transmitted signal
Rx=zeros(1,length(t)); %received signal
Mix = zeros(1,length(t)); %beat signal

%Similar vectors for range_covered and time delay.
r_t=zeros(1,length(t));
td=zeros(1,length(t));

%Signal generation and Moving Target simulation
%Running the radar scenario over the time. 
for i=1:length(t)         
    
    
    % *%TODO* :
    
    %For each time stamp update the Range of the Target for constant velocity. 
    r_t(i) = R + v*t(i); %% 
    % *%TODO* :
    %For each time sample we need update the transmitted and
    %received signal. 
    td(i) = 2*r_t(i) /c;
    Tx(i) = cos(2 * pi * ( fc*t(i) + slop*(t(i)^2) / 2 ));
    Rx(i)  = cos(2*pi*(fc*(t(i)-td(i)) + slop*(t(i)-td(i))^2 / 2 ));
    
    % *%TODO* :
    %Now by mixing the Transmit and Receive generate the beat signal
    %This is done by element wise matrix multiplication of Transmit and
    %Receiver Signal
    Mix(i) = Tx(i)*Rx(i);
    
end

%RANGE MEASUREMENT
 % *%TODO* :
%reshape the vector into Nr*Nd array. Nr and Nd here would also define the size of
%Range and Doppler FFT respectively.
Mix_2d =  reshape(Mix,[Nr,Nd]);
 % *%TODO* :
%run the FFT on the beat signal along the range bins dimension (Nr) and
Mix2d_fft = fft(Mix_2d, Nr) / Nr;


%normalize.

 % *%TODO* :
% Take the absolute value of FFT output
Mix2d_abs = abs(Mix2d_fft);
 % *%TODO* :
% Output of FFT is double sided signal, but we are interested in only one side of the spectrum.
% Hence we throw out half of the samples.
Mix2d_abs = Mix2d_abs(1:Nr/2);

%plotting the range
figure ('Name','Range from First FFT')
subplot(2,1,1)

 % *%TODO* :
 % plot FFT output 

plot(Mix2d_abs);

axis ([0 200 0 1]);

%RANGE DOPPLER RESPONSE
%The 2D FFT implementation is already provided here. This will run a 2DFFT on the mixed signal (beat signal) output and generate a range doppler map.You will implement CFAR on the generated RDM
% Range Doppler Map Generation.

% The output of the 2D FFT is an image that has reponse in the range and
% doppler FFT bins. So, it is important to convert the axis from bin sizes
% to range and doppler based on their Max values.

Mix=reshape(Mix,[Nr,Nd]);

% 2D FFT using the FFT size for both dimensions.
sig_fft2 = fft2(Mix,Nr,Nd);

% Taking just one side of signal from Range dimension.
sig_fft2 = sig_fft2(1:Nr/2,1:Nd);
sig_fft2 = fftshift (sig_fft2);
RDM = abs(sig_fft2);
RDM = 10*log10(RDM) ;

%use the surf function to plot the output of 2DFFT and to show axis in both
%dimensions
doppler_axis = linspace(-100,100,Nd);
range_axis = linspace(-200,200,Nr/2)*((Nr/2)/400);
figure,surf(doppler_axis,range_axis,RDM);

%CFAR implementation
%Slide Window through the complete Range Doppler Map

% *%TODO* :
%Select the number of Training Cells in both the dimensions.

Tr = 10 ; 
Td = 8 ;



% *%TODO* :
%Select the number of Guard Cells in both dimensions around the Cell under 
%test (CUT) for accurate estimation

Gr = 4;
Gd  = 4;


% *%TODO* :
% offset the threshold by SNR value in dB
offset = 9;

% *%TODO* :
%Create a vector to store noise_level for each iteration on training cells
noise_level = zeros(1,1);


% *%TODO* :
%design a loop such that it slides the CUT across range doppler map by
%giving margins at the edges for Training and Guard Cells.
%For every iteration sum the signal level within all the training
%cells. To sum convert the value from logarithmic to linear using db2pow
%function. Average the summed values for all of the training
%cells used. After averaging convert it back to logarithimic using pow2db.
%Further add the offset to it to determine the threshold. Next, compare the
%signal under CUT with this threshold. If the CUT level > threshold assign
%it a value of 1, else equate it to 0.


   % Use RDM[x,y] as the matrix from the output of 2D FFT for implementing
   % CFAR
   % iterate all the CUT cells, start from (Tr+Gr+1, Td+Gd+1), ends
   % in (Nr/2  -  Tr-Gr,  Nd - Td - Gd)
   % into each loop calculate the mean value of all  the training values;
   % add offest
   % determinate the CUT, if value of the current CUT is greatet than
   % threshold, assign  a value of 1, otherwise assign a value of 0;
   
RDM_CFAR = zeros(size(RDM));   
for cx = Tr+Gr+1: Nr/2- (Tr+Gr)       
    for cy = Td+Gd+1:Nd-(Td+Gd)
        
        noise_level =  zeros(1,1);
        for p= cx-(Tr+Gr) : cx+Tr+Gr
            for q= cy-(Td+Gd) : cy+Td+Gd
               if(abs(cx-p)>Gr || abs(cy-q) >Gd)
                   noise_level = noise_level + db2pow(RDM(p,q));
               end
            end
                
        end
        threshold = pow2db( noise_level / (2*(Td+Gd+1)*2*(Tr+Gr+1)-(Gr*Gd)-1));
        threshold = threshold + offset;
        CUT = RDM(cx,cy);
        if CUT < threshold
            
            RDM_CFAR(cx,cy) = 0;
        else 
            RDM_CFAR(cx,cy) = 1;
            
        end
        
        
    end
    
end


% *%TODO* :
% The process above will generate a thresholded block, which is smaller 
%than the Range Doppler Map as the CUT cannot be located at the edges of
%matrix. Hence,few cells will not be thresholded. To keep the map size same
% set those values to 0. 


%RDM(:, 1 : Td + Gd) = 0;
%RDM(:, Nd - (Gd + Td) + 1 : end) = 0;       
%RDM(1 : Tr + Gr, :) = 0;
%RDM(Nr/2 - (Gr + Tr) + 1 : end, :) = 0;




% *%TODO* :
%display the CFAR output using the Surf function like we did for Range
%Doppler Response output.
figure,surf(doppler_axis,range_axis,RDM_CFAR);
colorbar;