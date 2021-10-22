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
  Winapi.IpHlpApi
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
  
  TForm1 = class(TForm)
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
    ProgressBar1: TProgressBar;
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
  protected
    procedure TrayIconExit(Sender: TObject);
    procedure TrayIconClick(Sender: TObject);
// TaskbarLocation
    function GetMainTaskbarPosition: Integer;

    function GetWSAInstallationPath(amui: string): string;
  private
    { Private declarations }
    WSA: TWSA;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  TrayIcon: TTrayIcon;

implementation

uses
  Winapi.Windows, Winapi.Messages, Winapi.PsAPI, Winapi.DwmApi, Winapi.MultiMon,
  Winapi.ShellAPI, FMX.Platform.Win, Vcl.Graphics, Registry, MSXML, System.IOUtils,
  Winapi.KnownFolders, ShlObj, ActiveX, ComObj, Winapi.PropKey, OleAcc;

type
  TVclBmp = Vcl.Graphics.TBitmap;

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

procedure TForm1.btnDownloadADBClick(Sender: TObject);
begin
// Start debug client apk
//"C:\Program Files\WindowsApps\MicrosoftCorporationII.WindowsSubsystemForAndroid_1.7.32815.0_x64__8wekyb3d8bbwe\WsaClient\WsaClient.exe" /deeplink wsa-client://developer-settings

end;

procedure TForm1.btnRefreshAppsListClick(Sender: TObject);
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
            if (Pos('com.', sa) = 1)
            or (Pos('org.', sa) = 1)
            or (Pos('net.', sa) = 1)
            or (Pos('tv.', sa) = 1)
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
                Icon2Bitmap(icon.Handle, imgWSA.Bitmap);
              end
              else
              begin
                Item := ListView1.Items.Add;
                Item.Text := FileInfo.szDisplayName;
                Item.ButtonText := 'Execute';
                Item.Detail := sa;
                Item.TagString := sa;
                Icon2Bitmap(icon.Handle, Item.Bitmap);
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

procedure TForm1.Button1Click(Sender: TObject);
begin
  TrayIconClick(Self);
end;

procedure TForm1.FloatAnimation1Finish(Sender: TObject);
begin
  FloatAnimation1.Enabled := False;
end;

procedure TForm1.FloatAnimation1Process(Sender: TObject);
begin
  if not Visible then
    Visible := True;
end;

procedure TForm1.FloatAnimation2Finish(Sender: TObject);
begin
  FloatAnimation2.Enabled := False;
  Visible := False;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
//  Lang1.Lang := 'es';

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
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  TrayIcon.Destroy;
end;

function TForm1.GetMainTaskbarPosition: Integer;
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
function TForm1.GetWSAInstallationPath(amui: string): string;
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
          WSA.WsaClient := '\WsaClient\WsaClient.exe';
        Break;
      end;
    end;
  finally
    list.Free;
    reg.Free;
  end;
end;

procedure TForm1.imgWSAClick(Sender: TObject);
begin
  ShellExecute(0, 'OPEN', 'explorer.exe', PChar('shell:::{4234d49b-0245-4df3-b780-3893943456e1}\'+lbWSAMUI.Text), nil, SW_SHOWNORMAL)
end;

procedure TForm1.ListView1ButtonClick(const Sender: TObject;
  const AItem: TListItem; const AObject: TListItemSimpleControl);
begin
//  ShowMessage(AItem.TagString);
  ShellExecute(0, 'OPEN', 'explorer.exe', PChar('shell:::{4234d49b-0245-4df3-b780-3893943456e1}\'+AItem.TagString), nil, SW_SHOWNORMAL)
end;

procedure TForm1.MenuItem1Click(Sender: TObject);
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

procedure TForm1.MenuItem3Click(Sender: TObject);
//var
//  appPath: string;
begin
//  var p := Pos('!', lbWSAMUI.Text);
//  appPath := Copy(lbWSAMUI.Text, 1, p - 1);
//  ShellExecute(0, 'OPEN', 'explorer.exe', PChar('%PROGRAMFILES%\WindowsApps\'+appPath), nil, SW_SHOWNORMAL);
  ShellExecute(0, 'OPEN', 'explorer.exe', PChar(GetWSAInstallationPath(lbWSAMUI.Text)), nil, SW_SHOWNORMAL);
//  ShellExecute(0, 'OPEN', 'explorer.exe', PChar('shell:::{4234d49b-0245-4df3-b780-3893943456e1}\'+lbWSAMUI.Text), nil, SW_SHOWNORMAL)
end;

procedure TForm1.MenuItem4Click(Sender: TObject);
begin
  imgWSAClick(Self);
end;

procedure TForm1.PopupMenu1Popup(Sender: TObject);
begin
    MenuItem1.Enabled := Assigned(ListView1.Selected);
    if MenuItem1.Enabled then
      MenuItem1.Text := 'Uninstall ' + ListView1.Selected.TagString;
end;

procedure TForm1.TrayIconClick(Sender: TObject);
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

procedure TForm1.TrayIconExit(Sender: TObject);
begin
  Close;
end;

end.
