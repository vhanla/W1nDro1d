unit frmApkInstaller;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.TitleBarCtrls, UWP.Form, UWP.QuickButton, UWP.Caption, UWP.Button,
  Vcl.WinXCtrls, DosCommand, SynEditHighlighter, SynHighlighterUNIXShellScript,
  SynEdit, ES.BaseControls, ES.Images;

type

  TApkDetails = record
    DisplayName: string;
    PackageName: string;
    DisplayVersion: string;
    Icon: string;
  end;

  TPanel = class(Vcl.ExtCtrls.TPanel)
  private
    const
    DEFAULT_BORDER_COLOR = clActiveBorder;//$0033CCFF;
    DEFAULT_CLIENT_COLOR = clWindow;
    DEFAULT_BORDER_RADIUS = 16;
  private
    { Private Declarations }
    FBorderColor: TColor;
    FClientColor: TColor;
    FBorderRadius: Integer;
    FRounded: Boolean;
    procedure SetStyle(const Value: Boolean);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    property Rounded: Boolean read FRounded write SetStyle default False;
  end;


  TfrmInstaller = class(TUWPForm)
    btnReUnInstall: TButton;
    btnLaunch: TButton;
    lbAPKDisplayName: TLabel;
    lbPublisher: TLabel;
    lbVersion: TLabel;
    lbCertificate: TLabel;
    lbCapabilities: TLabel;
    apkInstallerMemo: TMemo;
    UWPQuickButton1: TUWPQuickButton;
    UWPQuickButton2: TUWPQuickButton;
    UWPQuickButton3: TUWPQuickButton;
    pnlAbout: TPanel;
    pnlCaption: TPanel;
    ActivityIndicator1: TActivityIndicator;
    lbAbout: TLabel;
    lbInsVersion: TLabel;
    Label1: TLabel;
    lnkWebSite: TLinkLabel;
    lnkRepository: TLinkLabel;
    Button1: TButton;
    Shape1: TShape;
    DCAapt: TDosCommand;
    SynEdit1: TSynEdit;
    SynUNIXShellScriptSyn1: TSynUNIXShellScriptSyn;
    eApkImage: TEsImage;
    btnLog: TButton;
    DCPKCS7: TDosCommand;
    procedure pnlCaptionMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure UWPButton2Click(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure lnkWebSiteLinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
    procedure lnkRepositoryLinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
    procedure DCAaptExecuteError(ASender: TObject; AE: Exception;
      var AHandled: Boolean);
    procedure DCAaptNewLine(ASender: TObject; const ANewLine: string;
      AOutputType: TOutputType);
    procedure DCAaptTerminateProcess(ASender: TObject;
      var ACanTerminate: Boolean);
    procedure btnLogClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure DCAaptTerminated(Sender: TObject);
    procedure lbCertificateClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    FApkFile: string;
    FApkInfo: TApkDetails;
    FApkPermissions: TStringList;
    procedure GetAPKInfoWithAndroidAssetPackagingTool;
  end;

var
  frmInstaller: TfrmInstaller;

implementation

uses
  Winapi.ShellAPI, WSAManager, UWP.ColorManager, RegularExpressions;

{$R *.dfm}

procedure TfrmInstaller.btnLogClick(Sender: TObject);
begin
  SynEdit1.Visible := not SynEdit1.Visible;
end;

procedure TfrmInstaller.Button1Click(Sender: TObject);
begin
  pnlAbout.Visible := not pnlAbout.Visible;
end;

procedure TfrmInstaller.DCAaptExecuteError(ASender: TObject; AE: Exception;
  var AHandled: Boolean);
begin
  if AHandled then
    ShowMessage(AE.ToString);

end;

procedure TfrmInstaller.DCAaptNewLine(ASender: TObject;
  const ANewLine: string; AOutputType: TOutputType);
begin
  AOutputType := otEntireLine;

  if SynEdit1.Lines.Count > 1000 then
    SynEdit1.Lines.Clear;

  SynEdit1.Lines.Add(ANewLine);
  SynEdit1.GotoLineAndCenter(SynEdit1.Lines.Count);

  if FApkInfo.PackageName = '' then
    if Pos('package: ', ANewLine) = 1 then
    begin
      FApkInfo.PackageName := TRegEx.Match(ANewLine, '(?<=name='')[^'']*').Value;
      FApkInfo.DisplayVersion := TRegEx.Match(ANewLine, '(?<=versionName='')[^'']*').Value;
    end;

  if FApkInfo.DisplayName = '' then
    if Pos('launchable-activity: ', ANewLine) = 1 then
    begin
      FApkInfo.DisplayName := TRegEx.Match(ANewLine, '(?<=label='')[^'']*').Value;
//      FApkInfo.Icon := TRegEx.Match(ANewLine, '(?<=icon='')[^'']*').Value;
    end
    else if Pos('application-label', ANewLine) = 1 then
      FApkInfo.DisplayName := TRegEx.Match(ANewLine, '(?<=:'')[^'']*').Value;

  if Pos('uses-permission: ', ANewLine) = 1 then
    FApkPermissions.Add(TRegEx.Match(ANewLine, '(?<=name='')[^'']*').Value);

  if FApkInfo.Icon = '' then
    if Pos('application-icon-', ANewLine) = 1 then
      FApkInfo.Icon := TRegEx.Match(ANewLine, '(?<=:'')[^'']*').Value;

end;

procedure TfrmInstaller.DCAaptTerminated(Sender: TObject);
begin
  lbAPKDisplayName.Caption := FApkInfo.DisplayName;
  lbCapabilities.Caption := 'Capabilities';
  lbVersion.Caption := 'Version: ' + FApkInfo.DisplayVersion;
  lbPublisher.Caption := 'Icon: ' + FApkInfo.Icon;
  apkInstallerMemo.Lines := FApkPermissions;
end;

procedure TfrmInstaller.DCAaptTerminateProcess(ASender: TObject;
  var ACanTerminate: Boolean);
begin
  ACanTerminate := True;
end;

procedure TfrmInstaller.FormClick(Sender: TObject);
begin
  pnlAbout.Visible := False;
end;

procedure TfrmInstaller.FormCreate(Sender: TObject);
begin
  FApkPermissions := TStringList.Create;
//  pnlCaption.Height := GetSystemMetrics(SM_CYCAPTION) + GetSystemMetrics(SM_CXBORDER);
//  pnlAbout.Rounded := True;
  ColorizationManager.ColorizationType :=  TUWPColorizationType.ctLight;
end;

procedure TfrmInstaller.FormDestroy(Sender: TObject);
begin
  DCAapt.Stop;
  FApkPermissions.Free;
end;

procedure TfrmInstaller.GetAPKInfoWithAndroidAssetPackagingTool;
var
  cmdline: string;
begin
  if FileExists(ExtractFilePath(ParamStr(0))+ 'aapt.exe') then
  begin
    cmdline := 'aapt.exe d badging "' + FApkFile + '"';
    if DCAapt.IsRunning then
      DCAapt.Stop;

    DCAapt.InputToOutput := False;
    DCAapt.CommandLine := cmdline;
    DCAapt.Execute;
  end;
end;

procedure TfrmInstaller.lbCertificateClick(Sender: TObject);
begin
  DCPKCS7.CommandLine := 'openssl pkcs7 -in '+GetRSAFile()+' -inform DER -print_certs | openssl x509 -text -noout'
end;

procedure TfrmInstaller.lnkRepositoryLinkClick(Sender: TObject;
  const Link: string; LinkType: TSysLinkType);
begin
  ShellExecute(0, 'OPEN', PChar(Link), nil, nil, SW_SHOWNORMAL);
end;

procedure TfrmInstaller.lnkWebSiteLinkClick(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
  ShellExecute(0, 'OPEN', PChar(Link), nil, nil, SW_SHOWNORMAL);
end;

procedure TfrmInstaller.pnlCaptionMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture;
  Perform(WM_SYSCOMMAND, $F012, 0);
end;

procedure TfrmInstaller.UWPButton2Click(Sender: TObject);
begin

end;

{ TPanel }

constructor TPanel.Create(AOwner: TComponent);
begin
  inherited;
  FBorderColor := DEFAULT_BORDER_COLOR;
  FClientColor := DEFAULT_CLIENT_COLOR;
  FBorderRadius := DEFAULT_BORDER_RADIUS;
end;

procedure TPanel.Paint;
var
  r: TRect;
begin
  inherited;
  if Rounded then
  begin
    //BevelOuter := bvNone;
    Canvas.Pen.Color := FBorderColor;
    Canvas.Brush.Color := FBorderColor;
    Canvas.Brush.Style := bsSolid;
    Canvas.FillRect(Rect(FBorderRadius,
      0, ClientWidth - FBorderRadius, FBorderRadius));
    Canvas.Ellipse(Rect(0, 0, 2 * FBorderRadius, 2 * FBorderRadius));
    Canvas.Ellipse(Rect(ClientWidth - 2 * FBorderRadius, 0,
      ClientWidth, 2 * FBorderRadius));
//    Canvas.Brush.Color := FClientColor;
////    Canvas.Rectangle(Rect(0, FBorderRadius, ClientWidth, ClientHeight));
//    Canvas.Font.Assign(Self.Font);
//    r := Rect(FBorderRadius, 0, ClientWidth - FBorderRadius, FBorderRadius);
//    Canvas.Brush.Style := bsClear;
  end;
end;

procedure TPanel.SetStyle(const Value: Boolean);
begin
  FRounded := Value;
end;

end.
