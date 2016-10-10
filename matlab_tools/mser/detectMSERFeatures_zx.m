function Regions=detectMSERFeatures_zx(I, varargin)
%detectMSERFeatures Finds MSER features.
%   regions = detectMSERFeatures(I) returns an MSERRegions object, regions,
%   containing region pixel lists and other information about MSER features
%   detected in a 2-D grayscale image I. detectMSERFeatures uses Maximally
%   Stable Extremal Regions (MSER) algorithm to find regions.
%
%   regions = detectMSERFeatures(I,Name,Value) specifies additional
%   name-value pair arguments described below:
%
%   'ThresholdDelta'   Scalar value, 0 < ThresholdDelta <= 100, expressed 
%                      as a percentage of the input data type range. This 
%                      value specifies the step size between intensity 
%                      threshold levels used in selecting extremal regions 
%                      while testing for their stability. Decrease this 
%                      value to return more regions. Typical values range 
%                      from 0.8 to 4.
%
%                      Default: 2
%
%   'RegionAreaRange'  Two-element vector, [minArea maxArea], which
%                      specifies the size of the regions in pixels. This  
%                      value allows the selection of regions containing 
%                      pixels between minArea and maxArea, inclusive.
%
%                      Default: [30 14000]
%
%   'MaxAreaVariation' Positive scalar. Increase this value to return a  
%                      greater number of regions at the cost of their
%                      stability. Stable regions are very similar in
%                      size over varying intensity thresholds. Typical 
%                      values range from 0.1 to 1.0.
%
%                      Default: 0.25
%
%   'ROI'              A vector of the format [X Y WIDTH HEIGHT],
%                      specifying a rectangular region in which corners
%                      will be detected. [X Y] is the upper left corner of
%                      the region.                                     
%                 
%                      Default: [1 1 size(I,2) size(I,1)]
%
%   Class Support
%   -------------
%   The input image I can be uint8, int16, uint16, single or double, 
%   and it must be real and nonsparse.
%
%   Example
%   -------
%   % Find MSER regions
%   I = imread('cameraman.tif');
%   regions = detectMSERFeatures(I);
%
%   % Visualize MSER regions which are described by pixel lists stored 
%   % inside the returned 'regions' object
%   figure; imshow(I); hold on;
%   plot(regions, 'showPixelList', true, 'showEllipses', false);
%
%   % Display ellipses and centroids fit into the regions
%   figure; imshow(I); hold on;
%   plot(regions); % by default, plot displays ellipses and centroids
%
%   See also MSERRegions, extractFeatures, matchFeatures,
%            detectBRISKFeatures, detectFASTFeatures, detectHarrisFeatures,
%            detectMinEigenFeatures, detectSURFFeatures, SURFPoints

%   Copyright 2011 The MathWorks, Inc.

%   References:
%      Jiri Matas, Ondrej Chum, Martin Urban, Tomas Pajdla. "Robust
%      wide-baseline stereo from maximally stable extremal regions",
%      Proc. of British Machine Vision Conference, pages 384-396, 2002.
%
%      David Nister and Henrik Stewenius, "Linear Time Maximally Stable 
%      Extremal Regions", European Conference on Computer Vision, 
%      pages 183-196, 2008. 

%#codegen
%#ok<*EMCA>

[Iu8, params] = parseInputs(I,varargin{:});

if isSimMode()
    % regionsCell is pixelLists in a cell array {a x 2; b x 2; c x 2; ...} and
    % can only be handled in simulation mode since cell arrays are not supported
    % in code genereration
    regionsCell = ocvExtractMSER(Iu8, params);
    
    if params.usingROI && ~isempty(params.ROI)        
        regionsCell = offsetPixelList(regionsCell, params.ROI);
    end
    
    Regions = MSERRegions(regionsCell);
    
else
    [pixelList, lengths] = ...
        vision.internal.buildable.detectMserBuildable.detectMser_uint8(Iu8, params);
    
    if params.usingROI && ~isempty(params.ROI) % offset location values
        pixelList = offsetPixelListCodegen(pixelList, params.ROI);
    end
    
    Regions = MSERRegions(pixelList, lengths);
    
end

%==========================================================================
% Parse and check inputs
%==========================================================================
function [img, params] = parseInputs(I, varargin)

validateattributes(I,{'logical', 'uint8', 'int16', 'uint16', ...
    'single', 'double'}, {'2d', 'nonempty', 'nonsparse', 'real'},...
    mfilename, 'I', 1); % Logical input is not supported

Iu8 = im2uint8(I);

imageSize = size(I);
if isSimMode()
    params = parseInputs_sim(imageSize, varargin{:});
else
    params = parseInputs_cg(imageSize, varargin{:});
end

%--------------------------------------------------------------------------
% Other OpenCV parameters which are not exposed in the main interface
%--------------------------------------------------------------------------
params.minDiversity  = single(0.2);
params.maxEvolution  = int32(200);
params.areaThreshold = 1;
params.minMargin     = 0.003;
params.edgeBlurSize  = int32(5);

img = vision.internal.detector.cropImageIfRequested(Iu8, params.ROI, params.usingROI);

%==========================================================================
function params = parseInputs_sim(imageSize, varargin)
% Parse the PV pairs
parser = inputParser;

defaults = getDefaultParameters(imageSize);




% parser.addParameter('ThresholdDelta',   2);
% parser.addParameter('RegionAreaRange',  defaults.RegionAreaRange);
% parser.addParameter('MaxAreaVariation', defaults.MaxAreaVariation);
% parser.addParameter('ROI',              defaults.ROI)

parser.addParameter('ThresholdDelta',   5);
parser.addParameter('RegionAreaRange',  [30 20000]);
parser.addParameter('MaxAreaVariation', 0.1);
parser.addParameter('ROI',              defaults.ROI)







% display(parser);

% Parse input
parser.parse(varargin{:});

checkThresholdDelta(parser.Results.ThresholdDelta);

params.usingROI  = ~ismember('ROI', parser.UsingDefaults);

roi = parser.Results.ROI;
if params.usingROI
    vision.internal.detector.checkROI(roi, imageSize);
end

isAreaRangeUserSpecified = ~ismember('RegionAreaRange', parser.UsingDefaults);

if isAreaRangeUserSpecified 
    checkRegionAreaRange(parser.Results.RegionAreaRange, imageSize, ...
        params.usingROI, roi);
end

checkMaxAreaVariation(parser.Results.MaxAreaVariation);

% Populate the parameters to pass into OpenCV's ocvExtractMSER()
params.delta        = parser.Results.ThresholdDelta*255/100;
params.minArea      = parser.Results.RegionAreaRange(1);
params.maxArea      = parser.Results.RegionAreaRange(2);
params.maxVariation = parser.Results.MaxAreaVariation;
params.ROI          = parser.Results.ROI;

%==========================================================================
function params = parseInputs_cg(imageSize, varargin)

% Optional Name-Value pair: 3 pairs (see help section)
defaults = getDefaultParameters(imageSize);
defaultsNoVal = getDefaultParametersNoVal();
properties    = getEmlParserProperties();

optarg = eml_parse_parameter_inputs(defaultsNoVal, properties, varargin{:});
parser_Results.ThresholdDelta = (eml_get_parameter_value( ...
        optarg.ThresholdDelta, defaults.ThresholdDelta, varargin{:}));
parser_Results.RegionAreaRange = (eml_get_parameter_value( ...
    optarg.RegionAreaRange, defaults.RegionAreaRange, varargin{:}));
parser_Results.MaxAreaVariation = (eml_get_parameter_value( ...
    optarg.MaxAreaVariation, defaults.MaxAreaVariation, varargin{:}));
parser_ROI  = eml_get_parameter_value(optarg.ROI, defaults.ROI, varargin{:});

checkThresholdDelta(parser_Results.ThresholdDelta);

% check whether ROI parameter is specified
usingROI = optarg.ROI ~= uint32(0);

if usingROI
    vision.internal.detector.checkROI(parser_ROI, imageSize);    
end

% check whether area range parameter is specified
isAreaRangeUserSpecified = optarg.RegionAreaRange ~= uint32(0);

if isAreaRangeUserSpecified 
    checkRegionAreaRange(parser_Results.RegionAreaRange, imageSize,...
        usingROI, parser_ROI);
end

checkMaxAreaVariation(parser_Results.MaxAreaVariation);

params.delta        = cCast('int32_T', parser_Results.ThresholdDelta*255/100);
params.minArea      = cCast('int32_T', parser_Results.RegionAreaRange(1));
params.maxArea      = cCast('int32_T', parser_Results.RegionAreaRange(2));
params.maxVariation = cCast('real32_T', parser_Results.MaxAreaVariation);
params.ROI          = parser_ROI;
params.usingROI     = usingROI;

%==========================================================================
% Offset pixel list locations based on ROI
%==========================================================================
function pixListOut = offsetPixelList(pixListIn, roi)
n = size(pixListIn,1);
pixListOut = cell(n,1);
for i = 1:n   
    pixListOut{i} = vision.internal.detector.addOffsetForROI(pixListIn{i}, roi, true);
end

%==========================================================================
% Offset pixel list locations based on ROI
%==========================================================================
function pixListOut = offsetPixelListCodegen(pixListIn, roi)

pixListOut = vision.internal.detector.addOffsetForROI(pixListIn, roi, true);

%==========================================================================
function defaults = getDefaultParameters(imgSize)
       
defaults = struct(...
    'ThresholdDelta', 5*100/255, ...
    'RegionAreaRange', [30 14000], ...
    'MaxAreaVariation', 0.25,...
    'ROI', [1 1 imgSize(2) imgSize(1)]);

%==========================================================================
function defaultsNoVal = getDefaultParametersNoVal()

defaultsNoVal = struct(...
    'ThresholdDelta', uint32(0), ... 
    'RegionAreaRange', uint32(0), ... 
    'MaxAreaVariation', uint32(0), ...
    'ROI', uint32(0));

%==========================================================================
function properties = getEmlParserProperties()

properties = struct( ...
    'CaseSensitivity', false, ...
    'StructExpand',    true, ...
    'PartialMatching', false);

%==========================================================================
function tf = checkThresholdDelta(thresholdDelta)
validateattributes(thresholdDelta, {'numeric'}, {'scalar',...
    'nonsparse', 'real', 'positive', '<=', 100}, mfilename);
tf = true;

%==========================================================================
function checkRegionAreaRange(regionAreaRange, imageSize, usingROI, roi)

if usingROI
    % When an ROI is specified, the region area range validation should
    % be done with respect to the ROI size.
    sz = int32([roi(4) roi(3)]);
else
    sz = int32(imageSize);
end

imgArea = sz(1)*sz(2);
validateattributes(regionAreaRange, {'numeric'}, {'integer',... 
    'nonsparse', 'real', 'positive', 'size', [1,2]}, mfilename);

coder.internal.errorIf(regionAreaRange(2) < regionAreaRange(1), ...
    'vision:detectMSERFeatures:invalidRegionSizeRange');

% When the imageSize is less than area range, throw a warning.
if imgArea < int32(regionAreaRange(1))
    coder.internal.warning('vision:detectMSERFeatures:imageAreaLessThanAreaRange')
end


%==========================================================================
function tf = checkMaxAreaVariation(maxAreaVariation)
validateattributes(maxAreaVariation, {'numeric'}, {'nonsparse', ...
    'real', 'scalar', '>=', 0}, mfilename);
tf = true;

%==========================================================================
function flag = isSimMode()

flag = isempty(coder.target);

%==========================================================================
function outVal = cCast(outClass, inVal)
outVal = coder.nullcopy(zeros(1,1,outClass));
outVal = coder.ceval(['('   outClass  ')'], inVal);


