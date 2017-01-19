close all; clearvars; clc;

% set-up the compiler's and linker's flags
kCFlags = ['CXXFLAGS="', ... % starting string
    '\$CXXFLAGS -largeArrayDims -O2 -Wall ', ... % basic settings
    '-mpopcnt ', ... % enable the POPCOUNT instruction
    '-fopenmp ', ... % enable OpenMP
    '-I/opt/OpenBLAS/include ', ... % enable OpenBLAS
    '-I/opt/OpenVML/include ', ... % enable OpenVML
    '"']; % ending string
kLDFlags = ['LDFLAGS="', ... % starting string
    '\$LDFLAGS ', ... % basic settings
    '-fopenmp ', ... % enable OpenMP
    '-L/opt/OpenBLAS/lib -lopenblas ', ... % enable OpenBLAS
    '-L/opt/OpenVML/lib -lopenvml ', ... % enable OpenVML
    '"']; % ending string

% change directory to ./Mex.Files
cd ./mex

% remove existing *.mex files
system('rm -f ./*.mex*');

% compile all *.cc files
srcFileLst = dir('./*.cc');
for srcFileIdx = 1 : numel(srcFileLst)
  srcFile = srcFileLst(srcFileIdx).name;
  fprintf('[BUILD] %s\n', srcFile);
  eval(sprintf('mex %s %s %s', srcFile, kCFlags, kLDFlags));
end

% change directory to the main directory
cd ../
