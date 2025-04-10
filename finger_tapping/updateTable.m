function T = updateTable(T, Presses, Timings, seqString, Condition, i)

Presses = {Presses};
Timings = {Timings};

tempTable = table();
tempTable.Condition(1,:) = {Condition};
tempTable.Trial(1,:) = i;
tempTable.Sequence(1,:) = seqString;
tempTable.Presses = Presses;
tempTable.Timings = Timings;

T = [T;tempTable];

end