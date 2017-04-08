clear;
GT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\DJI_Results\Real_MeanImage\';
GT_fpath = fullfile(GT_Original_image_dir, '*.JPG');
TT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\DJI_Results\Real_NoisyImage\';
TT_fpath = fullfile(TT_Original_image_dir, '*.JPG');
% GT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\cc_Results\Real_ccnoise_denoised_part\';
% GT_fpath = fullfile(GT_Original_image_dir, '*mean.png');
% TT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\cc_Results\Real_ccnoise_denoised_part\';
% TT_fpath = fullfile(TT_Original_image_dir, '*real.png');
GT_im_dir  = dir(GT_fpath);
TT_im_dir  = dir(TT_fpath);
im_num = length(TT_im_dir);

PSNR = [];
SSIM = [];
CCPSNR = [];
CCSSIM = [];

method = 'WNNM';
write_sRGB_dir = ['C:/Users/csjunxu/Desktop/CVPR2017/DJI_Results/' method '/'];
if ~isdir(write_sRGB_dir)
    mkdir(write_sRGB_dir)
end

for i = 1:im_num
    IMin = im2double(imread(fullfile(TT_Original_image_dir,TT_im_dir(i).name) ));
    IM_GT = im2double(imread(fullfile(GT_Original_image_dir, GT_im_dir(i).name)));
    S = regexp(TT_im_dir(i).name, '\.', 'split');
    IMname = S{1};
    [h,w,ch] = size(IMin);
    fprintf('%s: \n',TT_im_dir(i).name);
    CCPSNR = [CCPSNR csnr( IMin*255,IM_GT*255, 0, 0 )];
    CCSSIM = [CCSSIM cal_ssim( IMin*255, IM_GT*255, 0, 0 )];
    fprintf('The initial PSNR = %2.4f, SSIM = %2.4f. \n', CCPSNR(end), CCSSIM(end));
    IMout = zeros(size(IMin));
    for cc = 1:ch
        %% denoising
        fprintf('The PSNR = %2.4f, SSIM = %2.4f. \n', csnr( IMin(:,:,cc)*255, IM_GT(:,:,cc)*255, 0, 0 ), cal_ssim( IMin(:,:,cc)*255, IM_GT(:,:,cc)*255, 0, 0 ));
        nSig = NoiseLevel( IMin(:,:,cc)*255);
        Par   = ParSet(nSig);
        IMoutcc = WNNM_DeNoising( IMin(:,:,cc) *255, IM_GT(:,:,cc)*255, Par );
        IMout(:,:,cc) = IMoutcc;
    end
    PSNR = [PSNR csnr( IMout, IM_GT*255, 0, 0 )];
    SSIM = [SSIM cal_ssim( IMout, IM_GT*255, 0, 0 )];
    fprintf('The final PSNR = %2.4f, SSIM = %2.4f. \n', PSNR(end), SSIM(end));
    imwrite(IMout/255, [write_sRGB_dir method '_RID_' IMname '.png']);
end
mPSNR = mean(PSNR);
mSSIM = mean(SSIM);
mCCPSNR = mean(CCPSNR);
mCCSSIM = mean(CCSSIM);
save(['C:/Users/csjunxu/Desktop/CVPR2017/DJI_Results/', method, '_' num2str(nSig) '.mat'],'nSig','PSNR','mPSNR','SSIM','mSSIM','CCPSNR','mCCPSNR','CCSSIM','mCCSSIM');
