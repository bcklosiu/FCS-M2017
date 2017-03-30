function [FCSTrazaIntervalos, tTraza]=FCS_calculabinstraza(FCSData, numIntervalos, binFreq, binTime)
%
%[FCSTrazaIntervalos, tTraza]=FCS_calculabinstraza(FCSData, numIntervalos, binFreq, binTimeTraza)
%   FCS_calculabinstraza es un rebinning de la traza para representarla
%   Tambi�n la divide en los intervalos indicados en numIntervalos
%   FCSData son los fotones en bins de tama�o 1/binFreq (datos estilo ISS)
%   binFreq es la frecuencia de muestreo de FCSData
%   binTime es el nuevo binning del tiempo. Para representar en general usamos binTime=0.01s
%
% jri 27Nov14
% jri 4May15
% jri 21Jul15 - Comentarios



deltaT=1/binFreq; %deltaT es el periodo de muestreo de FCSData: deltaT=1/binFreq

numData=size(FCSData,1);
numCanales=size(FCSData,2);
numDataIntervalos =floor(numData/numIntervalos);  %% El floor es necesario para poder analizar el photon mode

tplot=numDataIntervalos*deltaT; % Tiempo que dura cada intervalo adquirido (FCSintervalo) en segundos multiplicando el n�mero de puntos por su intervalo temporal.
binning=floor(binTime/deltaT); % N�mero de bins de FCSData en un bin temporal (binTime)
numPuntosTraza=floor(tplot/binTime); 

FCSTraza_tmp=zeros(numPuntosTraza, numCanales);
FCSTrazaIntervalos=zeros(numPuntosTraza, numCanales, numIntervalos);
for intervalo=1:numIntervalos
    FCSintervalo=FCSData((intervalo-1)*numDataIntervalos+1:intervalo*numDataIntervalos, :);
    if not(isfloat(FCSintervalo)) %De esta forma lo �nico que es double es la parte con la que hace el subbinning
        FCSintervalo=double(FCSintervalo);
    end
    C_FCS_binning1(FCSTraza_tmp, FCSintervalo, binning); %Este es el binning de Matlab que hizo Unai. Es equivalente a las tres l�neas que siguen
    FCSTrazaIntervalos(:, :, intervalo)=FCSTraza_tmp;
end
    
% for nn=1:numPuntosTraza 
%         FCSTraza(nn, :)=sum(FCSData((nn-1)*binning+1:nn*binning, :));
% end

tTraza=(1:numPuntosTraza)*binTime;
tTraza=tTraza(:);
FCSTrazaIntervalos=uint16(FCSTrazaIntervalos);
