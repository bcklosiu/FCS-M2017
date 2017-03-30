function M= FCS_stdev (FCSData, numSubIntervalosError, deltaT, numSecciones, numPuntos, base, tLagMax)

%
%  M= FCS_stdev (FCSData, numSubIntervalosError, deltaT, numSecciones, numPuntos, base, tLagMax);
%
%   Este programa devuelve la funci�n de correlaci�n G y la incertidumbre (error est�ndar) en cada punto de G (calculada por el tercer metodo descrito en el articulo de Wohland
%   et al. de 2001. Asimismo tambi�n devuelve los valores de tiempo (tau) en los que se calcula de la curva de correlaci�n.
%   La forma de devolver estos datos es como una matriz M que contiene de 3 a 7 columnas con los datos del tiempo, correlaci�n y error est�ndar de la media de los subintervalos.
%   Hay una M por cada intervalo, que se construye en FCS_matriz
%   Asumimos G(infinito)=0
%
%   FCSData es un vector columna o una matriz de dos columnas que contiene datos de la traza temporal de uno o dos canales, respectivamente.
%   numSubIntervalosError es el numero de intervalos en que queremos dividir la traza temporal para calcular la desviaci�n est�ndar.
%   deltaT=1/sampfreq
%   numSecciones es el numero de secciones (Par�metros Multi-tau)
%   numPuntos es el numero de puntos por seccion (Par�metros Multi-tau)
%   base es la base que elegiremos para calcular la correlacion (Par�metros Multi-tau)
%   tLagMax es el �ltimo punto temporal con el que se hace correlaci�n, en s
%
%   Si FCSData contiene datos de dos canales calcula tambi�n la correlaci�n cruzada
%
% jri & GdlH (12nov10)
% Modificado el 26abr11 para hacer G_0 un escalar en lugar de un vector y evitar problemas al indicar tipoCorrelacion='todas'
% jri 20abr15 - Quito tipoCorrelacion y hago la correlaci�n cruzada cuando hay dos canales en FCSData
% jri 24abr15 - No se calcula el error a partir de los subintervalos si numSubIntervalosError son 0 o 1
% jri 26Apr15 - Reordeno la forma de calcular la media


numData=size(FCSData,1);
numCanales=size(FCSData, 2); %Si hay dos canales calcula tambi�n la correlaci�n cruzada
%Si hay dos canales hace la correlaci�n cruzada autom�ticamente
if numCanales>1
    numCanales=3; %Dos canales m�s la correlaci�n cruzada
end

[G tdatacorr]= FCS_multitau (FCSData, deltaT, numSecciones, numPuntos, base, tLagMax);
numPuntosCorrelacion=size(G, 1);

SE=zeros(numPuntosCorrelacion, numCanales);
%C�lculo de SD a partir de la correlaci�n de subintervalos. Si no SD=0 en todas las filas.
if numSubIntervalosError
    G_k=zeros(numPuntosCorrelacion, numCanales, numSubIntervalosError);
    gk_mean= zeros(numPuntosCorrelacion, numCanales); %La G de cada subIntervaloError promediada
    %Ahora divido cada intervalo en numSubIntervalosError trozos y calculo las subcorrelaciones
    intervalo=floor(numData./numSubIntervalosError);
    for k=1:numSubIntervalosError
        FCS_intervalo=FCSData((k-1)*intervalo+1:k*intervalo, :);
        G_k(:, :, k)= FCS_multitau (FCS_intervalo, deltaT, numSecciones, numPuntos, base, tLagMax);
    end
    %Y calculo la media de las correlaciones
    for canal=1:numCanales
        gk_mean(: ,canal)= mean(G_k(:, canal, :), 3); %Este es el promedio de los subIntervalosError
        SE(:, canal)=FCS_stderrG(gk_mean(:, canal), G_k(:, canal, :)); 
    end
end

if numCanales>1 %Cuando es correlaci�n cruzada o todas
    M=[tdatacorr G(:,1) SE(:,1) G(:,2) SE(:,2) G(:,3) SE(:,3)];
else %cuando es una autocorrelaci�n
    M=[tdatacorr G(:,1) SE(:,1)];
end

