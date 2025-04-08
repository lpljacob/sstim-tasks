function results = learn_and_recall(vars, current_word_list, recall_thresh, message_thresh)

% display words for learning
for t=1:height(current_word_list)

    DrawFormattedText(vars.window, current_word_list.cue{t}, 'center', vars.top_depth, vars.black, vars.white); 
    DrawFormattedText(vars.window, current_word_list.recall{t}, 'center', vars.bottom_depth, vars.black, vars.white);     
    Screen('Flip', vars.window); 
    WaitSecs(vars.present_duration);

    Screen('Flip', vars.window);
    WaitSecs(vars.isi);
end

str_array = ['Now, you will try to recall the bottom word of each pair.'...
            '\n You have unlimited time to type your answer.'...
            '\n If you can''t remember, make your best guess.'...
            '\n Press any key to continue.']; 

DrawFormattedText(vars.window, str_array, 'center', 'center', vars.black); 
Screen('Flip', vars.window);
WaitSecs(vars.pause_time);
KbStrokeWait;

% tests recall
current_recall = 0;

iteration = 1;
while current_recall < recall_thresh % repeats words until threshold is met

    % determines which words to show this time
    if iteration == 1
        this_iteration_list = current_word_list;
    else
        this_iteration_list = incorrect_word_list;
        this_iteration_list.timesShown(:) = iteration;

        % let the subject know we will be repeating things
        DrawFormattedText(vars.window, message_thresh, 'center', 'center', vars.black); 
        Screen('Flip', vars.window);
        KbStrokeWait;
    end

    this_iteration_list = this_iteration_list(randperm(height(this_iteration_list)), :); % shuffle

    % get subject recall for each word
    for t=1:height(this_iteration_list) 

        this_iteration_list.response{t} = run_recall(vars, this_iteration_list.cue{t}); % run function to obtain subject response

        % display correct answer
        DrawFormattedText(vars.window, this_iteration_list.cue{t}, 'center', vars.top_depth, vars.black, vars.white); 
        DrawFormattedText(vars.window, ['The correct answer is: \n\n' this_iteration_list.recall{t} '\n\n Press any key to continue.'], 'center', 'center', vars.black);     
        Screen('Flip', vars.window);
        KbStrokeWait;
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

results = [correct_word_list; incorrect_word_list];

end