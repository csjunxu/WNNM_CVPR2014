clear;
Original_image_dir  =    'C:\Users\csjunxu\Desktop\ECCV2016\grayimages\';
fpath = fullfile(Original_image_dir, '*.png');
im_dir  = dir(fpath);
im_num = length(im_dir);
for nSig = [10 20]
    for SpikyRatio = [0.15 0.3]
        for Sample = 1:1
            imPSNR{Sample} = [];
            imSSIM{Sample} = [];
            for i = 1:im_num
                %% read clean image
                S = regexp(im_dir(i).name, '\.', 'split');
                IMname = S{1};
                IMname = [IMname,'_',num2str(nSig),'_',num2str(fix(SpikyRatio*100))];
                O_Img = double(imread(fullfile(Original_image_dir, im_dir(i).name)));
                %% add Gaussian noise
                NoiseMatrix = zeros(size(O_Img));
                randn('seed',Sample-1)
                N_Img = O_Img + nSig*randn(size(O_Img));
                %% add "salt and pepper" noise
                rand('seed',Sample-1)
                N_Img = 255*imnoise(N_Img/255, 'salt & pepper', SpikyRatio); %"salt and pepper" noise
                %% add "salt and pepper" noise 0 or random value impulse noise 1
                %                 rand('seed',0)
                %                 [N_Img,Narr]          =   impulsenoise(N_Img,SpikyRatio,0);
                PSNR          =    csnr( N_Img, O_Img, 0, 0 );
                SSIM          =    cal_ssim(N_Img, O_Img, 0, 0 );
                fprintf('The initial value of PSNR = %2.2f  SSIM=%2.4f\n', PSNR, SSIM);
                %                 fprintf('%s :\n',im_dir(i).name);
                %                 imwrite(N_Img, ['Noisy_GauSpi_' IMname '_' num2str(nSig) '_' num2str(SpikyRatio) '.png']);
                %% AMF 
                [N_ImgAMF,ind]=adpmedft(N_Img,19);
                ind=(N_ImgAMF~=N_Img)&((N_Img==255)|(N_Img==0));
                N_ImgAMF(~ind)=N_Img(~ind);
                %% noise level estimation
                nLevel = NoiseLevel(N_ImgAMF);
                fprintf( 'Noisy Image: Noise Level is %2.2f, PSNR = %2.2f \n\n\n',nLevel, csnr( N_ImgAMF, O_Img, 0, 0 ) );
                %% denoising
                Par   = ParSet(nLevel);
                E_Img = WNNM_DeNoising( N_ImgAMF, O_Img, Par );
                %% output
                imname = sprintf('C:/Users/csjunxu/Desktop/ECCV2016/1_Results/WNNM/GauSPIN/WNNM_AMF2_GauSPIN_Sample%d_%d_%2.2f_%s',Sample,nSig,SpikyRatio,im_dir(i).name);
                imwrite(E_Img/255,imname);
                imPSNR{Sample} = [imPSNR{Sample} csnr( O_Img, E_Img, 0, 0 )];
                imSSIM{Sample} = [imSSIM{Sample} cal_ssim( E_Img, O_Img, 0, 0 )];
                fprintf( 'Estimated Image: PSNR = %2.2f, SSIM = %2.4f \n\n\n', csnr( O_Img, E_Img, 0, 0 ),cal_ssim( E_Img, O_Img, 0, 0 ) );
            end
            SmPSNR(Sample)=mean(imPSNR{Sample});
            SmSSIM(Sample)=mean(imSSIM{Sample});
            fprintf('The average PSNR = %2.4f, SSIM = %2.4f. \n', SmPSNR(Sample),SmSSIM(Sample));
            result = sprintf('C:/Users/csjunxu/Desktop/ECCV2016/1_Results/WNNM/WNNM_AMF2_GauSPIN_%d_%2.2f.mat',nSig,SpikyRatio);
            save(result,'SmPSNR','SmSSIM','imPSNR','imSSIM');
        end
    end
end