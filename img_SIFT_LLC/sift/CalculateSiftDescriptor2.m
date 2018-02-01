function CalculateSiftDescriptor2(rt_img_dir, rt_data_dir, image_list, image_index, gridSpacing, patchSize, maxImSize, nrml_threshold)
% used for extracting sift features from NUS-WIDE base on the image list;
% results will be saved according to their index.
% copy from Yan Jianchao's CalculateSiftDescriptor in LLC codes.
% updated by LI Wen on July 30, 2011
%
%==========================================================================
% usage: calculate the sift descriptors given the image home and image_list
%
% inputs
% rt_img_dir    -image database root path
% rt_data_dir   -feature database root path
% image_list    -an array of the file names of images
% image_index   -an array of the image index to be extracted
% gridSpacing   -spacing for sampling dense descriptors
% patchSize     -patch size for extracting sift feature
% maxImSize     -maximum size of the input image
% nrml_threshold    -low contrast normalization threshold
%
% Lazebnik's SIFT code is used.
%
% written by Jianchao Yang
% Mar. 2009, IFP, UIUC
%==========================================================================

disp('Extracting SIFT features...');
% predict the time
tic;
for i = 1:length(image_index)
    ii  = image_index(i);
    imgpath = fullfile(rt_img_dir, image_list{ii});
    
    I = imread(imgpath);
    if ndims(I) == 3,
        I = im2double(rgb2gray(I));
    else
        I = im2double(I);
    end;
    
    [im_h, im_w] = size(I);
    
    if max(im_h, im_w) > maxImSize,
        I = imresize(I, maxImSize/max(im_h, im_w), 'bicubic');
        [im_h, im_w] = size(I);
    end;
    
    % make grid sampling SIFT descriptors
    remX = mod(im_w-patchSize,gridSpacing);
    offsetX = floor(remX/2)+1;
    remY = mod(im_h-patchSize,gridSpacing);
    offsetY = floor(remY/2)+1;
    
    [gridX,gridY] = meshgrid(offsetX:gridSpacing:im_w-patchSize+1, offsetY:gridSpacing:im_h-patchSize+1);
    
    fprintf('Processing %d-th image: %s: wid %d, hgt %d, grid size: %d x %d, %d patches\n', ...
        i, image_list{ii}, im_w, im_h, size(gridX, 2), size(gridX, 1), numel(gridX));
    tt = toc;
    fprintf('Time used:%f, estimated time left:%f.\n', tt, (tt/i)*(length(image_index)-i));
    
    % find SIFT descriptors
    siftArr = sp_find_sift_grid(I, gridX, gridY, patchSize, 0.8);
    [siftArr, siftlen] = sp_normalize_sift(siftArr, nrml_threshold);
    
    feaSet.feaArr = siftArr';
    feaSet.x = gridX(:) + patchSize/2 - 0.5;
    feaSet.y = gridY(:) + patchSize/2 - 0.5;
    feaSet.width = im_w;
    feaSet.height = im_h;

    fpath = fullfile(rt_data_dir, ['img_', num2str(ii, '%06d'), '.mat']);
    
    save(fpath, 'feaSet');
end

% for ii = 1:length(subfolders),
%     subname = subfolders(ii).name;
%     
%     if ~strcmp(subname, '.') & ~strcmp(subname, '..'),
%         database.nclass = database.nclass + 1;
%         
%         database.cname{database.nclass} = subname;
%         
%         frames = dir(fullfile(rt_img_dir, subname, '*.jpg'));
%         
%         c_num = length(frames);           
%         database.imnum = database.imnum + c_num;
%         database.label = [database.label; ones(c_num, 1)*database.nclass];
%         
%         siftpath = fullfile(rt_data_dir, subname);        
%         if ~isdir(siftpath),
%             mkdir(siftpath);
%         end;
%         
%         for jj = 1:c_num,
%             imgpath = fullfile(rt_img_dir, subname, frames(jj).name);
%             
%             I = imread(imgpath);
%             if ndims(I) == 3,
%                 I = im2double(rgb2gray(I));
%             else
%                 I = im2double(I);
%             end;
%             
%             [im_h, im_w] = size(I);
%             
%             if max(im_h, im_w) > maxImSize,
%                 I = imresize(I, maxImSize/max(im_h, im_w), 'bicubic');
%                 [im_h, im_w] = size(I);
%             end;
%             
%             % make grid sampling SIFT descriptors
%             remX = mod(im_w-patchSize,gridSpacing);
%             offsetX = floor(remX/2)+1;
%             remY = mod(im_h-patchSize,gridSpacing);
%             offsetY = floor(remY/2)+1;
%     
%             [gridX,gridY] = meshgrid(offsetX:gridSpacing:im_w-patchSize+1, offsetY:gridSpacing:im_h-patchSize+1);
% 
%             fprintf('Processing %s: wid %d, hgt %d, grid size: %d x %d, %d patches\n', ...
%                      frames(jj).name, im_w, im_h, size(gridX, 2), size(gridX, 1), numel(gridX));
% 
%             % find SIFT descriptors
%             siftArr = sp_find_sift_grid(I, gridX, gridY, patchSize, 0.8);
%             [siftArr, siftlen] = sp_normalize_sift(siftArr, nrml_threshold);
%             
%             siftLens = [siftLens; siftlen];
%             
%             feaSet.feaArr = siftArr';
%             feaSet.x = gridX(:) + patchSize/2 - 0.5;
%             feaSet.y = gridY(:) + patchSize/2 - 0.5;
%             feaSet.width = im_w;
%             feaSet.height = im_h;
%             
%             [pdir, fname] = fileparts(frames(jj).name);                        
%             fpath = fullfile(rt_data_dir, subname, [fname, '.mat']);
%             
%             save(fpath, 'feaSet');
%             database.path = [database.path, fpath];
%         end;    
%     end;
% end;
