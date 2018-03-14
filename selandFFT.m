function [ pow3d, phase, freqs] = selandFFT( outmat3d, selectmat, selectmat2, selectmat3, subject )
%this function lets you select time points and does an FFT on each epoch
%IF YOU WANT TO KEEP THE WHOLE TRIAL, ENTER [1 1] FOR THAT TRIAL, OTHERWISE
%ENTER THE TIME POINTS YOU WANT TO REMOVE E.G., [1 1; 1 1; 51 5000; 1 1]
%WOULD BE KEEPING ALL POINTS FOR THE 1, 2, AND LAST TRIALS BUT REMOVING THE
%FIRST HALF OF THE THIRD TRIAL. 


%%%%IMPORTANT: the time needs to be in data points NOT the time. So you
%%%%need to divide by 2. 

pow3d = []; 

  outmat3dnew = outmat3d; 
  
    for trial = 1:size(outmat3d,3);         
        %outmat3dnew(:, selectmat(trial,1):selectmat(trial,2), trial) = 0;
        B= zeros(size(outmat3d(:, selectmat(trial,1):selectmat(trial,2), trial)));
        A= zeros(size(outmat3d(:, selectmat2(trial,1):selectmat2(trial,2), trial)));
        C= zeros(size(outmat3d(:, selectmat3(trial,1):selectmat3(trial,2), trial)));
        outmat3dnew(:, selectmat(trial,1):selectmat(trial,2), trial)=B;
        outmat3dnew(:, selectmat2(trial,1):selectmat2(trial,2), trial)=A;
        outmat3dnew(:, selectmat3(trial,1):selectmat3(trial,2), trial)=C;
    end

   for trial = 1:size(outmat3d,3); 

     [pow3d(:, :, trial), phase, freqs]= FFT_spectrum(squeeze(outmat3dnew(:, 51:end, trial)),500);

   end
save(strcat(subject,'.mat'),'pow3d');
