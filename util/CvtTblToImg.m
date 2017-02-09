function CvtTblToImg(tblFilePath, imgFilePath)
% INTRO
%   read in a table, convert it to an image, and then save it
% INPUT
%   tblFilePath: string (file path to the table)
% OUTPUT
%   imgFilePath: string (file path to the image)

% parse the table in the Markdown syntax
tbl = ParsTbl(tblFilePath);

% generate an image and then save it
GnrtImg(tbl, imgFilePath);

end

function tbl = ParsTbl(filePath)
% INTRO
%   parse the table in the Markdown syntax
% INPUT
%   filePath: string (file path to the table)
% OUTPUT
%   tbl: struct (table data)

% open file
iFile = fopen(filePath, 'r');

% parse the file in a line-by-line manner
lineIdx = 0;
tbl.hashBitCntLst = [];
tbl.mthdInfoLst = [];
while ~feof(iFile)
  % read in one line
  inLine = fgetl(iFile);
  lineIdx = lineIdx + 1;
  
  % table header parser
  if lineIdx == 1
    for subStr = strsplit(inLine, '|');
      charIdx = strfind(subStr{1}, '-bit');
      if ~isempty(charIdx)
        hashBitCnt = str2double(subStr{1}(1 : charIdx - 1));
        tbl.hashBitCntLst = [tbl.hashBitCntLst, hashBitCnt];
      end
    end
  end
  
  % table content parser
  if lineIdx >= 3
    subStrs = strsplit(inLine, '|');
    mthdInfo.mthdName = {strtrim(subStrs{2})};
    mthdInfo.scoreMat = zeros(numel(tbl.hashBitCntLst), 3);
    for idx = 1 : numel(tbl.hashBitCntLst)
      numStrs = strsplit(subStrs{idx + 2}, '/');
      if numel(numStrs) == 3
        mthdInfo.scoreMat(idx, :) = str2double(numStrs);
      else
        mthdInfo.scoreMat(idx, :) = zeros(1, 3);
      end
    end
    tbl.mthdInfoLst = [tbl.mthdInfoLst, mthdInfo];
  end
  
  fprintf('%s\n', inLine);
end

% close file
fclose(iFile);

end

function GnrtImg(tbl, filePath)
% INTRO
%   generate an image and then save it
% INPUT
%   tbl: struct (table data)
%   imgFilePath: string (file path to the image)
% OUTPUT
%   none

% add path for export_fig()
addpath('./extern/export_fig');

% specify a list of LineSpecs (some may not be used)
kLineSpecLst = [...
  {'r-o'}, {'r-.s'}, {'r--*'}, {'g-o'}, {'g-.s'}, {'g--*'}, ...
  {'b-o'}, {'b-.s'}, {'b--*'}, {'c-o'}, {'c-.s'}, {'c--*'}, ...
  {'m-o'}, {'m-.s'}, {'m--*'}, {'y-o'}, {'y-.s'}, {'y--*'}];

% plot 3 sub-figures, corresponding to different number of GT-links
gcf = figure('Position', [100, 100, 1024, 576]);
for plotIdx = 1 : 3
  h = subplot('Position', [0.05 + 0.27 * (plotIdx - 1), 0.12, 0.23, 0.8]);
  h.XTick = tbl.hashBitCntLst;
  hold on;
  for mthdIdx = 1 : numel(tbl.mthdInfoLst)
    plot(tbl.hashBitCntLst, ...
        tbl.mthdInfoLst(mthdIdx).scoreMat(:, plotIdx), kLineSpecLst{mthdIdx});
  end
  hold off;
end
h = legend([tbl.mthdInfoLst.mthdName]);
set(h, 'Position', [0.85, 0.35, 0.1, 0.4]);

% save the figure to file
set(gcf, 'Color', 'White');
export_fig(gcf, filePath, '-painters', '-jpg', '-r300');

end
