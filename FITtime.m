function dayNum = FITtime(FITseconds, GMToffset)

% function dayNum = FITtime(FITseconds, GMToffset)
% return dayNum (days and fraction since 01.01.0000)
% for specified FIT time (seconds since 01.01.1990)
% use GMToffset in hours to correct for local time zone offset
%
% called without output arguments the resulting date/time
% is printed

if nargin==0 GMToffset=0; end
offset = datenum("01-Jan-1990 00:00:00");
dayNum = offset + GMToffset/24 + FITseconds/24/3600 - 1;
if nargout==0
  datestr(dayNum)
end

