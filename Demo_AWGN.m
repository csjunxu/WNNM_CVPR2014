clear;
Original_image_dir  =    'C:\Users\csjunxu\Desktop\Projects\WODL\20images\';
% Original_image_dir  =    'C:\Users\csjunxu\Desktop\Projects\WODL\20newimages\';
% Original_image_dir  =    'C:\Users\csjunxu\Desktop\JunXu\Datasets\kodak24\kodak_color\';

Sdir = regexp(Original_image_dir, '\', 'split');
fpath = fullfile(Original_image_dir, '*.png');
im_dir  = dir(fpath);
im_num = length(im_dir);

for nSig = [20 60 80 100];
    PSNR = [];
    SSIM = [];
    for i = 1:im_num
        S = regexp(im_dir(i).name, '\.', 'split');
        O_Img = double(imread(fullfile(Original_image_dir, im_dir(i).name)));
        randn('seed',0);
        N_Img = O_Img + nSig* randn(size(O_Img));
        %         EnSig = NoiseLevel(N_Img);
        EnSig = nSig;
        fprintf( 'Noisy Image: nSig = %2.2f, PSNR = %2.2f \n\n\n', EnSig, csnr( N_Img, O_Img, 0, 0 ) );
        Par   = ParSet(EnSig);
        E_Img = WNNM_DeNoising( N_Img, O_Img, Par );
        imname = sprintf('C:/Users/csjunxu/Documents/GitHub/WODL_RID/WNNM/WNNM_nSig%d_%s',nSig,im_dir(i).name);
        imwrite(E_Img/255,imname);
        PSNR = [PSNR csnr( O_Img, E_Img, 0, 0 )];
        SSIM = [SSIM cal_ssim( E_Img, O_Img, 0, 0 )];
        fprintf( 'Estimated Image: nSig = %2.3f, PSNR = %2.2f, SSIM = %2.4f \n\n\n', nSig, csnr( O_Img, E_Img, 0, 0 ),cal_ssim( E_Img, O_Img, 0, 0 ) );
    end
    mPSNR=mean(PSNR,2);
    mSSIM=mean(SSIM,2);
    fprintf('The average PSNR = %2.4f, SSIM = %2.4f. \n', mPSNR,mSSIM);
    name = sprintf(['C:/Users/csjunxu/Documents/GitHub/WODL_RID/WNNM_'  Sdir{end-1} '_nSig' num2str(nSig) '.mat']);
    save(name,'nSig','mPSNR','mSSIM','PSNR','SSIM');
end
