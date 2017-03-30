function [G tdata]= FCS_multitau (FCSData, deltaT, numSecciones, numPuntosSeccion, base, tLagMax)
%
% [G  tdata]= FCS_multitau (FCSData, deltaT, numSecciones, numPuntos, base, tLagMax, tipoCorrelacion);
% Algorimo multitau para el c�lculo de la funci�n de autocorrelaci�n/correlacion cruzada

% Sigue el algoritmo de Wohland_2001
%
%   FCSData contiene la traza temporal. FCSData puede ser un vector columna o una matriz de dos columnas, segun se quiera calcular la auto- o la cross-correlacion, respectivamente.
%   deltaT es el inverso de la frecuencia de muestreo,
%   numSecciones es el n�mero de secciones de la funci�n de autocorrelaci�n
%   numPuntos es el n�mero de puntos por secci�n 
%   base define la resoluci�n temporal de cada secci�n: res_temporal=deltaT*(base^seccion)
%   tLagMax es el �ltimo punto temporal con el que se hace correlaci�n, en s
%
% 26-10-2010
% 27abr11 - Modificado para que llame a los programas que calculan la
% correlacion en C++
%
% jri - 16May14 Ordenado un poco
% jri - 20Apr15 Quito los puntos que repite al calcular la correlaci�n
% jri - 20Apr15 Quito tipoCorrelacio. Si FCSData tiene dos canales hace tambi�n la correlaci�n cruzada

if not(isfloat(FCSData))
    FCSData=double(FCSData);
end

numData=size(FCSData, 1);

%Calcula todos los puntos de cada secci�n en los que har� la correlaci�n
%para evitar los puntos repetidos por secci�n
[tdataTodos matrizIndices indicesNOrepe numPuntosCorrFinal]=FCS_calculaPuntosCorrelacionRepe (numSecciones, base, numPuntosSeccion, deltaT, tLagMax);
%Hace la correlaci�n

numCanales=size(FCSData, 2);
if numCanales>1 %Si hay dos canales hace la correlaci�n cruzada autom�ticamente
    numCanales=3; %Dos canales m�s la correlaci�n cruzada
end
    
G=zeros(numPuntosCorrFinal, numCanales, 'double');
tdata_corr=zeros(numPuntosCorrFinal, 1);

tdata=tdataTodos(indicesNOrepe);

numPuntosCorrAcumula=0;

%Esto para las primeras numSecciones (menos la logar�tmica)
for seccion=1:numSecciones %Hace una correlaci�n por cada secci�n
    multiBase=base^(seccion-1);
    vectorIndices=matrizIndices(indicesNOrepe(:, seccion), seccion);
    numPuntosCorrSeccion=numel(vectorIndices); %N�mero de puntos en la secci�n en los que se calcular� la correlaci�n
    numDataSeccion=floor(numData/multiBase); %N�mero de datos en cada secci�n que se usar�n para calcular la correlacion
    if numDataSeccion <= numPuntosSeccion
        error('No hay puntos suficientes para calcular la correlaci�n: %d', numDataSeccion)
    end
    if numCanales==1 %Autocorrelaci�n
        FCSDataSeccion=zeros (numDataSeccion, 1, 'double');
        C_FCS_binning1(FCSDataSeccion, FCSData, multiBase);
        %{
            for n=1:numDataSeccion     %Hace el binning para cada secci�n seg�n la base
                FCSDataSeccion(n)=sum(FCSData(((n-1)*multiBase+1:n*multiBase))); % Cuando es una autocorrelaci�n
            end
        %}
        [G(1+numPuntosCorrAcumula:numPuntosCorrAcumula+numPuntosCorrSeccion) tdata_corr(1+numPuntosCorrAcumula:numPuntosCorrAcumula+numPuntosCorrSeccion)]=...
            FCS_autocorr_Cpp (FCSDataSeccion, multiBase*deltaT, vectorIndices);
    else %Correlaci�n cruzada
        FCSDataSeccion=zeros (numDataSeccion, 2, 'double');
        C_FCS_binning1(FCSDataSeccion, FCSData, multiBase);
        %{
            for n=1:numDataSeccion     %Hace el binning para cada secci�n seg�n la base
                FCSDataSeccion(n, 1)=sum(FCSData(((n-1)*multiBase+1:n*multiBase), 1));
                FCSDataSeccion(n, 2)=sum(FCSData(((n-1)*multiBase+1:n*multiBase), 2));
            end
        %}
        [G(1+numPuntosCorrAcumula:numPuntosCorrAcumula+numPuntosCorrSeccion, 1) tdata_corr(1+numPuntosCorrAcumula:numPuntosCorrAcumula+numPuntosCorrSeccion)]=...
            FCS_autocorr_Cpp (FCSDataSeccion(:,1), multiBase*deltaT, vectorIndices);
        [G(1+numPuntosCorrAcumula:numPuntosCorrAcumula+numPuntosCorrSeccion, 2) tdata_corr(1+numPuntosCorrAcumula:numPuntosCorrAcumula+numPuntosCorrSeccion)]=...
            FCS_autocorr_Cpp (FCSDataSeccion(:,2), multiBase*deltaT, vectorIndices);
        [G(1+numPuntosCorrAcumula:numPuntosCorrAcumula+numPuntosCorrSeccion, 3) tdata_corr(1+numPuntosCorrAcumula:numPuntosCorrAcumula+numPuntosCorrSeccion)]=...
            FCCS_crosscorr_Cpp (FCSDataSeccion, multiBase*deltaT, vectorIndices);
        
    end
    %Control:
    %tdata_corr(1+numPuntosCorrAcumula:numPuntosCorrAcumula+numPuntosCorrSeccion)-tdataTodos(indicesNOrepe(:,seccion), seccion) tiene que ser 0
    numPuntosCorrAcumula=numPuntosCorrAcumula+numPuntosCorrSeccion;
    
end

%Calcula la correlacion puntos de la �ltima secci�n (logar�tmica), que comparte binning, datos y multiBase con la anterior
seccion=seccion+1;
vectorIndices=matrizIndices(indicesNOrepe(:, seccion), seccion);
numPuntosCorrSeccion=numel(vectorIndices);
if numCanales==1
    [G(1+numPuntosCorrAcumula:numPuntosCorrAcumula+numPuntosCorrSeccion) tdata_corr(1+numPuntosCorrAcumula:numPuntosCorrAcumula+numPuntosCorrSeccion)]=...
        FCS_autocorr_Cpp(FCSDataSeccion, multiBase*deltaT, vectorIndices);
else
    [G(1+numPuntosCorrAcumula:numPuntosCorrAcumula+numPuntosCorrSeccion, 1) tdata_corr(1+numPuntosCorrAcumula:numPuntosCorrAcumula+numPuntosCorrSeccion)]=...
        FCS_autocorr_Cpp (FCSDataSeccion(:,1), multiBase*deltaT, vectorIndices);
    [G(1+numPuntosCorrAcumula:numPuntosCorrAcumula+numPuntosCorrSeccion, 2) tdata_corr(1+numPuntosCorrAcumula:numPuntosCorrAcumula+numPuntosCorrSeccion)]=...
        FCS_autocorr_Cpp (FCSDataSeccion(:,2), multiBase*deltaT, vectorIndices);
    [G(1+numPuntosCorrAcumula:numPuntosCorrAcumula+numPuntosCorrSeccion, 3) tdata_corr(1+numPuntosCorrAcumula:numPuntosCorrAcumula+numPuntosCorrSeccion)]=...
        FCCS_crosscorr_Cpp (FCSDataSeccion, multiBase*deltaT, vectorIndices);
end

%Control:
%tdata_corr(1+numPuntosCorrAcumula:numPuntosCorrAcumula+numPuntosCorrSeccion)-tdataTodos(indicesNOrepe(:,seccion), seccion) tiene que ser 0

numPuntosCorrAcumula=numPuntosCorrAcumula+numPuntosCorrSeccion;

%Finalmente ordena
[tdata, IX]=sort (tdata); %Finalmente ordena
G=G(IX, :);


