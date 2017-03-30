function [G tdata]=FCS_autocorr(FCSdata, deltat, vectorindices)
% 
% [G tdata]=FCS_autocorr(FCSdata, deltat, vectorindices);
% Calcula la autocorrelaci�n siguiendo el art�culo de WOHL01
%
%   FCSdata tiene la traza temporal. FCSdata tiene que ser un vector columna: s�lo tiene datos de un canal de la traza temporal
%   deltat es el inverso de la frecuencia de muestreo, es decir, la resoluci�n del canal temporal
%   vectorindices es un vector que contiene los puntos en los que queremos que se calcule G
%
%
% S�lo hace el n�mero de numpuntos que se le pida, aunque calcula la correlaci�n con todos ellos
%
% Es equivalente a FCS_autocorr_Matlab
% GdlH, jri 12jul2010

%numdata=numel(FCSdata);
%Gtemp=zeros (numdata, 1, 'double');
%Gtempcuadrados=zeros (numdata, 1, 'double');
numpuntos=numel(vectorindices);
G=zeros(numpuntos, 1,'double');
%sigmaG=zeros(numpuntos,1,'double');
tdata=zeros (numpuntos, 1); 

if not(isfloat(FCSdata))
    FCSdata=double(FCSdata);
end
vectorindices=vectorindices(:)';
C_FCS_autocorr(G, tdata, FCSdata, deltat, vectorindices);
G=G-1; %Estamos calculando la funci�n de autocovarianza (que no es estrictamente la misma que la autocorrelaci�n)

