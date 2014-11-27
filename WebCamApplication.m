%% Kayit edilen butun resimler, videolar kaynak kodun bulundugu klasore gitmektedir.

function  RTR()
clear;
vid = videoinput('winvideo',1, 'YUY2_320x240');
set(vid,'ReturnedColorSpace','rgb');
%% Figürün yarat?lmas?. 
hFig = figure('Toolbar','none','Menubar', 'none','NumberTitle','Off',...
    'Name','WebCam Application','DeleteFcn',{});
axis off;
%% Buttonlar?n yarat?lmas?.
uicontrol('String', 'Webcam Aktif','Callback',{@startpreview_callback},...
    'Units','normalized','Position',[.01 .01 0.15 .06],'Parent',hFig);

uicontrol('String', 'Webcami Durdur','Callback',{@stoppreview_callback},...
    'Units','normalized','Position',[.16 .01 .15 .06],'Parent',hFig);

uicontrol('String', 'Snapshot','Callback', {@snapshot_callback},...
    'Units','normalized','Position',[.32 .01 .15 .06],'Parent',hFig);

tgl = uicontrol('String','Resim Cek','Callback',{@saveimages_callback},...
    'Units','normalized','Position',[.48 .01 .15 .06],'Parent',hFig);

uicontrol('String','Video Kayit','Callback', {@startcapture_callback},...
    'Units','normalized','Position',[.64 .01 .15 .06],'Parent',hFig);

uicontrol('String', 'Kaydi Durdur','Callback', {@stopcapture_callback},...
    'Units','normalized','Position',[.8 .01 .15 .06],'Parent',hFig);
uicontrol('String', 'Ip Camera','Callback', {@ipcamera_callback},...
    'Units','normalized','Position',[.01 .10 .15 .06],'Parent',hFig);
%% Gorevlerin Calistirilmasi
vidRes = get(vid, 'VideoResolution');
imWidth = vidRes(1);
imHeight = vidRes(2);
nBands = get(vid, 'NumberOfBands');
hImage = image( zeros(imHeight, imWidth, nBands) );

figSize = get(hFig,'Position');
figWidth = figSize(3);
figHeight = figSize(4);

set(gca,'unit','pixels', 'position',[ ((figWidth - imWidth)/2) ((figHeight - imHeight)/2) imWidth imHeight ]);
%% Inceleme ekraninin update edilmesi
setappdata(hImage,'UpdatePreviewWindowFcn',@mypreview_fcn);

preview(vid, hImage);
%% Figur icin kullanim fonksiyonlari
    function mypreview_fcn(obj,event,himage)
    % Frameler icin zaman damgasi
    tstampstr = event.Timestamp;
    ht = getappdata(himage,'HandleToTimestampLabel');
    set(ht,'String',tstampstr);
    % Resmin ekrana basilmasi
    set(himage, 'CData', event.Data)
    end
%% Snapshot olarak yeni figurde ekrana basma
    function snapshot_callback(hObject, eventdata)
    hFig2 = figure('Toolbar','none','Menubar', 'none','NumberTitle','Off',...
    'Name','Snapshot');
    imagesc(getsnapshot(vid));
    figure(hFig);
    end
%% Resim Cek (Frame-Frame Kayit eder)
    function saveimages_callback(hObject,eventdata)
    for i=1:100
        figure('Toolbar','none','Menubar', 'none','NumberTitle','Off',...
        'Name','Snapshot','Visible','off');
        imagesc(getsnapshot(vid));
        wait(vid,.001);
%Frame Isimlerini Dongusu
        saveas(gca,['ArialPic_' int2str(i)],'jpg') ;
        %if tgl.value==0, break; end;
    end
    figure(hFig);
    end
%% Canli Goruntuyu Durdur
    function stoppreview_callback(hObject, eventdata)
    stoppreview(vid);
    figure(hFig);
    end
%% Canli Goruntuyu Calistir
    function startpreview_callback(hObject, eventdata)
    figure(hFig);
    preview(vid);    
    end
%% Video Kaydina Basla
    function startcapture_callback(hObject, eventdata)
    set(vid,'TriggerFrameDelay',3);
    set(vid,'TriggerRepeat',0);
    set(vid,'Timeout',Inf);
    set(vid,'LoggingMode','disk');
    set(vid,'FramesPerTrigger',1000000);
    aviobj = avifile('UAV_datalog.avi','compression','none', 'fps', 30, 'quality', 50);
    set(vid,'DiskLogger',aviobj);
    start(vid);
    end
%% Video Kaydini Durdur
    function stopcapture_callback(hObject, eventdata)
    stop(vid);
    aviobj = close(vid.DiskLogger);
        if(exist('UAV_datalog.avi')==2)
        disp('AVI file created.')
        end
    end

%% Callback for IPcamera Görüntüsüne geçi?
% A?a??daki kima kameranin ip adresi girilmelidir, daha verimli çal??mas? için static ip
% tavsiye edilir...
%
    function ipcamera_callback(hObject, eventdata)
url = 'http://Kameranin IP adresi/shot.jpg';
ss  = imread(url);
fh = image(ss);

while(1)
    ss  = imread(url);
    set(fh,'CData',ss);
    drawnow;
end

    end
end