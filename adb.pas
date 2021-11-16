unit adb;

interface

uses
  Winapi.Windows, System.Win.ScktComp;

const
    AP_VERY_HIGH = 0;
    AP_HIGH = 1;
    AP_MODERATE_HIGH = 2;
    AP_MEDIUM_HIGH = 3;
    AP_MEDIUM = 4;
    AP_LOW_MODERATE = 5;
    AP_LOW = 6;
    AP_MODERATE = 7;
    AP_LOW_MEDIUM = 8;
    AP_CRITICAL = 9;
type

  TPermissions = (
    androidpermissionCALL_PHONE = AP_HIGH,
    androidpermissionSEND_SMS   = AP_HIGH,
    androidPermissionWRITE_EXTERNAL_STORAGE = AP_MEDIUM,
    androidPermissionREAD_CONTACTS = 3,
    androidPermissionWRITE_CONTACTS = 2,
    androidPermissionREAD_CALENDAR = 4,
    androidPermissionWRITE_CALENDAR = 4,
    comAndroidBrowserPermissionREAD_HISTORY_BOOKMARKS = 3,
    comAndroidBrowserPermissionWRITE_HISTORY_BOOKMARKS = 2,
    androidPermissionREAD_LOGS = 0,
    androidPermissionWRITE_SETTINGS = 4,
    androidPermissionREAD_SYNC_SETGINS = 5,
    androidPermissionRECEIVE_BOOT_COMPLETED = 2,
    androidPermissionRESTART_PACKAGES = 1,
    androidPermissionGET_TASKS = 3,
    androidPermissionSYSTEM_ALERT_WINDOW = 1,
    androidPermissionVIBRATE = 6,
    androidPermissionCAMERA = 2,
    androidPermissionACCESS_LOCATION_EXTRA_COMMANDS = 3,
    androidPermissionACCESS_MOCK_LOCATION = 7,
    androidPermissionBATTERY_STATUS = 6,
    androidPermissionBLUETOOTH_ADMIN = 4,
    androidPermissionBROADCAST_STICKY = 8,
    androidPermissionCHANGE_CONFIGURATION = 3,
    androidPermissionCLEAR_APP_CACHE = 6,
    androidPermissionDISABLE_KEYGUARD = 3,
    androidPermissionEXPAND_STATUS_BAR = 3,
    androidPermissionFLASHLIGHT = 6,
    androidPermissionGET_PACKAGE_SIZE = 5,
    androidPermissionKILL_BACKGROUND_PROCESSES = AP_HIGH,
    androidPermissionMODIFY_AUDIO_SETTINGS = AP_LOW,
    androidPermissionMOUNT_FORMAT_FILESYSTEMS = AP_MEDIUM,
    androidPermissionMOUNT_UNMOUNT_FILESYSTEMS = AP_MODERATE,
    androidPermissionNFC = AP_MEDIUM,
    androidPermissionPROCESS_OUTGOING_CALLS = AP_VERY_HIGH,
    androidPermissionREAD_SYNC_STATS = AP_MODERATE,
    androidPermissionRECORD_AUDIO = AP_MODERATE_HIGH,
    androidPermissionSET_ALARM = AP_LOW,
    androidPermissionSET_TIME_ZONE = AP_LOW,
    androidPermissionSET_WALLPAPER = AP_LOW,
    androidPermissionSUBSCRIBED_FEEDS_READ = AP_MEDIUM,
    androidPermissionSUBSCRIBED_FEEDS_WRITE = AP_LOW_MEDIUM,
    androidPermissionUSE_SIP = AP_MEDIUM_HIGH,
    androidPermissionWRITE_SECURE_SETTINGS = AP_VERY_HIGH,
    androidPermissionREAD_PROFILE = AP_MEDIUM_HIGH,
    comAndroidLauncherPermissionINSTALL_SHORTCUT = AP_MODERATE_HIGH,
    androidPermissionREAD_EXTERNAL_STORAGE = AP_LOW,
    comAndroidVoicemailPermissionADD_VOICEMAIL = AP_MEDIUM_HIGH,
    androidPermissionAUTHENTICATE_ACCOUNTS = AP_VERY_HIGH,
    comAndroidEmailPermissionREAD_ATTACHMENT = AP_HIGH,
    androidPermissionREAD_USER_DICTIONARY = AP_LOW,
    androidPermissionWRITE_USER_DICTIONARY = AP_LOW,
    androidPermissionINSTALL_DRM = AP_MODERATE_HIGH,
    androidPermissionADD_SYSTEM_SERVICE = AP_CRITICAL,
    androidPermissionACCESS_WIMAX_STATE = AP_LOW_MODERATE,
    androidPermissionCHANGE_WIMAX_STATE = AP_MODERATE,
    comAndroidProvidersImPermissionREAD_ONLY = AP_HIGH
  );

  TADB = class
  private
    PID: Cardinal;
    FPath: string;
    FClient: TClientSocket;
    FPort: Integer;
    FHost: string;
    procedure SetPath(const Value: string);
    procedure SetHost(const Value: string);
    procedure SetPort(const Value: Integer);
  protected
    procedure OnSocketError(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure OnSocketRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure OnSocketDisconnect(Sender: TObject; Socket: TCustomWinSocket);
  public
    function StartServer(forceRestart: Boolean = False): Boolean;
    function StopServer: Boolean;
    function IsADBServerOn: Boolean;
    function ConnectSocket(port: Integer = 5037): Boolean;
    function RunScript(const command: string): string;

    constructor Create;
    destructor Destroy; override;

    property Path: string read FPath write SetPath;
    property Port: Integer read FPort write SetPort;
    property Host: string read FHost write SetHost;
  end;

implementation

{ TADB }

function TADB.ConnectSocket(port: Integer = 5037): Boolean;
begin
  FClient.Address := FHost;
  if port <> 5037 then
    FClient.Port := port
  else
    FClient.Port := FPort;
  FClient.Active := True; // Activates the client

  Result := FClient.Socket.Connected;
end;

constructor TADB.Create;
begin
  FClient := TClientSocket.Create(nil);

  FPort := 5037; // default ADB socket port
  FHost := '127.0.0.1'; // localhost

  FClient.OnError := OnSocketError;
  FClient.OnDisconnect := OnSocketDisconnect;
  FClient.OnRead := OnSocketRead;
end;

destructor TADB.Destroy;
begin
  FClient.Free;
  inherited;
end;

function TADB.IsADBServerOn: Boolean;
begin
  Result := False;
end;

procedure TADB.OnSocketDisconnect(Sender: TObject; Socket: TCustomWinSocket);
begin

end;

procedure TADB.OnSocketError(Sender: TObject; Socket: TCustomWinSocket;
  ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  ErrorCode := 0;
//  FClient.Active := False;
// This can happen when no active server is started
  // do something
end;

procedure TADB.OnSocketRead(Sender: TObject; Socket: TCustomWinSocket);
begin
// Reads and displays the message received from the server
//  Socket.ReceiveText;
{ TODO : Handle receiving binary files }
end;

function TADB.RunScript(const command: string): string;
begin
  if FClient.Socket.Connected then
  begin
    FClient.Socket.SendText(command);
  end
  else
    Result := 'NOT CONNECTED!';
end;

procedure TADB.SetHost(const Value: string);
begin
  FHost := Value;
end;

procedure TADB.SetPath(const Value: string);
begin
  FPath := Value;
end;

procedure TADB.SetPort(const Value: Integer);
begin
  FPort := Value;
end;

function TADB.StartServer(forceRestart: Boolean): Boolean;
begin

end;

function TADB.StopServer: Boolean;
begin

end;

end.
