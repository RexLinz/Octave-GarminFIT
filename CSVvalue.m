function [val, unit, found] = CSVvalue(data, keyword, lastval)

% find keyword in first line of data
n = find(ismember(data(1,:),keyword));
found = length(n)>0;
if found
  val = char(data(n+1));
  if val(1) == """" % formatted as string
    val=val(2:end-1);% remove
  end
  val = str2num(val);
  unit = char(data(n+2));
else
  val = lastval;
end
