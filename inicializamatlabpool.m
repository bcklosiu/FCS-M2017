function inicializamatlabpool()
% matlabpool ha quedado obsoleto en Matlab 2017. El nuevo comando es parpool.
% 
% Unai 04Abr2017

p=gcp;
isOpen=numel(p>0);
if not(isOpen) %No inicializado
    p=parpool; %El n� m�ximo de cores se configura en el men� 'Parallel Preferences'
else %Ya inicializado
    disp('Parallel pool already started')
end


