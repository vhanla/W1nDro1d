program W1nDro1d;

uses
  System.StartUpCopy,
  FMX.Forms,
  main in 'main.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.RealCreateForms;
  Application.MainForm.Visible := False;
  Application.Run;
end.
