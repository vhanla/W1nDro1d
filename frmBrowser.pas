unit frmBrowser;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, WebView2, Winapi.ActiveX, Vcl.Edge,
  Vcl.OleCtrls, SHDocVw, SHDocVw_EWB, EwbCore, EmbeddedWB, IEDownload,
  IEMultiDownload, UrlMon, Vcl.ExtCtrls, UWP.Downloader, Vcl.WinXPanels,
  Vcl.ComCtrls;

const
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
  TWebBrowser = class(SHDocVw.TWebBrowser, IServiceProvider, IDownloadManager)
  private
    FFileSource: WideString;
    FOnBeforeFileDownload: TBeforeFileDownloadEvent;
    function QueryService(const rsid, iid: TGUID; out Obj): HRESULT; stdcall;
    function Download(pmk: IMoniker; pbc: IBindCtx; dwBindVerb: DWORD;
      grfBINDF: DWORD; pBindInfo: PBindInfo; pszHeaders: PWideChar;
      pszRedir: PWideChar; uiCP: UINT): HRESULT; stdcall;
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
    procedure FormCreate(Sender: TObject);
    procedure UWPDownloader1Downloaded(Sender: TObject; DownloadCode: Integer);
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
  System.Net.HttpClient, IdHTTP, helperFuncs;

{$R *.dfm}

procedure TfrmWeb.BeforeFileDownload(Sender: TObject;
  const FileSource: WideString; var Allowed: Boolean);
var
  FileTarget: string;
  LUrl: string;
  Http: TIdHTTP;
begin
  Allowed := False;
//  ShowMessage(FileSource);
  LUrl := Trim(FileSource);
  if LUrl = '' then Exit;

  Var domain := ExtractDomain(LUrl);
  Http := TIdHTTP.Create(nil);
  try
    Http.Head(LUrl);
    var fName := Http.Response.RawHeaders.Params['Content-Disposition', 'filename'];
    var Prompt := Format('You chose to download: '#13#10'%s '#13#10'Size: %s '#13#10'From %s. '#13#10''#13#10'Continue?',
    [
      fName,
      FormatFileSize(Http.Response.ContentLength),
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
  finally
    Http.Free;
  end;


end;

procedure TfrmWeb.FormCreate(Sender: TObject);
begin
  WebBrowser1.Silent := True;
  WebBrowser1.OnBeforeFileDownload := BeforeFileDownload;
end;

procedure TfrmWeb.UWPDownloader1Downloaded(Sender: TObject;
  DownloadCode: Integer);
begin
  ShowMessage('File Downloaded!');
end;

{ TWebBrowser }

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
