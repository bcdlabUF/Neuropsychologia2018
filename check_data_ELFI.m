     
MYfile= 'ELFI_5_6_Macaque'
MYpath='/Users/BCDLAB1600/Desktop/SSVEP files/SSVEP_processing_ELFI/Split_Condition/' 
     EEG = pop_loadset('filename',strcat(MYfile,'.set'),'filepath',MYpath);
     EEG = eeg_checkset( EEG );
     EEG = pop_select( EEG,'nochannel',{'E17' 'E43' 'E48' 'E49' 'E56' 'E63' 'E68' 'E73' 'E81' 'E88' 'E94' 'E99' 'E107' 'E113' 'E119' 'E120' 'E125' 'E126' 'E127' 'E128'});
     EEG = eeg_checkset( EEG );
     inmat3d = EEG.data; 
     
load locsEEGLAB109HCL.mat % Loads sensor locations for 109 channel net

% LINES 12- 90 clean up messy channels
interpsensvec = []; 

outmat3d = zeros(size(inmat3d)); % Creates an empty matrix the same size as the input matrix

cartesianmat109 = zeros(109,3); % Creates an empty variable for cartisian coordinates & corresponding data

% find X, Y, Z for each sensor
    for elec = 1:109
        
       cartesianmat109(elec,1) =  locsEEGLAB109HCL((elec)).X;
       cartesianmat109(elec,2) =  locsEEGLAB109HCL((elec)).Y;
       cartesianmat109(elec,3) =  locsEEGLAB109HCL((elec)).Z;
    end
       

% first, identify bad channels

    for trial = 1:size(inmat3d,3)
    
    trialdata2d = inmat3d(:, :, trial); 
    
    % caluclate three metrics of data quality at the channel level
    
    absvalvec = median(abs(trialdata2d)'); % Median absolute voltage value for each channel
    stdvalvec = std(trialdata2d'); % SD of voltage values
    maxtransvalvec = max(diff(trialdata2d')); % Max diff (??) of voltage values
    
    % calculate compound quality index
    qualindex = absvalvec+ stdvalvec+ maxtransvalvec; 
    
    % detect indices of bad channels; currently anything farther than 3 SD
    % from the median quality index value %% 
   interpvec1 =  find(qualindex > median(qualindex) + 2.5.* std(qualindex))
   
   % Second run through of bad channel detection, after removing extremely bad channels from first run  
   qualindex2 = qualindex;
   
       for a = 1:length(qualindex)
           extremechan = ismember(a,interpvec1);
            if extremechan == 1
                qualindex2(:,a) = median(qualindex);
            end
       end
   interpvec2 = find(qualindex2 > median(qualindex2) + 3.5.* std(qualindex2));
   
   interpvec = [interpvec1,interpvec2];
   
   % append channels that are bad so that we have them after going through
   % the trials
   
   interpsensvec = [interpsensvec trial interpvec];
    
    
    % set bad data channels nan, so that they are not used for inerpolating each other  
    cleandata = trialdata2d; 
    cleandata(interpvec,:) = nan; 
    
    % interpolate those channels from 6 nearest neighbors in the cleandata
    % find nearest neighbors
    
    if length(interpvec)==0
        outmat3d(:, :, trial)=cleandata;
    end
    
    for badsensor = 1:length(interpvec)
       
        for elec2 = 1:109
            distvec(elec2) = sqrt((cartesianmat109(elec2,1)-cartesianmat109(interpvec(badsensor),1)).^2 + (cartesianmat109(elec2,2)-cartesianmat109(interpvec(badsensor),2)).^2 + (cartesianmat109(elec2,3)-cartesianmat109(interpvec(badsensor),3)).^2);
        end
    
           [dist, index]= sort(distvec); 
           
           size( trialdata2d(interpvec(badsensor),:)), size(mean(trialdata2d(index(2:7), :),1))
           
           trialdata2d(interpvec(badsensor),:) = nanmean(cleandata(index(2:7), :),1); 
           
           outmat3d(:, :, trial) = trialdata2d; % Creates output file where bad channels have been replaced with interpolated data
    
    end    

    end
interpsensvec_unique = unique(interpsensvec); 

%re-reference to the average
outmat3d = avg_ref3d_baby109_noOuter(outmat3d);

%put back into EEGlab format so we can plot it
EEG.data = single(outmat3d);
EEG = pop_saveset( EEG, 'filename',strcat(MYfile,'_CLEAN.set'),'filepath',strcat(MYpath,'CLEAN CHAN/'));

EEG = eeg_checkset( EEG );
pop_eegplot( EEG, 1, 1, 1);

%% 





 