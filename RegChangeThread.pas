unit RegChangeThread;

interface

uses
  Classes, Windows, Messages, Registry;

const
  WM_REGKEYCHANGE = WM_USER + 42;
  REG_NOTIFY_THREAD_AGNOSTIC = $10000000; // Windows 8+ enables the use of
                                          // RegNotifyChangeKeyValue for ThreadPool threads

type
  //author   Author: Luthfi B Hakim
  TRegMon = class(TComponent)
  private
    FMonitordKey: string;
    FOnChange: TNotifyEvent;
    FRootKey: HKey;
    FMonitor: TThread;
    FWatchSubKeys: Boolean;
    FOnActivate: TNotifyEvent;
    FOnDeactivate: TNotifyEvent;
    procedure SetActive(const Value: Boolean);
    procedure SetMonitoredKey(const Value: string);
    procedure SetRootKey(const Value: HKey);
    function GetActive: Boolean;
    procedure SetWatchSubKeys(const Value: Boolean);
  protected
    procedure DoRegChanged;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Activate;
    procedure Deactivate;
  published
    property RootKey: HKEY read FRootKey write SetRootKey default HKEY_CURRENT_USER;
    property MonitoredKey: string read FMonitordKey write SetMonitoredKey;
    property WatchSubKeys: Boolean read FWatchSubKeys write SetWatchSubKeys;
    property Active: Boolean read GetActive write SetActive default False;

    // event that will be fired when monitored registry key is changed
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    // event that will be fired when monitoring is activated
    property OnActivate: TNotifyEvent read FOnActivate write FOnActivate;
    // evetn that will be fired when monitoring is deactivated
    property OnDeactivate: TNotifyEvent read FOnDeactivate write FOnDeactivate;
  end;

  TRegChangeThread = class(TThread)
  private
    FReg: TRegistry;
    FEvent: Integer;
    FKey: string;
    FRootKey: HKEY;
    FWatchSub: Boolean;
    FFilter: Integer;
    FWnd: THandle;
    procedure Initialize;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Execute; override;
    property Key: string read FKey write FKey;
    property RootKey: HKey read FRootKey write FRootKey;
    property WatchSub: Boolean read FWatchSub write FWatchSub;
    property Filter: Integer read FFilter write FFilter;
    property Wnd: THandle read FWnd write FWnd;
  end;

implementation

uses
  SysUtils;

type
  TMonitorThread = class(TThread)
  private
    FReg: TRegistry;
    FOwner: TRegMon;
    FFilter: DWORD;
    FTerminateEvent: THandle;
    FMonitorEvent: THandle;
    procedure Setup; // Here we initiated our object and vars prior to start
                      // executing the thread
    procedure TearDown; // Here we finalize our object and when the thread is terminated
  protected
    // main code of the thread
    procedure Execute; override;
  public
    constructor Create(AOwner: TRegMon); reintroduce;
    // we reintroduce new Terminate method, since we want to do something after
    // calling the original Terminate
    procedure Terminate; reintroduce;
  end;


{ TRegChangeThread }

constructor TRegChangeThread.Create;
begin
  inherited Create(True); // So properties can be set before calling Resume
  FReg := TRegistry.Create;
end;

destructor TRegChangeThread.Destroy;
begin
  FReg.Free;
  inherited;
end;

procedure TRegChangeThread.Execute;
begin
//  inherited;
  Initialize;
  while not Terminated do
  begin
    if WaitForSingleObject(FEvent, INFINITE) = WAIT_OBJECT_0 then
    begin
      SendMessage(FWnd, WM_REGKEYCHANGE, FRootKey, LongInt(PChar(FKey)));
    end;
  end;
end;

procedure TRegChangeThread.Initialize;
begin
  FReg.RootKey := RootKey;
  if not FReg.OpenKey(Key, False) then
  begin
    raise Exception.Create('Failed to open registry key ' + Key);
  end;
  FEvent := CreateEvent(nil, LongBool(False), LongBool(False), 'RegChange');
  RegNotifyChangeKeyValue(
    FReg.CurrentKey,
    LongBool(FWatchSub),
    FFilter,
    FEvent,
    LongBool(True)
  );
end;

{ TRegMon }

procedure TRegMon.Activate;
begin
  if Active then
    Exit;

  FMonitor := TMonitorThread.Create(Self);
  if Assigned(FOnActivate) then
    FOnActivate(Self);
end;

constructor TRegMon.Create(AOwner: TComponent);
begin
  inherited;
  FRootKey := HKEY_CURRENT_USER;
end;

procedure TRegMon.Deactivate;
var
  vThread: TMonitorThread;
begin
  if not Active then Exit;

  // we have to specifically typecast to TMonitorThread since wa want to call
  // the reintroduced Terminate instead of the original Terminate of TThread
  vThread := TMonitorThread(FMonitor);
  FMonitor := nil;
  vThread.Terminate;  // call the reintroduced Terminate
  Sleep(0);           // to immediately yield cpu to other thread/process.
                      // We aim for our monitoring thread to "sense" termination
                      // and clean accordingly.
  if Assigned(FOnDeactivate) then
    FOnDeactivate(Self);
end;

destructor TRegMon.Destroy;
begin
  // Make sure that we stop the monitoring thread prior destruction
  Deactivate;
  inherited;
end;

procedure TRegMon.DoRegChanged;
begin
  if Assigned(FOnChange) then 
    FOnChange(Self);
end;

function TRegMon.GetActive: Boolean;
begin
  Result := FMonitor <> nil;
end;

procedure TRegMon.SetActive(const Value: Boolean);
begin
  if Active <> Value then
  begin
    if Value then
      Activate
    else
      Deactivate;
  end;
end;

procedure TRegMon.SetMonitoredKey(const Value: string);
begin
  if FMonitordKey <> Value then
  begin
    Deactivate;
    FMonitordKey := Value;
  end;
end;

procedure TRegMon.SetRootKey(const Value: HKey);
begin
  if FRootKey <> Value then
  begin
    Deactivate;
    FRootKey := Value;
  end;
end;

procedure TRegMon.SetWatchSubKeys(const Value: Boolean);
begin
  if FWatchSubKeys <> Value then
  begin
    Deactivate;
    FWatchSubKeys := Value;
  end;
end;

{ TMonitorThread }

constructor TMonitorThread.Create(AOwner: TRegMon);
begin
  FOwner := AOwner;
  inherited Create(False);
  FreeOnTerminate := True;
  FReg := TRegistry.Create;
  FReg.RootKey := FOwner.FRootKey;
  if not FReg.OpenKeyReadOnly(FOwner.FMonitordKey) then
    raise Exception.Create('Can''t open regitry key!');
end;

procedure TMonitorThread.Execute;
var
  vEvents: array[1..2] of THandle;
begin
//  inherited;
  Setup;
  try
    vEvents[1] := FMonitorEvent;
    vEvents[2] := FTerminateEvent;
    while not Terminated do
    begin
      if WaitForMultipleObjects(2, @vEvents, False, INFINITE) = WAIT_OBJECT_0 then
      begin
        Synchronize(FOwner.DoRegChanged);
        ResetEvent(FMonitorEvent);
        if RegNotifyChangeKeyValue(FReg.CurrentKey,
          FOwner.FWatchSubKeys, FFilter, FMonitorEvent, True) <> ERROR_SUCCESS then
          Exit;        
      end;      
    end;    
  finally
    TearDown;
  end;  
end;

procedure TMonitorThread.Setup;
begin
  FFilter := {REG_NOTIFY_CHANGE_NAME or }REG_NOTIFY_CHANGE_LAST_SET;  
  FMonitorEvent := CreateEvent(nil, True, False, nil);
  FTerminateEvent := CreateEvent(nil, True, False, nil);
  if RegNotifyChangeKeyValue(FReg.CurrentKey,
    FOwner.FWatchSubKeys, FFilter, FMonitorEvent, True) <> ERROR_SUCCESS then
    raise Exception.Create('Can''t start monitoring!');
  
end;

procedure TMonitorThread.TearDown;
begin
  CloseHandle(FTerminateEvent);
  CloseHandle(FMonitorEvent);
  FReg.CloseKey;
  FReg.Free;
end;

procedure TMonitorThread.Terminate;
begin
  inherited Terminate;
  SetEvent(FTerminateEvent);
end;

end.
