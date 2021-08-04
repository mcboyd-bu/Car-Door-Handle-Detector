function generatePascalXML(imgType, imgDir, imgName, objList, bboxList, targetName)
% Adapted from "wider2pascal" by Samuel Albanie:
% https://github.com/albanie/wider2pascal/blob/master/generatePascalXML.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Changes from original by Matt Boyd:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - Updated to use MATLAB API for XML Processing (MAXP)
%    - Replaces Java API for XML Processing (JAXP), which is being removed
%    - REQUIRES MATLAB version R2021a or higher
% - Replaced "WIDER" database defaults with ADE20K defaults
% - Added objList input to pass in object names
%    - Each row in objList should correspond to the same row in bboxList
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%GENERATEPASCALXML a Pascal VOC syntax annotation generator
%   Generates Pascal VOC compatible XML annotations where:
%
%   `imgType` indicates if the image is for train, val, or test
%
%   `imgDir` is the path of img to get metadata
%
%   `imgName` is the name of the image file (to be stored in the
%       xml annotation.
%
%   `objList` is an n x 1 array of object names, each row has the format:
%           ["object name"]
%
%   `bboxList` is an n x 4 array of bounding box locations where each row
%       has the format:
%           [top left x, top left y, width, height]
%
%   `targetName` the name which the annotation is saved with 
%   (should inculde an xml suffix e.g. 'annotation_1.xml'.
%
%   NOTE: Annotation bounding box values are rounded to the 
%   nearest pixel
%
%   Original Author: Samuel Albanie
%   Adapted By: Matt Boyd 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Example output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% <?xml version="1.0" encoding="utf-8"?>
% <annotation>
%    <folder>train</folder>
%    <filename>ADE_train_00018625.jpg</filename>
%    <path>C:\ADE20K\images\train\ADE_train_00018625.jpg</path>
%    <source>
%       <database>ADE20K Dataset</database>
%       <annotation>ADE20K</annotation>
%    </source>
%    <size>
% 		<width>300</width>
% 		<height>229</height>
% 		<depth>3</depth>
% 	 </size>
% 	 <segmented>0</segmented>
%    <object>
%       <name>door</name>
%       <bndbox>
%          <xmin>449</xmin>
%          <ymin>330</ymin>
%          <xmax>570</xmax>
%          <ymax>478</ymax>
%       </bndbox>
%    </object>
%    <object>
%       <name>handle</name>
%       <bndbox>
%          <xmin>449</xmin>
%          <ymin>330</ymin>
%          <xmax>570</xmax>
%          <ymax>478</ymax>
%       </bndbox>
%    </object>
% </annotation>

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hardcoded values for ADE20K database
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
imgFolder = imgType;
databaseName = 'ADE20K Dataset';
annotationType = 'ADE20K';

% annotation (document) element
import matlab.io.xml.dom.*
docNode = Document('annotation');
docRootNode = docNode.getDocumentElement;

% folder element
elem = docNode.createElement('folder');
elem.appendChild...
    (docNode.createTextNode(sprintf('%s', imgFolder)));
docRootNode.appendChild(elem);

% filename element
elem = docNode.createElement('filename');
elem.appendChild...
    (docNode.createTextNode(sprintf('%s', imgName)));
docRootNode.appendChild(elem);

% path element
elem = docNode.createElement('path');
elem.appendChild...
    (docNode.createTextNode(sprintf('%s', imgDir)));
docRootNode.appendChild(elem);

% source element
sourceElem = docNode.createElement('source');
docRootNode.appendChild(sourceElem);

% database element
databaseElem = docNode.createElement('database');
databaseElem.appendChild...
    (docNode.createTextNode(sprintf('%s', databaseName)));
sourceElem.appendChild(databaseElem);

% annotation element
annotationElem = docNode.createElement('annotation');
annotationElem.appendChild...
    (docNode.createTextNode(sprintf('%s', annotationType)));
sourceElem.appendChild(annotationElem);

% size element
sizeElem = docNode.createElement('size');
% get metadata from image
immeta = imfinfo(imgDir);
% store width
elem = docNode.createElement('width');
elem.appendChild...
    (docNode.createTextNode(sprintf('%d', immeta.Width)));
sizeElem.appendChild(elem);
% store height
elem = docNode.createElement('height');
elem.appendChild...
    (docNode.createTextNode(sprintf('%d', immeta.Height)));
sizeElem.appendChild(elem);
% store depth, assume 3
elem = docNode.createElement('depth');
elem.appendChild...
    (docNode.createTextNode(sprintf('%d', 3)));
sizeElem.appendChild(elem);
docRootNode.appendChild(sizeElem);

% segmented element
elem = docNode.createElement('segmented');
elem.appendChild...
    (docNode.createTextNode(sprintf('%d', 0)));
docRootNode.appendChild(elem);

% Loop over bounding boxes to produce annotations
for i = 1:size(bboxList, 1)
    
    % First, pull the object name for this bounding box
    objName = objList(i,1);
    
    % convert from 
    %   (minX, minY, width, height) (Matlab format)
    % to -> 
    %   (minX, minY, maxX, maxY) (Pascal VOC format)
    xmin = bboxList(i,1);
    ymin = bboxList(i,2);
    xmax = bboxList(i,1) + bboxList(i,3);
    ymax = bboxList(i,2) + bboxList(i,4);
    
    % object element
    objectElem = docNode.createElement('object');
    docRootNode.appendChild(objectElem);
    
    % name element
    elem = docNode.createElement('name');
    elem.appendChild...
        (docNode.createTextNode(sprintf('%s', objName)));
    objectElem.appendChild(elem);
    
    % bounding box element
    bboxElem = docNode.createElement('bndbox');
    objectElem.appendChild(bboxElem);
    
    elem = docNode.createElement('xmin');
    elem.appendChild...
        (docNode.createTextNode(sprintf('%d', round(xmin))));
    bboxElem.appendChild(elem);
    
    elem = docNode.createElement('ymin');
    elem.appendChild...
        (docNode.createTextNode(sprintf('%d', round(ymin))));
    bboxElem.appendChild(elem);
    
    elem = docNode.createElement('xmax');
    elem.appendChild...
        (docNode.createTextNode(sprintf('%d', round(xmax))));
    bboxElem.appendChild(elem);
    
    elem = docNode.createElement('ymax');
    elem.appendChild...
        (docNode.createTextNode(sprintf('%d', round(ymax))));
    bboxElem.appendChild(elem);
    clc
end

xmlFileName = targetName;
writer = matlab.io.xml.dom.DOMWriter;
writer.Configuration.FormatPrettyPrint = true;

writeToFile(writer,docNode,xmlFileName);

type(targetName);

end

