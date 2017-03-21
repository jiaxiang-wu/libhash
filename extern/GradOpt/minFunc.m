function [paraVec, funcVal, funcVec] = minFunc(funcHndl, paraVec, opts, varargin)
% INTRO
%   minimize the objective function via gradient-based methods
% INPUT
%   funcHndl: function handler (compute the function's value and gradient)
%   paraVec: D x 1 (initial solution)
%   opts: structure (optimization options)
%   varargin: K x 1 (cell array; additional parameters)
% OUTPUT
%   paraVec: D x 1 (optimal solution)
%   funcVal: scalar (function's value of the optimal solution)
%   funcVec: T x 1 (list of function's values through iterations)

% choose the proper entry based on the selected optimization method
switch opts.method
  case 'GradDst'
    [paraVec, funcVal, funcVec] = ...
      minFunc_GradDst(funcHndl, paraVec, opts, varargin{:});
  case 'AdaGrad'
    [paraVec, funcVal, funcVec] = ...
      minFunc_AdaGrad(funcHndl, paraVec, opts, varargin{:});
  case 'AdaDelta'
    [paraVec, funcVal, funcVec] = ...
      minFunc_AdaDelta(funcHndl, paraVec, opts, varargin{:});
  case 'Adam'
    [paraVec, funcVal, funcVec] = ...
      minFunc_Adam(funcHndl, paraVec, opts, varargin{:});
end

% display the objective function's value curve
if opts.enblVis
  figure;
  plot(1 : numel(funcVec), funcVec);
  title(opts.method);
  grid on;
  drawnow;
end

end
