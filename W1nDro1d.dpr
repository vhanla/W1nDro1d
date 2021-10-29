program W1nDro1d;

{$R *.dres}

uses

  Vcl.Forms,
  System.StartUpCopy,
  FMX.Forms,
  FMX.Platform.Win,
  System.SysUtils,
  Winapi.Windows,
  main in 'main.pas' {WinDroidHwnd},
  frmApkInstaller in 'frmApkInstaller.pas' {frmInstaller};

{$R *.res}

begin
// WsaClient process Mutex {42CEB0DF-325A-4FBE-BBB6-C259A6C3F0BB}
  if CreateMutex(nil, True, '{42CEB0DF-325A-4FBE-BBB6-C259A6C3F0BC}') = 0 then
    RaiseLastOSError;

  if GetLastError = ERROR_ALREADY_EXISTS then
  begin
    Exit;
  end;

  Application.Initialize;
  Application.CreateForm(TWinDroidHwnd, WinDroidHwnd);
  Application.CreateForm(TfrmInstaller, frmInstaller);
  Application.RealCreateForms;
  Application.MainForm.Visible := False;
  Application.Run;
end.
