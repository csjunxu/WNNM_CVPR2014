clear;
Original_image_dir  =    'C:\Users\csjunxu\Desktop\ECCV2016\grayimages\';
fpath = fullfile(Original_image_dir, '*.png');
im_dir  = dir(fpath);
im_num = length(im_dir);
for nSigG = 10
    for nSigL = [30 45]
        for Sample = 1:1
            imPSNR{Sample} = [];
            imSSIM{Sample} = [];
            for i = 1:im_num
                %% read clean image
                S = regexp(im_dir(i).name, '\.', 'split');
                IMname = S{1};
                IMname = [IMname,'_',num2str(nSigG),'_',num2str(nSigL)];
                O_Img = double(imread(fullfile(Original_image_dir, im_dir(i).name)));
                %% add Gaussian noise
                NoiseMatrix = zeros(size(O_Img));
                randn('seed',Sample-1);
                N_Img = O_Img + nSigG*randn(size(O_Img));
                rand('seed',Sample-1);
                N_Img = N_Img + nSigL.*randl(size(O_Img));
                PSNR          =    csnr( N_Img, O_Img, 0, 0 );
                SSIM          =    cal_ssim(N_Img, O_Img, 0, 0 );
                fprintf('The initial value of PSNR = %2.2f  SSIM=%2.4f\n', PSNR, SSIM);
                %% noise level estimation
                nLevel = NoiseLevel(N_Img);
                fprintf( 'Noisy Image: Noise Level is %2.2f, PSNR = %2.2f \n\n\n',nLevel, csnr( N_Img, O_Img, 0, 0 ) );
                %% denoising
                Par   = ParSet(nLevel);
                E_Img = WNNM_DeNoising( N_Img, O_Img, Par );
                %% output
                imname = sprintf('C:/Users/csjunxu/Desktop/ECCV2016/1_Results/WNNM/GauLap/WNNM_GauLap_%d_%d_%s',nSig,nSigL,im_dir(i).name);
                imwrite(E_Img/255,imname);
                imPSNR{Sample} = [imPSNR{Sample} csnr( O_Img, E_Img, 0, 0 )];
                imSSIM{Sample} = [imSSIM{Sample} cal_ssim( E_Img, O_Img, 0, 0 )];
                fprintf( 'Estimated Image: PSNR = %2.2f, SSIM = %2.4f \n\n\n', csnr( O_Img, E_Img, 0, 0 ),cal_ssim( E_Img, O_Img, 0, 0 ) );
            end
            SmPSNR(Sample)=mean(imPSNR{Sample});
            SmSSIM(Sample)=mean(imSSIM{Sample});
            fprintf('The average PSNR = %2.4f, SSIM = %2.4f. \n', SmPSNR(Sample),SmSSIM(Sample));
            result = sprintf('C:/Users/csjunxu/Desktop/ECCV2016/1_Results/WNNM/WNNM_GauLap_%d_%d.mat',nSig,nSigL);
            save(result,'SmPSNR','SmSSIM','imPSNR','imSSIM');
        end
    end
end