function response = run_recall(vars, this_cue)

 % show cue word and obtain response
DrawFormattedText(vars.window, this_cue, 'center', vars.top_depth, vars.black, vars.white); 

[response, ~] = GetEchoString(vars.window, 'Type your answer:', vars.typing_left_loc, vars.bottom_depth, [0,0,0,255], [255,255,255,255]);

DrawFormattedText(vars.window, ['Press ENTER again to submit "', response, '" or BACKSPACE to change'], 'center', 'center', vars.black); 
Screen('Flip', vars.window);

[~, keyCode, ~] = KbStrokeWait;
if ~keyCode(vars.enter)
    response = run_recall(vars,this_cue);
elseif length(response) < 3 && strcmp(vars.sess_type,'Post-sleep')
    DrawFormattedText(vars.window, 'Make your best guess, even if you''re not sure. \n Press any button to go back.',...
    'center', 'center', vars.black); 
    Screen('Flip', vars.window); 
    KbStrokeWait;
    response = run_recall(vars,this_cue);
end

end