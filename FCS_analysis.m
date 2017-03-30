function varargout=FCS_analysis (varargin)

%
% Scanning FCS:
%[FCSintervalos, Gintervalos, FCSmean, Gmean, tData, imgROI, imgALIN, tPromedioLS]=...
%    FCS_analysis (photonArrivalTimes, numIntervalos, binFreq, tauLagMax, numSecciones, numPuntosSeccion, base, numSubIntervalosError, tipoCorrelacion,... 
%    imgDecode, lineSync, pixelSync, indLinesLS, indMaxCadaLinea, sigma2_5); 
% 
%
% Point FCS
%[FCSintervalos, Gintervalos, FCSmean, Gmean]=...
%   FCS_analysis (photonArrivalTimes, numIntervalos, binFreq, tauLagMax, numSecciones, numPuntosSeccion, base, numSubIntervalosError, tipoCorrelacion);
%
%
%   FCSintervalos es FCSData de cada intervalo (los datos de FCS en bins temporales de tama�o deltaT=1/binFreq)
%   Gintervalos es la curva experimental de correlaci�n de cada intervalo con su tiempo, su traza y su error en la tercera columna
%   FCSmean es el promedio de todas las trazas
%   Gmean es el promedio de todas las curvas de correlaci�n
%
%   photonArrivalTimes es la matriz de tiempos de llegada (arrivalTimes) de B&H
%   binFreq es la frecuencia del binning, en Hz
%   numIntervalos es el n�mero de numIntervalos en los que dividimos la traza temporal. Generalmente son de 10s cada uno
%Par�metros del algoritmo multitau
%   numSecciones es el n�mero de secciones en las que divide la curva de correlaci�n
%   base define la resoluci�n temporal de cada secci�n
%   numPuntosSeccion es el n�mero de puntos en los que se calcula la curva de
%   autocorrelaci�n (en cada secci�n). numPuntosSeccion define, por tanto, la precisi�n del ajuste
%   tauLagMax es el �ltimo punto temporal (tiempo m�ximo) para el que se calcula la correlaci�n (con todos los fotones adquiridos, incluyendo los de momentos posteriores a tauLagMax)
%Par�metros del c�lculo de la incertidumbre
%   numSubIntervalosError es el n�mero de subintercalos para los que calcula la correlaci�n y que utiliza para obtener la incertidumbre (error est�ndar) de cada punto de la curva de correlaci�n
%
%   tipoCorrelacion puede ser auto, cross o todas 
%
%   TAC range y TACgain dependen del reloj SYNC (ya o hay que introducirlos como argumentos)
%
%
%   En el caso de scanning FCS hay que llamar antes a FCS_align, que hace
%   el ROI y despu�s la alineaci�n
%
% Basado en FCS_analisis_BH
% ULS Sep2014
% jri 25Nov14
% Unai 10Sep15: Cambio de nombre de funci�n (no coincid�a con el archivo). Los argumentos en la llamada a FCS_matriz estaban desordenados.
% Actualmente esta funci�n no se usa. Se ha sustituido por FCS_computecorrelation.


photonArrivalTimes=varargin{1};
numIntervalos=varargin{2};
binFreq=varargin{3};
tauLagMax=varargin{4};
numSecciones=varargin{5};
numPuntosSeccion=varargin{6};
base=varargin{7};
numSubIntervalosError=varargin{8};
tipoCorrelacion=varargin{9};

% Es esto necesario? No parece que lo est� usando
isOpen=matlabpool ('size')>0;
if not(isOpen) %Inicializa matlabpool con el m�ximo numero de cores
    numWorkers=feature('NumCores'); %N�mero de workers activos. 
    if numWorkers>=8
        numWorkers=8; %Para Matlab 2010b, 8 cores m�ximo.
    end
    disp (['Inicializando matlabpool con ' num2str(numWorkers) ' cores'])
matlabpool ('open', numWorkers) 
end

photonArrivalTimes_flp=photonArrivalTimes.frameLinePixel;
photonArrivalTimes_MTmT=photonArrivalTimes.MacroMicroTime;
photonArrivalTimes_c=photonArrivalTimes.channel;
numPixels=numel(unique(photonArrivalTimes_flp(:,3)));
numCanales=numel(unique(photonArrivalTimes_c));
deltaTBin=1/binFreq;
isScanning = logical(numPixels-1); %isScanning es true si se trata de scanning FCS; sino, false
if isScanning
    imgDecode=varargin{10};
    lineSync=varargin{11};
    pixelSync=varargin{12};
    indLinesLS=varargin{13};
    indMaxCadaLinea=varargin{14};
    sigma2_5=varargin{15};    
    
    multiploLineas=2; %Es el binning de 2 l�neas; equivalente a binFreq. Tiene que salir de binFreq
    lineSync_fl=lineSync.frameLine;
    pixelSync_flp=pixelSync.frameLinePixel;
    lineSync_fl_ROI=lineSync_fl(indLinesLS,2);
    roiFilaDesde=min(lineSync_fl_ROI) %L�mite inferior de las filas de la ROI
    roiFilaHasta=max(lineSync_fl_ROI) %L�mite superior de las filas de la ROI
    pixelSync_flp_ROI=pixelSync_flp(and(pixelSync_flp(:,2)>=roiFilaDesde, pixelSync_flp(:,2)<=roiFilaHasta),3);
    roiColDesde=min(pixelSync_flp_ROI) %L�mite inferior de las columnas de la ROI
    roiColHasta=max(pixelSync_flp_ROI) %L�mite superior de las columnas de la ROI
    imgROIcolumnas=imgDecode(:,roiColDesde:roiColHasta);
    [FCSData, deltaTBin]=FCS_binning_FIFO_lines(imgROIcolumnas, lineSync, indLinesLS, indMaxCadaLinea, sigma2_5, multiploLineas); % Binning temporal de imgBIN, en m�ltiplos de l�nea de la imagen
    
else %isSCanningFCS==0 -  Esto es FCS puntual
    imgROI=0;
    imgALIN=0;
    
    switch numCanales
        case 1
            t0=photonArrivalTimes_MTmT(1,1)+photonArrivalTimes_MTmt(1,2); %pixel de referencia para binning (1er photon)
        case 2 
            t0channels=zeros(numCanales,1);
            for channel=1:numCanales
                indPrimerPhotonCanal=find(photonArrivalTimes_c==channel-1,1,'first');
                t0channels(channel)=photonArrivalTimes_MTmT(indPrimerPhotonCanal,1)+photonArrivalTimes_MTmT(indPrimerPhotonCanal,2);
            end
            t0=min(t0channels);
    end
    FCSData=FCS_binning_FIFO_pixel1(photonArrivalTimes, binFreq, t0); %Binning temporal de FCSDataALINcorregido con los datos del Macro+micro times
end %end if isSCanningFCS

FCSintervalos= FCS_troceador(FCSData, numIntervalos);
Gintervalos= FCS_matriz (FCSintervalos, numIntervalos, numSubIntervalosError, binFreq, numSecciones, numPuntosSeccion, base, tauLagMax);
[FCSmean Gmean]=FCS_promedio(Gintervalos, FCSintervalos, 1:numIntervalos, deltaTBin, tipoCorrelacion);
tData=(1:size(FCSintervalos, 1))/binFreq;

if isScanning
    varargout={FCSintervalos, Gintervalos, FCSmean, Gmean, tData, imgROI, imgALIN};
else
    varargout={FCSintervalos, Gintervalos, FCSmean, Gmean, tData};
end

