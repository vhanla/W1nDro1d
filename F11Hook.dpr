library F11Hook;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  Winapi.Windows,
  Winapi.Messages,
  Winapi.ActiveX,
  System.Classes,
  System.SysUtils;

const
  MemMapFile = 'WinDroidWnd';
  WM_USER = $0400;
  WM_COPYDATA = $004A;
  WM_TOGGLEFULLSCREEN = WM_USER + 9;

const
  LLKHF_ALTDOWN = $20;
  LLKHF_UP = $80;

{ Define a record for recording and passing information process wide }
type
  PKBDLLHOOKSTRUCT = ^TKBDLLHOOKSTRUCT;
  TKBDLLHOOKSTRUCT = record
    vkCode: Cardinal;
    scanCode: Cardinal;
    flags: Cardinal;
    time: Cardinal;
    dwExtrainfo: Cardinal;
  end;

  PHookRec = ^THookRec;
  THookRec = packed record
    HookHandle: HHOOK;
    AppHandle: HWND;
    CtrlWinHandle: HWND;
    KeyCount: DWORD;
    CtrlDown: BOOL;
    ShiftDown: BOOL;
  end;

  TSystemKeyCombination = (skLWin,
  skRWin,
  skCtrlEsc,
  skAltTab,
  skAltEsc,
  skCtrlShiftEsc,
  skAltF4);
  TSystemKeyCombinations = set of TSystemKeyCombination;

{$R *.res}

var
  hObjHandle: THandle; { Variable for the file mappgin object }
  lpHookRec: PHookRec;
  InvalidCombinations: TSystemKeyCombinations;
  AltPressed: BOOL;
  CtrlPressed: BOOL;
  ShiftPressed: BOOL;

procedure SwitchToThisWindow(h1: hWnd; x: bool); stdcall;
  external user32 Name 'SwitchToThisWindow';
{ Pointer to our hook record }
procedure MapFileMemory (dwAllocSize: DWORD);
begin
  { Create a process wide memory mapped variable }
  hObjHandle := CreateFileMapping(INVALID_HANDLE_VALUE, nil, PAGE_READWRITE, 0, dwAllocSize, MemMapFile);
  if hObjHandle = 0 then
  begin
    raise Exception.Create('Hook couldn''t create file map object.');
    Exit;
  end;

  { Get a pointer to our process wide memory mapped file }
  lpHookRec := MapViewOfFile(hObjHandle, FILE_MAP_WRITE, 0, 0, dwAllocSize);
  if lpHookRec = nil then
  begin
    CloseHandle(hObjHandle);
    raise Exception.Create('Hook couldn''t map file.');
    Exit;
  end;
end;

procedure UnmapFileMemory;
begin
  { Delete our process wide memory mapped variable }
  if lpHookRec <> nil then
  begin
    UnmapViewOfFile(lpHookRec);
    lpHookRec := nil;
  end;

  if hObjHandle > 0 then
  begin
    CloseHandle(hObjHandle);
    hObjHandle := 0;
  end;
end;

function GetHookRecPointer:Pointer; stdcall;
begin
  { Return a pointer to our process wide memory mapped variable }
  Result := lpHookRec;
end;

function KeyboardProc(nCode: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
var
  ParentHandle: HWND;
  hs: PKBDLLHOOKSTRUCT;
  command: string;
  AppClassName: array[0..255] of char;
  currWnd: HWND;
begin
  Result := 0;

  case nCode of
    HC_ACTION: // HC_ACTION is the only allowed for WH_KEYBOARD_LL
    begin

      hs := PKBDLLHOOKSTRUCT(lParam);

      if (wParam = WM_KEYDOWN) or (wParam = WM_SYSKEYDOWN) then
      begin
        if (hs^.vkCode = VK_SHIFT) or (hs^.vkCode = VK_LSHIFT) or (hs^.vkCode = VK_RSHIFT) then
        begin
          ShiftPressed := True;
        end;

        if (hs^.vkCode = VK_CONTROL) or (hs^.vkCode = VK_LCONTROL) or (hs^.vkCode = VK_RCONTROL) then
        begin
          CtrlPressed := True;
        end;
      end;

      if (wParam = WM_KEYUP) or (wParam = WM_SYSKEYUP) then
      begin

        /// NOTE: When this callback function is called in response to a change
        ///  in the state of a key, the callback function is called before the
        ///  asynchronous state of the key is updated. Consequently, the
        ///  asynchronous state of the key cannot be determined by calling
        ///  GetAsyncKeyState from within this callback

        if (hs^.vkCode = VK_SHIFT) or (hs^.vkCode = VK_LSHIFT) or (hs^.vkCode = VK_RSHIFT) then
        begin
          ShiftPressed := False;
        end;

        if (hs^.vkCode = VK_CONTROL) or (hs^.vkCode = VK_LCONTROL) or (hs^.vkCode = VK_RCONTROL) then
        begin
          CtrlPressed := False;
        end;

        // Use hard coded F11 as fullscreen toggler
        if (hs^.vkCode = VK_F11) then
        begin

          currWnd := GetForegroundWindow;
          if currWnd > 0 then
          begin
            if not IsWindow(currWnd) then
            begin
              Result := CallNextHookEx(lpHookRec^.HookHandle, nCode, wParam, lParam);
              Exit;
            end;
          end;

          ParentHandle := FindWindow('FMTWinDroidHwnd', nil);
          if ParentHandle > 0 then
          begin
            // FireMonkey windows to have a parent window with win class name TFMAppClass
            // However, any other FireMonkey application has it too, so we need to get our one only
            //ParentHandle := GetParent(ParentHandle);
//            ParentHandle := GetWindowLong(ParentHandle, GWL_HWNDPARENT);
//            GetClassName(ParentHandle, AppClassName, 255);
//            OutputDebugString(PChar('FONCE '+ AppClassName));


            /// The hook procedure should process a message in less time than the data entry specified in the LowLevelHooksTimeout value in the following registry key:
            ///  HKEY_CURRENT_USER\Control Panel\Desktop
            ///  The value is in milliseconds. If the hook procedure times out, the system passes the message to the
            ///  next hook. However, on Windows 7 and later, the hook is silently removed without being called.
            ///  There is no way for the application to know whether the hook is removed.
//            PostMessage(ParentHandle, WM_TOGGLEFULLSCREEN, wParam, Winapi.Windows.LPARAM(PChar(command)));
//            PostMessage(ParentHandle, WM_TOGGLEFULLSCREEN, wParam, lParam);
            SendMessageTimeout(ParentHandle, WM_TOGGLEFULLSCREEN, wParam, lParam, SMTO_ABORTIFHUNG or SMTO_NORMAL, 5, nil);
          end;
        end;
      end;
    end;
  end;

  Result := CallNextHookEx(lpHookRec^.HookHandle, nCode, wParam, lParam);
end;

function StartHook:BOOL stdcall;
begin
  Result := False;
  { If we have a process wide memory variable and the hook has not already been set }
  if ((lpHookRec <> nil) and (lpHookRec^.HookHandle = 0)) then
  begin
    { Set the hook and remember our hook handle }
    lpHookRec^.HookHandle := SetWindowsHookEx(WH_KEYBOARD_LL, @KeyboardProc, HInstance, 0);
    Result := True;
  end;
end;

procedure StopHook; stdcall;
begin
  { If we have a process wide memory variable and the hook has already been ser }
  if ((lpHookRec <> nil) and (lpHookRec^.HookHandle <> 0)) then
  begin
    { Remove our hook and clear our hook handle }
    if (UnhookWindowsHookEx(lpHookRec^.HookHandle) <> False) then
    begin
      lpHookRec^.HookHandle := 0;
    end;
  end;
end;

procedure DllEntryPoint(dwReason: DWORD);
begin
  case dwReason of
    DLL_PROCESS_ATTACH:
    begin
      { If we are getting mapped into a process, then get a pointer
        to our process wide memory mapped variable }
      hObjHandle := 0;
      lpHookRec := nil;
      MapFileMemory(SizeOf(lpHookRec^));
    end;
    DLL_PROCESS_DETACH:
    begin
      { If we are getting unmapped from a proces then, remove the
        pointer to our process wide memory mapped variable }
      UnmapFileMemory;
    end;
  end;
end;

Exports
  KeyboardProc Name 'KEYBOARDPROC',
  GetHookRecPointer name 'GETHOOKRECPOINTER',
  StartHook name 'STARTHOOK',
  StopHook name 'STOPHOOK';

begin
  DllProc := @DllEntryPoint;
  DllEntryPoint(DLL_PROCESS_ATTACH);
end.


