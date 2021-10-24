unit main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  // TrayIcon
  FMX.Windows.TrayIcon, FMX.Effects, FMX.Objects, FMX.TabControl,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Ani, FMX.Layouts,
  DosCommand, ksVirtualListView, System.ImageList, FMX.ImgList, FMX.Edit,
  FMX.Menus,
  Winapi.Messages, Net.HTTPClient,
  Winapi.IpHlpApi, ksAppEvents, ksTypes, ksCircleProgress, ksSegmentButtons,
  ksTileMenu, FMX.ExtCtrls, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo,
  ksTabControl, FMX.Filter.Effects
  ;

const  // hard coded paths, for now located in the same directory where this application runs
{ TODO : Add proper directories handling specially when this applications install in ProgramFiles or other restricted directories }
  ADB_PATH = 'adb';
  DOWNLOADS_PATH = 'downloads';
  // Up to date download link for Windows is located here
  ADB_URL = 'https://dl.google.com/android/repository/platform-tools-latest-windows.zip';
type
  TWSA = record
    InstallPath: string;  
    AppUserModelID: string;
    Version: string;
    DisplayName: string;
    WsaSettings: string;
    WsaClient: string;
  end;

  TDownloadEvent = procedure(Sender: TObject; DownloadCode: Integer) of Object;

  TDownloader = class
  private
    FValue: Byte;
    
    FClient: THTTPClient;    
    FGlobalStart: Cardinal;
    FGlobalStep: Cardinal;
    FAsyncResult: IAsyncResult;
    FDownloaderStream: TStream;
    FSize: Int64;
    FURL: string;
    FUA: string;
    FHeader: string;
    FSavePath: string;

    FOnDownloaded: TDownloadEvent;

    FDownloading: Boolean;
    FAbortNow: Boolean;
    FAborted: Boolean;
    procedure SetValue(const Value: byte);
  protected
    procedure DoReceiveDataEvent(const Sender: TObject; AContentLength: Int64;
      AReadCount: Int64; var Abort: Boolean);
    procedure DoEndDownload(const AsyncResult: IAsyncResult);
  public
    constructor Create;
    destructor Destroy; override;
    procedure DoStartDownload;
    procedure AbortDownload;

    property Value: byte read FValue write SetValue;

    property OnDownloaded: TDownloadEvent read FOnDownloaded write FOnDownloaded;
    property IsDownloading: Boolean read FDownloading;

    property URL: string read FURL write FURL;
    property Header: string read FHeader write FHeader;
    property UserAgent: string read FUA write FUA;
    property SavePath: string read FSavePath write FSavePath;
  end;
  
  TWinDroidHwnd = class(TForm)
    Rectangle1: TRectangle;
    GlowEffect1: TGlowEffect;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    TabItem3: TTabItem;
    TabItem4: TTabItem;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    StyleBook1: TStyleBook;
    FloatAnimation1: TFloatAnimation;
    FloatAnimation2: TFloatAnimation;
    Layout1: TLayout;
    Button1: TButton;
    DosCommand1: TDosCommand;
    Timer1: TTimer;
    ListView1: TListView;
    btnTempOfflineInstaller: TButton;
    btnInstallOffline: TButton;
    btnRefreshAppsList: TButton;
    btnDownloadADB: TButton;
    Edit1: TEdit;
    PopupMenu1: TPopupMenu;
    MenuItem1: TMenuItem;
    Lang1: TLang;
    loWSAInfo: TLayout;
    imgWSA: TImage;
    lbWSAInfo: TLabel;
    lbWSAMUI: TLabel;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    Rectangle2: TRectangle;
    GlowEffect2: TGlowEffect;
    lbWSAVersion: TLabel;
    ksCircleProgress1: TksCircleProgress;
    DropTarget1: TDropTarget;
    OpenDialog1: TOpenDialog;
    Edit2: TEdit;
    Memo1: TMemo;
    ksTabControl1: TksTabControl;
    ksTabItem0: TksTabItem;
    ksTabItem2: TksTabItem;
    ksTabItem3: TksTabItem;
    ksTabItem4: TksTabItem;
    btnReplaceAmazon: TButton;
    ksCircleProgress2: TksCircleProgress;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Button2: TButton;
    Edit3: TEdit;
    FillRGBEffect1: TFillRGBEffect;
    ksCircleProgress3: TksCircleProgress;
    lbWSAStatus: TLabel;
    lbWSAForeground: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FloatAnimation1Finish(Sender: TObject);
    procedure FloatAnimation1Process(Sender: TObject);
    procedure FloatAnimation2Finish(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure btnRefreshAppsListClick(Sender: TObject);
    procedure ListView1ButtonClick(const Sender: TObject;
      const AItem: TListItem; const AObject: TListItemSimpleControl);
    procedure btnDownloadADBClick(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure imgWSAClick(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure DropTarget1DragOver(Sender: TObject; const Data: TDragObject;
      const Point: TPointF; var Operation: TDragOperation);
    procedure DropTarget1Dropped(Sender: TObject; const Data: TDragObject;
      const Point: TPointF);
    procedure DropTarget1Click(Sender: TObject);
    procedure Edit4ChangeTracking(Sender: TObject);
  protected
    procedure TrayIconExit(Sender: TObject);
    procedure TrayIconClick(Sender: TObject);
// TaskbarLocation
    function GetMainTaskbarPosition: Integer;

    function GetWSAInstallationPath(amui: string): string;

    function ReplaceAmazonAppstore: Boolean;
    function IsValidAppPackageName(value: string): Boolean;
    { TODO : In Progress, Shell:AppsFolder items can resolve to lnk files at Shell:Programs directory, we need to do that }
    function IsWsaClientLnkTarget(value: string): Boolean;
    function IsWsaClientRunning:Boolean;
    procedure CheckWsaClientStatus;
  private
    { Private declarations }
    WSA: TWSA;
//    FHookWndHandle: THandle;
//    procedure WndMethod(var Msg: Winapi.Messages.TMessage);
  public
    { Public declarations }
  end;

var
  WinDroidHwnd: TWinDroidHwnd;
  TrayIcon: TTrayIcon;
  Hook: NativeUInt;
  prevRect: TRect;
  AppsClasses: TStringList;
  WsaClientPath: string;
  WndProcHook: THandle;
  IsForegroundWSA: Boolean = False;
  ForegroundWSA: THandle;

implementation

uses
  Winapi.Windows, Winapi.PsAPI, Winapi.DwmApi, Winapi.MultiMon,
  Winapi.ShellAPI, FMX.Platform.Win, Vcl.Graphics, Registry, MSXML, System.IOUtils,
  Winapi.KnownFolders, ShlObj, ActiveX, ComObj, Winapi.PropKey, OleAcc;

type
  TVclBmp = Vcl.Graphics.TBitmap;

const
  WM_TOGGLEFULLSCREEN = WM_USER + 9;


  function StartHook:BOOL; stdcall; external 'F11Hook.dll' name 'STARTHOOK';
  procedure StopHook; stdcall; external 'F11Hook.dll' name 'STOPHOOK';  


{$R *.fmx}

function Icon2Bitmap(hIcon: HICON; ABmp: FMX.Graphics.TBitmap): Boolean;
var
  LIcon: TIcon;
  LBmp: TVclBmp;
  LStream: TMemoryStream;
begin
  Result := False;
  LIcon := TIcon.Create;
  LBmp := TVclBmp.Create;
  LStream := TMemoryStream.Create;  
  try
    LIcon.Handle := hIcon;
    LBmp.SetSize(LIcon.Width, LIcon.Height);
    LBmp.PixelFormat := pf32bit;
    if DrawIcon(LBmp.Canvas.Handle, 0, 0, LIcon.Handle) then
    begin      
      ABmp.SetSize(LBmp.Width, LBmp.Height);
      LBmp.SaveToStream(LStream);
      LStream.Position := 0;
      ABmp.LoadFromStream(LStream);
    end;
  finally
    LStream.Free;
    LBmp.Free;
    LIcon.Free;
  end;  
end;

procedure WinEventProc(hWinEventHook: NativeUInt; dwEvent: DWORD; handle: HWND;
  idObject, idChild: LONG; dwEventThread, dwmsEventTime: DWORD);
var
  LHWindow: HWND;
  LHFullScreen: BOOL;
  vRect: TRect;
  ParentHandle: HWND;
  clsName: array[0..255] of Char;
  pid: DWORD;
  path: array [0..4095] of Char;  
begin
  if (dwEvent = EVENT_OBJECT_LOCATIONCHANGE)
  or (dwEvent = EVENT_SYSTEM_FOREGROUND) then
  begin
    LHWindow := GetForegroundWindow;
    if LHWindow <> 0 then
    begin
      GetWindowRect(LHWindow, vRect);
      if prevRect <> vRect then
      begin
        prevRect := vRect;
        // process current 64bit foreground window to find out if it is a WsaClient.exe instance
        // and what WindowState is currently applied, in order to toggle its size with the keyhook dll
        GetClassName(LHWindow, clsName, 255);
        if Trim(clsName) <> '' then
        begin          
          WinDroidHwnd.lbWSAForeground.Text := '';
          // check if this class name is one of our listed applications
          if AppsClasses.IndexOf(clsName) <> -1 then
          begin
            GetWindowThreadProcessId(LHWindow, pid);
            var proc := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False, pid);
            if proc <> 0 then
            begin
              try
                GetModuleFileNameEx(proc, 0, @path[0], Length(path));
                // check if is our wsaclient, and not other executable named the same
                if Trim(path) = Trim(WsaClientPath) then
                begin
                  WinDroidHwnd.lbWSAForeground.Text := 'WSA App: ' + clsName;                
//                  WinDroidHwnd.lbWSAVersion.Text := path;
                  IsForegroundWSA := True;
                  ForegroundWSA := LHWindow;
                end
                else
                begin
                  IsForegroundWSA := False;
                  ForegroundWSA := 0;
                end;
              finally
                CloseHandle(proc);
              end;
            end;
          end;
        end;
      end;
    end;
  end;
  // check wsaclient.exe status using shell events
  if (dwEvent = EVENT_OBJECT_CREATE) or 
  (dwEvent = EVENT_OBJECT_DESTROY)
  then
  begin
    if (idObject = OBJID_WINDOW) //or (idChild = INDEXID_CONTAINER)
    then
    begin
      WinDroidHwnd.CheckWsaClientStatus;
    end;    
  end;
end;

function WndProc(nCode: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
var
  msg: TCWPRetStruct;
  LMonitor: HMONITOR;
  MonInfo: MONITORINFO;
  IsFull: Boolean;
begin
  if (nCode >= HC_ACTION) {and (lParam > 0)} then
  begin
    msg := PCWPRetStruct(lParam)^;
    
    if (msg.message = WM_TOGGLEFULLSCREEN) then
    begin
//      OutputDebugString('F11 EVENT');
//      WinDroidHwnd.lbWSAVersion.Text := 'F11 ' + inttoStr(Random(100));      
      // if current foreground window is an Android app, let's toogle its size to mimix windowed fullscreen
      if IsForegroundWSA 
      and (GetForegroundWindow = ForegroundWSA)
      and IsWindow(ForegroundWSA) 
      then
      begin
        var style := GetWindowLong(ForegroundWSA, GWL_STYLE);                
        if (style and WS_CAPTION = WS_CAPTION)
        and (style and WS_THICKFRAME = WS_THICKFRAME)
        then
        begin
          style := style and not WS_CAPTION;
          style := style and not WS_THICKFRAME;
          IsFull := False; //current fullscreen state
        end
        else
        begin
          style := style or WS_CAPTION;        
          style := style or WS_THICKFRAME;
          IsFull := True;
        end;
        
        SetWindowLong(ForegroundWSA, GWL_STYLE, style);

        LMonitor := Winapi.MultiMon.MonitorFromWindow(ForegroundWSA, MONITOR_DEFAULTTOPRIMARY);
        MonInfo.cbSize := SizeOf(MONITORINFO);
        GetMonitorInfo(LMonitor, @MonInfo);
        
//        if IsFull then
//        SetWindowPos(ForegroundWSA, 0, 
//          MonInfo.rcWork.Left, 
//          MonInfo.rcWork.Top, 
//          MonInfo.rcWork.Width, 
//          MonInfo.rcWork.Height,
//          {SWP_NOSIZE or} SWP_NOMOVE or SWP_FRAMECHANGED or SWP_NOACTIVATE)
//        else
//        SetWindowPos(ForegroundWSA, 0, 
//          MonInfo.rcMonitor.Left, 
//          MonInfo.rcMonitor.Top, 
//          MonInfo.rcMonitor.Width, 
//          MonInfo.rcMonitor.Height,
//          SWP_NOMOVE or SWP_FRAMECHANGED or SWP_NOACTIVATE);
//        Sleep(1);
        if IsFull then
          SendMessage(ForegroundWSA, WM_SYSCOMMAND, SC_RESTORE, 0)
        else
          SendMessage(ForegroundWSA, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
      end;      
    end;
  end;

  Result := CallNextHookEx(WndProcHook, nCode, wParam, lParam);
end;

procedure TWinDroidHwnd.btnDownloadADBClick(Sender: TObject);
begin
// Start debug client apk
//"C:\Program Files\WindowsApps\MicrosoftCorporationII.WindowsSubsystemForAndroid_1.7.32815.0_x64__8wekyb3d8bbwe\WsaClient\WsaClient.exe" /deeplink wsa-client://developer-settings

end;

procedure TWinDroidHwnd.btnRefreshAppsListClick(Sender: TObject);
var
  io: IKnownFolderManager;
  count: Cardinal;
//  vie: array [0..65534] of TGUID;
  a: PGUIDList;
  knownfoldernative: IKnownFolder;
  hr: HRESULT;
  oguid: TGUID;
  si: IShellItem2;
  sfgao: Cardinal;
  isFileSystem: Boolean;
  fd: TKnownFolderDefinition;
  Item: TListViewItem;
begin

  CoInitialize(nil);
  //FOLDERID_AppsFolder 1e87508d-89c2-42f0-8a7e-645a0f50ca58
  CoCreateInstance(CLSID_KnownFolderManager, nil, CLSCTX_ALL, IKnownFolderManager, io);
  if Assigned(io) then
  begin
    //SHGetKnownFolderIDList(FOLDERID_NetworkFolder)
//    io.GetFolderIds(vie, count);
    hr := io.GetFolder(FOLDERID_AppsFolder, knownfoldernative);
    if hr = S_OK then
    begin
      //kf := get
      hr := knownfoldernative.GetShellItem(0, IID_IShellItem2, si);
      if Succeeded(hr) then
      begin
        if si <> nil then
        begin
          si.GetAttributes(SFGAO_FILESYSTEM, sfgao);
//          sfgao and
          isFileSystem := (sfgao and SFGAO_FILESYSTEM) <> 0;
        end;
        // not file system
        if not isFileSystem then
        begin
          knownfoldernative.GetShellItem(0, IID_IShellItem2, si); //nativeShellItem should go instead of si
          knownfoldernative.GetFolderDefinition(fd);
          var pidControl: PItemIDList;
          var psfDesktop, dt: IShellFolder;
          var psfControl: IShellFolder;
          var pc: IShellFolder2;
          var pEnumList: IEnumIDList;
          var pidChild: PItemIDList;
          var pidAbsolute: PItemIDList;
          var celtFetched: ULONG;
          var FileInfo: SHFILEINFOW;

          OleCheck(SHGetDesktopFolder(psfDesktop));
          OleCheck(SHGetDesktopFolder(dt));
          olecheck(knownfoldernative.GetIDList(KF_FLAG_DEFAULT, pidControl));
          OleCheck(psfDesktop.BindToObject(pidControl, nil, IID_IShellFolder, psfControl));
          OleCheck(psfControl.EnumObjects(0, SHCONTF_NONFOLDERS or SHCONTF_INCLUDEHIDDEN, pEnumList));

          ListView1.Items.Clear;
          AppsClasses.Clear;
//          ImageList1.
          while pEnumList.Next(1, pidChild, celtFetched) = 0 do
          begin
            pidAbsolute := ILCombine(pidControl, pidChild);
            OleCheck(dt.BindToObject(pidControl, nil, IID_IShellFolder2, Pointer(pc)));
            var sa: OleVariant;
//            var cs: SHCOLUMNID;
//            cs.fmtid := StringToGUID('{9F4C2855-9F79-4B39-A8D0-E1D42DE1D5F3}');
//            cs.pid := 5;
            OleCheck(pc.GetDetailsEx(pidChild, SHCOLUMNID(PKEY_AppUserModel_ID), @sa));
{ TODO : If ADB connection is established, better list using adb shell cmd package list packages -3 }          
//            if (Pos('com.', sa) = 1)
//            or (Pos('org.', sa) = 1)
//            or (Pos('net.', sa) = 1)
//            or (Pos('tv.', sa) = 1)
            if IsValidAppPackageName(sa)
            or (Pos('!Setti', sa) > 0)
            then
            begin
//            SHILCreateFromPath(LPCTSTR(pidAbsolute), pidAbsolute, nil);
              SHGetFileInfo(LPCTSTR(pidAbsolute), 0, FileInfo, SizeOf(FileInfo), SHGFI_PIDL or SHGFI_DISPLAYNAME or SHGFI_ICON or SHGFI_SYSICONINDEX or SHGFI_SHELLICONSIZE or SHGFI_LARGEICON);
              CoTaskMemFree(pidAbsolute);

              var icon := TIcon.Create;
                  icon.Handle := FileInfo.hIcon;

              if (Pos('!Sett', sa) > 0) then
              begin
                lbWSAInfo.Text := FileInfo.szDisplayName;
                lbWSAMUI.Text := sa;
//                Icon2Bitmap(icon.Handle, imgWSA.Bitmap);
              end
              else //if IsWsaClientLnkTarget(sa) then
              begin
                Item := ListView1.Items.Add;
                Item.Text := FileInfo.szDisplayName;
                Item.ButtonText := 'Execute';
                Item.Detail := sa;
                Item.TagString := sa;
                Icon2Bitmap(icon.Handle, Item.Bitmap);
                AppsClasses.Add(sa);
              end;

              icon.Free;
            end;
            CoTaskMemFree(pidChild);
          end;

          CoTaskMemFree(pidControl);

//          ListBox1.Items.Add(fd.pszParsingName);//'shell:::{4234d49b-0245-4df3-b780-3893943456e1}'
          //
//          SHCreateItemFromParsingName(fd.pszParsingName, nil, IID_IShellItem2, si);
        end;
      end
      else
        OleCheck(hr);


    end;


//    ListBox1.Clear;
//    ListBox1.Items.Add(IntToStr(count));
//    CoTaskMemFree(@vie);
  end;

  CoUninitialize;
end;

procedure TWinDroidHwnd.Button1Click(Sender: TObject);
begin
  TrayIconClick(Self);
end;

procedure TWinDroidHwnd.CheckWsaClientStatus;
begin
  if IsWsaClientRunning then
    lbWSAStatus.Text := 'Running'
  else
  begin
    lbWSAStatus.Text := 'Not running';
  end;
end;

procedure TWinDroidHwnd.DropTarget1Click(Sender: TObject);
begin
  OpenDialog1.Filter := 'APK|*.apk|XAPK|*.xapk';
  if OpenDialog1.Execute then
  begin
        
  end;
end;

procedure TWinDroidHwnd.DropTarget1DragOver(Sender: TObject;
  const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
begin
  if Length(Data.Files) = 1 then
    Operation := TDragOperation.Move
  else
    Operation := TDragOperation.None;  
end;

procedure TWinDroidHwnd.DropTarget1Dropped(Sender: TObject;
  const Data: TDragObject; const Point: TPointF);
begin
// for d in  Data.Files
end;

procedure TWinDroidHwnd.Edit4ChangeTracking(Sender: TObject);
begin
  
end;

//https://developer.android.com/guide/topics/manifest/manifest-element#package
function TWinDroidHwnd.IsValidAppPackageName(value: string): Boolean;
const
  VALIDCHARS='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._';
var
  ch: PChar;
  I: Integer;
  dotsCounter: Integer;
  dotsoffset: Integer; 
begin
  dotsCounter := 0;
  dotsoffset := 0;
  Result := True;  
  I := 1; // first char must be A_Z only
  if value[I] in ['A'..'Z', 'a'..'z'] then
  begin
    for I := 2 to value.Length do
    begin
      if value[I] = '.' then
      begin
        Inc(dotsCounter);
        if dotsoffset = 0 then
          dotsoffset := I;
      end;
        
      if not(value[I] in ['A'..'Z','a'..'z','0'..'9','_','.']) then
        Result := False;
        
      if (value[I-1] = '.') and (value[I] = '.') // two consecutive dots are not allowed
      then
        Result := False;
        
      if not Result then Break;
    end;
    if Result and (dotsCounter < 2) then
      Result := False;    
    // hacky (bad) way to ignore other windows apps like Microsoft.Windows.Explorer
    // since they also use its AppUserModelID similarly to an Android Package Name
    // but most Android apps tend to use com. tv. org. net. etc which are shorter Microsoft.
    { TODO : compare to ADB's list result better, but we need to install/configure its path first }
    if (dotsoffset > 4) or (dotsoffset < 2) then
      Result := False;
  end
  else
    Result := False;
end;

// Verify that lnk located at
function TWinDroidHwnd.IsWsaClientLnkTarget(value: string): Boolean;
var
  lnk: IShellLink;
  storage: IPersistFile;
  widePath: WideString;
  buf: array[0..4096] of Char;
  fileData: TWin32FindData;
  realPath: LPCWSTR;
begin
  Result := False;
  OleCheck(CoCreateInstance(CLSID_ShellLink, nil, CLSCTX_INPROC_SERVER, IShellLink, lnk));
  OleCheck(lnk.QueryInterface(IPersistFile, storage));

  if Succeeded(SHGetKnownFolderPath(FOLDERID_AppsFolder, KF_FLAG_DEFAULT, 0, realPath)) then
  begin
//    widePath := 'shell:::{4234d49b-0245-4df3-b780-3893943456e1}\'+value;
    widePath := {utf16toutf8}realPath + '\' + value;
    if Succeeded(storage.Load(@widePath[1], STGM_READ)) then
      if Succeeded(lnk.Resolve(GetActiveWindow, SLR_NOUPDATE)) then
        if Succeeded( lnk.GetPath(buf, SizeOf(buf), fileData, SLGP_UNCPRIORITY) )
        then
        begin
          Result := LowerCase(buf).Contains('\wsaclient.exe');
        end;
    CoTaskMemFree(realPath);
  end;
  storage := nil;
  lnk := nil;
end;

function TWinDroidHwnd.IsWsaClientRunning: Boolean;
const
  WSA_CLIENT_MUTEX = '{42CEB0DF-325A-4FBE-BBB6-C259A6C3F0BB}';
var
  Mutex: NativeUInt;
begin
  Result := False;
  Mutex := OpenMutex(MUTEX_ALL_ACCESS, False, WSA_CLIENT_MUTEX);
  if Mutex <> 0 then
  begin
    Result := True;
  end;

  CloseHandle(Mutex);
  
end;

procedure TWinDroidHwnd.FloatAnimation1Finish(Sender: TObject);
begin
  FloatAnimation1.Enabled := False;
end;

procedure TWinDroidHwnd.FloatAnimation1Process(Sender: TObject);
begin
  if not Visible then
    Visible := True;
end;

procedure TWinDroidHwnd.FloatAnimation2Finish(Sender: TObject);
begin
  FloatAnimation2.Enabled := False;
  Visible := False;
end;

procedure TWinDroidHwnd.FormCreate(Sender: TObject);
begin
//  Lang1.Lang := 'es';

  AppsClasses := TStringList.Create;
  AppsClasses.Sorted := True;

  Layout1.Align := TAlignLayout.None;
  TrayIcon := TTrayIcon.Create(Self);
  TrayIcon.SetOnClick(TrayIconClick);
  TrayIcon.AddMenuAction('Exit', TrayIconExit);
  TrayIcon.Show('WSA Manager');

  with FloatAnimation1 do
  begin
    AnimationType := TAnimationType.Out;
    Duration := 0.3;
    Interpolation := TInterpolationType.Circular;
    PropertyName := 'Position.X';
    StartValue := Width;
    StartFromCurrent := True;
    StopValue := 0.0;
  end;

  with FloatAnimation2 do
  begin
    Duration := 0.2;
    Interpolation := TInterpolationType.Circular;
    PropertyName := 'Position.X';
    StartValue := 0.0;
    StartFromCurrent := True;
    StopValue := Width;
  end;

//  Layout1.BoundsRect := Bounds;
  Layout1.Position.X := Width;

  btnRefreshAppsListClick(Sender); // this gets WSA Settings app AppUserModelID
  GetWSAInstallationPath(lbWSAMUI.Text); // this makes sure it is correct and updates WSA record info
  lbWSAVersion.Text := 'Version: ' + WSA.Version;

//  FHookWndHandle := AllocateHWnd(WndMethod);  

  // detect window change foreground
  Hook := SetWinEventHook(EVENT_MIN, EVENT_MAX, 0, @WinEventProc, 0, 0, WINEVENT_OUTOFCONTEXT or WINEVENT_SKIPOWNPROCESS);
  if Hook = 0 then
    raise Exception.Create('Couldn''t create event hook!');
//  RunHook(Handle);
  if not StartHook then
    raise Exception.Create('Couldn''t set global hook to intercept F11');
end;

procedure TWinDroidHwnd.FormDestroy(Sender: TObject);
begin
  StopHook;
//  KillHook;
  UnhookWinEvent(Hook);

//  DeallocateHWnd(FHookWndHandle);
  TrayIcon.Destroy;

  AppsClasses.Free;
end;

function TWinDroidHwnd.GetMainTaskbarPosition: Integer;
const ABNONE = -1;
var
  AMonitor: HMonitor;
  MonInfo: MONITORINFO;
  TaskbarHandle: THandle;
  ABData: TAppBarData;
  Res: HRESULT;
  TaskbarRect: TRect;
begin
  Result := ABNONE;
  ABData.cbSize := SizeOf(TAppbarData);
  Res := SHAppBarMessage(ABM_GETTASKBARPOS, ABData);
  if BOOL(Res) then
  begin
    // return ABE_LEFT=0, ABE_TOP, ABE_RIGHT or ABE_BOTTOM values
    Result := ABData.uEdge;
  end
  else // this might fail if explorer process is hung or is not set as shell (rare)
  begin
    TaskbarHandle := Winapi.Windows.FindWindow('Shell_TrayWnd', nil);
    if TaskbarHandle <> 0 then
    begin
      AMonitor := Winapi.MultiMon.MonitorFromWindow(TaskbarHandle, MONITOR_DEFAULTTOPRIMARY);
      MonInfo.cbSize := SizeOf(MONITORINFO);
      GetMonitorInfo(AMonitor, @MonInfo);
      if (MonInfo.rcMonitor.Left = TaskbarRect.Left) and (MonInfo.rcMonitor.Top = TaskbarRect.Top)
      and (MonInfo.rcMonitor.Width = TaskbarRect.Width)
      then
        Result := ABE_TOP
      else if (MonInfo.rcMonitor.Left + MonInfo.rcMonitor.Width = TaskbarRect.Right)
      and (MonInfo.rcMonitor.Width <> TaskbarRect.Width)
      then
        Result := ABE_RIGHT
      else if (MonInfo.rcMonitor.Left = TaskbarRect.Left) and (MonInfo.rcMonitor.Top + MonInfo.rcMonitor.Height = TaskbarRect.Bottom)
      and (MonInfo.rcMonitor.Width = TaskbarRect.Width)
      then
        Result := ABE_BOTTOM
      else
        Result := ABE_LEFT;
    end;
    // no explorer with taskbar running here, maybe
  end;


end;

{ TODO : If for some weird reason there is more than one WSA installed (maybe a variant), we must make sure it picks the correct on :-/ }
function TWinDroidHwnd.GetWSAInstallationPath(amui: string): string;
var
  reg: TRegistry;
  list: TStringList;
  I, J, K: Integer;
  xmlstr: string;
  xml: IXMLDOMDocument2;
  node: IXMLDOMNode;
  nodes_row, nodes_se: IXMLDOMNodeList;
  name, vers, arqt, appid: string;
  appUserModelID: string;
  installPath: string;
begin
  Result := '';
  reg := TRegistry.Create;
  list := TStringList.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    reg.OpenKeyReadOnly('Software\Classes\ActivatableClasses\Package');
    reg.GetKeyNames(list);
    for I := 0 to list.Count - 1 do
    begin
      installPath := GetEnvironmentVariable('PROGRAMW6432')+'\WindowsApps\'+list[I];
      if list[I].Contains('MicrosoftCorporationII.WindowsSubsystemForAndroid') 
      and FileExists(installPath+'\AppxManifest.xml') then
      begin
        Result := installPath;
        xmlstr := TFile.ReadAllText(installPath+'\AppxManifest.xml');
        xml := CreateOleObject('Microsoft.XMLDOM') as IXMLDOMDocument2;
        xml.async := False;

        xml.loadXML(xmlstr);
        if xml.parseError.errorCode <> 0 then
          raise Exception.Create('XML Load Error: ' + xml.parseError.reason);

        nodes_row := xml.selectNodes('/Package');

        for J := 0 to nodes_row.length - 1 do
        begin
          node := nodes_row.item[J];
          name := node.selectSingleNode('Identity').attributes.getNamedItem('Name').text;
          vers := node.selectSingleNode('Identity').attributes.getNamedItem('Version').text;
          try
            arqt := node.selectSingleNode('Identity').attributes.getNamedItem('ProcessorArchitecture').text;          
          except
            arqt := 'Unknown'; //applies for extension for old edge, I guess we don't need it.
          end;          

          nodes_se := node.selectNodes('Applications');
          for K := 0 to nodes_se.length - 1 do
          begin
            node := nodes_se.item[K];
            appid := node.selectSingleNode('Application').attributes.getNamedItem('Id').text;
            // let's forge the Settings app AMUI listed which we passed to make sure it belong to our app
            appUserModelID := name + Copy(list[I], StrLen(PChar(name + '_' + vers + '_' + arqt + '_'))+1, 
              StrLen(PChar(name + '_' + vers + '_' + arqt + '_'))) + '!Settings' + appid;

            if appUserModelID <> amui then
              Result := '';
          end;
        end;
      end;
      // let's just use the first occurrence
      if Result <> '' then 
      begin
        // we found it, let's update our WSA info
        WSA.InstallPath := installPath;
        WSA.Version := vers;
        WSA.AppUserModelID := appUserModelID;
        WSA.DisplayName := name;
        WSA.WsaSettings := '';
        if FileExists(installPath + '\WsaSettings.exe') then
          WSA.WsaSettings := '\WsaSettings.exe';
        WSA.WsaClient := '';
        if FileExists(installPath + '\WsaClient\WsaClient.exe') then
        begin
          WSA.WsaClient := '\WsaClient\WsaClient.exe';
          WsaClientPath := Trim(installPath + '\WsaClient\WsaClient.exe');
        end;
        Break;
      end;
    end;
  finally
    list.Free;
    reg.Free;
  end;
end;

procedure TWinDroidHwnd.imgWSAClick(Sender: TObject);
begin
  ShellExecute(0, 'OPEN', 'explorer.exe', PChar('shell:::{4234d49b-0245-4df3-b780-3893943456e1}\'+lbWSAMUI.Text), nil, SW_SHOWNORMAL)
end;

procedure TWinDroidHwnd.ListView1ButtonClick(const Sender: TObject;
  const AItem: TListItem; const AObject: TListItemSimpleControl);
begin
//  ShowMessage(AItem.TagString);
  ShellExecute(0, 'OPEN', 'explorer.exe', PChar('shell:::{4234d49b-0245-4df3-b780-3893943456e1}\'+AItem.TagString), nil, SW_SHOWNORMAL)
end;

procedure TWinDroidHwnd.MenuItem1Click(Sender: TObject);
begin
//"C:\Users\<username>\AppData\Local\Microsoft\WindowsApps\MicrosoftCorporationII.WindowsSubsystemForAndroid_8wekyb3d8bbwe\WsaClient.exe" /uninstall com.amazon.venezia
  if Assigned(ListView1.Selected) then
  begin
//  ShowMessage(ListView1.Selected.TagString);
    if MessageDlg('Are you sure to uninstall ' + ListView1.Selected.TagString + '?'#13#10'This procedure is irreversible!', TMsgDlgType.mtWarning, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then
    begin
      ShellExecute(0, 'OPEN', '%USERPROFILE%\AppData\Local\Microsoft\WindowsApps\MicrosoftCorporationII.WindowsSubsystemForAndroid_8wekyb3d8bbwe\WsaClient.exe', PChar('/uninstall ' + ListView1.Selected.TagString), nil, SW_SHOWNORMAL);
    end;
  end;
end;

procedure TWinDroidHwnd.MenuItem3Click(Sender: TObject);
//var
//  appPath: string;
begin
//  var p := Pos('!', lbWSAMUI.Text);
//  appPath := Copy(lbWSAMUI.Text, 1, p - 1);
//  ShellExecute(0, 'OPEN', 'explorer.exe', PChar('%PROGRAMFILES%\WindowsApps\'+appPath), nil, SW_SHOWNORMAL);
  ShellExecute(0, 'OPEN', 'explorer.exe', PChar(GetWSAInstallationPath(lbWSAMUI.Text)), nil, SW_SHOWNORMAL);
//  ShellExecute(0, 'OPEN', 'explorer.exe', PChar('shell:::{4234d49b-0245-4df3-b780-3893943456e1}\'+lbWSAMUI.Text), nil, SW_SHOWNORMAL)
end;

procedure TWinDroidHwnd.MenuItem4Click(Sender: TObject);
begin
  imgWSAClick(Self);
end;

procedure TWinDroidHwnd.PopupMenu1Popup(Sender: TObject);
begin
    MenuItem1.Enabled := Assigned(ListView1.Selected);
    if MenuItem1.Enabled then
      MenuItem1.Text := 'Uninstall ' + ListView1.Selected.TagString;
end;

function TWinDroidHwnd.ReplaceAmazonAppstore: Boolean;
begin
//https://amazonadsi-a.akamaihd.net/public/ix/stable/default/us/Amazon_App.apk
  
end;

procedure TWinDroidHwnd.TrayIconClick(Sender: TObject);
const
  ABE_NONE = -1;
  GAP = 0;
var
  TaskbarMonitor: THandle;
  TaskbarRect: TRect;
  AMonitor: HMonitor;
  MonInfo: MONITORINFO;
  CurPos: TPoint;
  LeftGap: Integer;
  TopGap: Integer;
begin
  TaskbarMonitor := Winapi.Windows.FindWindow('Shell_TrayWnd', nil);
  GetCursorPos(CurPos);
  LeftGap := Width - ClientWidth;
  Layout1.Position.Y := 0;
  TopGap := Height - Round(Layout1.Height) - 5;
  if TaskbarMonitor <> 0 then
  begin
    AMonitor := Winapi.MultiMon.MonitorFromWindow(TaskbarMonitor, MONITOR_DEFAULTTOPRIMARY);
    MonInfo.cbSize := SizeOf(MONITORINFO);
    GetMonitorInfo(AMonitor, @MonInfo);
    GetWindowRect(TaskbarMonitor, TaskbarRect);
    case GetMainTaskbarPosition of
      ABE_LEFT: begin
        Left := MonInfo.rcMonitor.Left + TaskbarRect.Width + GAP - LeftGap div 2;
        Top := CurPos.Y - Height div 2;
      end;
      ABE_TOP: begin
        Left := MonInfo.rcMonitor.Left + MonInfo.rcMonitor.Width - Width - GAP + LeftGap;
        Top := MonInfo.rcMonitor.Top + TaskbarRect.Height + GAP - TopGap;
      end;
      ABE_RIGHT: begin
        Left := MonInfo.rcMonitor.Left + MonInfo.rcMonitor.Width - TaskbarRect.Width - Width - GAP + LeftGap div 2;
        Top := CurPos.Y - Height div 2;
      end;
      ABE_BOTTOM: begin
        Left := MonInfo.rcMonitor.Left + MonInfo.rcMonitor.Width - Width - GAP + LeftGap;
        Top := MonInfo.rcMonitor.Top + MonInfo.rcMonitor.Height - TaskbarRect.Height - Height - GAP + TopGap;
        if not Visible then
          Layout1.Position.X := Width
        else
          Layout1.Position.X := 0;
      end;
      ABE_NONE: begin
        //Position := poScreenCenter;
      end;
    end;
  end;

  WindowState := TWindowState.wsNormal;
  //SetForegroundWindow(Handle);
  if not Visible then
  begin
    if WindowState = TWindowState.wsMinimized then
      WindowState := TWindowState.wsNormal;
    FloatAnimation2.Stop;
    FloatAnimation2.Enabled := False;
    FloatAnimation1.Enabled := True
  end
  else
  begin
    FloatAnimation1.Stop;
    FloatAnimation1.Enabled := False;
    FloatAnimation2.Stop;
    FloatAnimation2.Enabled := True;
  end;
end;

procedure TWinDroidHwnd.TrayIconExit(Sender: TObject);
begin
  Close;
end;

//procedure TWinDroidHwnd.WndMethod(var Msg: TMessage);
//begin
//  if Msg.Msg = WM_TOGGLEFULLSCREEN then
//  begin
//    OutputDebugString('F11 WndMethod EVENT');
//    WinDroidHwnd.lbWSAVersion.Text := 'F11 ' + inttoStr(Random(100));          
//  end;
//end;

{ TDownloader }

procedure TDownloader.AbortDownload;
begin
  if FDownloading then
    FAbortNow := True;
end;

constructor TDownloader.Create;
begin
  inherited;
  FDownloading := False;
  FAbortNow := False;
  FAborted := False;

  FClient := THTTPClient.Create;
  FClient.OnReceiveData := DoReceiveDataEvent;

  FValue := 0;

end;

destructor TDownloader.Destroy;
begin
  FClient.Free;
  FDownloaderStream.Free;
  
  inherited;
end;

procedure TDownloader.DoEndDownload(const AsyncResult: IAsyncResult);
var
  LResponse: IHTTPResponse;
begin
  try
    LResponse := THTTPClient.EndAsyncHTTP(AsyncResult);
    TThread.Synchronize(nil,
      procedure
      begin
        if LResponse.StatusCode = 200 then
        begin
          if FAborted then
          begin
            FAborted := False;
            FOnDownloaded(Self, 209) // Let's consider 209 as aborted successfully
          end
          else
            FOnDownloaded(Self, 200);
        end
        else
        begin
          // some other error has occurred
          FOnDownloaded(Self, LResponse.StatusCode);
        end;
        FDownloading := False;
      end
    );
  finally
    LResponse := nil;
    FreeAndNil(FDownloaderStream);
    // Show success or something
  end;
end;

procedure TDownloader.DoReceiveDataEvent(const Sender: TObject; AContentLength,
  AReadCount: Int64; var Abort: Boolean);
var
  LTime: Cardinal;
  LSpeed: Integer;
begin
  if FAbortNow then
  begin
    Abort := True;
    FAbortNow := False;
    FAborted := True;    
  end;  
  LTime := TThread.GetTickCount - FGlobalStart;
  LSpeed := (AReadCount * 1000) div LTime;
  TThread.Queue(nil,
    procedure
    begin
      FValue := Round(100 / FSize * AReadCount);
//      FStatus := Format('%d KB/s', [LSpeed div 1024]);
    end
  );  
end;

procedure TDownloader.DoStartDownload;
var
  LResponse: IHTTPResponse;
begin
  if FDownloading then
  begin
    raise Exception.Create('Already downloading, stop first!');
    Exit;
  end;  
  try
    LResponse := FClient.Head(FURL);
    FSize := LResponse.ContentLength;
    LResponse := nil;
    FValue := 0;
    FDownloaderStream := TFileStream.Create(FSavePath, fmCreate);
    FDownloaderStream.Position := 0;

    FGlobalStart := TThread.GetTickCount;

    FDownloading := True;
    FClient.CustomHeaders['Connection'] := 'close'; // to close connection afterwards
    FAsyncResult := FClient.BeginGet(DoEndDownload, FURL, FDownloaderStream);
  finally
    FAsyncResult := nil;
  end;
end;

procedure TDownloader.SetValue(const Value: byte);
begin
  if Value <> FValue then
    if Value <= 100 then
    begin
      FValue := Value;
      //
    end;  
end;

initialization
  CoInitialize(nil);
  WndProcHook := 0;
  WndProcHook := SetWindowsHookEx(WH_CALLWNDPROCRET, @WndProc, 0, GetCurrentThreadId);
  if WndProcHook = 0 then
    raise Exception.Create('Couldn''t create secondary Window Proc');
finalization
  UnhookWindowsHookEx(WndProcHook);
  CoUninitialize;

end.
