%% Load the ADE20K dataset details from the .mat file included with it

load('ADE20K_2021_17_01\index_ade20k.mat')


%% Pre-processing

% Get list of images containing objects of interest

% Index of object of interest in index.objectnames
% In this case the "car, auto, automobile, ..." object
objIndex = 401;  

% The row in index.objectPresence associated with the object of interest
% Every column in this row represents one image and the column value is
% either 0 or 1 to indicate if the desired object is present in the image
objRow = index.objectPresence(objIndex,:);

% Find the indexes (columns) of all non-zero values in the row extracted above
% (i.e., object is present in the associated image)
objColIdxs = find(objRow);

% Find all of the images with the desired objects present
objImageNames = index.filename(objColIdxs);

% Pull the base names from the image names above
[~,objBaseNames] = fileparts(objImageNames);

% Find all of the folders for the images above
objFolders = index.folder(objColIdxs);

% Generate full filenames for all images
objFullFileNames = fullfile(objFolders, objImageNames);


%% Get part instances, add segments for parts of interest, add bounding 
% boxes, save images (with bboxes and segments for verification), save 
% original images in new folder (for training later), and generate 
% PascalVOC-formatted XML annotations

doorCount = 0;
handleCount = 0;

for p = 1:size(objBaseNames,2)  % REAL
% for p = 1:20  % TESTING ("20" should only produce 3 images/annotations)
    
    origImage = imread(objFullFileNames{p});
    objImage = zeros(size(origImage(:,:,1)));
    overlayImage = zeros(size(origImage(:,:,1)));
    
    fileName = fullfile(objFolders{p},[objBaseNames{p} '.json']);
    str = fileread(fileName); % dedicated for reading files as text
    data = jsondecode(str); % Using the jsondecode function to parse JSON from string

    dataStruct = data.annotation.object;
    
    j = 1;    
    objList = [""];
    bboxList = [];
    % Look for object of interest in the datastruct
    for h = 1:size(dataStruct)
        if dataStruct(h).name_ndx == objIndex  % "car" object
            objParts = dataStruct(h).parts.hasparts;
            if size(objParts) > 0
                % Then look for the parts of interest in the object
                for i = 1:size(objParts)
                    partIdx = objParts(i);
                    dSRecord = dataStruct([dataStruct.id] == partIdx, :);
                    % First the "door" part of the car
                    if dSRecord.name_ndx == 774  % car "door" part
                        overlayFilename = fullfile(objFolders(p),dSRecord.instance_mask);
                        A = imread(overlayFilename{1});
                        label = find(A);  % "find" looks for all non-zero values in image and returns their indices
                        overlayImage(label) = j;  % this sets the values at the indices to be different integer values (for labeloverlay to display them in separate colors)
                        objList(j,:) = "door";
                        bbox = regionprops(A, 'BoundingBox');
                        bboxList(j,:) = bbox(255).BoundingBox;
                        j = j + 1;
                        doorCount = doorCount + 1;
                        doorParts = dSRecord.parts.hasparts;
                        if size(doorParts) > 0
                            for di = 1:size(doorParts)
                                doorPartIdx = doorParts(di);
                                dSPartRecord = dataStruct([dataStruct.id] == doorPartIdx, :);
                                % Then the "handle" part of the car door
                                if dSPartRecord.name_ndx == 1180  % car door "handle" part
                                    overlayFilename = fullfile(objFolders(p),dSPartRecord.instance_mask);
                                    APart = imread(overlayFilename{1});
                                    label = find(APart);  % "find" looks for all non-zero values in image and returns their indices
                                    overlayImage(label) = j;  % this sets the values at the indices to be different integer values (for labeloverlay to display them in separate colors)
                                    objList(j,:) = "handle";
                                    bbox = regionprops(APart, 'BoundingBox');
                                    bboxList(j,:) = bbox(255).BoundingBox;
                                    j = j + 1;
                                    handleCount = handleCount + 1;
                                end
                            end
                        end
                    end
                end
                if j > 1  % Meaning the overlay has data in it
                    % First, save the original image for processing
                    imwrite(origImage,fullfile('XML',[objBaseNames{p} '.jpg']));
                    
                    % Then, add the overlay labels for parts of interest
                    B = labeloverlay(origImage,overlayImage);
                    imshow(B);
                    % Get bounding boxes for overlay items
                    props = regionprops(overlayImage, 'BoundingBox');
                    % Plot all the bounding boxes (below few lines)
                    % 'rectangle' only displays (doesn't save in the image)
                    % 'insertShape' only saves to image (doesn't display)
                    hold on;
                    for k = 1 : length(props)
                        % rectangle('Position', props(k).BoundingBox, 'EdgeColor', 'y');  % Display only
                        B = insertShape(B,'rectangle',props(k).BoundingBox, 'Color', 'y');  % Add to image to be saved (won't display here)
                    end
                    hold off
                    % imwrite(B,fullfile('Visualize',[objBaseNames{p} '.jpg']));  % Segments only
                    imwrite(B,fullfile('VisualizeBB',[objBaseNames{p} '.jpg']));  % Segments + Bounding boxes
                    
                    % Now write the XML data
                    generatePascalXML("train", objFullFileNames{p}, [objBaseNames{p} '.jpg'], objList, bboxList, fullfile('XML',[objBaseNames{p} '.xml']));
                end
            end 
        end
    end

end


