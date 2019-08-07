function varargout = GUI_PLOT_OCTA(varargin)
% GUI_PLOT_OCTA MATLAB code for GUI_PLOT_OCTA.fig
%      GUI_PLOT_OCTA, by itself, creates a new GUI_PLOT_OCTA or raises the existing
%      singleton*.
%
%      H = GUI_PLOT_OCTA returns the handle to a new GUI_PLOT_OCTA or the handle to
%      the existing singleton*.
%
%      GUI_PLOT_OCTA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_PLOT_OCTA.M with the given input arguments.
%
%      GUI_PLOT_OCTA('Property','Value',...) creates a new GUI_PLOT_OCTA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_PLOT_OCTA_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_PLOT_OCTA_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_PLOT_OCTA

% Last Modified by GUIDE v2.5 17-Jul-2019 14:39:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_PLOT_OCTA_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_PLOT_OCTA_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GUI_PLOT_OCTA is made visible.
function GUI_PLOT_OCTA_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_PLOT_OCTA (see VARARGIN)
%% add MATLAB functions' path
% addpath('/autofs/cluster/MOD/OCT/Jianbo/CODE/Functions') % Path on server
handles.CodePath=pwd;
addpath(handles.CodePath);
addpath([handles.CodePath, '\SubFunctions'])
handles.defpath='H:';

handles.startZ=1;
handles.stackZ=100;
% Choose default command line output for GUI_PLOT_OCTA
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_PLOT_OCTA wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_PLOT_OCTA_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btn_LoadData.
function btn_LoadData_Callback(hObject, eventdata, handles)
% hObject    handle to btn_LoadData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clc;
addpath(handles.CodePath); 
addpath([handles.CodePath, '\SubFunctions'])
%% select file path %%%%%%%%%
defaultpath=handles.defpath;
[filename,datapath]=uigetfile(defaultpath);
handles.defpath=datapath;
handles.filename=filename;
guidata(hObject, handles);
%% load data %%%%%%%%%%
%%%%% input number of sub GG to be loaded %%%%%%%%
lding=msgbox(['Loading data...  ',datestr(now,'DD:HH:MM')]);
handles.AG=LoadMAT(datapath,filename);
lded=msgbox(['Data loaded. ',datestr(now,'DD:HH:MM')]);
pause(1);
delete(lding); delete(lded);
[nz,nx,ny]=size(handles.AG);
%%%%%%%%%%%%%
prompt={'dX (um): ', 'dY(um): ', 'dZ size (um)'};
name='Enter Imaging info';
defaultvalue={'1.5','1.5','2.9'};
dXYZinput=inputdlg(prompt,name, 1, defaultvalue);
handles.Xcoor=[1:nx]*str2num(dXYZinput{1});
handles.Ycoor=[1:ny]*str2num(dXYZinput{2});
handles.Zcoor=[1:nz]*str2num(dXYZinput{3});
%% plot en face MIP
axes(handles.axes1);
cla(handles.axes1);
AG=log(squeeze(max(handles.AG(:,:,:),[],1)));
imagesc(AG);  % axis image;  set(gca,'Clim',limC);
caxis(MyCaxis(AG,0.15, 0.8))
colormap('gray')
title(['XY MIP']);
xlabel( 'X [pix]'); ylabel('Y [pix]')
axis equal;axis tight

guidata(hObject, handles);

% --- Executes on button press in btn_sfcRemove.
function btn_sfcRemove_Callback(hObject, eventdata, handles)
% hObject    handle to btn_sfcRemove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes on button press in btn_Save.
clc;
addpath(handles.CodePath); 
addpath([handles.CodePath, '\SubFunctions'])
[nz,nx,ny]=size(handles.AG);

prompt={'number of fitting points - X', 'number of fitting points - Y'};
name='Enter Imaging info';
defaultvalue={'5','7'};
dXYZinput=inputdlg(prompt,name, 1, defaultvalue);
nxRef=str2num(dXYZinput{1});
nyRef=str2num(dXYZinput{2});
yFrame(1:nyRef)=round(linspace(1,ny,nyRef));

for iy=1:nyRef
    axes(handles.axes1);
    cla(handles.axes1);
    imagesc(squeeze(handles.AG(:,:,yFrame(iy))));colormap(parula)
    [xRef(1:nxRef,iy),zRef(1:nxRef,iy)]=ginput(nxRef);
%     pause(1)
    xRef=round(xRef);
    zRef=round(zRef);
    yRef(1:nxRef,iy)=yFrame(iy);
end
xRef0=reshape(xRef,[nyRef*(nxRef),1]);
yRef0=reshape(yRef,[nyRef*(nxRef),1]);
zRef0=reshape(zRef,[nyRef*(nxRef),1]);
RefSurface=fit([xRef0,yRef0],zRef0,'poly23');
% figure,plot(RefSurface,[xRef0,yRef0],zRef0)

for x=1:nx
    for y=1:ny
        zSf(x,y)=round(RefSurface(x,y));
        handles.AG(1:zSf(x,y)+1,x,y)=0;
    end
end
handles.zSf=zSf;
%% plot surface reflection removed angiogram
axes(handles.axes1);
cla(handles.axes1);
AG=log(squeeze(max(handles.AG(:,:,:),[],1)));
imagesc(AG);  % axis image;  set(gca,'Clim',limC);
caxis(MyCaxis(AG,0.15, 0.8))
colormap('gray')
title(['XY MIP']);
xlabel( 'X [pix]'); ylabel('Y [pix]')
axis equal;axis tight

guidata(hObject, handles);

% --- Executes on button press in btn_plot.
function btn_plot_Callback(hObject, eventdata, handles)
% hObject    handle to btn_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clc;
addpath(handles.CodePath); 
addpath([handles.CodePath, '\SubFunctions'])
[nz,nx,ny]=size(handles.AG);

prompt={'SideView(N:0;Y:1)','MIP zStart', 'MIP zStack','Image refine'};
name='Enter Imaging info';
defaultvalue={'0',num2str(handles.startZ),num2str(min(nz,nz-handles.startZ)),'1'};
dXYZinput=inputdlg(prompt,name, 1, defaultvalue);
PlotSideView=str2num(dXYZinput{1});
zStart=str2num(dXYZinput{2});
zStack=str2num(dXYZinput{3});
rfn=str2num(dXYZinput{4});
handles.stackZ=zStack;
handles.startZ=zStart;

handles.stackZ=zStack;
handles.startZ=zStart;
guidata(hObject, handles);  

%% PLOT
AGMIP=log(squeeze(max(handles.AG(zStart:zStart+zStack-1,:,:),[],1)));
cMap='gray';
if PlotSideView==1 % plot SideView figures
    axes(handles.axes1);
    handles.slt(1)=str2num(get(handles.zStart,'string'));
    [handles.slt(3), handles.slt(2)]=ginput(1); % [y x]
    handles.slt=round(handles.slt);
    
    handles.fig=figure;
    set(handles.fig,'Position',[400 500 1400 800])
    subplot(2,2,1) % xz side view
    AGxy=log(squeeze(max(handles.AG(handles.slt(1),:,:),[],1)));
    AGxy(handles.slt(2)+[0 1],:)=1;
    AGxy(:,handles.slt(3)+[0 1])=1;
    imagesc(handles.Xcoor,handles.Ycoor,AGxy);
    colorbar; colormap(cMap);caxis(MyCaxis(AGMIP,0.05, 0.8));
    axis equal; axis tight;
    title(['OCTA-XY, iz=',num2str(handles.slt(1))])
    xlabel('X [um]'); ylabel('Y [um]')
    
    subplot(2,2,2) % yz side view
    AGyz=log(squeeze(handles.AG(:,handles.slt(2),:)));
    AGyz(handles.slt(1),:)=1;
    imagesc(handles.Ycoor,handles.Zcoor,AGyz);
    colorbar; colormap(cMap); caxis(MyCaxis(AGMIP,0.01, 0.8));
    axis equal; axis tight;
    title(['OCTA-XZ, iY=',num2str(handles.slt(2))])
    xlabel('X [um]'); ylabel('Z [um]')
    
    subplot(2,2,3) % XY single plan enface view
    AGMIP=log(squeeze(max(handles.AG(zStart:zStart+zStack-1,:,:),[],1)));
    AGMIP(handles.slt(2)+[0 1],:)=1;
    AGMIP(:,handles.slt(3)+[0 1])=1;
    imagesc(handles.Xcoor,handles.Ycoor,AGMIP);
    colorbar; colormap(cMap);caxis(MyCaxis(AGMIP,0.01, 0.8));
    axis equal; axis tight;
    title('OCTA')
    xlabel('X [um]'); ylabel('Y [um]')
    
    subplot(2,2,4) % XY enface view MIP
    AGxz=log(squeeze(handles.AG(:,:,handles.slt(3))));
    AGxz(handles.slt(1),:)=1;
    imagesc(handles.Xcoor,handles.Zcoor,AGxz);
    colorbar; colormap(cMap); caxis(MyCaxis(AGMIP,0.05, 0.8));
    axis equal; axis tight;
    title(['OCTA-YZ, iX=',num2str(handles.slt(3))])
    xlabel('Y [um]'); ylabel('Z [um]')
else %% plot enface MIP only
    handles.fig=figure;
    imagesc(handles.Xcoor,handles.Ycoor,AGMIP);
    colorbar; colormap(cMap);caxis(MyCaxis(AGMIP,0.15, 0.8));
    axis equal; axis tight;
    title('OCTA')
    xlabel('X [um]'); ylabel('Y [um]')
end


guidata(hObject, handles);

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
addpath(handles.CodePath); 
addpath([handles.CodePath, '\SubFunctions'])
clc
zStart=str2num(get(handles.zStart,'string'));
zStack=str2num(get(handles.zStack,'string'));

[nz,nx,ny] = size(handles.AG);
set(hObject,'SliderStep',[1/(nz-1), 3/(nz-1)])
set(hObject,'Max',nz)
zStart=nz-min(round(get(hObject,'Value')),nz-1);
set(handles.zStart,'string',zStart);

AGMIP=log(squeeze(max(handles.AG(zStart:min(zStart+zStack-1,nz),:,:),[],1)));
axes(handles.axes1)
imagesc(AGMIP);
colorbar; colormap('gray');caxis(MyCaxis(AGMIP,0.2, 0.8));
axis equal; axis tight;
title(['OCTA-XY, z=[',num2str(zStart),'-',num2str(min(zStart+zStack-1,nz)),']'])
xlabel('X [um]'); ylabel('Y [um]')
guidata(hObject, handles);


function zStart_Callback(hObject, eventdata, handles)
% hObject    handle to zStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zStart as text
%        str2double(get(hObject,'String')) returns contents of zStart as a double
addpath(handles.CodePath); 
addpath([handles.CodePath, '\SubFunctions'])
zStart=str2num(get(handles.zStart,'string'));
zStack=str2num(get(handles.zStack,'string'));
[nz,nx,ny]=size(handles.AG);
AGMIP=log(squeeze(max(handles.AG(zStart:min(zStart+zStack-1,nz),:,:),[],1)));
axes(handles.axes1)
imagesc(AGMIP);
colorbar; colormap('gray');caxis(MyCaxis(AGMIP,0.2, 0.8));
axis equal; axis tight;
title(['OCTA-XY, z=[',num2str(zStart),'-',num2str(min(zStart+zStack-1,nz)),']'])
xlabel('X [um]'); ylabel('Y [um]')


function zStack_Callback(hObject, eventdata, handles)
% hObject    handle to zStack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zStack as text
%        str2double(get(hObject,'String')) returns contents of zStack as a double
addpath(handles.CodePath); 
addpath([handles.CodePath, '\SubFunctions'])
zStart=str2num(get(handles.zStart,'string'));
zStack=str2num(get(handles.zStack,'string'));
[nz,nx,ny]=size(handles.AG);
AGMIP=log(squeeze(max(handles.AG(zStart:min(zStart+zStack-1,nz),:,:),[],1)));
axes(handles.axes1)
imagesc(AGMIP);
colorbar; colormap('gray');caxis(MyCaxis(AGMIP,0.2, 0.8));
axis equal; axis tight;
title(['OCTA-XY, z=[',num2str(zStart),'-',num2str(min(zStart+zStack-1,nz)),']'])
xlabel('X [um]'); ylabel('Y [um]')

function btn_Save_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clc;
addpath(handles.CodePath); 
addpath([handles.CodePath, '\SubFunctions'])
%% select file path %%%%%%%%%
defaultpath=handles.defpath;
AG=handles.AG;
xCoor=handles.Xcoor;
yCoor=handles.Ycoor;
disp('Saving data......')
save([defaultpath,'AG-',handles.filename(1:end-4),'.mat'],'AG','xCoor','yCoor');
saveas(handles.fig,[defaultpath,'AG-',handles.filename(1:end-4),'.fig']);
saveas(handles.fig,[defaultpath,'AG-',handles.filename(1:end-4),'.jpg']);
disp('Data saved!')



% --- Executes on button press in btn_reset.
function btn_reset_Callback(hObject, eventdata, handles)
% hObject    handle to btn_reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

addpath(handles.CodePath); 
addpath([handles.CodePath, '\SubFunctions'])
handles.defpath='H:';

handles.startZ=1;
handles.stackZ=100;
% Choose default command line output for GUI_PLOT_OCTA
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% --- Executes during object creation, after setting all properties.
function zStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function zStack_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zStack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
