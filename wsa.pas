unit wsa;

interface

uses
  Winapi.Windows, Generics.Collections, System.Classes, Vcl.ImageCollection;

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
    FImageCollection: TImageCollection;
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

uses
  Winapi.ShlObj, Winapi.ActiveX, Winapi.KnownFolders, Winapi.ShellAPI,
  Winapi.PropKey, Vcl.Graphics, System.SysUtils;

{ TWSA }

constructor TWSA.Create;
begin
  FInstalledApps := TAPKList.Create;
  FImageCollection := TImageCollection.Create(nil);
end;

destructor TWSA.Destroy;
begin
  FImageCollection.Free;
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
var
  io: IKnownFolderManager;
  count: Cardinal;
  a: PGUIDList;
  knownfoldernative: IKnownFolder;
  hr: HRESULT;
  oguid: TGUID;
  si: IShellItem2;
  sfgao: Cardinal;
  isFileSystem: Boolean;
  fd: TKnownFolderDefinition;
  Item: TStrings;
  fPath: array[0..1024] of Char;

  pidControl: PItemIDList;
  psfDesktop, dt: IShellFolder;
  psfControl: IShellFolder;
  pc: IShellFolder2;
  pEnumList: IEnumIDList;
  pidChild: PItemIDList;
  pidAbsolute: PItemIDList;
  celtFetched: ULONG;
  fileInfo: SHFILEINFOW;
begin
  CoInitialize(nil);

  // Clear content
  FImageCollection.Images.Clear;
  FInstalledApps.Clear;

  CoCreateInstance(CLSID_KnownFolderManager, nil, CLSCTX_ALL, IID_IKnownFolderManager, io);
  if Assigned(io) then
  begin
  //FOLDERID_AppsFolder 1e87508d-89c2-42f0-8a7e-645a0f50ca58
    hr := io.GetFolder(FOLDERID_AppsFolder, knownfoldernative);
    if hr = S_OK then
    begin
      hr := knownfoldernative.GetShellItem(0, IID_IShellItem2, si);
      if Succeeded(hr) then
      begin
        if si <> nil then
        begin
          si.GetAttributes(SFGAO_FILESYSTEM, sfgao);
          isFileSystem := (sfgao and SFGAO_FILESYSTEM) <> 0;

          if not isFileSystem then
          begin
            knownfoldernative.GetFolderDefinition(fd);
            if SHGetDesktopFolder(psfDesktop) = S_OK then
              if SHGetDesktopFolder(dt) = S_OK then
                if knownfoldernative.GetIDList(KF_FLAG_DEFAULT, pidControl) = S_OK then
                  if psfDesktop.BindToObject(pidControl, nil, IID_IShellFolder, psfControl) = S_OK then
                    if psfControl.EnumObjects(0, SHCONTF_NONFOLDERS or SHCONTF_INCLUDEHIDDEN, pEnumList) S_OK then
                    begin
                      while pEnumList.Next(1, pidChild, celtFetched) = 0 do
                      begin
                        pidAbsolute := ILCombine(pidControl, pidChild);
                        if dt.BindToObject(pidControl, nil, IID_IShellFolder2, Pointer(pc)) = S_OK then
                        begin
                          var sa, lnk, flnk: OleVariant;
//                          var cs: SHCOLUMNID;
//                          cs.fmtid := StringToGUID('{9F4C2855-9F79-4B39-A8D0-E1D42DE1D5F3}');
//                          cs.pid := 5;
                          if pc.GetDetailsEx(pidChild, SHCOLUMNID(PKEY_AppUserModel_ID), @sa) = S_OK then
                          begin
                            var re: HRESULT;
                            try
                              re := (pc.GetDetailsEx(pidChild, SHCOLUMNID(PKEY_Link_Arguments), @flnk));
                              re := (pc.GetDetailsEx(pidChild, SHCOLUMNID(PKEY_Link_TargetParsingPath), @lnk));
//                              SHGetPathFromIDList(pidAbsolute, fPath);
                            except
                              lnk := '';
                            end;

                            if IsValidAppPackageName(sa)
                            or (Pos('!Setti', sa) > 0)
                            then
                            begin
                              SHGetFileInfo(LPCTSTR(pidAbsolute), 0, fileInfo, SizeOf(fileInfo),
                                SHGFI_PIDL or SHGFI_DISPLAYNAME or SHGFI_ICON or SHGFI_SYSICONINDEX {or SHGFI_SHELLICONSIZE} or SHGFI_LARGEICON);

//                              pc.GetUIObjectOf(0, )
//                              var c:uint32;
//                              pc.GetAttributesOf(1,pidChild,c);
                              CoTaskMemFree(pidAbsolute);

                              // Get WSA (wsaclient.exe) info
                              if Pos('!Sett', sa) > 0 then
                              begin
                                FDisplayName := fileInfo.szDisplayName;
                                FAppUserModelId := sa;
                              end
                              // and APK installed ones info
                              else if LowerCase(lnk).Contains('wsaclient.exe') then//if IsWsaClientLnkTarget(sa) then
                              begin
                                Item := TStrings.Create;
                                try

                                finally
                                  Item.Free;
                                end;
                              end;

                              var icon := TIcon.Create;
                              try
                                icon.Handle := fileInfo.hIcon;

                              finally
                                icon.Free;
                              end;
                            end;


                          end;

                        end;
                      end;
                    end;
          end;
        end;
      end;
    end;
  end;

  CoUninitialize;
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
