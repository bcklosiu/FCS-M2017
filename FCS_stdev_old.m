function M= FCS_stdev (FCSData, numSubIntervalosError, deltaT, numSecciones, numPuntos, base, tLagMax)

%  A partir del 24Abr15 aqu� quito las referencias a la g normalizada en FCS_stdev
%
%  M= FCS_stdev (FCSData, numSubIntervalosError, deltaT, numSecciones, numPuntos, base, tLagMax);
%
%   Este programa devuelve la funci�n de correlaci�n G y su desviacion est�ndar SD calculada por el tercer metodo descrito en el articulo de Wohland
%   et al. de 2001. Asimismo tambi�n devuelve los valores del tiempo de la curva de correlaci�n, tdatacorr.
%   La forma de devolver estos datos es como una matriz M que contiene de 3 a 7 columnas con los datos del tiempo, correlaci�n y desviaci�n est�ndar.
%   Para la normalizaci�n no se tiene en cuenta el t�rmino Ginfinito (descrito en Wohl01) ya que nos introduce un error sistem�tico en el c�lculo de la G
%
%   FCSData es un vector columna o una matriz de dos columnas que contiene
%   datos de la traza temporal de uno o dos canales, respectivamente.
%   tdatatraza es un vector columna con los datos temporales correspondientes
%   a FCSData.
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


numData=size(FCSData,1);
numCanales=size(FCSData, 2); %Si hay dos canales calcula tambi�n la correlaci�n cruzada

numColumnasG=3; %Autocorrelaci�n: G=[tdata, G, SD]
if numCanales>1
    numColumnasG=7; %Correlaci�n cruzada: G=[tdata, G_ch1, SD_ch1, G_ch2, SD_ch2, Gcc, SDcc]
end

if numSubIntervalosError<2
    numSubIntervalosError=1;
end

[G tdatacorr]= FCS_multitau  (FCSData, deltaT, numSecciones, numPuntos, base, tLagMax);
numPuntosCorrelacion=size(G, 1);

SD=zeros(numPuntosCorrelacion, numColumnasG);
%C�lculo de SD a partir de la correlaci�n de subintervalos. Si no SD=0 en
%todas las filas.
if numSubIntervalosError
    G_k=zeros(numSubIntervalosError, numPuntosCorrelacion, numColumnasG);
    g_norm= zeros(numPuntosCorrelacion, numColumnasG);
    SD_norm_p= zeros(numPuntosCorrelacion, numColumnasG);
    
    %C�lculo de G(0) y G(inf) como promedio de los primeros y �ltimos 5 puntos respectimamente para la normalizaci�n de G y su error
    %Gt_inf=sum(G(end-4:end,:))/5;
    %Gt_0=sum(G(1:5,:))/5;
    
    %Ahora divido cada intervalo en numSubIntervalosError trozos y calculo las subcorrelaciones 
    intervalo=floor(numData./numSubIntervalosError);
    %G_inf=zeros(size(G,3), numSubIntervalosError,1);
    %G_0=zeros(size(G,3), numSubIntervalosError);
    for k=1:numSubIntervalosError
        FCS_intervalos=FCSData((k-1)*intervalo+1:k*intervalo,:);
        G_k(k,:,:)= FCS_multitau (FCS_intervalos, deltaT, numSecciones, numPuntos, base, tLagMax);
        %G_inf(:,k)=squeeze(sum(G_k(k, end-4:end, :))/5);
        %G_0(:,k)=squeeze(sum(G_k(k, 1:5, :))/5);
        %G_0(:,k)=Gt_0;
    end
     
    %Y calculo la media de las correlaciones
    for m=1:numPuntosCorrelacion
        %g_norm es la media (antiguamente normalizada)
        g_norm(m,:)= sum(squeeze(G_k(:,m,:)))/numSubIntervalosError; %Este es el promedio. Se llama norm porque antes se normalizaba
        %g_norm(m,:)= sum(squeeze(G_k(:,m,:))./G_0)/numSubIntervalosError;  %Prescindimos de incluir Ginfinito porque en nuestro modelo de ajuste suponemos que es igual a cero
        %g_norm(m,:)= sum((squeeze(G_k(:,m,:))-G_inf)./(G_0-G_inf))/numSubIntervalosError;
        for ll=1:numColumnasG
            %Calculo la desviaci�n est�ndar
            %SD_norm_p(m,ll)=sqrt(sum(((squeeze(G_k(1:numSubIntervalosError,m,ll))-G_inf(:,ll))./(G_0(:,ll)-G_inf(:,ll))-g_norm(m,ll)).^2)/(numSubIntervalosError-1));
            %SD_norm_p(m,ll)=sqrt(sum((squeeze(G_k(1:numSubIntervalosError, m,ll))./G_0-g_norm(m,ll)).^2)/(numSubIntervalosError-1));
            SD_norm_p(m,ll)=sqrt(sum((squeeze(G_k(1:numSubIntervalosError, m,ll))-g_norm(m,ll)).^2)/(numSubIntervalosError-1)); %SD en cada punto
        end
        
    end
    SD_norm=SD_norm_p/sqrt(numSubIntervalosError); %Convierte la desviaci�n est�ndar en error est�ndar de la media de las curvas de cada subIntervalo
    
    for m=1:numColumnasG
        %SD(:,ll)=SD_norm(:,ll)*(Gt_0(ll)-Gt_inf(ll));
        %SD(:, m)=SD_norm(:, m)*Gt_0;
        SD(:, m)=SD_norm(:, m);
    end
end

if numCanales>1 %Cuando es correlaci�n cruzada o todas
    M=[tdatacorr G(:,1) SD(:,1) G(:,2) SD(:,2) G(:,3) SD(:,3)];
else %cuando es una autocorrelaci�n
    M=[tdatacorr G(:,1) SD(:,1)];
end

