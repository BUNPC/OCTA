%% OCT angiography data processing, CPU-based
% input: 
    % 1D array spectrum, nK*nXrpt*nX*nY, data format: ASCII int16
        % nK: spectrum pixel (camera elements); nXrpt: Ascan repeat;
        % nX: number of Ascans per Bscan; nY: number of Bscans for the whole volum
        % NOTE: the raw data for the whole volume is usually very large, it's recommended to process chunk by chunk
% output:
    % AG: [nz,nx,ny] OCT angiogram
% subFunctions:
    % function [Dim, fNameBase, fIndex]=GetNameInfoRaw(filename0)
    % function DAT= ReadDat_int16(filePath, Dim, iseg, ARpt_extract,RptBscan) 
    % function RR = DAT2RR(Dat, intpDk)
    % function AG=RR2AG(RR, it0, ncorrect, z, K)
%% Angiogram OCT, each Y plane was scanned twice, data: nz_(nx*2)_ny
close all; clear;clc 
%% Select file location %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
datapath0  = 'H:\BU\PROJ - g1 OCTA\1205AnesIntralipidMouseDepth\ROI2\Dep1-Intralipid-OCTA';
[filename0,datapath]=uigetfile(fullfile(datapath0,'*.dat'),'select file');
%% add MATLAB functions path
addpath('.\SubFunctions')
%% get data information
[Dim, fNameBase,fIndex]=GetNameInfoRaw(filename0);
%% Data processing info
prompt={'startFile','nFile to Load',['# of sub Spectrum (nk0=',num2str(Dim.nk),')'], 'intDk',...
    'dZ','dX','dY'};
inputNumGG=inputdlg(prompt,'File info', 1,{num2str(fIndex),'10', '1', '-0.43',...
    '3.29','1.5','1.5'});
startFile=str2num(inputNumGG{1});  % start load file
nFile=str2num(inputNumGG{2});  % number of file
Nspec=str2num(inputNumGG{3});
PRSinfo.intDk=str2num(inputNumGG{4});
dZ=str2num(inputNumGG{5});
dX=str2num(inputNumGG{6});
dY=str2num(inputNumGG{7});
Nx=Dim.nxRpt*Dim.nx*Dim.nyRpt;
xCoor=[1:Dim.nx]*dX;
yCoor=[1:Dim.ny]*dY;
%% Angiogram calculation 
nSubPixel=floor(Dim.nk/Nspec); % number of pixels for each sub spectrum
for i_file=startFile:startFile+nFile-1
    tic;
    if nFile==1
        ifilePath=[datapath,filename0];
    else
        ifilename=[fNameBase,num2str(i_file,'%d')];
        ifilePath=[datapath,ifilename,'.dat'];
    end
    disp(['Start loading EXP data-', num2str(i_file), ', ',datestr(now,'DD-HH:MM:SS')]);
    DAT = ReadDat_int16(ifilePath, Dim); % read raw data, DAT(nk,nxRpt*nx*nyRpt,ny)
    disp(['Raw_Lamda data of EXP data-', num2str(i_file), ' Loaded. Calculating RR ... ',datestr(now,'DD-HH:MM:SS')]);
    DAT_k=DAT2k(DAT,PRSinfo.intDk);
    for ispec=1:Nspec % split spectrum compounding
        %% data processing
        disp(['Start processing ith spectrum-', num2str(ispec), ', #pix=',num2str(nSubPixel),', ',datestr(now,'DD-HH:MM:SS')]);
        DAT_k_ispec((ispec-1)*nSubPixel+1:ispec*nSubPixel,:,:)=DAT_k((ispec-1)*nSubPixel+1:ispec*nSubPixel,:,:);
        RR0 = ifft(DAT_k_ispec,[],1); % RR0(nz,nX,ny)
        disp(['RR-', num2str(i_file), ', iSpectrum/Nspec=',num2str(ispec),'/',num2str(Nspec),' is calculated, ',datestr(now,'DD-HH:MM:SS')]);
        %% select axial range %%%%%%
        if i_file==startFile && ispec==1
            fig=figure;
            subplot(1,2,1);imagesc(abs((squeeze(max(RR0(:,round(Dim.nx/2),:),[],2)))))
            xlabel('Y');ylabel('Z');ylim([1 400]);title('MIP along X');  caxis([0 5])
            subplot(1,2,2);imagesc(abs((squeeze(max(RR0(:,:,round(Dim.ny/2)),[],3)))))
            xlabel('X');ylabel('Z');ylim([1 400]);title('MIP along Y');  caxis([0 5])
            disp(['Select brain surface and stack start layer in figure']);
            [XY_surf, Z_surf]=ginput(3);
            close(fig);
            prompt2={'Surface','Start Z_range','End Z_range'};
            inputZrange=inputdlg(prompt2,'Z Segment parameter', 1,{num2str(floor(Z_surf(1))),num2str(floor(Z_surf(2))),num2str(floor(Z_surf(3)))});
            z_seg_surf=str2num(inputZrange{1});
            zRange(1)=str2num(inputZrange{2});  
            zRange(2)=str2num(inputZrange{3});  
            LengthZ=zRange(2)-zRange(1)+1;
            zCoor=[1:LengthZ]*dZ;
            AG=zeros(LengthZ,Dim.nx,Dim.ny);
        end
        %% OCTA processing and averaging
        RR=permute(reshape(RR0(zRange(1):zRange(2),:,:),[LengthZ,Dim.nxRpt,Dim.nx,Dim.nyRpt,Dim.ny]),[1 3 5 2 4]); % RR(nz,nx,ny,nxRpt,nyRpt)
        AG=AG+RR2AG(RR); % CPU-based
    end
    toc
end
AG=AG/(nFile);
%% figure plot %%%%%%%%%%%%%%%%%%%%%%%%%
figure;
imagesc(xCoor,yCoor,log(squeeze(max(abs(AG),[],1)))); 
colormap(gray);colorbar
xlabel('X [mm]')
ylabel('Y [mm]')
axis equal tight
%% save data %%%%%%%%%%%%%%%%%%%%%%
savename=['AG-nCamPix',num2str(nSubPixel),'-AVG',num2str(nFile),'-zRange(',num2str(zRange),')'];
saveas(gcf,[datapath,savename,'-EnfaceMIP.jpg'],'jpg');
saveas(gcf,[datapath,savename,'-EnfaceMIP.fig'],'fig');
save([datapath, savename, '.mat'],'AG')
disp(['Data saved, ', datestr(now,'DD-HH:MM:SS')])
    