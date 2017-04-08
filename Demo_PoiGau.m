% Script reproducing the results in Table 1 of the paper:
% [1] M. Mäkitalo and A. Foi, "Optimal inversion of the generalized Anscombe transformation for Poisson-Gaussian noise", IEEE Trans. Image Process., doi:10.1109/TIP.2012.2202675
%
%  Alessandro Foi and Markku Mäkitalo - Tampere University of Technology - 2011-2012
% -----------------------------------------------------------------------------------


clear all
addpath(genpath('./BM3D_PoissonGaussian_v203'));

Original_image_dir  =    'C:\Users\csjunxu\Desktop\ECCV2016\grayimages\';
fpath = fullfile(Original_image_dir,'*.png');
im_dir  = dir(fpath);
im_num = length(im_dir);
% yy = im2double(imread('./images/fluocells.tif'));
% yy = im2double(imread('./images/Lena512.png'));
% yy = im2double(imread('./images/boat.png'));
% yy = im2double(imread('./images/cameraman.tif'));

peaks = [120 60 30 10];    % target peak values for the scaled image
sigmas = peaks/10;          % standard deviation of the Gaussian noise
reps = 1;                        % number of replications (noise realizations)

for pp=1:numel(peaks)
    PSNR_input = zeros(1,im_num);
    PSNR_yhat = zeros(1,im_num);
    PSNR_yhat_cfa = zeros(1,im_num);
    PSNR_yhat_asy = zeros(1,im_num);
    PSNR_yhat_alg = zeros(1,im_num);
    
    for i = 1:im_num
        S = regexp(im_dir(i).name, '\.', 'split');
        IMname = S{1};
        %                     read the clean image and normalization
        yy = double(imread( strcat(Original_image_dir,im_dir(i).name) ))/255;
        
        randn('seed',0);    % fixes seed of random noise
        rand('seed',0);
        
        % mixed Poisson-Gaussian noise parameters:
        
        peak = peaks(pp); % target peak value for the scaled image
        scaling = peak/max(yy(:));
        y = scaling*yy;
        
        % Poisson scaling factor
        alpha = 1;
        
        % Gaussian component N(g,sigma^2)
        sigma = sigmas(pp);
        g = 0.0;
        
        %% Generate noisy observation
        z = alpha*poissrnd(y) + sigma*randn(size(y)) + g;
        
        PSNR_input(i) = 10*log10(peak^2/(mean((y(:)-z(:)).^2)));
        disp(['Peak = ' num2str(peak) ', sigma = ' num2str(sigma)])
        disp(['input PSNR = ' num2str(PSNR_input(i))])
        %% Apply forward variance stabilizing transformation
        
        fz = GenAnscombe_forward(z,sigma,alpha,g);
        % Generalized Anscombe VST (J.L. Starck, F. Murtagh, and A. Bijaoui, Image  Processing  and  Data Analysis, Cambridge University Press, Cambridge, 1998)
        
        %% DENOISING
        
        sigma_den = 1;  % Standard-deviation value assumed after variance-stabiliation
        
        % Scale the image (BM3D processes inputs in [0,1] range)
        scale_range = 1;
        scale_shift = (1-scale_range)/2;
        
        maxzans = max(fz(:));
        minzans = min(fz(:));
        fz = (fz-minzans)/(maxzans-minzans);
        sigma_den = sigma_den/(maxzans-minzans);
        fz = fz*scale_range+scale_shift;
        sigma_den = sigma_den*scale_range;
        
        Par   = ParSet(sigma_den*255);
        D = WNNM_DeNoising( fz, y, Par );
        %         restoredIn = sprintf('./BM3Dresults/PoiGau/BM3D_PoiGau_Sample%d_%d_%2.2f_%d_%2.2f_%d_%2.2f_%s',Sample,nSig(1),nWeight(1),nSig(2),nWeight(2),nSig(3),nWeight(3),im_dir(i).name);
        %         imwrite(dummy,restoredIn,'png');
        
        % Scale back to the initial VST range
        D = (D-scale_shift)/scale_range;
        D = D*(maxzans-minzans)+minzans;
        
        %% Apply the inverse transformation
        yhat = GenAnscombe_inverse_exact_unbiased(D,sigma,alpha,g);   % exact unbiased inverse
        yhat_cfa = GenAnscombe_inverse_closed_form(D,sigma,alpha,g);  % closed-form approximation
        yhat_asy =  (D/2).^2 - 1/8 - sigma^2;                       % asymptotical inverse
        yhat_alg =  (D/2).^2 - 3/8 - sigma^2;                       % algebraic inverse
        
        PSNR_yhat(i)   =   10*log10(peak^2/mean((y(:)-yhat(:)).^2));
        SSIM_yhat(i)   =   cal_ssim(y,yhat,0,0);
        PSNR_yhat_cfa(i) = 10*log10(peak^2/mean((y(:)-yhat_cfa(:)).^2));
        PSNR_yhat_asy(i) = 10*log10(peak^2/mean((y(:)-yhat_asy(:)).^2));
        PSNR_yhat_alg(i) = 10*log10(peak^2/mean((y(:)-yhat_alg(:)).^2));
        %% output
        imwrite(yhat/peak, ['./PoiGau/WNNM_PoiGau_' IMname '_peak' num2str(peak) '_alpha' num2str(alpha) '.png']);
        fprintf('%s : PSNR = %2.4f, SSIM = %2.4f \n',im_dir(i).name,PSNR_yhat(i),SSIM_yhat(i));
        
    end
    disp(' ')
    disp(['Avg output PSNR (exact unbiased inv.)  = ' num2str(mean(PSNR_yhat))])
    disp(['Avg output PSNR (closed-form approx.)  = ' num2str(mean(PSNR_yhat_cfa))])
    disp(['Avg output PSNR (asymptotical inverse) = ' num2str(mean(PSNR_yhat_asy))])
    disp(['Avg output PSNR (algebraic inverse)    = ' num2str(mean(PSNR_yhat_alg))])
    disp(' ')
    mPSNR = mean(PSNR_yhat);
    mSSIM = mean(SSIM_yhat);
    fprintf('The average PSNR = %2.4f, SSIM = %2.4f.. \n', mPSNR,mSSIM);
    matname = sprintf('WNNM_PoiGau_peak%d_alpha%1.1f.mat',peak,alpha);
    save(matname,'PSNR_yhat','SSIM_yhat','mPSNR','mSSIM','PSNR_yhat_cfa','PSNR_yhat_asy','PSNR_yhat_alg');
end