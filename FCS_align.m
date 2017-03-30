function [imgROI, indLinesLS, indLinesPS,indMaxCadaLinea, sigma2_5, timeInterval]=FCS_align(photonArrivalTimes, imgDecode, lineSync, pixelSync)
 
%[imgROI, indLinesLS, indMaxCadaLinea, sigma2_5, timeInterval]=FCS_align(photonArrivalTimes, imgDecode, lineSync, pixelSync)
%
%Escoge la ROI y la alinea a uno o dos canales
%
%
% jri 3Dic14 (de FCS_analisis_BH de Unai)
% jri 27Mar15 - Corrijo para cuando tenemos dos canales que analiza por separado
% jri 22Abr15 - Error peque�o
% Unai 3Sept15 - photonArrivalTimes es una struct. Sustituci�n del switch final por un if.
% Unai 19may15 - Se elimina imgBin por estar duplicada. Es igual que imgROI.
 
inicializamatlabpool();
 
numCanales=numel(unique(photonArrivalTimes.channel));

%Seleccionar ROI de la imagen decodificada
[imgROI, ~, indLinesLS, indLinesPS, timeInterval] = FCS_ROI(imgDecode, photonArrivalTimes, lineSync, pixelSync);
if numCanales>1
    cellOption=inputdlg('Selecciona tipo de alineaci�n: 1-S�lo canal 1. 2- S�lo canal 2. 3-La suma de canales');
    option=str2double(cellOption{1});
    switch option
        case 3 %Suma de canales. 
            imgROIsuma=imgROI(:,:,1)+imgROI(:,:,2);
            [imgALIN, sigma2_5, indMaxCadaLinea]=FCS_membraneAlignment_space(imgROIsuma);
        otherwise
            [imgALIN, sigma2_5, indMaxCadaLinea]=FCS_membraneAlignment_space(imgROI(:,:,option));
    end
    
else %numCanales=1;
    [imgALIN, sigma2_5, indMaxCadaLinea]=FCS_membraneAlignment_space(imgROI);
end
 
% switch option
%     case 3 %Suma de canales
%         imgBin=imgDecode(:, pixelROIdesde:pixelROIhasta, :); %Imagen que se utilizar� para el binning temporal
%     case 4 %Para que alinee los dos canales a un �nico canal
%         imgBin=imgDecode(:, pixelROIdesde:pixelROIhasta, :); 
%     case 5 
%         imgBin=imgDecode(:, pixelROIdesde:pixelROIhasta, :); 
%     otherwise %Para que s�lo alinee un canal
%         imgBin=imgDecode(:, pixelROIdesde:pixelROIhasta, option); %Imagen que se utilizar� para el binning temporal
% end
