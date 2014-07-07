function main()

quality = 10;
inputName = 'test.bmp';
outputName = 'output.jpg';

initGlobals(quality);

jpeg_encoder(inputName, outputName);


end

function initGlobals(quality)
    global dc_luminance_nrcodes;
    dc_luminance_nrcodes=[0 0 1 5 1 1 1 1 1 1 0 0 0 0 0 0 0];

    global dc_luminance_values;
    dc_luminance_values=[0 1 2 3 4 5 6 7 8 9 10 11];

    global dc_chrominance_nrcodes;
    dc_chrominance_nrcodes=[1 0 3 1 1 1 1 1 1 1 1 1 0 0 0 0 0];

    global dc_chrominance_values;
    dc_chrominance_values=[0 1 2 3 4 5 6 7 8 9 10 11];

    global ac_luminance_nrcodes;
    ac_luminance_nrcodes=[16 0 2 1 3 3 2 4 3 5 5 4 4 0 0 1 125];

    global ac_luminance_values;
    ac_luminance_values = [
          1 2 3 0 4 17 5 18 33 49 65 6 19 81 97 7 ...
          34 113 20 50 129 145 161 8 35 66 177 193 ...
          21 82 209 240 36 51 98 114 130 9 10 22 23 ...
          24 25 26 37 38 39 40 41 42 52 53 54 55 56 ...
          57 58 67 68 69 70 71 72 73 74 83 84 85 86 87 ...
          88 89 90 99 100 101 102 103 104 105 106 115 ...
          116 117 118 119 120 121 122 131 132 133 134 ...
          135 136 137 138 146 147 148 149 150 151 152 ...
          153 154 162 163 164 165 166 167 168 169 170 ...
          178 179 180 181 182 183 184 185 186 194 195 ...
          196 197 198 199 200 201 202 210 211 212 213 ...
          214 215 216 217 218 225 226 227 228 229 230 ...
          231 232 233 234 241 242 243 244 245 246 247 248 249 250 ];

    global ac_chrominance_nrcodes;  
    ac_chrominance_nrcodes=[17 0 2 1 2 4 4 3 4 7 5 4 4 0 1 2 119];

    global ac_chrominance_values;
    ac_chrominance_values = [
          0 1 2 3 17 4 5 33 49 6 18 65 81 7 97 ...
          113 19 34 50 129 8 20 66 145 161 177 ...
          193 9 35 51 82 240 21 98 114 209 10 22 ...
          36 52 225 37 241 23 24 25 26 38 39 40 ...
          41 42 53 54 55 56 57 58 67 68 69 70 71 ...
          72 73 74 83 84 85 86 87 88 89 90 99 100 ...
          101 102 103 104 105 106 115 116 117 118 ...
          119 120 121 122 130 131 132 133 134 135 ...
          136 137 138 146 147 148 149 150 151 152 ...
          153 154 162 163 164 165 166 167 168 169 ...
          170 178 179 180 181 182 183 184 185 186 ...
          194 195 196 197 198 199 200 201 202 210 ...
          211 212 213 214 215 216 217 218 226 227 ...
          228 229 230 231 232 233 234 242 243 244 ...
          245 246 247 248 249 250];

    global zigZagOrder;
    zigZagOrder = [ 1 2 9 17 10 3 4 11 ...
                18 25 33 26 19 12 5 6 ...
                13 20 27 34 41 49 42 35 ...
                28 21 14 7 8 15 22 29  ...
                36 43 50 57 58 51 44 37 ...
                30 23 16 24 31 38 45 52 ...
                59 60 53 46 39 32 40 47 ...
                54 61 62 55 48 56 63 64];
            
    global lumMat;    
    lumMat = [
             16 11 10 16 24 40 51 61 ...
             12 12 14 19 26 58 60 55 ...
             14 13 16 24 40 57 69 56 ...
             14 17 22 29 51 87 80 62 ...
             18 22 37 56 68 109 103 77 ...
             24 35 55 64 81 104 113 92 ...
             49 64 78 87 103 121 120 101 ... 
             72 92 95 98 112 100 103 99];
         
    global chromMat 
    chromMat = [
             17 18 24 47 99 99 99 99 ... 
             18 21 26 66 99 99 99 99 ... 
             24 26 56 99 99 99 99 99 ... 
             47 66 99 99 99 99 99 99 ... 
             99 99 99 99 99 99 99 99 ... 
             99 99 99 99 99 99 99 99 ... 
             99 99 99 99 99 99 99 99 ... 
             99 99 99 99 99 99 99 99];

    global DC_matrix;
    global AC_matrix;

    global quantLumMatrix;
    quantLumMatrix = quantLumMat(quality);
    
    global divLumMatrix;
    divLumMatrix = divMat(quantLumMatrix);

    global quantChromMatrix;
    quantChromMatrix = quantChromMat(quality);
    
    global divChromMatrix;
    divChromMatrix = divMat(quantChromMatrix);

    global bufferPutBits;
    bufferPutBits = 0;
    
    global bufferPutBuffer;
    bufferPutBuffer = 0;

    global bits;
    bits{1} = dc_luminance_nrcodes;
    bits{2} = ac_luminance_nrcodes;
    bits{3} = dc_chrominance_nrcodes;
    bits{4} = ac_chrominance_nrcodes;

    global values;
    values{1} = dc_luminance_values;
    values{2} = ac_luminance_values;
    values{3} = dc_chrominance_values;
    values{4} = ac_chrominance_values;
    
    initHuffman();

end

function out = quantLumMat(quality) 
    global lumMat;
    if quality <= 50
        quality = 5000 / quality;
    else
        quality = 200 - quality * 2;
    end
    matr = lumMat;
    for i=1:64
        matr(i) = floor((matr(i) * quality + 50) / 100);
        if matr(i) <= 0
            matr(i) = 1;
        elseif matr(i) > 255
            matr(i) = 255;
        end
    end
    out = matr;
end

function out = quantChromMat(quality) 
    global chromMat;
    if quality <= 50
        quality = 5000 / quality;
    else
        quality = 200 - quality * 2;
    end
    
    matr = chromMat;
    for i=1:64
        matr(i) = floor((matr(i) * quality + 50) / 100);
        if matr(i) <= 0
            matr(i) = 1;
        elseif matr(i) > 255
            matr(i) = 255;
        end
    end
    out = matr;
end

function out = divMat(quant)
    aanScale = [1.0 1.387039845 1.306562965 1.175875602 1.0 0.785694958 0.541196100 0.275899379];
    index = 1;
    for i = 1:8
        for j = 1:8
            div(index) = (1.0 / (quant(index) * aanScale(i) * aanScale(j) * 8.0));
            index=index + 1;
        end
    end
    out = div;
end

function initHuffman()
    global dc_chrominance_nrcodes;
    global dc_chrominance_values;
    global ac_chrominance_nrcodes;
    global ac_chrominance_values;
    global dc_luminance_nrcodes;
    global dc_luminance_values;
    global ac_luminance_nrcodes;
    global ac_luminance_values;
    global DC_matrix;
    global AC_matrix;
    
    
    %------------
    p = 0;
    for l = 1:16
        for i = 1:dc_chrominance_nrcodes(l+1)
            huffsize(p+1) = l;
            p = p + 1;
        end
    end

    huffsize(p+1) = 0;
    lastp = p;

    code = 0;
    si = huffsize(0+1);
    p = 0;
    while huffsize(p+1) ~= 0
        while huffsize(p+1) == si                
            huffcode(p+1) = code;
            p = p + 1;
            code = code + 1;
        end
        code = bitshift(code, 1);
        si = si + 1;
    end

    for p = 0:lastp-1
        DC_matrix1(dc_chrominance_values(p+1)+1, 0+1) = huffcode(p+1);
        DC_matrix1(dc_chrominance_values(p+1)+1, 1+1) = huffsize(p+1);
    end

    %--------------
    p = 0;
    for l = 1:16
        for i = 1:ac_chrominance_nrcodes(l+1)
            huffsize(p+1) = l;
            p=p+1;
        end
    end
    huffsize(p+1) = 0;
    lastp = p;

    code = 0;
    si = huffsize(0+1);
    p = 0;
    while huffsize(p+1) ~= 0
        while huffsize(p+1) == si
            huffcode(p+1) = code;
            p=p+1;
            code=code+1;
        end
        code = bitshift(code, 1);
        si=si+1;
    end 

    for p = 0:lastp-1
        AC_matrix1(ac_chrominance_values(p+1)+1, 0+1) = huffcode(p+1);
        AC_matrix1(ac_chrominance_values(p+1)+1, 1+1) = huffsize(p+1);
    end

    %--------
    p = 0;
    for l = 1:16
        for i = 1:dc_luminance_nrcodes(l+1)
            huffsize(p+1) = l;
            p = p + 1;
        end
    end
    huffsize(p+1) = 0;
    lastp = p;

    code = 0;
    si = huffsize(0+1);
    p = 0;
    while huffsize(p+1) ~= 0
        while huffsize(p+1) == si
            huffcode(p+1) = code;
            p = p + 1;
            code = code + 1;
        end
        code  = bitshift(code, 1);
        si = si + 1;
    end

    for p = 0:lastp-1
        DC_matrix0(dc_luminance_values(p+1)+1, 0+1) = huffcode(p+1);
        DC_matrix0(dc_luminance_values(p+1)+1, 1+1) = huffsize(p+1);
    end


    %-----------
    p = 0;
    for l = 1:16
        for i = 1:ac_luminance_nrcodes(l+1)
            huffsize(p+1) = l;
            p = p + 1;
        end
    end
    huffsize(p+1) = 0;
    lastp = p;

    code = 0;
    si = huffsize(0+1);
    p = 0;
    while huffsize(p+1) ~= 0
        while huffsize(p+1) == si
            huffcode(p+1) = code;
            p = p + 1;
            code = code+1;
        end
        code = bitshift(code, 1);
        si = si + 1;
    end
    for q = 0:lastp-1
        AC_matrix0(ac_luminance_values(q+1)+1, 0+1) = huffcode(q+1);
        AC_matrix0(ac_luminance_values(q+1)+1, 1+1) = huffsize(q+1);
    end

    DC_matrix(0+1, :, :) = DC_matrix0;
    DC_matrix(1+1, :, :) = DC_matrix1;
    AC_matrix(0+1, :, :) = AC_matrix0;
    AC_matrix(1+1, :, :) = AC_matrix1;
end