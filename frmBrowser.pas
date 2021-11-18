unit frmBrowser;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, WebView2, Winapi.ActiveX, Vcl.Edge,
  Vcl.OleCtrls, SHDocVw, SHDocVw_EWB, EwbCore, EmbeddedWB, IEDownload,
  IEMultiDownload, UrlMon, Vcl.ExtCtrls, UWP.Downloader, Vcl.WinXPanels,
  Vcl.ComCtrls, Winapi.Mshtmhst, Vcl.StdCtrls, Vcl.FileCtrl;

const
  DOCHOSTUIFLAG_DPI_AWARE = $40000000;
  IID_IDownloadManager: TGUID = '{988934A4-064B-11D3-BB80-00104B35E7F9}';
  SID_IDownloadManager: TGUID = '{988934A4-064B-11D3-BB80-00104B35E7F9}';

type
  //https://stackoverflow.com/a/13389595/537347
  IDownloadManager = interface(IUnknown)
    ['{988934A4-064B-11D3-BB80-00104B35E7F9}']
    function Download(pmk: IMoniker; pbc: IBindCtx; dwBindVerb: DWORD;
      grfBINDF: DWORD; pBindInfo: PBindInfo; pszHeaders: PWideChar;
      pszRedir: PWideChar; uiCP: UINT): HRESULT; stdcall;
  end;

  TBeforeFileDownloadEvent = procedure(Sender: TObject; const FileSource: WideString;
    var Allowed: Boolean) of Object;

  TWebBrowser = class(SHDocVw.TWebBrowser, IServiceProvider, IDownloadManager, IDocHostUIHandler)
  private
    FFileSource: WideString;
    FOnBeforeFileDownload: TBeforeFileDownloadEvent;
    function QueryService(const rsid, iid: TGUID; out Obj): HRESULT; stdcall;
    function Download(pmk: IMoniker; pbc: IBindCtx; dwBindVerb: DWORD;
      grfBINDF: DWORD; pBindInfo: PBindInfo; pszHeaders: PWideChar;
      pszRedir: PWideChar; uiCP: UINT): HRESULT; stdcall;

    // handling special chars
    procedure CNChar(var Msg: TWMChar); message CN_CHAR;
    // making webbrowser DPI aware https://stackoverflow.com/a/63810030
    function GetHostInfo(var pInfo: TDocHostUIInfo): HRESULT; stdcall;
  protected
    procedure InvokeEvent(ADispID: TDispID; var AParams: TDispParams); override;
  published
    property OnBeforeFileDownload: TBeforeFileDownloadEvent read FOnBeforeFileDownload write FOnBeforeFileDownload;
  end;

  TfrmWeb = class(TForm)
    WebBrowser1: TWebBrowser;
    UWPDownloader1: TUWPDownloader;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    FileListBox1: TFileListBox;
    procedure FormCreate(Sender: TObject);
    procedure UWPDownloader1Downloaded(Sender: TObject; DownloadCode: Integer);
    procedure WebBrowser1NewWindow2(ASender: TObject; var ppDisp: IDispatch;
      var Cancel: WordBool);
    procedure ListView1DblClick(Sender: TObject);
    procedure VirtualExplorerListview1DblClick(Sender: TObject);
    procedure FileListBox1DblClick(Sender: TObject);
  private
    { Private declarations }
    procedure BeforeFileDownload(Sender: TObject; const FileSource: WideString;
      var Allowed: Boolean);
  public
    { Public declarations }
  end;

var
  frmWeb: TfrmWeb;

implementation

uses
  System.Net.HttpClient, {IdHTTP,} helperFuncs,
  frmApkInstaller;

{$R *.dfm}

procedure TfrmWeb.BeforeFileDownload(Sender: TObject;
  const FileSource: WideString; var Allowed: Boolean);
  function GetAttachmentFilename(CD: string): string;
  var
    fq, sq: Integer;
  begin
    Result := 'fileattachment';
    if CD.Contains('filename') then // e.g. Content-Disposition returns: attachment; filename="filename.ext"
    begin
      fq := Pos('"', CD);
      sq := Pos('"', CD, fq + 1);
      if (fq > 0) and (sq > 0) and (sq > fq) then
      begin
        Result := Copy(CD, fq + 1, sq - fq - 1);
      end;

    end;

  end;
var
  FileTarget: string;
  LUrl: string;
//  Http: TIdHTTP;
  Client: THTTPClient;
  Response: IHTTPResponse;
begin
  Allowed := False;
//  ShowMessage(FileSource);
  LUrl := Trim(FileSource);
  if LUrl = '' then Exit;

  Var domain := ExtractDomain(LUrl);
  Client := THTTPClient.Create;
//  Http := TIdHTTP.Create(nil);
  try
    try
      Response := Client.Head(LUrl, nil);
    except
    end;
//    Http.Head(LUrl);
    if Assigned(Response) and (Response.StatusCode = 200) and (Response.ContentLength > 0) then
    begin
      var fName := GetAttachmentFilename(Response.HeaderValue['Content-Disposition']); //Http.Response.RawHeaders.Params['Content-Disposition', 'filename'];
      var Prompt := Format('You chose to download: '#13#10'%s '#13#10'Size: %s '#13#10'From %s. '#13#10''#13#10'Continue?',
      [
        fName,
        FormatFileSize(Response.ContentLength),//Http.Response.ContentLength),
        domain
      ]);
      if MessageDlg(Prompt,TMsgDlgType.mtConfirmation, mbYesNo, 0) = mrYes then
      begin
        UWPDownloader1.SavePath := ExtractFilePath(ParamStr(0)) + 'Downloads\' + fName;
        UWPDownloader1.Detail := fName;
        UWPDownloader1.URL := LUrl;
        UWPDownloader1.DoStartDownload;
        PageControl1.SelectNextPage(True);
      end;
    end;
  finally
    Client.Free;
//    Http.Free;
  end;


end;

procedure TfrmWeb.FileListBox1DblClick(Sender: TObject);
begin
  frmInstaller.FApkFile := FileListBox1.Items[FileListBox1.ItemIndex];
  frmInstaller.Show;
  frmInstaller.FApkInfo.DisplayName := '';
  frmInstaller.FApkInfo.DisplayVersion := '';
  frmInstaller.FApkInfo.PackageName := '';
  frmInstaller.FApkInfo.Icon := '';

  frmInstaller.FApkPermissions.Clear;
  if LowerCase(FileListBox1.Items[FileListBox1.ItemIndex]).Contains('.xapk') then
    frmInstaller.GetXAPKInfo
  else
    frmInstaller.GetAPKInfoWithAndroidAssetPackagingTool;
end;

procedure TfrmWeb.FormCreate(Sender: TObject);
begin
  WebBrowser1.Silent := True;
  WebBrowser1.OnBeforeFileDownload := BeforeFileDownload;

  if DirectoryExists(ExtractFilePath(ParamStr(0))+'Downloads') then
  begin
    FileListBox1.Directory := ExtractFilePath(ParamStr(0))+'Downloads';
  end;
end;

procedure TfrmWeb.ListView1DblClick(Sender: TObject);
begin
//  frmInstaller.FApkFile := ListView1.Items[ListView1.ItemIndex].;
  frmInstaller.Show;
  frmInstaller.FApkInfo.DisplayName := '';
  frmInstaller.FApkInfo.DisplayVersion := '';
  frmInstaller.FApkInfo.PackageName := '';
  frmInstaller.FApkInfo.Icon := '';

  frmInstaller.FApkPermissions.Clear;
  frmInstaller.GetAPKInfoWithAndroidAssetPackagingTool;
end;

procedure TfrmWeb.UWPDownloader1Downloaded(Sender: TObject;
  DownloadCode: Integer);
begin
  ShowMessage('File Downloaded!');
end;

procedure TfrmWeb.VirtualExplorerListview1DblClick(Sender: TObject);
begin

end;

// prevent opening links in MSEdge
procedure TfrmWeb.WebBrowser1NewWindow2(ASender: TObject; var ppDisp: IDispatch;
  var Cancel: WordBool);
begin
  Cancel := True;
end;

{ TWebBrowser }

procedure TWebBrowser.CNChar(var Msg: TWMChar);
begin
  Msg.Result := 0;
end;

function TWebBrowser.Download(pmk: IMoniker; pbc: IBindCtx; dwBindVerb,
  grfBINDF: DWORD; pBindInfo: PBindInfo; pszHeaders, pszRedir: PWideChar;
  uiCP: UINT): HRESULT;
var
  Allowed: Boolean;
begin
  Result := E_NOTIMPL;
  if Assigned(FOnBeforeFileDownload) then
  begin
    Allowed := True;
    if pszRedir <> '' then
      FFileSource := pszRedir;
    FOnBeforeFileDownload(Self, FFileSource, Allowed);
    if not Allowed then
      Result := S_OK;
  end;
end;

function TWebBrowser.GetHostInfo(var pInfo: TDocHostUIInfo): HRESULT;
begin
  // original code
  pInfo.cbSize := SizeOf(pInfo);
  pInfo.dwFlags := 0;
  pInfo.dwFlags := pInfo.dwFlags or DOCHOSTUIFLAG_NO3DBORDER;
  pInfo.dwFlags := pInfo.dwFlags or DOCHOSTUIFLAG_THEME;
  pInfo.dwFlags := pInfo.dwFlags or DOCHOSTUIFLAG_DPI_AWARE; // NEW added flag
  Result := S_OK;
//  ResizeScrollBars; // will be called by subsequent routines anyway
end;

procedure TWebBrowser.InvokeEvent(ADispID: TDispID; var AParams: TDispParams);
begin
  inherited;
  /// DispID 250 is the BeforeNavigatte2 dispinterface and to the FFileSource here
  ///  is stored the URL parameter (for cases, when the IDownloaderManager::Download
  ///  won't redirect the URL and pass empty string to the pszRedir)
  if ADispID = 250 then
    FFileSource := OleVariant(AParams.rgvarg^[5]);
end;

function TWebBrowser.QueryService(const rsid, iid: TGUID; out Obj): HRESULT;
begin
  Result := E_NOINTERFACE;
  Pointer(Obj) := nil;
  if Assigned(FOnBeforeFileDownload) and IsEqualCLSID(rsid, SID_IDownloadManager) and
    IsEqualIID(iid, IID_IDownloadManager) then
  begin
    if Succeeded(QueryInterface(IID_IDownloadManager, Obj)) and
      Assigned(Pointer(Obj))
    then
      Result := S_OK;
  end;
end;

end.
