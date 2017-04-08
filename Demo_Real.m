clear;
Original_image_dir = 'C:/Users/csjunxu/Desktop/CVPR2017/DSCDL_BID/TestedImages/';
fpath = fullfile(Original_image_dir, 'coffee_middle.png');
im_dir  = dir(fpath);
im_num = length(im_dir);
%% the whole image or part
type = 'middle';
for i = 1:im_num
    IMin = im2double(imread(fullfile(Original_image_dir, im_dir(i).name)));
    S = regexp(im_dir(i).name, '\.', 'split');
    IMname = S{1};
    fprintf('%s : \n',IMname);
    % color or gray image
    [h,w,ch] = size(IMin);
    fprintf('%s : \n',IMname);  
    hh = [0:1000:h,h];
    ww = [0:1000:w,w];
    num_part = 0;
    if strcmp(type, 'all')
        listh = 1 : length(hh)-1;
        listw = 1 : length(ww)-1;
        IMout = zeros(h,w,ch);
    elseif strcmp(type, 'random')
        listh = randi([1, length(hh)-1],1,1);
        listw = randi([1, length(ww)-1],1,1);
        IMout = zeros(1000,1000,3);
    elseif strcmp(type, 'middle')
        listh = floor(median(1:length(hh)-1));
        listw = floor(median(1:length(ww)-1));
        IMout = zeros(1000,1000,3);
    end
    %%
    for nh = listh
        for nw = listw
            num_part = num_part + 1;
            fprintf('Part %d/%d : \n',num_part, (length(hh)-1)*(length(ww)-1));
            IMin_part = IMin(hh(nh)+1:hh(nh+1),ww(nw)+1:ww(nw+1),:);
            % color or gray image
            if ch==1
                IMin_part_y = IMin_part;
            else
                % change color space, work on illuminance only
                IMin_part_ycbcr = rgb2ycbcr(IMin_part);
                IMin_part_y = IMin_part_ycbcr(:, :, 1);
                IMin_part_cb = IMin_part_ycbcr(:, :, 2);
                IMin_part_cr = IMin_part_ycbcr(:, :, 3);
            end
            %% denoising
            nSig = NoiseLevel( IMin_part_y *255);
            Par   = ParSet(nSig);
            IMout_part_y = WNNM_DeNoising( IMin_part_y, IMin_part_y, Par );
            if ch==1
                IMout_part = IMout_part_y;
            else
                IMout_part_ycbcr = zeros(size(IMin_part));
                IMout_part_ycbcr(:, :, 1) = IMout_part_y;
                IMout_part_ycbcr(:, :, 2) = IMin_part_cb;
                IMout_part_ycbcr(:, :, 3) = IMin_part_cr;
                IMout_part = ycbcr2rgb(IMout_part_ycbcr);
            end
            fprintf('This is the %d/%d part of the image %s.%s!\n',num_part,(length(hh)-1)*(length(ww)-1),IMname,S{2});
            if strcmp(type, 'all')
                IMout(hh(nh)+1:hh(nh+1),ww(nw)+1:ww(nw+1),:) = IMout_part;
            elseif strcmp(type, 'random') || strcmp(type, 'middle')
                IMout = IMout_part;
            end
        end
    end
    %% output
    imwrite(IMout, ['C:/Users/csjunxu/Desktop/CVPR2017/1_Results/WNNM_' IMname '.png']);
end