function options = InitOpt(method)

options = [];
switch method
    
    case 'IMH-tSNE'
        options.s = 5;
        options.sigma = 0;
  
    case 'IMH-LE'
        options.s = 5;
        options.sigma = 0;
        options.k = 20; % knn graph   
        options.bTrueKNN  = 0; % if 0, construct symmetric graph for S
   

end
