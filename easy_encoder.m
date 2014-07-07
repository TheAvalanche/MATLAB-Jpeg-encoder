function easy_encoder()
    CELL_SIZE = 8; %greater than 4
    
   lumMat = [
         16 11 10 16 24 40 51 61;
         12 12 14 19 26 58 60 55;
         14 13 16 24 40 57 69 56;
         14 17 22 29 51 87 80 62;
         18 22 37 56 68 109 103 77;
         24 35 55 64 81 104 113 92;
         49 64 78 87 103 121 120 101; 
         72 92 95 98 112 100 103 99];
     
    chromMat = [
         17 18 24 47 99 99 99 99; 
         18 21 26 66 99 99 99 99; 
         24 26 56 99 99 99 99 99; 
         47 66 99 99 99 99 99 99; 
         99 99 99 99 99 99 99 99; 
         99 99 99 99 99 99 99 99; 
         99 99 99 99 99 99 99 99; 
         99 99 99 99 99 99 99 99];
     
    quality = 80;
    disp('quality');
    disp(quality);
    if quality < 50
        quality = 50/quality;
    else
        quality = 2 - quality/50;
    end
    lumMat = lumMat * quality;
    chromMat = chromMat * quality;

    img = imread('sample.bmp');
    
    %plots RGB
    figure(1);
    subplot(3,1,1);
    imhist(img(:,:,1));
    title('R');
    grid on;
    subplot(3,1,2);
    imhist(img(:, :, 2));
    title('G');
    grid on;
    subplot(3,1,3);
    imhist(img(:, :, 3));
    title('B');
    grid on;

    %%% MAPPER RGB -> YCbCr
    ycbcr_img = rgb2ycbcr(img);
    y_image = ycbcr_img(:, :, 1);
    cb_image = ycbcr_img(:, :, 2);
    cr_image = ycbcr_img(:, :, 3);

    %plots YCbCr
    figure(2);
    subplot(3,1,1);
    imhist(ycbcr_img(:,:,1));
    title('Y');
    grid on;
    subplot(3,1,2);
    imhist(ycbcr_img(:, :, 2));   
    title('Cb');
    grid on;
    subplot(3,1,3);
    imhist(ycbcr_img(:, :, 3));
    title('Cr');
    grid on;
    
    
    %%% Turn into cells 8x8
    repeat_height = size(y_image, 1)/CELL_SIZE;
    repeat_width = size(y_image, 2)/CELL_SIZE;
    repeat_height_mat = repmat(CELL_SIZE, [1 repeat_height]);
    repeat_width_mat = repmat(CELL_SIZE, [1 repeat_width]);
    y_sub_image = mat2cell(y_image, repeat_width_mat, repeat_height_mat);
    cb_sub_image = mat2cell(cb_image, repeat_width_mat, repeat_height_mat);
    cr_sub_image = mat2cell(cr_image, repeat_width_mat, repeat_height_mat);    

    zero_count = 0;
    for i=1:repeat_height
        for j=1:repeat_width
            y_sub_image{i, j} = dct2(y_sub_image{i, j});
            y_sub_image{i, j} = round(y_sub_image{i, j}./lumMat);
            zero_count = zero_count + sum(sum(y_sub_image{i, j} == 0));

            cb_sub_image{i, j} = dct2(cb_sub_image{i, j});
            cb_sub_image{i, j} = round(cb_sub_image{i, j}./chromMat);
            zero_count = zero_count + sum(sum(cb_sub_image{i, j} == 0));

            cr_sub_image{i, j} = dct2(cr_sub_image{i, j});
            cr_sub_image{i, j} = round(cr_sub_image{i, j}./chromMat);
            zero_count = zero_count + sum(sum(cr_sub_image{i, j} == 0));
        end
    end
    
    y_compressed_img = cell2mat(y_sub_image);
    cb_compressed_img = cell2mat(cb_sub_image);
    cr_compressed_img = cell2mat(cr_sub_image);
    compressed_img = img;
    compressed_img(:, :, 1) = y_compressed_img;
    compressed_img(:, :, 2) = cb_compressed_img;
    compressed_img(:, :, 3) = cr_compressed_img; 
    
    %plots DCT
    figure(3);
    subplot(3,1,1);
    hist(double(reshape(compressed_img(:, :, 1), 1, 262144)), double(max(max(compressed_img(:, :, 1)))));
    title('DCT and Q over Y');
    grid on;
    subplot(3,1,2);
    hist(double(reshape(compressed_img(:, :, 2), 1, 262144)), double(max(max(compressed_img(:, :, 2)))));
    title('DCT and Q over Cb');
    grid on;
    subplot(3,1,3);
    hist(double(reshape(compressed_img(:, :, 3), 1, 262144)), double(max(max(compressed_img(:, :, 3)))));
    title('DCT and Q over Cr');
    grid on;
    
    disp('zeros count: ');
    disp(zero_count);
    
    %decompression
    for i=1:repeat_height
        for j=1:repeat_width
            y_sub_image{i, j} = y_sub_image{i, j}.*lumMat;
            y_sub_image{i, j} = round(idct2(y_sub_image{i, j}));
            
            cb_sub_image{i, j} = cb_sub_image{i, j}.*chromMat;
            cb_sub_image{i, j} = round(idct2(cb_sub_image{i, j}));
            
            cr_sub_image{i, j} = cr_sub_image{i, j}.*chromMat;
            cr_sub_image{i, j} = round(idct2(cr_sub_image{i, j}));   
        end
    end 
    
    y_decompressed_img = cell2mat(y_sub_image);
    cb_decompressed_img = cell2mat(cb_sub_image);
    cr_decompressed_img = cell2mat(cr_sub_image);
    decompressed_img = img;
    decompressed_img(:, :, 1) = y_decompressed_img;
    decompressed_img(:, :, 2) = cb_decompressed_img;
    decompressed_img(:, :, 3) = cr_decompressed_img; 
    
    %plots YCbCr
    figure(4);
    subplot(3,1,1);
    imhist(decompressed_img(:, :, 1));
    title('Y');
    grid on;
    subplot(3,1,2);
    imhist(decompressed_img(:, :, 2));
    title('Cb');
    grid on;
    subplot(3,1,3);
    imhist(decompressed_img(:, :, 3));
    title('Cr');
    grid on;
    
    decompressed_img = ycbcr2rgb(decompressed_img);
    
    %plots RGB
    figure(5);
    subplot(3,1,1);
    imhist(decompressed_img(:, :, 1));
    title('R');
    grid on;
    subplot(3,1,2);
    imhist(decompressed_img(:, :, 2));
    title('G');
    grid on;
    subplot(3,1,3);
    imhist(decompressed_img(:, :, 3));
    title('B');
    grid on;
    
    noise_img = abs(img - decompressed_img);
    
    %plots noise
    figure(6);
    subplot(3,1,1);
    hist(double(reshape(noise_img(:, :, 1), 1, 262144)), double(max(max(noise_img(:, :, 1)))));
    title('\Delta R');
    grid on;
    subplot(3,1,2);
    hist(double(reshape(noise_img(:, :, 2), 1, 262144)), double(max(max(noise_img(:, :, 2)))));
    title('\Delta G');
    grid on;
    subplot(3,1,3);
    hist(double(reshape(noise_img(:, :, 3), 1, 262144)), double(max(max(noise_img(:, :, 3)))));
    title('\Delta B');
    grid on;
    
    image_en = sum(img(:));%.^2;
    noise_img_en = sum(noise_img(:));%.^2;
    
    snr = image_en / noise_img_en;
    nsr = noise_img_en / image_en;
    disp('image energy: ');
    disp(image_en);
    disp('noise energy');
    disp(noise_img_en);
    disp('SNR')
    disp(snr);
    disp('NSR')
    disp(nsr);
    figure(7);
    imshow(255-noise_img.^2);
end