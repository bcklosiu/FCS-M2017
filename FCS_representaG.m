function varargout=FCS_representaG (Gdata, tipoCorrelacion, hfig)

%
% [hCorr hfig]=FCS_representaG (Gdata, tipoCorrelacion, hfig)
% Representa la funci�n de correlaci�n
%   Gdata es una matriz que contiene los datos de la correlaci�n (matrizFCS): la 1� columna es el tiempo, la 2� la ACF del canal 1, la 3� su error, etc.
%   tipoCorrelacion es 3 para correlac�n cruzada o 1 � 2 para autocorrelaci�n
%   hfig es el handle a la figura en la que lo representar�. Si no se indica crea una figura nueva
%   Si no hay argumentos de salida no devuelve nada
%
%  hCorr es el handle a los ejes de la gr�fica de la traza de correlaci�n 
%  hfig es el handle a la figura
%
% jri 21Jul15 - Cambio el nombre a FCS_representaG

tdata_k=Gdata(:,1)*1000; %Para poner la escala en ms
G(:,1)=Gdata(:,2);
SD (:,1)=Gdata(:,3);
if size(Gdata, 2)>3
    G(:,2)=Gdata(:,4);
    SD (:,2)=Gdata(:,5);
    G(:,3)=Gdata(:,6);
    SD (:,3)=Gdata(:,7);
end


verde =[1 131 95]/255;
rojo = [197 22 56]/255;
azul = [0 102 204]/255;
negro = [50 50 50]/255;

if nargin<3 %No hay handle a la figura, por tanto crea una nueva
    hfig=figure;
else
    clf (hfig)
    figure (hfig) %Si est� oculta la muestra y lleva el foco
end
set (0, 'CurrentFigure', hfig);
hCorr=axes;
%[FCSTraza, tTraza, cpscanal]=FCS_calculabinstraza(FCSData, deltaT, 0.01);
if tipoCorrelacion==3 % cuando es correlaci�n cruzada
    set(hfig, 'CurrentAxes', hCorr)
    hold on
    hcorr1=errorbar (tdata_k, G(:,1), SD(:,1), 'o-', 'Color', verde, 'Linewidth', 1.5);
    hcorr2=errorbar (tdata_k, G(:,2), SD(:,2), 'o-', 'Color', rojo, 'Linewidth', 1.5);
    hcorr12=errorbar (tdata_k, G(:,3), SD(:,3), 'o-', 'Color', azul, 'Linewidth', 1.5);
    hLegend=legend ('Ch1', 'Ch2', 'Cross');
    hold off
else
    canal=1;
    set(hfig, 'CurrentAxes', hCorr)
    hCorrPlot=errorbar (tdata_k, G(:, canal), SD(:, canal), 'o-', 'Color', verde, 'Linewidth', 1.5);
    hLegend=legend (['Ch' num2str(canal)]);
end


rect=get (hfig, 'OuterPosition');
screenSize=get(0, 'Screensize');
%set (hfig, 'OuterPosition', [rect(1) 50 screenSize(4)-50 (screenSize(4)-50])
set (hCorr, 'Box', 'on', 'XGrid', 'on', 'YGrid', 'on')
v=axis (hCorr);
axis (hCorr, [tdata_k(1)-0.25*tdata_k(1) tdata_k(end)+0.5*tdata_k(end) v(3) v(4)])

set (hfig, 'Color', [1 1 1])
set (hCorr, 'Color', 'none', 'FontName', 'Calibri', 'FontSize', 11)

set (hCorr, 'XScale', 'log')
hLabel(1)=xlabel (hCorr, '\tau (ms)');
hLabel(2)=ylabel (hCorr, 'G (\tau)');
set (hLabel, 'FontName', 'Calibri', 'FontSize', 11)
set (hLegend, 'FontName', 'Calibri', 'FontSize', 11)


if nargout>0
    varargout(1)={hCorr};
end
if nargout>1
    varargout(2)={hfig};
end




