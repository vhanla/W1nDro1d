unit frmApkInstaller;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.TitleBarCtrls, UWP.Form, UWP.QuickButton, UWP.Caption, UWP.Button,
  Vcl.WinXCtrls, DosCommand, SynEditHighlighter, SynHighlighterUNIXShellScript,
  SynEdit;

type
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
    btnReInstall: TButton;
    btnLaunch: TButton;
    Image1: TImage;
    lbAPKDisplayName: TLabel;
    lbPublisher: TLabel;
    lbVersion: TLabel;
    lbCertificate: TLabel;
    lbCapabilities: TLabel;
    Memo1: TMemo;
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
    DosCommand1: TDosCommand;
    SynEdit1: TSynEdit;
    SynUNIXShellScriptSyn1: TSynUNIXShellScriptSyn;
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
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmInstaller: TfrmInstaller;

implementation

uses
  Winapi.ShellAPI;

{$R *.dfm}

procedure TfrmInstaller.Button1Click(Sender: TObject);
begin
  pnlAbout.Visible := not pnlAbout.Visible;
end;

procedure TfrmInstaller.FormClick(Sender: TObject);
begin
  pnlAbout.Visible := False;
end;

procedure TfrmInstaller.FormCreate(Sender: TObject);
begin
//  pnlCaption.Height := GetSystemMetrics(SM_CYCAPTION) + GetSystemMetrics(SM_CXBORDER);
//  pnlAbout.Rounded := True;

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
