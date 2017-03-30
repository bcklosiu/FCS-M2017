function [M cpsIntervalos]= FCS_matriz (FCSData, numIntervalos, numSubIntervalosError, binFreq, numSecciones, numPuntosSeccion, base, tauLagMax)

%[M cpsIntervalos]= FCS_matriz (FCSData, numIntervalos, numSubIntervalosError, binFreq, numSecciones, numPuntosSeccion, base, tauLagMax)
% Genera las curvas de correlaci�n en forma de matriz bi o tridimensional, dependiendo de los intervalos en que hayamos dividido la traza temporal.

%   M es una matriz que contiene las trazas de autocorrelaci�n y correlaci�n cruzada de los intervalos. 
%   M es una matriz numpuntoscorrelacionx7xnumintervalos 
%   M (:,1, intervalo) contiene tdatacorr, que es la informaci�n temporal de la correlaci�n
%   M (:,2, intervalo) es la autocorrelaci�n del canal 1
%   M (:,3, intervalo) es el error de la autocorrelaci�n del canal 1
%   M (:,4, intervalo) es la autocorrelaci�n del canal 2
%   M (:,5, intervalo) es el error de la autocorrelaci�n del canal 2
%   M (:,6, intervalo) es la correlaci�n cruzada
%   M (:,7, intervalo) es el error de la correlaci�n cruzada
% 
%
%   FCSintervalos son los datos de la traza temporal, que puede ser una matriz bidimensional (si no hay intervalos) o tridimensional (si hemos dividido en intervalos)
%   numSubIntervalosError es el n�mero de intervalos en que se subdivide de FCSintervalos para calcular la desviacion est�ndar de la correlaci�n (es decir, es S)
%-----  Importante: NO confundir los intervalos de FCSintervalos (para evitar el drifting de la traza temporal) con numSubIntervalosError o S (para calcular la SD) ------
%   deltaTBin=1/sampfreq
%   numSecciones es el numero de secciones (Par�metros Multi-tau)
%   numPuntosSeccion es el numero de puntos por seccion (Par�metros Multi-tau)
%   base es la base que elegiremos para calcular la correlacion (Par�metros Multi-tau)
%
% 26-10-10
% jri 22Abr15 - Inicializa Mtotal
% jri 4May15 - Calcula los intervalos de cada vez para no duplicar FCSData


numData=size(FCSData, 1);
numCanales=size(FCSData, 2);
deltaTBin=1/binFreq;
numDataIntervalos =floor(numData/numIntervalos);  %% El floor es necesario para poder analizar el photon mode


%Calculo el n�mero de puntos que tendr� la correlaci�n al final, quitando los que se repiten
[~ , ~ , ~, numPuntosCorrFinal]=FCS_calculaPuntosCorrelacionRepe (numSecciones, base, numPuntosSeccion, deltaTBin, tauLagMax);

numColumnasM=3; %Autocorrelaci�n: M=[tdata, G, SD]
if numCanales>1
    numColumnasM=7; %Correlaci�n cruzada: M=[tdata, G1, SD1, G2, SD2, Gcc, SDcc]
end

M=zeros(numPuntosCorrFinal, numColumnasM, numIntervalos, 'double');
cpsIntervalos=zeros(numIntervalos, numCanales, 'double');

for intervalo=1:numIntervalos, 
    FCSintervalo=FCSData((intervalo-1)*numDataIntervalos+1:intervalo*numDataIntervalos, :);
    if not(isfloat(FCSintervalo)) %De esta forma lo �nico que es double es la parte con la que hace el subbinning
        FCSintervalo=double(FCSintervalo);
    end
    M (:, :, intervalo)=FCS_stdev(FCSintervalo, numSubIntervalosError, deltaTBin, numSecciones, numPuntosSeccion, base, tauLagMax);
    
    cpsIntervalos(intervalo, :)=round(squeeze(sum(FCSintervalo, 1, 'double'))/(numDataIntervalos*deltaTBin));

end


% Gtotal=M(:,2:end,:);
% tdatacorr=Mtotal(:,1,1);

