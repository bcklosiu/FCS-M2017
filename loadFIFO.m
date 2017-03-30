function [fblock_pos,TACrange,TACgain]=loadFIFO(fnameSPC)

% 7-11-2013: Lee archivos .spc, que luego pueden ser decodificados con decodeFIFO
% 05-05-2014: Lee par�metros TAC_range y TAC_gain del archivo .set

%lectura SPC
fidSPC=fopen (fnameSPC);
fblock= fread(fidSPC,inf,'*uint32'); % Con el *uint32 lee un uint32 y obliga a que fblock sea uint32
ind= fblock>0;
fblock_pos= fblock(ind); % Nos quedamos con los mayores de 0
fclose (fidSPC);

ind_fname=strfind(fnameSPC,'.spc');
fname=fnameSPC(1:ind_fname-1);
fnameSET=strcat(fname,'.set');
%lectura SET
fidSET=fopen (fnameSET);
fread(fidSET,1, 'uint16');
fread(fidSET,1, 'uint32'); % fileinfoposition
fread(fidSET,1, 'uint16'); % fileinfocount
setuppos=fread(fidSET,1, 'uint32'); %Posici�n inicial de Setup Parameters
setupcount=fread(fidSET,1, 'uint16'); %Posici�n final de Setup Parameters
fseek (fidSET, setuppos, 'bof');
setup=fread (fidSET, setupcount, 'uint8=>char')'; %Contiene todos los Setup parameters
setParams=textscan(setup, '%s', 'Delimiter', sprintf('\n'));
TACrangeCell=setParams{1,1}(26);
indTACrange=strfind(TACrangeCell,',');
TACrange=str2double(TACrangeCell{1,1}(max(indTACrange{1,1})+1:end-1)); %TAC Range en s
TACgainCell=setParams{1,1}(27);
indTACgain=strfind(TACgainCell,',');
TACgain=str2double(TACgainCell{1,1}(max(indTACgain{1,1})+1:end-1)); %TAC Gain
fclose(fidSET);