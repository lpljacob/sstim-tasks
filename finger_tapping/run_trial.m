function [Timings,Presses,seqString] = run_trial(sequence, vars)

% initialize response recording
Presses = [];
Timings = [];

seqString = num2str(sequence);
    
% set up 30 second timer 
startSecs = GetSecs;
endTime = startSecs + vars.trial_duration;

KbQueueCreate;
KbQueueStart;

% separate numbers so they can be colored independently
num1 = sprintf('%c - ', seqString(1));
num2 = sprintf('%c - ', seqString(2));
num3 = sprintf('%c - ', seqString(3));
num4 = sprintf('%c - ', seqString(4));
num5 = sprintf('%c', seqString(5));

% set up variables for coloring correctly pressed keys
correct_idx = 1;
next_correct = str2double(seqString(correct_idx));
colors = zeros(5,3);

while GetSecs < endTime

    time_passed = GetSecs - startSecs;
    time_remaining = vars.trial_duration - time_passed;
    timeLeft = num2str(fix(time_remaining));

    % display sequence
    Screen('TextSize', vars.window, 60);

    DrawFormattedText(vars.window, num1,...
    vars.screenXpixels/2 - 220, 'center', colors(1,:).*255);          

    DrawFormattedText(vars.window, num2,...
    vars.screenXpixels/2 - 130, 'center',colors(2,:).*255);

    DrawFormattedText(vars.window, num3,...
    'center', 'center', colors(3,:).*255);
    
    DrawFormattedText(vars.window, num4,...
    vars.screenXpixels/2 + 50, 'center', colors(4,:).*255);           

    DrawFormattedText(vars.window, num5,...
    vars.screenXpixels/2 + 140, 'center', colors(5,:).*255);         

    % countdown timer
    DrawFormattedText(vars.window, timeLeft, vars.screenXpixels - 80, vars.screenYpixels - 40, vars.black);
    Screen('Flip', vars.window);

    % record responses
    [pressed, firstPress]=KbQueueCheck;

    if pressed
        response = KbName(find(firstPress, 1, 'first'));
        response = str2double(response(1));

        responseTime = firstPress(find(firstPress, 1, 'first'));

        Presses(end+1) = response;
        Timings(end+1) = responseTime - startSecs;

        if response == next_correct
            colors(correct_idx,:) = [0 1 0];    % set color matrix to [0 1 0] (green) for number if pressed correctly

            if correct_idx==5
                colors = zeros(5,3);            % reset sequence back to black once all 5 numbers are pressed 
                correct_idx = 0;
            end 
            correct_idx=1+correct_idx;          % next correct number in sequence
            next_correct = str2double(seqString(correct_idx));
        end
    end
end
KbQueueStop;
