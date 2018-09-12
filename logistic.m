function [ y ] = logistic( x )
% y = LOGISTIC(x)
%   the inverse of the logit function

y = exp(x)./(1+exp(x));


end

