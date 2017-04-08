clear;
Original_image_dir  =    'C:\Users\csjunxu\Desktop\ECCV2016\grayimages\';
fpath = fullfile(Original_image_dir, '*.png');
im_dir  = dir(fpath);
im_num = length(im_dir);
for scale = [0.03]
    SmPSNR = [];
    SmSSIM = [];
    for Sample = 1:1
        matname = sprintf('WNNM_scale_%2.2f.mat',scale);
        imPSNR{Sample} = [];
        imSSIM{Sample} = [];
        for i = 1:im_num
            S = regexp(im_dir(i).name, '\.', 'split');
            O_Img = im2double(imread(fullfile(Original_image_dir, im_dir(i).name)));
            rand('seed',Sample-1);
            V = scale*rand(size(O_Img));
            N_Img = imnoise(O_Img,'localvar',V);
            O_Img = O_Img*255;
            N_Img = N_Img*255;
            RannSig = NoiseLevel(N_Img);
            fprintf( 'Noisy Image: Estimated nSig = %2.2f, PSNR = %2.2f \n\n\n', RannSig, csnr( N_Img, O_Img, 0, 0 ) );
            Par   = ParSet(RannSig);
            E_Img = WNNM_DeNoising( N_Img, O_Img, Par );
            imname = sprintf('C:/Users/csjunxu/Desktop/ECCV2016/1_Results/WNNM/GauLocVar/WNNM_scale%2.2f_Sample%d_%s',scale,Sample,im_dir(i).name);
            imwrite(E_Img/255,imname);
            imPSNR{Sample} = [imPSNR{Sample} csnr( O_Img, E_Img, 0, 0 )];
            imSSIM{Sample} = [imSSIM{Sample} cal_ssim( E_Img, O_Img, 0, 0 )];
            fprintf( 'Estimated Image: scale = %2.2f, PSNR = %2.2f, SSIM = %2.4f \n\n\n', scale, csnr( O_Img, E_Img, 0, 0 ),cal_ssim( E_Img, O_Img, 0, 0 ) );
        end
        SmPSNR(Sample)=mean(imPSNR{Sample},2);
        SmSSIM(Sample)=mean(imSSIM{Sample},2);
        fprintf('The average PSNR = %2.4f, SSIM = %2.4f. \n', SmPSNR(Sample),SmSSIM(Sample));
        name = sprintf('C:/Users/csjunxu/Desktop/ECCV2016/1_Results/WNNM/WNNM_GauLocVar_scale%2.2f_Sample%d.mat',scale,Sample);
        save(name,'SmPSNR','SmSSIM','imPSNR','imSSIM');
    end
    mPSNR = mean(SmPSNR);
    mSSIM = mean(SmSSIM);
    result = sprintf('WNNM_scale%2.2f.mat',scale);
    save(result,'SmPSNR','SmSSIM','mPSNR','mSSIM');
end