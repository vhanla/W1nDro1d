unit wsa;

interface

uses
  Winapi.Windows, Generics.Collections, System.Classes;

type
  PAPK = ^TAPK;
  TAPK = record
    AndroidPackageName: string;
    AndroidVersionCode: string;
    DisplayIcon: string;
    DisplayName: string;
    DisplayVersion: string;
    EstimatedSize: Integer;
    InstallDate: string;
    ModifyPath: string;
    NoRepair: Integer;
    Publisher: string;
    QuietUninstallString: string;
    UninstalString: string;
  end;

  TAPKList = class(TList)
  private
    function Get(Index: Integer): PAPK;
  public
    destructor Destroy; override;
    function Add(Value: PAPK): Integer;
    property Items[Index: Integer]: PAPK read Get; default;
  end;

  TWSA = class
  private
    FInstalledApps: TAPKList;
    FInstallationPath: string;
    FAppUserModelId: string;
    FVersion: string;
    FDisplayName: string;
    FMinimumWindowsVersion: string;
    FIconPath: string;
    FLogoPath: string;
    FPublisherDisplayName: string;
    FWsaClientRelativePath: string;
    FWsaSettingsRelativePath: string;
    procedure SetInstallationPath(const Value: string);
    procedure SetAppUserModelId(const Value: string);
    procedure SetVersion(const Value: string);
    procedure SetDisplayName(const Value: string);
    procedure SetMinimumWindowsVersion(const Value: string);
    procedure SetIconPath(const Value: string);
    procedure SetLogoPath(const Value: string);
    procedure SetPublisherDisplayName(const Value: string);
    procedure SetWsaClientRelativePath(const Value: string);
    procedure SetWsaSettingsRelativePath(const Value: string);
    {WSA related things}
  public
    constructor Create;
    destructor Destroy; override;

    procedure UpdateInstalledAPKList;

    property InstallationPath: string read FInstallationPath write SetInstallationPath;
    property AppUserModelId: string read FAppUserModelId write SetAppUserModelId;
    property Version: string read FVersion write SetVersion;
    property DisplayName: string read FDisplayName write SetDisplayName;
    property IconPath: string read FIconPath write SetIconPath;
    property LogoPath: string read FLogoPath write SetLogoPath;
    property PublisherDisplayName: string read FPublisherDisplayName write SetPublisherDisplayName;
    property MinimumWindowsVersion: string read FMinimumWindowsVersion write SetMinimumWindowsVersion;
    property WsaClientRelativePath: string read FWsaClientRelativePath write SetWsaClientRelativePath;
    property WsaSettingsRelativePath: string read FWsaSettingsRelativePath write SetWsaSettingsRelativePath;
  end;

implementation

{ TWSA }

constructor TWSA.Create;
begin
  FInstalledApps := TAPKList.Create;
end;

destructor TWSA.Destroy;
begin
  FInstalledApps.Free;
  inherited;
end;

procedure TWSA.SetAppUserModelId(const Value: string);
begin
  FAppUserModelId := Value;
end;

procedure TWSA.SetDisplayName(const Value: string);
begin
  FDisplayName := Value;
end;

procedure TWSA.SetIconPath(const Value: string);
begin
  FIconPath := Value;
end;

procedure TWSA.SetInstallationPath(const Value: string);
begin
  FInstallationPath := Value;
end;

procedure TWSA.SetLogoPath(const Value: string);
begin
  FLogoPath := Value;
end;

procedure TWSA.SetMinimumWindowsVersion(const Value: string);
begin
  FMinimumWindowsVersion := Value;
end;

procedure TWSA.SetPublisherDisplayName(const Value: string);
begin
  FPublisherDisplayName := Value;
end;

procedure TWSA.SetVersion(const Value: string);
begin
  FVersion := Value;
end;

procedure TWSA.SetWsaClientRelativePath(const Value: string);
begin
  FWsaClientRelativePath := Value;
end;

procedure TWSA.SetWsaSettingsRelativePath(const Value: string);
begin
  FWsaSettingsRelativePath := Value;
end;

procedure TWSA.UpdateInstalledAPKList;
begin

end;

{ TAPKList }

function TAPKList.Add(Value: PAPK): Integer;
begin
  Result := inherited Add(Value);
end;

destructor TAPKList.Destroy;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    // let's first release strings
    SetLength(Items[I].AndroidPackageName, 0);
    SetLength(Items[I].AndroidVersionCode, 0);
    SetLength(Items[I].DisplayIcon, 0);
    SetLength(Items[I].DisplayName, 0);
    SetLength(Items[I].DisplayVersion, 0);
    SetLength(Items[I].InstallDate, 0);
    SetLength(Items[I].ModifyPath, 0);
    SetLength(Items[I].Publisher, 0);
    SetLength(Items[I].QuietUninstallString, 0);
    SetLength(Items[I].UninstalString, 0);
    // since we use GetMem(PAPK, SizeOf(TAPK)); we release it here
    FreeMem(Items[I]);
  end;
  inherited;
end;

function TAPKList.Get(Index: Integer): PAPK;
begin
  Result := PAPK(inherited Get(Index));
end;

end.
