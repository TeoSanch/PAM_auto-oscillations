% La fonction svm_clarinet_3D calcule la cartographie des états de la
% clarinette en fonction d'un descripteur donné.
% Les entrées sont :
% - descriptor (string) : 
%   - "isAccurate" : Justesse ou non (selon une fréquence f0 à définir dans la
%   fonction du même nom)
%   D'autres descripteurs peuvent être implémentés de la même manière, mais
%   par choix, on n'a utilisé que la justesse.
% - doe_samples : nombre d'échantillons du "Design of Experience"
% - edsd_samples : nombre d'échantillonnage adaptatif
function [] = svm_clarinet_3D(descriptor, f0,...
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
    midi_note = 12*log2(f0/440)+69;
    midi_min = midi_note-2; midi_max = midi_note+2;
    f0_min = 2.^((midi_min-69)/12).*440; % On réduit l'invervalle de fréquence à explorer
    f0_max = 2.^((midi_max-69)/12).*440;
    gamma_min = 0.1; gamma_max = 1.1;   % Pression dans la bouche
    zeta_min = 0.1; zeta_max = 1.1;     % Paramètre d'anche

    sprintf('Generating design of experience...')
    Latin_sample = lhsdesign(doe_samples, 3);
    
    % Rescaling
    gamma_sample = Latin_sample(:,1)*(gamma_max-gamma_min) + gamma_min;
    zeta_sample = Latin_sample(:,2)*(zeta_max-zeta_min) + zeta_min;
    f0_sample = Latin_sample(:,3)*(f0_max-f0_min) + f0_min;
    
    % Parmètres du DOE
    clarinet_samples = [gamma_sample zeta_sample f0_sample];
    %% Audio descriptor
    f = @(x) classify_3D(x,f0);
    % Si la fonction f prend une liste de variables -> doit retourner une
    % liste de la même longueur
    sprintf('Apply descriptor on the DOE...')
    classes_doe = f(clarinet_samples)      % Classes associées au DOE

    %% Training
    sprintf('Train the SVM model')
    % Avec la fonction MATLAB
    % svm = svmtrain(clarinet_sample, classes_init, 'kernel_function', 'polynomial', 'ShowPlot',true);
    % Avec CODES
    svm = CODES.fit.svm(clarinet_samples, classes_doe,'solver','dual');
    %% Adaptive sampling
    sprintf('Refine with adaptive sampling...')
    svm_col=CODES.sampling.edsd(f,svm,[gamma_min zeta_min f0_min],...
        [gamma_max zeta_max f0_max],...
        'iter_max',edsd_samples, 'conv', false);
    %% Plot
    figure(1)
    set(gca,'FontSize',26);
    svm_col{end}.isoplot('sv',false,'samples',false,'legend',false,'bcol','r')
    xlabel('Force', 'Fontsize', 30)
    ylabel('Vitesse', 'Fontsize', 30)
  %% Save SVM edsd & images
    frequency = f0;
    %get directory of function
    func_file = which('svm_clarinet');
    func_folder = dir(func_file)
    cd(func_folder.folder);
    
    finalSVM = svm_col{end};
    savefilename = strcat(num2str(descriptor),'_',num2str(frequency),'_',num2str(gamma_min),...
        '_',num2str(gamma_max),'_',num2str(zeta_min),'_',num2str(zeta_max));
    % Save the 'svm' struct
    saveMatFilename = strcat(savefilename,'.mat');
    mkdir('./clarinet_3D/matFiles');
    saveMatFilename = strcat('./clarinet_3D/matFiles/',saveMatFilename);
    save(saveMatFilename, 'finalSVM')

    % Save graph as an image
    savePngFilename = strcat(savefilename,'.png');
    mkdir('./clarinet_3D/png');
    savePngFilename = strcat('./clarinet_3D/png/',savePngFilename);
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
