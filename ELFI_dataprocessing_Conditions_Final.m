function [] = ELFI_dataprocessing_NEW()
    %% ELFI ssvep data processing
    % Created 8/20/2015
    %
    % Read in set file & process data so it's ready to read into FFT script
    %
    % Raw data and Event Info must have already been imported, and the file
    % must be saved as a .set file: ELFI_#_age (e.g., ELFI_2_9)

    %% Prompt information

    prompt = {'Subject'};
    defaults = {'1'};
    answer = inputdlg(prompt,'Condition',1,defaults);

    [subject] = deal(answer{:});


    % Get the age of the participant
    ageArray = {'6', '9', 'Adult'};
    [selectionIndex, leftBlank] = listdlg('PromptString', 'Select an age:', 'SelectionMode', 'single', 'ListString', ageArray);
    age = ageArray{selectionIndex};
    %get the species you want to run
    speciesArray = {'cap' 'mac'};
    [selectionIndex, leftBlank] = listdlg('PromptString', 'Select a species:', 'SelectionMode', 'single', 'ListString', speciesArray);
    species = speciesArray{selectionIndex};
    %UPDATE NEXT LINE WITH YOUR CORRECT FILE PATH
    pathToFiles = ['/Users/BCDLAB1600/Desktop/SSVEP files/Hillary dissertation ssVEP/Data/'];
    filename = strcat(pathToFiles, 'rawData/ELFI_',num2str(subject), '_', age, '.set');

    %% Initial processing steps
    
    eeglab;
    
    EEG = pop_loadset('filename', filename);

    % eeglab redraw;
    % Add channel locations
    EEG = pop_editset(EEG, 'setname', strcat(pathToFiles, 'ELFI_',num2str(subject),'_',num2str(age),'_chan'));

    % Create Event List
    EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' } );
    EEG = pop_editset(EEG, 'setname', strcat(pathToFiles, 'ELFI_',num2str(subject),'_',num2str(age),'_chan_elist'));
    % eeglab redraw;

    
     % Bandpass filter from 0.02-30 Hz
     dataAK=double(EEG.data); 
     [alow, blow] = butter(6, 0.12); 
     [ahigh, bhigh] = butter(3,0.002, 'high'); 
     
     dataAKafterlow = filtfilt(alow, blow, dataAK'); 
     dataAKafterhigh = filtfilt(ahigh, bhigh, dataAKafterlow)'; 
     
     EEG.data = single(dataAKafterhigh); 
     
    
    EEG = pop_editset(EEG, 'setname', strcat(pathToFiles, 'ELFI_',num2str(subject),'_',num2str(age),'_chan_elist_filt'));
    % eeglab redraw;
    %% Assign bins via BINLISTER

    
        if strcmp(species,'mac') == 1
            EEG  = pop_binlister( EEG , 'BDF', '/Users/BCDLAB1600/Desktop/SSVEP files/SSVEP processing_OREP/ELFI scripts/PreMacaque.txt', 'IndexEL',  1, 'SendEL2',...
 'EEG', 'Voutput', 'EEG' );
        elseif strcmp(species,'cap') == 1 
            EEG  = pop_binlister( EEG , 'BDF', '/Users/BCDLAB1600/Desktop/SSVEP files/SSVEP processing_OREP/ELFI scripts/PreCapuchin.txt', 'IndexEL',  1, 'SendEL2',...
 'EEG', 'Voutput', 'EEG' );
        end
    EEG = pop_editset(EEG, 'setname', strcat(pathToFiles, 'ELFI_',num2str(subject),'_',num2str(age),'_chan_elist_filt_bins'));
    % eeglab redraw;

    % Create bin-based epochs
    % segment trials from 100ms before the trial starts to the end of the
    % trial (10s)
    EEG = pop_epochbin( EEG , [-100.0  10000.0],  'pre'); 
    EEG = pop_editset(EEG, 'setname', strcat(pathToFiles, 'ELFI_',num2str(subject),'_',num2str(age),'_chan_elist_filt_bins_be'));
    % eeglab redraw;

    %save the segmented file as a .set file
    EEG = pop_saveset( EEG, 'filename',strcat(pathToFiles, 'SplitCondition/ELFI_',num2str(subject),'_',num2str(age),'_',species,'.set'));

end


