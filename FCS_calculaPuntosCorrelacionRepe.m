function [tdata matrizIndices indicesNOrepe numPuntosNOrepe]=FCS_calculaPuntosCorrelacionRepe (numSecciones, base, numPuntosSeccion, deltaT, tLagMax)

% [tdata matrizIndices indicesNOrepe numPuntosNOrepe]=FCS_calculaPuntosCorrelacionRepe(numSecciones, base, numPuntosSeccion, deltaT, tLagMax);
% 
% Los puntos temporales de tdata no est�n ordenados para poder trabajar con ellos en FCS_multitau
%
% Devuelve una matriz de �ndices no repetidos para luego calcular la correlaci�n s�lo en esos puntos
% jri 22Abr15

numSecciones=numSecciones+1;

tdata=zeros (numPuntosSeccion, numSecciones);
matrizIndices=zeros (numPuntosSeccion, numSecciones);
indicesNOrepe=false(size(tdata));

%Esto para las primeras numSecciones-1
vectorIndices=1:numPuntosSeccion;
for seccion=1:numSecciones-1 %Hace una correlaci�n por cada secci�n
    multiBase=base^(seccion-1);
    tdata(:, seccion)=calculatdata (vectorIndices, multiBase, deltaT);
    matrizIndices(:, seccion)=vectorIndices;
end

%�ltima secci�n:
%Calcula los puntos de la �ltima secci�n expandiendo logar�tmicamente la base de la secci�n anterior,
%puesto que la �ltima secci�n la hemos a�adido para expandir el final de la correlaci�n logar�tmicamente
%multiBase tiene el mismo valor que la �ltima secci�n del bucle anterior.
numPuntos_ultimaSeccion=floor(tLagMax/(deltaT*multiBase)); %Esto es el numero de puntos que habria que calcular de la ultima seccion para correlacionar hasta tLagMax
vectorIndices=round(logspace (0, log10(numPuntos_ultimaSeccion), numPuntosSeccion));  % logspace genera un vector FILA
matrizIndices(:, seccion+1)=vectorIndices;
tdata(:, numSecciones)=calculatdata (vectorIndices, multiBase, deltaT);

%Ahora localizo los repetidos en tdata
[~, m]=unique(tdata(:), 'last');
indicesNOrepe(m)=true;

numPuntosNOrepe=numel(find(indicesNOrepe));


function tdata=calculatdata (vectorIndices, multiBase, deltaT)
%Calcula tdata en cada secci�n para ver qu� puntos se repiten en el c�lculo de la correlaci�n seg�n la secci�n

numPuntos=numel(vectorIndices);
tdata=zeros(numPuntos, 1);
for puntosCorrelacion=1:numPuntos
    tdata(puntosCorrelacion)=vectorIndices(puntosCorrelacion)*multiBase*deltaT;
end
