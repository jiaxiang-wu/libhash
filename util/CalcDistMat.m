function distMat = CalcDistMat(dataMatQry, dataMatDtb, dstPrtl)
% INTRO
%   compute the pair-wise Euclidean distance matrix
% INPUT
%   dataMatQry: D x N_Q (data matrix of all query instances)
%   dataMatDtb: D x N_D (data matrix of all database instances)
%   dstPrtl: string (distance computation protocal: 'ecld' or 'cosn')
% OUTPUT
%   distMat: N_Q x N_D (pair-wise distance matrix)

switch dstPrtl
  case 'ecld'
    distMat = CalcDistMat_Ecld(dataMatQry, dataMatDtb);
  case 'cosn'
    distMat = CalcDistMat_Cosn(dataMatQry, dataMatDtb);
  otherwise
    fprintf('[ERROR] unsupported distance computation protocal\n');
    return;
end

end
