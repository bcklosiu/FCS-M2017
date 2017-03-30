function Gmean=FCS_promedio(Gtotal, combinacion, usaSubIntervalosError)

% Gmean=FCS_promedio(Gtotal, combinacion, usaSubIntervalosError);
%
% Devuelve el promedio de las trazas temporales y de autocorrelaci�n indicadas en combinacion
%   Gtotal es una matriz que contiene las trazas de autocorrelaci�n y correlaci�n cruzada de los intervalos.
%   Gtotal es una matriz numpuntoscorrelacionx7xnumintervalos
%       Gtotal (:,1, intervalo) contiene tdatacorr, que es la informaci�n temporal de la correlaci�n
%       Gtotal (:,2, intervalo) es la autocorrelaci�n del canal 1
%       Gtotal (:,3, intervalo) es el error de la autocorrelaci�n del canal 1
%       Gtotal (:,4, intervalo) es la autocorrelaci�n del canal 2
%       Gtotal (:,5, intervalo) es el error de la autocorrelaci�n del canal 2
%       Gtotal (:,6, intervalo) es la correlaci�n cruzada
%       Gtotal (:,7, intervalo) es el error de la correlaci�n cruzada
%   FCSintervalo es una matriz que contiene las trazas temporales de los intervalos de xx s (en general 10 s). FCSintervalo es una matriz numpuntostemporalesx2xnumintervalos - el 2 es porque hay dos canales
%   combinacion es un vector que contiene elos �ndices de los intervalos que nos interesa promediar
%   deltat=1/sampfreq
%
%   Si usaSubIntervalosError=true, el error est�ndar de cada punto es el SD de las curvas que se promedian entre la ra�z del n�mero de curvas
%   Si usaSubIntervalosError=false, el error est�ndar de cada punto calculado a partir de la suma cudr�tica de la incertidumbre de los subintervalos
%
% Gmean es la media de las correlaciones y la suma en cuadratura de los errores de las correlaciones de los intervalos
% Gmean (:,1) es la informaci�n temporal de la correlacion (tdata)
% Gmean (:,2) es la media de las autocorrelaciones del canal 1
% Gmean (:,3) es la incertidumbre de la media de las autocorrelaciones del canal 1
% etc.
%
%
% jri & GdlH (12nov10)
% jri - 2Feb15 Quito deltat porque no lo usamos. Antes era: [FCSmean Gmean]=FCS_promedio(Gtotal, FCSintervalo, combinacion, deltat, tipocorrelacion);
% jri - 20abr15 Cambio el tipocorrelacion
% jri - 24Abr15 C�lculo del error est�ndar de la media a partir de las curvas con las que se hace el promedio
% jri - 26Apr15 Hago la funci�n del c�lculo del error una funci�n externa
% jri - 28Apr15 Ya no devuelve FCSmean. Ahora hay que hacerlo fuera 


indices=false(1, size (Gtotal,3));
indices(combinacion)=true;
numPuntosCorrelacion=size(Gtotal, 1);
Gmean=zeros(numPuntosCorrelacion, size(Gtotal, 2));
%FCSmean=mean(FCSintervalo (:, : , indices),3);
numCurvasPromediadas=numel(combinacion);

Gmean(:,1)=Gtotal(:,1,1);
Gmean(:,2)=mean (Gtotal(:,2, indices),3);
if logical(usaSubIntervalosError) %Usa el SEM de los subintervalos para calcular la SEM de la traza promedio
    Gmean(:,3)=sqrt (sum (Gtotal(:,3, indices).^2,3))/numel(combinacion);   %Suma cuadr�tica de los errores
else %Si no usa cada uno de los intervalos
    Gmean(:,3)=FCS_stderrG(Gmean(:,2), Gtotal(:,2, indices));
end
if size(Gmean,2)==7
    Gmean(:,4)=mean (Gtotal(:,4, indices),3);
    Gmean(:,6)=mean (Gtotal(:,6, indices),3);
    if usaSubIntervalosError
        Gmean(:,5)=sqrt (sum (Gtotal(:,5, indices).^2,3))/numCurvasPromediadas;   %Suma cuadr�tica de los errores
        Gmean(:,7)=sqrt (sum (Gtotal(:,7, indices).^2,3))/numCurvasPromediadas;
    elseif numCurvasPromediadas>1 
        Gmean(:,5)=FCS_stderrG(Gmean(:,4), Gtotal(:,4, indices));
        Gmean(:,7)=FCS_stderrG(Gmean(:,6), Gtotal(:,6, indices));
    end
end

