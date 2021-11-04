program WinDroid;



uses
  FastMM4,
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Vcl.Forms,
  System.SysUtils,
  Winapi.Windows,
  WSAManager in 'WSAManager.pas' {frmWinDroid},
  frmApkInstaller in 'frmApkInstaller.pas' {frmInstaller},
  Vcl.Themes,
  Vcl.Styles,
  frmBrowser in 'frmBrowser.pas' {frmWeb},
  helperFuncs in 'helperFuncs.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
// WsaClient process Mutex {42CEB0DF-325A-4FBE-BBB6-C259A6C3F0BB}
  if CreateMutex(nil, True, '{42CEB0DF-325A-4FBE-BBB6-C259A6C3F0BC}') = 0 then
    RaiseLastOSError;

  if GetLastError = ERROR_ALREADY_EXISTS then
  begin
    Exit;
  end;

  Application.Initialize;
//  Application.MainFormOnTaskbar := False;
//  Application.ShowMainForm := False;
  Application.CreateForm(TfrmWinDroid, frmWinDroid);
  Application.CreateForm(TfrmInstaller, frmInstaller);
  Application.CreateForm(TfrmWeb, frmWeb);
  Application.Run;
end.
