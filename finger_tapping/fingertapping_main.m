% !!!!!!!! ENSURE CURRENT FOLDER IS WHERE THIS SCRIPT IS LOCATED !!!!!!!!!

close all; clear; sca;

addpath([pwd '\data'])

%%
develop_mode = 1; % set to 1 to shorten the experiment for testing/debugging

if develop_mode==1; trial_duration = 1; pause_time = 0.1; skip_tests = 1; else; trial_duration = 30; pause_time = 1; skip_tests = 0; end
%% set up initial parameters
          
x = inputdlg({'Enter subject number:','Enter visit number (1, 2, or 3):','Enter tapping list number (1, 2, or 3):'},...
              'Subject Info', [1 50; 1 50; 1 50]);
value = questdlg('Select session type', ...
	'Experimenter input', ...
	'Practice','Recall','Practice');
          
subjectNum = str2double(x{1});
visitNum = str2double(x{2});
listNum = str2double(x{3});

%% prepare screen and related properties

Screen('Preference', 'SkipSyncTests', skip_tests);
PsychDefaultSetup(2);
screens = Screen('Screens');
screenNumber = max(screens);

KbName('UnifyKeyNames')

% Define black, white and grey
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;

%setting up screen background 
if develop_mode==1
    res = [1200 700];
else
    screen_res = Screen('Resolution', screenNumber);
    res = [screen_res.width screen_res.height];
end
[window, windowRect] = Screen(screenNumber, 'OpenWindow', [], [0 0 res(1) res(2)]); 
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%setting up layout
[screenXpixels, screenYpixels] = Screen('WindowSize', window); 
[xCenter, yCenter] = RectCenter(windowRect); 
TextSizeRatio = .023;
TextSize = round(res(1) * TextSizeRatio);
top_depth = screenYpixels * 0.25;
bottom_depth = screenYpixels - screenYpixels * 0.25;

%HideCursor;

vars = struct();
vars.trial_duration = trial_duration;
vars.screenXpixels = screenXpixels;
vars.screenYpixels = screenYpixels;    
vars.window = window;
vars.black = black;

%%
%--------------------------------------------------------------------------
%                         Present Intructions
%--------------------------------------------------------------------------

if strcmp(value, 'Practice')
    
    line1 = 'In this task, you will tap keys on the keyboard in specific sequences.';
    line2 = '\n These sequences all use the numbers 1 to 4.';
    line3 = '\n\n Rest all fingers (other than your thumb) of your left hand over those keys,';
    line4 = '\n and use your little finger to press 1, your ring finger to press 2,';
    line5 = '\n your middle finger to press 3, and your index finger to press 4.';
    line6 = '\n \n \n Press any key to continue.';
    
    DrawFormattedText(window, [line1 line2 line3 line4 line5 line6 ],...
        'center', screenYpixels * 0.25, black);
    Screen('Flip', window);
    
    WaitSecs(pause_time);
    KbStrokeWait;        
    
    % prompt through key presses 4-1  
    Key1 = KbName('1!'); Key2 = KbName('2@'); Key3 = KbName('3#'); Key4 = KbName('4$');
    
    Screen('TextSize', window, 30);
    DrawFormattedText(window, [line1 line2 line3 line4 line5],...
        'center', screenYpixels * 0.25-100, black);
    
    Screen('TextSize', window, 50);
    DrawFormattedText(window, 'Press 4 with your index finger.', 'center',...
        'center', black);
    Screen('Flip', window);
            
    response = 0;
    
    while response ~=4        
        response = get_key(Key1, Key2, Key3, Key4);   
    end
    
    Screen('TextSize', window, 30);
    DrawFormattedText(window, [line1 line2 line3 line4 line5],...
        'center', screenYpixels * 0.25-100, black);
    
    Screen('TextSize', window, 50);
    DrawFormattedText(window, 'Now; press 3 with your middle finger.', 'center',...
        'center', black);
    Screen('Flip', window);

    while response ~=3  
       response = get_key(Key1, Key2, Key3, Key4);
    end
    
    Screen('TextSize', window, 30);
    DrawFormattedText(window, [line1 line2 line3 line4 line5],...
        'center', screenYpixels * 0.25-100, black);
    
    Screen('TextSize', window, 50);
    DrawFormattedText(window, 'Now; press 2 with your ring finger.', 'center',...
        'center', black);
    Screen('Flip', window);

    while response ~=2
        response = get_key(Key1, Key2, Key3, Key4);
    end
    
    Screen('TextSize', window, 30);
    DrawFormattedText(window, [line1 line2 line3 line4 line5],...
        'center', screenYpixels * 0.25-100, black);
    
    Screen('TextSize', window, 50);
    DrawFormattedText(window, 'Now, press 1 with your little finger.', 'center',...
        'center', black);
    Screen('Flip', window);
    
    while response ~=1        
        response = get_key(Key1, Key2, Key3, Key4);
    end
%%
    %--------------------------------------------------------------------------
    %                           Practice Trials
    %--------------------------------------------------------------------------

    line1 = 'You will now receive two practice trials. Tap the sequences';
    line2 = '\nthat appear on the top of the screen as quickly and';
    line3 = '\naccurately as possible. You will have 30 seconds per trial to';
    line4 = '\ntap them as many times as you can. If you have any questions,';
    line5 = '\nplease ask the experimenter for help at any time.';
    line6 = '\n \n \n Press any key to continue.';

    Screen('TextSize', window, 40);
    DrawFormattedText(window, [line1 line2 line3 line4 line5 line6],...
        'center', screenYpixels * 0.25, black);
    Screen('Flip', window);

    WaitSecs(pause_time);
    KbStrokeWait;

    % load practice number sequences 
    practiceTrials = ["42132","13421"];
    
    ntrial = length(practiceTrials);
    numCorrect = 0;
    
    while numCorrect < 2

        T = table(); 
        tempTable = table();

        for i = 1:ntrial
            Condition = {'Practice'};

            [Timings,Presses,seqString] = run_trial(i, practiceTrials, vars); % make struct for inputs
            
            numCorrect = numCorrect + strfind(seqString,Presses);

                if i == 1

                    line1 = '\n\n The second sequence will appear next.';
                    line2 = '\n \n \n Press ENTER to continue.';

                    Screen('TextSize', window, 40);
                    DrawFormattedText(window, [line1 line2],...
                        'center', screenYpixels * 0.25, black);
                    Screen('Flip', window);

                    WaitSecs(pause_time);

                    KbStrokeWait;
                end    
                
                               
                if i == 2
                    if numCorrect<2
                        line1 = 'Practice trials will continue until each';
                        line2 = '\nsequence is tapped correctly at least twice';
                        line3 = '\nIf you have any questions, please ask the';
                        line4 = '\nexperimenter for help at any time.';
                        line5 = '\n \n \n Press ENTER to continue.';

                        Screen('TextSize', window, 40);
                    DrawFormattedText(window, [line1 line2 line3 line4 line5],...
                        'center', screenYpixels * 0.25, black);
                    Screen('Flip', window);

                    WaitSecs(pause_time); 

                    KbStrokeWait; 
                    end                    
                end

                T = updateTable(T, Presses, Timings, i);

        if develop_mode==1; numCorrect=2; end
        
        end
    end
    
%-------------------------------------------------------------%
%----------------------LEARNING PHASE-------------------------%
%-------------------------------------------------------------%                 
                    
    line1 = '\n\n\nGood job! Press ENTER to ';
    line2 = 'begin the real experiment.';
    Screen('TextSize', window, 40);
    DrawFormattedText(window, [line1 line2],...
                      'center', screenYpixels * 0.25, black);
    Screen('Flip', window);

    WaitSecs(pause_time);
    KbStrokeWait;

    line1 = 'You will now tap several sequences of numbers.';
    line2 = '\n Between each sequence, you can rest as long as ';
    line3 = '\n you want. Remember to type each sequence as';
    line4 = '\n quickly and accurately as you can, and to type them';
    line5 = '\n as many times as you can within the time limit.';
    line6 = '\n\n\n Press ENTER when you are ready to begin.';

    Screen('TextSize', window, 40);
    DrawFormattedText(window, [line1 line2 line3 line4 line5 line6],...
        'center', screenYpixels * 0.25, black);
    Screen('Flip', window);

    WaitSecs(pause_time); 
    
    KbStrokeWait;
    
    %load in and begin learning trials

    numseq = readtable('numberseq.csv');
    learningTrials = table2array(numseq(:,listNum)); %3rd row as learning sequences

    %randomize order of sequences
    idx=randperm(length(learningTrials));
    learningTrials=learningTrials(idx);
    ntrial = length(learningTrials);
    
    [Timings,Presses,seqString] = run_trial(1, learningTrials, vars);

    for i = 2:ntrial
        Condition = {'Learning'};

        line1 = '\n Remember to type each sequence as quickly and';
        line2 = '\n accurately as you can, and to type them as many';
        line3 = '\n times as you can within the time limit. Press ';
        line4 = '\n ENTER with your right hand you are ready to begin.';
        line5 = '\n Make sure your left hand is already in position.';
        line6 = '\n Start tapping as soon as you see the sequence.';

        Screen('TextSize', window, 40);
        DrawFormattedText(window, [line1 line2 line3 line4 line5 line6],...
            'center', screenYpixels * 0.25, black);
        Screen('Flip', window);
        
        WaitSecs(pause_time); 
        KbStrokeWait;

        [Timings,Presses,seqString] = run_trial(i, learningTrials, vars);

        T = updateTable(T, Presses, Timings, i);
        
    end    

    writetable(T, sprintf('FingerTapping_subject%d_visit%d.csv',subjectNum, visitNum))

    line1 = 'This stage is now over. Please notify the experimenter.';
    
    Screen('TextSize', window, 40);
    DrawFormattedText(window, [line1 line2 line3 line4 line5 line6],...
            'center', screenYpixels * 0.25, black);
    Screen('Flip', window);
        

    wakeup=WaitSecs(pause_time);
    sca;
    
%-------------------------------------------------------------%
%----------------------RECALL PHASE---------------------------%
%-------------------------------------------------------------%

elseif strcmp(value, 'Recall')
    %code for recall trials

    line1 = 'You will now tap 3 sequences of numbers. Between';
    line2 = '\n each sequence, you can rest as long as you want.';
    line3 = '\n Remember to type each sequence as quickly and ';
    line4 = '\n accurately as you can, and to type them as many';
    line5 = '\n times as you can within the time limit.';
    line6 = '\n\n\n Press ENTER when you are ready to begin.';

    Screen('TextSize', window, 40);
    DrawFormattedText(window, [line1 line2 line3 line4 line5 line6],...
        'center', screenYpixels * 0.25, black);
    Screen('Flip', window);

    WaitSecs(pause_time); 

    KbStrokeWait;

    T = readtable(sprintf('FingerTapping_subject%d_visit%d.csv',subjectNum,visitNum), 'Format', 'auto');

    [r,c] = size(T);

    recallTrials = T.Sequence(r-2:r);

    ntrial = length(recallTrials);
    
    tempTable = table();
    
    [Timings,Presses,seqString] = run_trial(1, recallTrials, vars);
    
    for i = 2:ntrial
        Condition = {'Learning'};

        line1 = '\n Remember to type each sequence as quickly and';
        line2 = '\n accurately as you can, and to type them as many';
        line3 = '\n times as you can within the time limit. Press ';
        line4 = '\n ENTER with your right hand you are ready to begin.';
        line5 = '\n Make sure your left hand is already in position.';
        line6 = '\n Start tapping as soon as you see the sequence.';

        Screen('TextSize', window, 40);
        DrawFormattedText(window, [line1 line2 line3 line4 line5 line6],...
            'center', screenYpixels * 0.25, black);
        Screen('Flip', window);
        
        WaitSecs(pause_time); 
        KbStrokeWait;

        [Timings,Presses,seqString] = run_trial(i, recallTrials, vars);
        
    end    

    writetable(T, [pwd '\data\' sprintf('FingerTapping_subject%d_visit%d.csv',subjectNum, visitNum)])

    line1 = 'This stage is now over. Please notify the experimenter.';
    
    Screen('TextSize', window, 40);
    DrawFormattedText(window, line1,...
            'center', screenYpixels * 0.25, black);
    Screen('Flip', window);
        
    WaitSecs(pause_time);
    KbStrokeWait;
    sca
    
end