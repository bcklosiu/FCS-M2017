function varargout=FCS_computecorrelation (varargin)

%
% Scanning FCS:
%[FCSData, Gintervalos, Gmean, cps, cpsIntervalos, tData, binFreq, FCSTraza, tTraza]=...
%    FCS_computecorrelation (photonArrivalTimes, numIntervalos, binLines, tauLagMax, numSecciones, numPuntosSeccion, base, numSubIntervalosError, tipoCorrelacion, ...
%    imgBin, lineSync, indLinesLS, indMaxCadaLinea, sigma2_5);
%
% Point FCS
%[FCSData, Gintervalos, Gmean, cps, cpsIntervalos, tData, FCSTraza, tTraza]=...
%   FCS_computecorrelation (photonArrivalTimes, numIntervalos, binFreq, tauLagMax, numSecciones, numPuntosSeccion, base, numSubIntervalosError, tipoCorrelacion)
%
%   FCSData son los datos temporales en bins temporales de tama�o deltaT=1/binFreq
%   Gintervalos es la curva experimental de correlaci�n de cada intervalo con su tiempo, su traza y su error en la tercera columna
%   FCSmean es el promedio de todas las trazas
%   Gmean es el promedio de todas las curvas de correlaci�n
%   cps son las cuentas por segundo en cada canal
%   tData es el tiempo de cada punto en FCSData
%   FCSTraza es la traza temporal (los fotones de la adquisici�n) agrupados en intervalos de 0.01s
%   tTraza es el tiempo que le corresponde a esos fotones
%
%   photonArrivalTimes es la matriz de tiempos de llegada (arrivalTimes) de B&H
%   binFreq es la frecuencia del binning, en Hz.
%   en el caso de scanning FCS usamos multiploLineas que es el n�mero de
%   l�neas sobre las que se hace binning. En este caso binFreq ser�a scanning frequency/multiploLineas
%   numIntervalos es el n�mero de numIntervalos en los que dividimos la traza temporal. Generalmente son de 10s cada uno
%Par�metros del algoritmo multitau
%   numSecciones es el n�mero de secciones en las que divide la curva de correlaci�n
%   base define la resoluci�n temporal de cada secci�n
%   numPuntosSeccion es el n�mero de puntos en los que se calcula la curva de
%   autocorrelaci�n (en cada secci�n). numPuntosSeccion define, por tanto, la precisi�n del ajuste
%   tauLagMax es el �ltimo punto temporal (tiempo m�ximo) para el que se calcula la correlaci�n (con todos los fotones adquiridos, incluyendo los de momentos posteriores a tauLagMax)
%Par�metros del c�lculo de la incertidumbre
%   numSubIntervalosError es el n�mero de subintercalos para los que calcula la correlaci�n y que utiliza para obtener la incertidumbre (error est�ndar) de cada punto de la curva de correlaci�n
%   Si es cero calcula la incertidumbre para el promedio de las curvas como SEM de las curvas promediadas
%   tipoCorrelacion puede ser 1 o 2 para autocorrelaci�n de los canales 1 o 2, respectivamente, o 3 para ambas
%
%   TAC range y TACgain dependen del reloj SYNC (ya no hay que introducirlos como argumentos)
%
%   binLines es el n�mero de l�neas con las que se hace binning en el caso de scanning FCS
%
%   En el caso de scanning FCS hay que llamar antes a FCS_align, que hace
%   el ROI y despu�s la alineaci�n
%
% Basado en FCS_analisis_BH
% ULS Sep2014
% jri 25Nov14
% jri 22Ene15 - Corrijo el deltaTbin, que faltaba para el point-FCS
% jri 24Abr15 - A�ado las cuentas por segundo y corrijo tData para que sea el t de los FCSintervalos y no el de FCSData
% jri 28Apr15 - A�ado cps por intervalo y cambio FCS promedio para que FCSmean la calcule fuera de FCSpromedio
% jri 4May15 - Calculo los intervalos uno de cada vez para evitar duplicar FCSData
% jri 4May15 - Convierto FCSData en uint8
% jri 21Jul15 - Comentarios
% Unai 18Sept15 - photonArrivalTimes es una struct. Para el caso de scanning FCS da error: la llamada a FCS_binning_FIFO_lines es incorrecta.



photonArrivalTimes=varargin{1};
numIntervalos=varargin{2};
tauLagMax=varargin{4};
numSecciones=varargin{5};
numPuntosSeccion=varargin{6};
base=varargin{7};
numSubIntervalosError=varargin{8};
tipoCorrelacion=varargin{9};


% Es esto necesario?
inicializamatlabpool();

photonArrivalTimes_flp=photonArrivalTimes.frameLinePixel;
photonArrivalTimes_MTmT=photonArrivalTimes.MacroMicroTime;
photonArrivalTimes_c=photonArrivalTimes.channel;
numPixels=numel(unique(photonArrivalTimes_flp(:,3)));
isScanning = logical(numPixels-1); %isScanning es true si se trata de scanning FCS; sino, false
if isScanning
    binLines=varargin{3};
    imgROI=varargin{10};
    lineSync=varargin{11};
    indLinesLS=varargin{12};
    indMaxCadaLinea=varargin{13};
    sigma2_5=varargin{14};  
    
else
    binFreq=varargin{3};
end

numCanales=numel(unique(photonArrivalTimes_c));

if isScanning
    [FCSData, deltaTBin]=FCS_binning_FIFO_lines(imgROI, lineSync, indLinesLS,...
        indMaxCadaLinea, sigma2_5, binLines); % Binning temporal de imgBIN, en m�ltiplos de l�nea de la imagen (binLines)
    binFreq=1/deltaTBin;
    
else %isSCanningFCS==0 -  Esto es FCS puntual
    switch numCanales
        case 1
            t0=photonArrivalTimes_MTmT(1,1)+photonArrivalTimes_MTmT(1,2); %pixel de referencia para binning (1er photon)
        case 2
            t0channels=zeros(numCanales, 1);
            for channel=1:numCanales
                indPrimerPhotonCanal=find(photonArrivalTimes_c==channel-1,1,'first');
                t0channels(channel)=photonArrivalTimes_MTmT(indPrimerPhotonCanal,1)+photonArrivalTimes_MTmT(indPrimerPhotonCanal,2);
            end
            t0=min(t0channels);
    end
    FCSData=FCS_binning_FIFO_pixel1(photonArrivalTimes, binFreq, t0); %Binning temporal de FCSDataALINcorregido con los datos del Macro+micro times
    deltaTBin=1/binFreq;
end %end if isSCanningFCS

%FCS_binning_FIFO_pixel1 devuelve siempre dos canales si los hay
%Si s�lo quiero un canal tengo que deshacerlo. Si tipoCorrelacion=1 � 2
%indica que �se es el canal que quiero. Si es 3, entonces va todo.
if tipoCorrelacion < 3
    FCSData=FCSData(:, tipoCorrelacion);
end


numData=size(FCSData,1);
tData=(1:numData)*deltaTBin;
cps=round(sum(FCSData, 'double')/(numData*deltaTBin));
if max(FCSData(:))==255
    disp('Error: FCSData es uint8, pero cada bin tiene m�s de 255 cuentas')
end
disp (['Maximal number of counts per bin: ' num2str(max(FCSData(:)))])
disp (['Average counts per second: ' num2str(cps)])

%cpsIntervalos=FCS_calculacpsintervalos (FCSData, numIntervalos, binFreq); 
%cps(intervalo, canal) - Primero los intervalos, luego los canales

disp(['Correlating ' num2str(size(FCSData, 2)) ' channels at ' num2str(binFreq/1000) ' kHz'])
[Gintervalos cpsIntervalos]= FCS_matriz (FCSData, numIntervalos, numSubIntervalosError, binFreq, numSecciones, numPuntosSeccion, base, tauLagMax);
usaSubIntervalosError=logical(numSubIntervalosError); %Si numSubIntervalosError>0 entonces usa los subIntervalos para calcular la incertidumbre
Gmean=FCS_promedio(Gintervalos, 1:numIntervalos, usaSubIntervalosError);

%Finalmente calculo unas trazas con un binning de 0.01s para poder representarlas con facilidad
binTimeTraza=0.01;
[FCSTraza, tTraza]=FCS_calculabinstraza(FCSData, numIntervalos, binFreq, binTimeTraza);


if isScanning
    varargout={FCSData, Gintervalos, Gmean, cps, cpsIntervalos, tData, binFreq, FCSTraza, tTraza};
else
    varargout={FCSData, Gintervalos, Gmean, cps, cpsIntervalos, tData, FCSTraza, tTraza};
end

