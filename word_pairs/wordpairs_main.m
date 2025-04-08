% !!!!!!!! ENSURE CURRENT FOLDER IS WHERE THIS SCRIPT IS LOCATED !!!!!!!!!

close all; clear; sca;

ListenChar(0); % if matlab was prevented from listening to keys, allows it to do so again

addpath([pwd '\data'])

%%
develop_mode = 1; % set to 1 to shorten the experiment for testing/debugging

if develop_mode==1
    present_duration = 1; pause_time = 0.1; skip_tests = 1; isi = 0.1; correct_display = 0.1;
else; present_duration = 4; pause_time = 1; skip_tests = 0; isi = 1; correct_display = 2;
end

%% set up initial parameters
          
x = inputdlg({'Enter subject number:','Enter visit number (1, 2, or 3):','Enter word list number (1, 2, or 3):'},...
              'Subject Info', [1 50; 1 50; 1 50]);
sess_type = questdlg('Select session type', ...
	'Experimenter input', ...
	'Pre-sleep','Post-sleep','Pre-sleep');
          
subjectNum = str2double(x{1});
visitNum = str2double(x{2});

if strcmp(sess_type,'Pre-sleep')

    listToLoad = ['wp' x{3} '.csv'];
    pairs = readtable(listToLoad, 'ReadVariableNames',false);
    pairs.Properties.VariableNames{1} = 'cue';
    pairs.Properties.VariableNames{2} = 'recall';
    
    practice_pairs = readtable('wp_practice.csv');
    practice_pairs.Properties.VariableNames{1} = 'cue';
    practice_pairs.Properties.VariableNames{2} = 'recall';
end

%% prepare screen, keyboard, etc

Screen('Preference', 'SkipSyncTests', skip_tests);
PsychDefaultSetup(2);
screens = Screen('Screens');
screenNumber = max(screens);

KbName('UnifyKeyNames')

% Define black, white and grey
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;

% setting up screen background 
if develop_mode==1
    res = [1200 700];
else
    screen_res = Screen('Resolution', screenNumber);
    res = [screen_res.width screen_res.height];
end
[window, windowRect] = Screen(screenNumber, 'OpenWindow', [], [0 0 res(1) res(2)]); 
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% setting up layout
[screenXpixels, screenYpixels] = Screen('WindowSize', window); 
[xCenter, yCenter] = RectCenter(windowRect); 
TextSizeRatio = .023;
TextSize = round(res(1) * TextSizeRatio);
Screen('Preference', 'DefaultFontSize', TextSize)

top_depth = screenYpixels * 0.25;
bottom_depth = screenYpixels - screenYpixels * 0.25;

% setting up keyboard
% ListenChar(2); % prevents typed keys from showing up in matlab
enter = KbName('RETURN');

% setting up variables
vars = struct(); 
vars.window = window;
vars.black = black;
vars.white = white;
vars.top_depth = top_depth;
vars.bottom_depth = bottom_depth;
vars.enter = enter;

results = table();

%%
%--------------------------------------------------------------------------
%                         Practice phase
%--------------------------------------------------------------------------

if strcmp(sess_type, 'Pre-sleep') 
    
    if develop_mode==1 % CHANGE THIS WHEN DONE TESTING

        % show practice trials

        str_array = [...
        'In this task you will view several pairs of words.' ...
        '\n Try to memorize the pairs. There will be a word on the top and another on the bottom.' ...
        '\n\n Later, you will be presented with the first (top) word of each pair.' ...
        '\n You will need to remember and type the second word using the keyboard.' ...
        '\n\n You can use BACKSPACE key to erase.' ...
        '\n Use the ENTER key to submit your guess.' ...
        '\n\n Press any key to continue.']; 

        DrawFormattedText(window, str_array, 'center', 'center', black); 
        Screen('Flip', window);
        WaitSecs(pause_time);
        KbStrokeWait; 

        str_array = ['If you have any questions, please ask the experimenter for help at any time.'...
        '\n\n The first two trials are for practice.'...
        '\n The correct word will be shown after you type your guess.'...
        '\n\n Press any key to continue.'];

        DrawFormattedText(window, str_array, 'center', 'center', black); 
        Screen('Flip', window);
        WaitSecs(pause_time);
        KbStrokeWait; 

        % shuffle list and add variable properties to each pair
        current_word_list = practice_pairs(randperm(height(practice_pairs)), :);
        condition = 'Practice';
        current_word_list = addvars(current_word_list, ...
            repelem({'NotGuessed'}, height(current_word_list))', repelem(1, height(current_word_list))', ...
            [1:height(current_word_list)]', repelem({condition}, height(current_word_list))', ...
            'NewVariableNames',{'response', 'timesShown', 'initialOrder', 'condition'});

        % display words for learning
        for t=1:height(current_word_list)

            DrawFormattedText(window, current_word_list.cue{t}, 'center', top_depth, black, white); 
            DrawFormattedText(window, current_word_list.recall{t}, 'center', bottom_depth, black, white);     
            Screen('Flip', window); 
            WaitSecs(present_duration)

            Screen('Flip', window);
            WaitSecs(isi)
        end

        str_array = ['Now, you will try to recall the bottom word of each pair.'...
            '\n You have unlimited time to type your answer.'...
            '\n If you can''t remember, make your best guess.'...
            '\n Press any key to continue.']; 
        DrawFormattedText(window, str_array, 'center', 'center', black); 
        Screen('Flip', window);
        WaitSecs(pause_time);
        KbStrokeWait;

        % tests recall
        recall_thresh = 1; % percentage of words that must be recalled
        current_recall = 0;

        iteration = 1;
        while current_recall < recall_thresh % repeats words until threshold is met

            % determines which words to show this time
            if iteration == 1
                this_iteration_list = current_word_list;
            else
                this_iteration_list = incorrect_word_list;
                this_iteration_list.timesShown(:) = iteration;

                str_array = ['Practice trials will continue until both answers are correct.'...
                '\n\n Press any key to practice again.'];
                DrawFormattedText(window, str_array, 'center', 'center', black); 
                Screen('Flip', window);
                WaitSecs(pause_time);
                KbStrokeWait;
            end

            this_iteration_list = this_iteration_list(randperm(height(this_iteration_list)), :); % shuffle

            % get subject recall for each word
            for t=1:height(this_iteration_list) 

                this_cue = this_iteration_list.cue{t};
                this_correct =  this_iteration_list.recall{t};

                this_iteration_list.response{t} = run_recall(vars, this_cue); % run function to obtain subject response

                % display correct answer
                DrawFormattedText(window, this_iteration_list.cue{t}, 'center', top_depth, black, white); 
                DrawFormattedText(window, ['The correct answer is: ' this_iteration_list.recall{t}], 'center', 'center', black, white);     
                Screen('Flip', window);
                WaitSecs(correct_display)
            end

            % determine which pairs were correct
            correct_pairs = strcmp(this_iteration_list.recall,this_iteration_list.response);

            % save correct pairs
            if iteration==1
                correct_word_list = this_iteration_list(correct_pairs,:);
            else
                correct_word_list = [correct_word_list; this_iteration_list(correct_pairs,:)];
            end

            % set aside incorrect pairs to be repeated if necessary
            incorrect_word_list = this_iteration_list(~correct_pairs,:);

            current_recall = sum(correct_pairs)/length(correct_pairs);
            iteration = iteration+1;
        end

        practice_results = [correct_word_list; incorrect_word_list];

        str_array = ['Good Job!'...
        '\n\n Press any key to begin the real experiment.'];
        DrawFormattedText(window, str_array, 'center', 'center', black); 
        Screen('Flip', window);
        KbStrokeWait;    
    end

%%
%--------------------------------------------------------------------------
%                         Learning phase
%--------------------------------------------------------------------------

    str_array = ['Next, several pairs of words will be displayed for around 4 minutes.' ...
            '\n Try to memorize the pairs. Once presentation begins, it cannot be paused.'...
            '\n\n Press any key when you are ready to begin viewing the words']; 
    DrawFormattedText(window, str_array, 'center', 'center', black); 
    Screen('Flip', window);
    WaitSecs(pause_time);
    KbStrokeWait;

    % shuffle list and add variable properties to each pair
    current_word_list = pairs(randperm(height(practice_pairs)), :);
    condition = 'Learning';
    current_word_list = addvars(current_word_list, ...
        repelem({'NotGuessed'}, height(current_word_list))', repelem(1, height(current_word_list))', ...
        [1:height(current_word_list)]', repelem({condition}, height(current_word_list))', ...
        'NewVariableNames',{'response', 'timesShown', 'initialOrder', 'condition'});

    % display words for learning
    for t=1:height(current_word_list)

        DrawFormattedText(window, current_word_list.cue{t}, 'center', top_depth, black, white); 
        DrawFormattedText(window, current_word_list.recall{t}, 'center', bottom_depth, black, white);     
        Screen('Flip', window); 
        WaitSecs(present_duration)

        Screen('Flip', window);
        WaitSecs(isi)
    end

    str_array = ['Now, you will try to recall the bottom word of each pair.'...
        '\n You have unlimited time to type your answer.'...
        '\n If you can''t remember, make your best guess.'...
        '\n Press any key to continue.']; 
    DrawFormattedText(window, str_array, 'center', 'center', black); 
    Screen('Flip', window);
    WaitSecs(pause_time);
    KbStrokeWait;

    % tests recall
    recall_thresh = 0.6; % percentage of words that must be recalled
    current_recall = 0;

    iteration = 1;
    while current_recall < recall_thresh % repeats words until threshold is met

        % determines which words to show this time
        if iteration == 1
            this_iteration_list = current_word_list;
        else
            this_iteration_list = incorrect_word_list;
            this_iteration_list.timesShown(:) = iteration;

            str_array = ['Good job. Some pairs will now be repeated.'...
        '\n You will be shown the first word of each pair.'...
        '\n Please type the second word using the keyboard.' ...
        '\n\n Press any key to continue.'];
            DrawFormattedText(window, str_array, 'center', 'center', black); 
            Screen('Flip', window);
            WaitSecs(pause_time);
            KbStrokeWait;
        end

        this_iteration_list = this_iteration_list(randperm(height(this_iteration_list)), :); % shuffle

        % get subject recall for each word
        for t=1:height(this_iteration_list) 

            this_cue = this_iteration_list.cue{t};
            this_correct =  this_iteration_list.recall{t};

            this_iteration_list.response{t} = run_recall(vars, this_cue); % run function to obtain subject response

            % display correct answer
            DrawFormattedText(window, this_iteration_list.cue{t}, 'center', top_depth, black, white); 
            DrawFormattedText(window, ['The correct answer is: ' this_iteration_list.recall{t}], 'center', 'center', black, white);     
            Screen('Flip', window);
            WaitSecs(correct_display)
        end

        % determine which pairs were correct
        correct_pairs = strcmp(this_iteration_list.recall,this_iteration_list.response);

        % save correct pairs
        if iteration==1
            correct_word_list = this_iteration_list(correct_pairs,:);
        else
            correct_word_list = [correct_word_list; this_iteration_list(correct_pairs,:)];
        end

        % set aside incorrect pairs to be repeated if necessary
        incorrect_word_list = this_iteration_list(~correct_pairs,:);

        current_recall = sum(correct_pairs)/length(correct_pairs);
        iteration = iteration+1;
    end

    learning_results = [correct_word_list; incorrect_word_list];

    writetable([practice_results; learning_results], [pwd '\data\' sprintf('WordPairs_subject%d_visit%d.csv',subjectNum, visitNum)]) 

elseif strcmp(sess_type, 'Post-sleep')

    learning_table = readtable(sprintf('WordPairs_subject%d_visit%d.csv',subjectNum,visitNum), 'Format', 'auto');
    
    % shuffle words




end

str_array = ['Good Job!'...
'\n\n This stage is now over. Please notify the experimenter.'];
DrawFormattedText(window, str_array, 'center', 'center', black); 
Screen('Flip', window);
KbStrokeWait; 

sca
    
ListenChar(0); % if matlab was prevented from listening to keys, allows it to do so again
