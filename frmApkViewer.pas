unit frmApkViewer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.ExtCtrls, Vcl.WinXCtrls,
  SynEditHighlighter, SynEditCodeFolding, SynHighlighterJava, SynEdit,
  Vcl.ComCtrls, Vcl.WinXPanels;

type
  TfrmApkViewerWnd = class(TForm)
    SplitView1: TSplitView;
    MainMenu1: TMainMenu;
    CardPanel1: TCardPanel;
    Card1: TCard;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    SynEdit1: TSynEdit;
    SynJavaSyn1: TSynJavaSyn;
    TreeView1: TTreeView;
    File1: TMenuItem;
    Edit1: TMenuItem;
    Help1: TMenuItem;
    Open1: TMenuItem;
    Close1: TMenuItem;
    Save1: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    StatusBar1: TStatusBar;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmApkViewerWnd: TfrmApkViewerWnd;

implementation

{$R *.dfm}

end.
