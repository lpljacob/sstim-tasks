function response = run_recall(vars, this_cue)

 % show cue word and obtain response
DrawFormattedText(vars.window, this_cue, 'center', vars.top_depth, vars.black, vars.white); 
Screen('Flip', window); 

[response, ~] = GetEchoString(vars.window, '', 'center', vars.bottom_depth, vars.black, vars.white);

DrawFormattedText(vars.window, ['Press ENTER again to submit "', response, '" or BACKSPACE to change'], 'center', 'center', vars.black); 
Screen('Flip', vars.window);

[~, keyCode, ~] = KbStrokeWait;
if ~keyCode(vars.enter)
    response = run_recall(this_cue);
end

end