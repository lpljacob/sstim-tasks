function response = run_recall(vars, this_cue)

 % show cue word and obtain response
DrawFormattedText(vars.window, this_cue, 'center', vars.top_depth, vars.black, vars.white); 

[response, ~] = GetEchoString(vars.window, 'Type your answer:', vars.typing_left_loc, vars.bottom_depth, [0,0,0,255], [255,255,255,255]);

DrawFormattedText(vars.window, ['Press ENTER again to submit "', response, '" or BACKSPACE to change'], 'center', 'center', vars.black); 
Screen('Flip', vars.window);

[~, keyCode, ~] = KbStrokeWait;
if ~keyCode(vars.enter)
    response = run_recall(vars,this_cue);
end

end