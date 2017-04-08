clear;
Original_image_dir  =    'C:\Users\csjunxu\Desktop\ECCV2016\grayimages\';
fpath = fullfile(Original_image_dir, '*.png');
im_dir  = dir(fpath);
im_num = length(im_dir); 
nSig = [10 30 50];
nWeight = [0.25 0.5 0.25];
for Sample = 1:1
    matname = sprintf('WNNM_MoG_%d_%2.2f_%d_%2.2f_%d_%2.2f.mat',nSig(1),nWeight(1),nSig(2),nWeight(2),nSig(3),nWeight(3));
    if exist(matname,'file')
        eval(['load ' matname]);
        if Sample <=length(mPSNR)
            continue
        end
    end
    imPSNR{Sample} = [];
    imSSIM{Sample} = [];
    for i = 1:im_num
        %% read clean image
        S = regexp(im_dir(i).name, '\.', 'split');
        O_Img = double(imread(fullfile(Original_image_dir, im_dir(i).name)));
        
        %% generate MoG noise
        stream = RandStream('mt19937ar','Seed',Sample-1);
        SampleIndex = randperm(stream,numel(O_Img));
        NoiseMatrix = zeros(size(O_Img));
        randn('seed',Sample-1)
        Pixels1 = fix(nWeight(1)*numel(NoiseMatrix));
        NoiseMatrix(SampleIndex(1 : Pixels1)) = nSig(1)*randn(1,Pixels1);
        randn('seed',Sample-1)
        Pixels2 = fix(nWeight(2)*numel(NoiseMatrix));
        NoiseMatrix(SampleIndex(Pixels1+1 : Pixels1+Pixels2)) = nSig(2)*randn(1,Pixels2);
        randn('seed',Sample-1)
        Pixels3 = numel(NoiseMatrix) - (Pixels1+Pixels2);
        NoiseMatrix(SampleIndex(Pixels1+Pixels2+1 : end)) = nSig(3)*randn(1,Pixels3);
        %% generate noisy image with MoG noise
        N_Img = O_Img + NoiseMatrix;
        %% noise level estimation
        nLevel = NoiseLevel(N_Img);
        fprintf( 'Noisy Image: Noise Level is %2.2f, PSNR = %2.2f \n\n\n',nLevel, csnr( N_Img, O_Img, 0, 0 ) );
        %% denoising
        Par   = ParSet(nLevel);
        E_Img = WNNM_DeNoising( N_Img, O_Img, Par );
        %% output
        imname = sprintf('./MoGresults/WNNM_MoG_Sample%d_%d_%2.2f_%d_%2.2f_%d_%2.2f_%s',Sample,nSig(1),nWeight(1),nSig(2),nWeight(2),nSig(3),nWeight(3),im_dir(i).name);
        imwrite(E_Img/255,imname);
        imPSNR{Sample} = [imPSNR{Sample} csnr( O_Img, E_Img, 0, 0 )];
        imSSIM{Sample} = [imSSIM{Sample} cal_ssim( E_Img, O_Img, 0, 0 )];
        fprintf( 'Estimated Image: PSNR = %2.2f, SSIM = %2.4f \n\n\n', csnr( O_Img, E_Img, 0, 0 ),cal_ssim( E_Img, O_Img, 0, 0 ) );
    end
    mPSNR(Sample)=mean(imPSNR{Sample},2);
    mSSIM(Sample)=mean(imSSIM{Sample},2);
    fprintf('The average PSNR = %2.4f, SSIM = %2.4f. \n', mPSNR(Sample),mSSIM(Sample));
    save(matname,'mPSNR','mSSIM','imPSNR','imSSIM');
end
PSNR = mean(mPSNR);
SSIM = mean(mSSIM);
result = sprintf('Sample%d_WNNM_MoG_%d_%2.2f_%d_%2.2f_%d_%2.2f.mat',Sample,nSig(1),nWeight(1),nSig(2),nWeight(2),nSig(3),nWeight(3));
save(result,'PSNR','SSIM','mPSNR','mSSIM','imPSNR','imSSIM');