function out = quantize(in, code)

    global divLumMatrix;
    global divChromMatrix;
    if strcmp(code, 'lum')
        index = 1;
        for i = 1:8
            for j = 1:8
                outputData(index) = round(in(i, j) *  divLumMatrix(index));
                index=index+1;
            end
        end
    elseif strcmp(code, 'chrom')
        index = 1;
        for i = 1:8
            for j = 1:8
                outputData(index) = round(in(i, j) *  divChromMatrix(index));
                index=index+1;
            end
        end
    end     

    out = outputData;
end