function out = dcTransform(input) 

    input = double(input);
    for i = 1:8
        for j = 1:8
            output(i, j) = input(i, j) - 128.0;
        end
    end

    for i = 1:8
        tmp0 = output(i, 1) + output(i, 8);
        tmp7 = output(i, 1) - output(i, 8);
        tmp1 = output(i, 2) + output(i, 7);
        tmp6 = output(i, 2) - output(i, 7);
        tmp2 = output(i, 3) + output(i, 6);
        tmp5 = output(i, 3) - output(i, 6);
        tmp3 = output(i, 4) + output(i, 5);
        tmp4 = output(i, 4) - output(i, 5);

        tmp10 = tmp0 + tmp3;
        tmp13 = tmp0 - tmp3;
        tmp11 = tmp1 + tmp2;
        tmp12 = tmp1 - tmp2;

        output(i, 1) = tmp10 + tmp11;
        output(i, 5) = tmp10 - tmp11;

        z1 = (tmp12 + tmp13) * 0.707106781;
        output(i, 3) = tmp13 + z1;
        output(i, 7) = tmp13 - z1;

        tmp10 = tmp4 + tmp5;
        tmp11 = tmp5 + tmp6;
        tmp12 = tmp6 + tmp7;

        z5 = (tmp10 - tmp12) * 0.382683433;
        z2 = 0.541196100 * tmp10 + z5;
        z4 = 1.306562965 * tmp12 + z5;
        z3 = tmp11 * 0.707106781;

        z11 = tmp7 + z3;
        z13 = tmp7 - z3;

        output(i, 6) = z13 + z2;
        output(i, 4) = z13 - z2;
        output(i, 2) = z11 + z4;
        output(i, 8) = z11 - z4;
    end

    for i=1:8
        tmp0 = output(1, i) + output(8, i);
        tmp7 = output(1, i) - output(8, i);
        tmp1 = output(2, i) + output(7, i);
        tmp6 = output(2, i) - output(7, i);
        tmp2 = output(3, i) + output(6, i);
        tmp5 = output(3, i) - output(6, i);
        tmp3 = output(4, i) + output(5, i);
        tmp4 = output(4, i) - output(5, i);

        tmp10 = tmp0 + tmp3;
        tmp13 = tmp0 - tmp3;
        tmp11 = tmp1 + tmp2;
        tmp12 = tmp1 - tmp2;

        output(1, i) = tmp10 + tmp11;
        output(5, i) = tmp10 - tmp11;

        z1 = (tmp12 + tmp13) * 0.707106781;
        output(3, i) = tmp13 + z1;
        output(7, i) = tmp13 - z1;

        tmp10 = tmp4 + tmp5;
        tmp11 = tmp5 + tmp6;
        tmp12 = tmp6 + tmp7;

        z5 = (tmp10 - tmp12) * 0.382683433;
        z2 = 0.541196100 * tmp10 + z5;
        z4 = 1.306562965 * tmp12 + z5;
        z3 = tmp11 * 0.707106781;

        z11 = tmp7 + z3;
        z13 = tmp7 - z3;

        output(6, i) = z13 + z2;
        output(4, i) = z13 - z2;
        output(2, i) = z11 + z4;
        output(8, i) = z11 - z4;
    end

    out = output;

end