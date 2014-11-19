pinn2dicom
===========

by Mark Geurts <mark.w.geurts@gmail.com>
<br>Copyright &copy; 2014, University of Wisconsin Board of Regents

pinn2dicom is a script that converts a Pinnacle<sup>3</sup> VolHeader formatted CT dataset to a series of DICOM images.  The primary application of this tool was to be able to read data from really old Pinnacle archives (verson 6), where the original CT DICOM data is not present.

The resulting DICOM images will be saved to a folder named "output", which is cleared/removed at the start of execution of this function.  In addition, this tool generates unique DICOM UIDs for the resulting files, such that they will be not conflict with other DICOM datasets.

WARNING: This tool has not been rigorously validated, as it was developed ad-hoc for a particular project.  Please contact the author if it does not work with your dataset.

Pinnacle<sup>3</sup> is a registered trademark of Philips Healthcare.

## Contents

* [MATLAB Function Use](README.md#matlab-function-use)
* [License](README.md#license)

## MATLAB Function Use

This function optionally accepts the following inputs.  If not provided, the user will be prompted to select these files at the time of execution:

* varargin{1} (optional): string containing the file name and path of the header file to be converted
* varargin{2} (optional): string containing the file name and path of the image file to be converted
* varargin{3} (optional): string containing a DICOM from which to copy much of the header information from (so that third party tools think the resulting DICOM images are actually real).  A reference DICOM file is included as part of this tool.

This function returns the following variables upon successful execution:

* varargout{1} (optional): structure containinig the CT data acquired from the volheader, including dim/width/start fields as well as a data field containing the 3D image.  See below for the definition of this structure.

## License

This program is free software: you can redistribute it and/or modify it 
under the terms of the GNU General Public License as published by the  
Free Software Foundation, either version 3 of the License, or (at your 
option) any later version.

This program is distributed in the hope that it will be useful, but 
WITHOUT ANY WARRANTY; without even the implied warranty of 
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General 
Public License for more details.

You should have received a copy of the GNU General Public License along 
with this program. If not, see http://www.gnu.org/licenses/.
