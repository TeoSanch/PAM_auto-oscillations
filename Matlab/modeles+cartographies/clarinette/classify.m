function class = classify(params, f0, descriptor)
    if strcmp(descriptor,'isSound')
        desc = @(sig) isSound(sig);
    elseif strcmp(descriptor,'isCanard')
        desc = @(sig) isCanard(sig);
    elseif strcmp(descriptor,'isQuasiPeriodic')
        desc = @(sig) isQuasiPeriodic(sig);
    elseif strcmp(descriptor, 'isRough')
        desc = @(sig) isRough(sig);
    elseif strcmp(descriptor, 'isBright')
        desc = @(sig) isBright(sig);
    end

    N = size(params);
    L =N(1);    
    class = zeros(L,1);
    for i=1:L
        if L > 2
            sprintf('DOE sample n� %d / %d', i, L)
        end
        param1 = params(i, 1); param2 = params(i, 2);
        signal = clarinet(param1, param2, f0, 2, 44100, false, false);
        class(i) = desc(signal);
    end
end