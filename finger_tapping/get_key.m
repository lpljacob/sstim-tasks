function response = get_key(Key1, Key2, Key3, Key4)
    [~, keyCode, ~] = KbStrokeWait;
    if keyCode(Key1)
        response = 1;
    elseif keyCode(Key2)
        response = 2;
    elseif keyCode(Key3)
        response = 3;
    elseif keyCode(Key4)
        response = 4;
    else
        response = 99;
    end
end