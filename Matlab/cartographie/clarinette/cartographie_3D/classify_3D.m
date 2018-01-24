function class = classify_3D(params,f0)
    N = size(params);
    L =N(1);    
    class = zeros(L,1);
    for i=1:L
        if L > 2
            sprintf('DOE sample n° %d / %d', i, L)
        end
        param1 = params(i, 1); param2 = params(i, 2); param3 = params(i,3);
        signal = clarinet_3D(param1, param2, param3, 2, 44100, false, false);
        class(i) = isAccurate(signal, 10, f0);
    end
end