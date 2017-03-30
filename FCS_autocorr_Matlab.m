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
% GdlH, jri 12jul2010


%FCSdata=double(FCSdata);
numdata=numel(FCSdata);
Gtemp=zeros (numdata, 1, 'double');
Gtempcuadrados=zeros (numdata, 1, 'double');
numpuntos=numel(vectorindices);
G=zeros(numpuntos,1,'double');
%sigmaG=zeros(numpuntos,1,'double');
tdata=zeros (numpuntos, 1); 
for n=1:numpuntos
   m=vectorindices(n)
        Gtemp(1:numdata-m)=FCSdata(1:numdata-m).*FCSdata(1+m:numdata);
        %size(Gtemp)
        sumGtemp=sum(Gtemp(1:numdata-m));
        Mdir=sum(FCSdata(1:numdata-m));
        Mdel=sum(FCSdata(m:numdata));
        %    disp ('aqu�')
        %    disp(numdata)
        Mmenosm=numdata-m;
        %    disp(k)
        %    disp (m)
        %size (Mmenosm*sumGtemp/(Mdel*Mdir))
        G(n)=Mmenosm*sumGtemp/(Mdel*Mdir);
        
        %------------Normalizacion asim�trica----------------------
        %    Gtemp(1:numdata-m)=FCSdata(1:numdata-m).*FCSdata(1+m:numdata);
        %    sumGtemp=sum(Gtemp(1:numdata-m));
        %    Mmenosm=numdata-m;
        %    denom_asim=((sum(FCSdata(1:numdata)))./numdata).^2;
        %    G(m)=(sumGtemp./Mmenosm)./denom_asim;
        %------------Normalizacion asimetrica----------------------
        
        %Gtempcuadrados(1:numdata-m)=Gtemp(1:numdata-m).^2;
        %sumGtempcuadrados=sum(Gtempcuadrados(1:numdata-m));  %Esto era para el
        %calcular el sigmaIT
        %sigmaG(m)=Mmenosm*sqrt(sumGtempcuadrados-(sumGtemp^2)/Mmenosm)/(Mdel*Mdir);
        tdata(n)=m*deltat;
   
end
G=G-1; %Estamos calculando la funci�n de autocovarianza (que no es estrictamente la misma que la autocorrelaci�n)

% Esta es la expresi�n para la G con normalizaci�n est�ndar
%    G(m, 1)=(numdata-m)*sum(Gtemp(1:numdata-m))/(sum(FCSdata(m:numdata,1))*sum(FCSdata(1:numdata-m,1))); 


