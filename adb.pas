unit adb;

interface

uses
  Winapi.Windows, System.Win.ScktComp;

type
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
