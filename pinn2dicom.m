function varargout = pinn2dicom(varargin)
% pinn2dicom is a script that converts a Pinnacle VolHeader formatted CT
% dataset to a series of DICOM images.  The primary application of this
% tool was to be able to read data from really old Pinnacle archives
% (verson 6), where the original CT DICOM data is not present.
%
% The resulting DICOM images will be saved to a folder named "output",
% which is cleared/removed at the start of execution of this function.  In
% addition, this tool generates unique DICOM UIDs for the resulting files,
% such that they will be not conflict with other DICOM datasets.
%
% WARNING: This tool has not been rigorously validated, as it was developed
% ad-hoc for a particular project.  Please contact the author if it does
% not work with your dataset.
%
% This function optionally accepts the following inputs.  If not provided,
% the user will be prompted to select these files at the time of execution:
%   varargin{1} (optional): string containing the file name and path of the 
%       header file to be converted
%   varargin{2} (optional): string containing the file name and path of the 
%       image file to be converted
%   varargin{3} (optional): string containing a DICOM from which to copy
%       much of the header information from (so that third party tools 
%       think the resulting DICOM images are actually real).  A reference
%       DICOM file is included as part of this tool.
%
% This function returns the following variables upon successful execution:
%   varargout{1}: structure containinig the CT data acquired from the
%       volheader, including dim/width/start fields as well as a data
%       field containing the 3D image.  See below for the definition of
%       this structure.
%
% Author: Mark Geurts, mark.w.geurts@gmail.com
% Copyright (C) 2014 University of Wisconsin Board of Regents
%
% This program is free software: you can redistribute it and/or modify it 
% under the terms of the GNU General Public License as published by the  
% Free Software Foundation, either version 3 of the License, or (at your 
% option) any later version.
%
% This program is distributed in the hope that it will be useful, but 
% WITHOUT ANY WARRANTY; without even the implied warranty of 
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General 
% Public License for more details.
% 
% You should have received a copy of the GNU General Public License along 
% with this program. If not, see http://www.gnu.org/licenses/.

% Clear the output directory, if it exists
[~,~] = system('rm -rf output');

%% Read VolHeader
% If a volheader file was provided as an input argument
if nargin >= 1
    
    % Set the volheader to the input argument
    header = varargin{1};
    
else
    
    % Otherwise, request the user to select a file
    [header_name, header_path] = ...
        uigetfile('*.header', 'Select the header file:');
    
    % If the user did not select a file
    if strcmp(header_name, '');
        % Throw an error
        error('A header file was not chosen.');
    end
    
    % Otherwise, store the full path to the header
    header = fullfile(header_path, header_name);
    
    % Clear temporary variables
    clear header_name header_path;
    
end

% Open a read file handle to the volheader
fid = fopen(header, 'r');

% Get the first line
tline = fgetl(fid);

% While more data exists in the volheader
while ischar(tline)
    
    % Look for the byte_order variable, storing its contents if found
    value = regexp(tline, 'byte_order = (.+);$', 'tokens');
    if size(value) == [1 1] %#ok<*BDSCA>
        ct.byte_order = str2double(value{1,1}{1});
    end
    
    % Look for the x_dim variable, storing its contents if found
    value = regexp(tline, 'x_dim = (.+);$', 'tokens');
    if size(value) == [1 1]
        ct.dim(1) = str2double(value{1,1}{1});
    end
    
    % Look for the y_dim variable, storing its contents if found
    value = regexp(tline, 'y_dim = (.+);$', 'tokens');
    if size(value) == [1 1]
        ct.dim(2) = str2double(value{1,1}{1});
    end
    
    % Look for the z_dim variable, storing its contents if found
    value = regexp(tline, 'z_dim = (.+);$', 'tokens');
    if size(value) == [1 1]
        ct.dim(3) = str2double(value{1,1}{1});
    end
    
    % Look for the x_pixdim variable, storing its contents if found
    value = regexp(tline, 'x_pixdim = (.+);$', 'tokens');
    if size(value) == [1 1]
        ct.width(1) = str2double(value{1,1}{1});
    end
    
    % Look for the y_pixdim variable, storing its contents if found
    value = regexp(tline,'y_pixdim = (.+);$', 'tokens');
    if size(value) == [1 1]
        ct.width(2) = str2double(value{1,1}{1});
    end
    
    % Look for the z_pixdim variable, storing its contents if found
    value = regexp(tline, 'z_pixdim = (.+);$', 'tokens');
    if size(value) == [1 1]
        ct.width(3) = str2double(value{1,1}{1});
    end
    
    % Look for the x_start variable, storing its contents if found
    value = regexp(tline, 'x_start = (.+);$', 'tokens');
    if size(value) == [1 1]
        ct.start(1) = str2double(value{1,1}{1});
    end
    
    % Look for the y_start variable, storing its contents if found
    value = regexp(tline, 'y_start = (.+);$', 'tokens');
    if size(value) == [1 1]
        ct.start(2) = str2double(value{1,1}{1});
    end
    
    % Look for the z_start variable, storing its contents if found
    value = regexp(tline, 'z_start = (.+);$', 'tokens');
    if size(value) == [1 1]
        ct.start(3) = str2double(value{1,1}{1});
    end
    
    % Look for the db_name variable, storing its contents if found
    value = regexp(tline, 'db_name : (.+)$', 'tokens');
    if size(value) == [1 1]
        ct.db_name = value{1,1}{1};
    end
    
    % Look for the medical_record variable, storing its contents if found
    value = regexp(tline, 'medical_record : (.+)$', 'tokens');
    if size(value) == [1 1]
        ct.medical_record = value{1,1}{1};
    end
    
    % Look for the date variable, storing its contents if found
    value = regexp(tline, 'date : (.+)$', 'tokens');
    if size(value) == [1 1]
        ct.date = datenum(value{1,1}{1},'yyyy-mm-dd HH:MM:SS');
    end
    
    % Look for the patient_position variable, storing its contents if found
    value = regexp(tline, 'patient_position : (.+)$', 'tokens');
    if size(value) == [1 1]
        ct.patient_position = value{1,1}{1};
    end
   
    % Clear temporary variables
    clear value;
    
    % Retrieve the next line in the file
    tline = fgetl(fid);
end

% Close the file handle
fclose(fid);

% Clear temporary variables
clear tline fid;

%% Read VolImage
% If a volimage file was provided as an input argument
if nargin >= 2
    
    % Set the volimage to the input argument
    img = varargin{2};
    
else
    
    % Otherwise, request the user to select a file
    [img_name, img_path] = uigetfile('*.img', 'Select the img file:');
    
    % If the user did not select a file
    if strcmp(img_name, '');
        
        % Throw an error
        error('An img file was not chosen.');
    end
    
    % Otherwise, store the full path to the image
    img = fullfile(img_path, img_name);
end

% If the volheader byte_order flag indicated the file is little endian
if ct.byte_order == 0
    
    % Open a litte endian read only file handle to the volimage
    fid = fopen(img, 'r', 'l');
    
else
    
    % Open a big endian read only file handle to the volimage
    fid = fopen(img, 'r', 'b');
    
end

% Read the volimage, storing as a 3D array to ct.data
ct.data = uint16(reshape(fread(fid, ct.dim(1) * ct.dim(2) * ct.dim(3), ...
    'uint16'), ct.dim(1), ct.dim(2), ct.dim(3)));

% Clear temporary variables
clear fid;

%% Read DICOM Header
% If a DICOM file was provided as an input argument
if nargin >= 3
    
    % Set the dicom file to the input argument
    dcm = varargin{2};
    
    
else
    
    % Otherwise, request the user to select a file
    [dcm_name, dcm_path] = ...
        uigetfile('*.*', '(OPTIONAL) Select the dcm file:');
    
    % Store the full path to the DICOM file
    dcm = fullfile(dcm_path, dcm_name);
end
    
% If the user did not specify a file
if strcmp(dcm,'/')
    
    % Load the reference DICOM header contents
    info = dicominfo(['2.16.840.1.114362.1.6.0.2.13412.5981035325.', ...
        '338356779.634.5206.dcm']);
    
    % Update the UIDs
    info.StudyInstanceUID = dicomuid;
    info.PatientName.FamilyName = ct.db_name;
    info.PatientID = ct.medical_record;
    info.FrameOfReferenceUID = dicomuid;
    info.SOPClassUID = '1.2.840.10008.5.1.4.1.1.2';
    info.MediaStorageSOPClassUID = '1.2.840.10008.5.1.4.1.1.2';
    info.SOPInstanceUID = dicomuid;
    info.MediaStorageSOPInstanceUID = info.SOPInstanceUID;
    
% Otherwise, the user selected a DICOM file
else
    
    % Load the provided DICOM header contents
    info = dicominfo(dcm);
    
    % Update the UIDs
    info.FrameOfReferenceUID = ...
        info.ReferencedFrameOfReferenceSequence.Item_1.FrameOfReferenceUID;
    info.SOPClassUID = '1.2.840.10008.5.1.4.1.1.2';
    info.MediaStorageSOPClassUID = '1.2.840.10008.5.1.4.1.1.2';
    info.SOPInstanceUID = ...
        info.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.ReferencedSOPInstanceUID;
    info.MediaStorageSOPInstanceUID = ...
        info.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.ReferencedSOPInstanceUID;
    
    % Clear some of the patient specific tags
    info.StructureSetROISequence = '';
    info.StructureSetDate = '';
    info.StructureSetLabel = '';
    info.StructureSetTime = '';
    info.ReferencedFrameOfReferenceSequence = '';
    info.ReferencedStudySequence = '';
    info.ReferringPhysicianName = '';
    info.ROIContourSequence = '';
    info.RTROIObservationsSequence = '';
end

% Update the date and time
info.StudyDate = datestr(ct.date,'yyyymmdd');
info.StudyTime = datestr(ct.date,'hhmmss');

% Set the dimension/width header tags
info.Width = ct.dim(1);
info.Height = ct.dim(2);
info.SliceThickness = ct.width(3)*10;
info.Rows = ct.dim(1);
info.Columns = ct.dim(2);
info.PixelSpacing = [ct.width(1)*10; ct.width(2)*10];

% Set the bit info
info.BitDepth = 16;
info.BitsAllocated = 16;
info.BitsStored = 16;
info.HighBit = 15;

% Set miscellaneous tags
info.ColorType = 'grayscale';
info.ImageType = 'ORIGINAL\PRIMARY\AXIAL';
info.WindowCenter = 40;
info.WindowWidth = 400;
info.RescaleIntercept = -1024;
info.RescaleSclope = 1;
info.FileMetaInformationGroupLength = 188;
info.FileMetaInformationVersion = [0;1];
info.Modality = 'CT';
info.SamplesPerPixel = 1;
info.PhotometricInterpretation = 'MONOCHROME2';
info.PixelRepresentation = 1;
info.PixelPaddingValue = 63536;

% Set position info
info.PatientPosition = ct.patient_position;

% Set image orientation vector, depending on position
if strcmp(ct.patient_position,'HFS')
   info.ImageOrientationPatient = [1;0;0;0;1;0];
elseif strcmp(ct.patient_position,'FFS')
   info.ImageOrientationPatient = [-1;0;0;0;1;0];
elseif strcmp(ct.patient_position,'HFP')
   info.ImageOrientationPatient = [1;0;0;0;-1;0];
elseif strcmp(ct.patient_position,'FFP')
   info.ImageOrientationPatient = [-1;0;0;0;-1;0];
else
    error('An unknown patient position exists in the volheader');
end

% Set series description
info.SeriesDescription = 'Pinnacle Volheader';

% Set filesize
info.FileSize = ct.dim(1) * ct.dim(2) * 2;

%% Write DICOM files
% Create a new folder to store output DICOM files
[~,~] = system('mkdir output');

% Loop through each DICOM slice (IEC-Y image)
for i = 1:ct.dim(3)
    % Write message to stdout
    fprintf('Writing image %i...\n', i);
    
    % Update slice specific tags
    info.ImagePositionPatient = [-ct.dim(1)/2*ct.width(1)*10; ...
        -ct.dim(2)/2*ct.width(2)*10; ...
        (ct.dim(3)/2*ct.width(3) - (i-1) * ct.width(3))*10];
    info.SliceLocation = (ct.dim(3)/2*ct.width(3) - (i-1) * ct.width(3))*10;
    
    % Write info and slice data to DICOM file 
    dicomwrite(rot90(ct.data(:,:,i),3), sprintf('output/ct_%03i.dcm', i), ...
        info, 'CreateMode', 'create');
end

% If an output variable is requested
if nargout == 1
    
    % Return the ct structure
    varargout{1} = ct;
    
end

% Clear temporary variables
clear i header img dcm info ct;
