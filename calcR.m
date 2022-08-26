function r = calcR(x, y)

% function r = calcR(x, y)
% calulate radius from x and y coordinates

r = zeros(size(x));
r(1) = NaN;
r(end) = NaN;
for k = 2:length(x)-1
  r(k) = calcCircle(x(k-1),y(k-1), x(k),y(k), x(k+1),y(k+1));
end
