function current_word_list = prepareWordList(word_list)

current_word_list = word_list(randperm(height(word_list)), :);

current_word_list = addvars(current_word_list, ...
    repelem({'NotGuessed'}, height(current_word_list))', repelem(1, height(current_word_list))', ...
    [1:height(current_word_list)]', ...
    'NewVariableNames',{'response', 'timesShown', 'initialOrder'});

end