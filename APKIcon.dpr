library APKIcon;

uses
  ComServ,
  APKIcon_TLB in 'APKIcon_TLB.pas',
  APKIconUnit in 'APKIconUnit.pas' {APKIcon: CoClass};

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer,
  DllInstall;

{$R *.TLB}

{$R *.RES}

begin
end.
