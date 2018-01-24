% La fonction svm_violon calcule la cartographie des états de la
% violon en fonction d'un descripteur donné.
% Les entrées sont :
% - descriptor (string) : 
%   - "isSound" : son ou absence de son
%   - "isCanard" : Canard ou non
%   - "isRough" : Rugosité (plusieurs frontières/seuils)
%   - "isBright : Brillance (plusieurs frontières/seuils)
%   - "isQuasiPeriodic" : Régime quasi-périodique ou non 
%   - "isOctavie" : Changement de registre
% - doe_samples : nombre d'échantillons du "Design of Experience"
% - edsd_samples : nombre d'échantillonnage adaptatif
function [] = svm_violon(descriptor, f0,...
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
    t_max = 2; Fe = 44100;  % durée des échantillons générés
    N_pext = t_max*Fe; % length of pext
    
    % Variations de force et vitesse
    force_min = 0; force_max = 5;           % force de l'archet sur les cordes
    vitesse_min = 0; vitesse_max = 5;       % vitesse de l'archet
    beta_min = 0; beta_max = 0.33/2;        % positition de l'archet
    sprintf('Generating design of experience...')
    Latin_sample = lhsdesign(doe_samples, 2);
    
    % Rescaling
    force_sample = Latin_sample(:,1)*(force_max-force_min) + force_min;
    vitesse_sample = Latin_sample(:,2)*(vitesse_max-vitesse_min) + vitesse_min;
    beta_sample = Latin_sample(:,2)*(beta_max-beta_min) + beta_min;
    % Parmètres du DOE
    violon_samples = [force_sample vitesse_sample];
    %% Audio descriptor
    f = @(x) classify(x, f0, descriptor);
    % Si la fonction f prend une liste de variables -> doit retourner une
    % liste de la même longueur
    
    sprintf('Apply descriptor on the DOE...')
    classes_doe = f(violon_samples);      % Classes associées au DOE
    %% Training
    sprintf('Train the SVM model')
    % Avec la fonction MATLAB
    % svm = svmtrain(violon_sample, classes_init, 'kernel_function', 'polynomial', 'ShowPlot',true);
    % Avec CODES
    svm = CODES.fit.svm(violon_samples, classes_doe,'solver','dual');
    %% Adaptive sampling
    sprintf('Refine with adaptive sampling...')
    svm_col=CODES.sampling.edsd(f,svm,[force_min vitesse_min],[force_max vitesse_max],...
        'iter_max',edsd_samples, 'conv', false);
    %% Plot
    svm_fin = svm_col{end}
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
            svm_col=CODES.sampling.edsd(f,svm,[force_min vitesse_min],...
                [force_max vitesse_max], 'iter_max',edsd_samples,...
                'conv', false);
            svm_fin.isoplot('sv', false, 'samples', false,...
                'legend', false, 'bcol', ind_color);
            hold on
        end
        xlabel('\force', 'Fontsize', 30);
        ylabel('\vitesse', 'Fontsize', 30);
        
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
    func_file = which('svm_violon');
    func_folder = dir(func_file)
    cd(func_folder.folder);
    
    finalSVM = svm_col{end};
    savefilename = strcat(num2str(descriptor),'_',num2str(frequency),'_',num2str(force_min),...
        '_',num2str(force_max),'_',num2str(vitesse_min),'_',num2str(vitesse_max));
    % Save the 'svm' struct
    saveMatFilename = strcat(savefilename,'.mat');
    mkdir('./violon/matFiles');
    saveMatFilename = strcat('./violon/matFiles/',saveMatFilename);
    save(saveMatFilename, 'finalSVM')

    % Save graph as an image
    savePngFilename = strcat(savefilename,'.png');
    mkdir('./violon/png');
    savePngFilename = strcat('./violon/png/',savePngFilename);
    figure(2)
    finalSVM.isoplot('sv',false,'samples',false,'legend',false,'bcol','r')
    set(gca,'FontSize',26);
    xlabel('Force', 'Fontsize', 30)
    ylabel('Vitesse', 'Fontsize', 30)
    F = getframe;

    Im = frame2im(F);
%     threshold = graythresh(Im);
%     Im=im2bw(Im,threshold);
%     Im = imbinarize(Im);
%     Im = imfill(Im,'holes');
    imwrite(Im,savePngFilename);
    keyboard
end
