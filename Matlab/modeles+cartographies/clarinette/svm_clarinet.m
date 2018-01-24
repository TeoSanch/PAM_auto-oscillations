% La fonction svm_clarinet calcule la cartographie des états de la
% clarinette en fonction d'un descripteur donné.
% Les entrées sont :
% - descriptor (string) : 
%   - "isSound" : son ou absence de son
%   - "isCanard" : Canard ou non
%   - "isRough" : Rugosité (plusieurs frontières/seuils)
%   - "isBright : Brillance (plusieurs frontières/seuils)
%   - "isQuasiPeriodic" : Régime quasi-périodique ou non 
%   - "isOctavie" : Changement de regisres (absent pour la clarinette)
% - doe_samples : nombre d'échantillons du "Design of Experience"
% - edsd_samples : nombre d'échantillonnage adaptatif
function [] = svm_clarinet(descriptor, f0,...
    doe_samples, edsd_samples)
    if nargin > 4
    error('myfuns:somefun2:TooManyInputs', ...
        'requires at most 4 optional inputs');
    end

    % Fill in unset optional values.
    switch nargin
        case 2
            doe_samples = 100;
            edsd_samples = 100;
        case 3
            edsd_samples = 100;
    end
    %% Hypercube latin : Design Of Experience
    t_max = 2; Fe = 44100;
    N_pext = t_max*Fe; % length of pext
    
    % Variations de gamma et zeta
    gamma_min = 0.3; gamma_max = 1.1;   % Pression dans la bouche
    zeta_min = 0; zeta_max = 6;         % Paramètre d'anche
    sprintf('Generating design of experience...')
    Latin_sample = lhsdesign(doe_samples, 2);
    
    % Rescaling
    gamma_sample = Latin_sample(:,1)*(gamma_max-gamma_min) + gamma_min;
    zeta_sample = Latin_sample(:,2)*(zeta_max-zeta_min) + zeta_min;
    
    % Parmètres du DOE
    clarinet_samples = [gamma_sample zeta_sample];
    %% Audio descriptor
    f = @(x) classify(x, f0, descriptor);
    
    % Si la fonction f prend une liste de variables -> doit retourner une
    % liste de la même longueur
    sprintf('Apply descriptor on the DOE...')
    classes_doe = f(clarinet_samples);      % Classes associées au DOE

    %% Training
    sprintf('Train the SVM model')
    % Avec la fonction MATLAB
    % svm = svmtrain(clarinet_sample, classes_init, 'kernel_function', 'polynomial', 'ShowPlot',true);
    % Avec CODES
    svm = CODES.fit.svm(clarinet_samples, classes_doe,'solver','dual');
    %% Adaptive sampling
    sprintf('Refine with adaptive sampling...')
    svm_col=CODES.sampling.edsd(f,svm,[gamma_min zeta_min],[gamma_max zeta_max],...
        'iter_max',edsd_samples, 'conv', false);
    %% Plot
    figure(1)
    set(gca,'FontSize',26);
    svm_col{end}.isoplot
    xlabel('Force', 'Fontsize', 30)
    ylabel('Vitesse', 'Fontsize', 30)
    
    if strcmp(descriptor, 'isRough') ||strcmp(descriptor, 'isBright')
        svm_fin = svm_col{end};
        color = colormap;
        nb_class = 9;
        figure(3)
        set(gca, 'Fontsize', 26);
        for i=0:nb_class-3
            ind_color = color(round(i*length(color)/nb_class)+1, :);
            svm_fin.Y = svm_fin.Y + 1;
            svm_fin.Y
            svm_fin = CODES.fit.svm(svm_fin.X, svm_fin.Y,...
                'solver', 'dual');
            sprintf('Refine with adaptive sampling...')
            svm_col=CODES.sampling.edsd(f,svm,[gamma_min zeta_min],...
                [gamma_max zeta_max], 'iter_max',edsd_samples,...
                'conv', false);
            svm_fin.isoplot('sv', false, 'samples', false,...
                'legend', false, 'bcol', ind_color);
            hold on
        end
        xlabel('\gamma', 'Fontsize', 30);
        ylabel('\zeta', 'Fontsize', 30);
        title('SVM roughness of the clarinet model');
        
    end
    
   %% Save SVM edsd & images
    frequency = f0;
    if frequency >= 100
        frequency = roundn(f0, -3);
    elseif frequency >= 1000
          frequency = roundn(f0, -2);  
    elseif frequency >= 10
        frequency = roundn(f0, -4);
    else
        frequency = roundn(f0, -5);
    end
    %get directory of function
    func_file = which('svm_clarinet');
    func_folder = dir(func_file)
    cd(func_folder.folder);
    
    finalSVM = svm_col{end};
    savefilename = strcat(num2str(descriptor),'_',num2str(frequency),'_',num2str(gamma_min),...
        '_',num2str(gamma_max),'_',num2str(zeta_min),'_',num2str(zeta_max));
    % Save the 'svm' struct
    saveMatFilename = strcat(savefilename,'.mat');
    mkdir('./clarinet/matFiles');
    saveMatFilename = strcat('./clarinet/matFiles/',saveMatFilename);
    save(saveMatFilename, 'finalSVM')

    % Save graph as an image
    savePngFilename = strcat(savefilename,'.png');
    mkdir('./clarinet/png');
    savePngFilename = strcat('./clarinet/png/',savePngFilename);
    figure(2)
    finalSVM.isoplot('sv',false,'samples',false,'legend',false,'bcol','r')
    set(gca,'FontSize',26);
    xlabel('\gamma', 'Fontsize', 30)
    ylabel('\zeta', 'Fontsize', 30)
    F = getframe;

    Im = frame2im(F);
%     threshold = graythresh(Im);
%     Im=im2bw(Im,threshold);
%     Im = imbinarize(Im);
%     Im = imfill(Im,'holes');
    imwrite(Im,savePngFilename);
    keyboard
end
