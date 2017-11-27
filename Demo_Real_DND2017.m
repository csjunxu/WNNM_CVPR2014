clear;
Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2018 Denoising\dnd_2017\images_srgb\';
fpath = fullfile(Original_image_dir, '*.mat'); 
im_dir  = dir(fpath);
im_num = length(im_dir);
load 'C:\Users\csjunxu\Desktop\CVPR2018 Denoising\dnd_2017\info.mat';

method = 'WNNM';
addpath('NoiseEstimation');
% write image directory
write_MAT_dir = ['C:/Users/csjunxu/Desktop/CVPR2018 Denoising/dnd_2017Results/'];
write_sRGB_dir = [write_MAT_dir method];
if ~isdir(write_sRGB_dir)
    mkdir(write_sRGB_dir)
end

for i = 49:-1:28
    Par.image = i;
    load(fullfile(Original_image_dir, im_dir(i).name));
    S = regexp(im_dir(i).name, '\.', 'split');
    [h, w, ch] = size(InoisySRGB);
    for j = 1:size(info(1).boundingboxes,1)
        IMname = [S{1} '_' num2str(j)];
        fprintf('%s: \n', IMname);
        bb = info(i).boundingboxes(j,:);
        IMin = InoisySRGB(bb(1):bb(3), bb(2):bb(4),:);
        IM_GT = IMin;
        IMout = zeros(size(IMin));
        for c = 1:ch
            %% denoising
            nSig = NoiseEstimation(IMin(:,:,c)*255, 8);
            Par   = ParSet(nSig);
            IMoutcc = WNNM_DeNoising( IMin(:,:,c) *255, IM_GT(:,:,c)*255, Par );
            IMout(:,:,c) = IMoutcc;
        end
        imwrite(IMout/255, [write_sRGB_dir '/' method '_DND_' IMname '.png']);
    end
end
