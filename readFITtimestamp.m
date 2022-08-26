function record = readFITtimestamp(id, record)

% TODO
disp("compressed timestamp");
record.messageType = bitand(record.header, 96) >> 5;
record.timeOffset = bitand(record.header, 31);

