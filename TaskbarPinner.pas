unit TaskbarPinner;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  ShlObj, ActiveX, ShellApi, ComObj, RegChangeThread, DWMApi;

const
  SID_IShellDispatch6        = '{286e6f1b-7113-4355-9562-96b7e9d64c54}';
  IID_IShellDispatch5: TGUID = SID_IShellDispatch6;


const
  CLSID_TaskbandPin: TGUID = '{90AA3A4E-1CBA-4233-B8BB-535773D48449}';
  CLSID_TrayNotify: TGUID  = '{25DEAD04-1EAC-4911-9E3A-AD0A4AB560FD}';

  IID_IFlexibleTaskbarPinnedList: TGUID = '{60274FA2-611F-4B8A-A293-F27BF103D148}';
  IID_IUnknown: TGUID = '{00000000-0000-0000-C000-000000000046}';
  IID_IFlexibleTaskbarPinnedList0: TGUID = '{53d51c3c-d7e0-4fec-b4c6-33b4f8a41c64}';
  IID_IFlexibleTaskbarPinnedList1: TGUID = '{60274FA2-611F-4B8A-A293-F27BF103D148}';
  IID_IFlexibleTaskbarPinnedList2: TGUID = '{BBD20037-BC0E-42F1-913F-E2936BB0EA0C}';
  IID_IFlexibleTaskbarPinnedList3: TGUID = '{C3C6EB6D-C837-4EAE-B172-5FEC52A2A4FD}';
  IID_IPinnedList3: TGUID = '{0DD79AE2-D156-45D4-9EEB-3B549769E940}';
  SID_ITrayNotify = '{FB852B2C-6BAD-4605-9551-F15F87830935}';
  IID_ITrayNotify: TGUID = '{FB852B2C-6BAD-4605-9551-F15F87830935}';
  SID_INotificationCB = '{D782CCBA-AFB0-43F1-94DB-FDA3779EACCB}';
  IID_INotificationCB: TGUID = '{D782CCBA-AFB0-43F1-94DB-FDA3779EACCB}';

type
  PLMC =(PLMC_EXPLORER = 4);

  IFlexibleTaskbarPinnedList = interface(IUnknown)
    ['{60274FA2-611F-4B8A-A293-F27BF103D148}']
//    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
//    function _AddRef: Integer; stdcall;
//    function _Release: Integer; stdcall;
    function EnumObjects(var p2: IEnumFullIDList): HRESULT; stdcall;
    function GetPinnableinfo: HRESULT; stdcall;
    function IsPinnable: HRESULT; stdcall;
    function Resolve: HRESULT; stdcall;
    function LeaveFolder: HRESULT; stdcall;
    function GetChangeCount: HRESULT; stdcall;
    function IsPinned: HRESULT; stdcall;
    function GetPinnedItem: HRESULT; stdcall;
    function GetAppIDForPinnedItem: HRESULT; stdcall;
    function ItemChangeNotify: HRESULT; stdcall;
    function UpdateForRemovedItemsAsNecessary: HRESULT; stdcall;
    function PinShellLink: HRESULT; stdcall;
    function GetPinnedItemForAppID: HRESULT; stdcall;
    function ApplyPrependDefaultTaskbarLayour: HRESULT; stdcall;
    function ApplyInPlaceTaskbarLayout: HRESULT; stdcall;
    function ApplyReorderTaskbarLayout: HRESULT; stdcall;
    function IsEmpty: HRESULT; stdcall;
  end;

  // Windows Vista
  IPinnedList = interface(IUnknown)
    ['{C3C6EB6D-C837-4EAE-B172-5FEC52A2A4FD}']
    function EnumObjects: HRESULT; stdcall;   // $18
    function Modify: HRESULT; stdcall;        // $20
    function GetChangeCount: HRESULT; stdcall;// $28
    function IsPinnable: HRESULT; stdcall;    // $30
    function Resolve: HRESULT; stdcall;       // $38
    function IsPinned: HRESULT; stdcall;      // $40
  end;

  // Windows 7, 8, 8.1
  IPinnedList2 = interface(IUnknown)
    ['{BBD20037-BC0E-42F1-913F-E2936BB0EA0C}']
    function EnumObjects: HRESULT; stdcall;   // $18
    function Modify: HRESULT; stdcall;        // $20
    function GetChangeCount: HRESULT; stdcall;// $28
    function GetPinnableInfo: HRESULT; stdcall;// $30
    function IsPinnable: HRESULT; stdcall;    // $38
    function Resolve: HRESULT; stdcall;       // $40
    function IsPinned: HRESULT; stdcall;      // $48
    function GetPinnedItem: HRESULT; stdcall; // $50
    function GetAppIDForPinnedItem: HRESULT; stdcall; // $58
    function ItemChangeNotify: HRESULT; stdcall; // $60
    function UpdateForRemovedItemsAsNecessary: HRESULT; stdcall; // $68
  end;

  // Windows 10 build 1809+
  IPinnedList3 = interface(IUnknown)
    ['{0DD79AE2-D156-45D4-9EEB-3B549769E940}']
    function EnumObjects(var ppv: IEnumFullIDList): HRESULT; stdcall;   // $18
    function GetPinnableInfo(ido: IDataObject; pinnableFlag: Integer; var isi, isi2: IShellItem; var us: USHORT; i: integer): HRESULT; stdcall;// $20
    function IsPinnable(pn: IDataObject; pinableFlag: Integer): HRESULT; stdcall;    // $28
    function Resolve(hWnd: HWND; l: ULONG; pidl: PCIDLIST_ABSOLUTE; var pidlo: PCIDLIST_ABSOLUTE): HRESULT; stdcall;       // $30
    function LegacyModify(unpin: PCIDLIST_ABSOLUTE; pin: PCIDLIST_ABSOLUTE): HRESULT; stdcall; // $38
    //Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Taskband", L"FavoritesChanges
    function GetChangeCount(var FavoritesChanges: ULONG): HRESULT; stdcall;// $40
    function IsPinned(pin: PCIDLIST_ABSOLUTE): HRESULT; stdcall; // $48 S_OK = pinned S_FALSE = not pinned
    function GetPinnedItem(pidl: PCIDLIST_ABSOLUTE; var pidlI: PCIDLIST_ABSOLUTE): HRESULT; stdcall; // $50
    function GetAppIDForPinnedItem(pidl: PCIDLIST_ABSOLUTE; var apID: USHORT): HRESULT; stdcall; // $58
    function ItemChangeNotify(pidl1: PCIDLIST_ABSOLUTE; pidl2: PCIDLIST_ABSOLUTE): HRESULT; stdcall; // $60
    function UpdateForRemovedItemsAsNecessary: HRESULT; stdcall; // $68
    function PinShellLink(us: USHORT; var ish: IShellLinkW): HRESULT; stdcall; // $70
    function GetPinnedItemForAppID(apID: USHORT; var pidl: PCIDLIST_ABSOLUTE): HRESULT; stdcall; // $78
    function Modify(unpin: PCIDLIST_ABSOLUTE; pin: PCIDLIST_ABSOLUTE; caller: PLMC): HRESULT; stdcall; // $80
  end;

  LPNOTIFYITEM = ^tagNOTIFYITEM;
  tagNOTIFYITEM = record
    pszExeName: LPWSTR;
    pszIconText: LPWSTR;
    hIcon: HICON;
    hWnd: HWND;
    dwUserPref: DWORD;
    uID: UINT;
    guitItem: TGUID;
  end;
  NOTIFYITEM = tagNOTIFYITEM;


  INotificationCB = interface(IUnknown)
    [SID_INotificationCB]
    function Notify(dwMessage: DWORD; var pNotifyItem: NotifyItem): HRESULT; stdcall;
  end;

  ITrayNotify = interface(IUnknown)
    [SID_ITrayNotify]
    function RegisterCallback(var pNotifyCB: INotificationCB): HRESULT; stdcall;
    function SetPreference(pNotifyItem: LPNOTIFYITEM): HRESULT; stdcall;
    function EnableAutoTray(bTraySetting: BOOL): HRESULT; stdcall;
  end;

  { interface IShellDispatch6 Windows 8+ }
  IShellDispatch6 = interface(IShellDispatch5)
    [SID_IShellDispatch6]
    function SearchCommand: HRESULT; stdcall; { [helpstring] }
  end;

type
  TOnTaskbarPinChange = procedure(Sender: TObject) of Object;

  TTaskbarPinner = class (TObject)
  private
    FOnTaskbarPinChange: TOnTaskbarPinChange;
    procedure SetOnTaskbarPinChange(const Value: TOnTaskbarPinChange);
    function GetPinnedList: TStrings;
  public
    function PinLnk(lnkPath: string; UnPinIfPinned: Boolean = False): Boolean;
  published
    property OnTaskbarPinChange: TOnTaskbarPinChange read FOnTaskbarPinChange write SetOnTaskbarPinChange;
    property Items: TStrings read GetPinnedList;
  end;

implementation

uses
  helperFuncs;

{ TTaskbarPinner }

function TTaskbarPinner.GetPinnedList: TStrings;
var
  hr: HRESULT;
  vPinList: IPinnedList3;
  vEnumList: IEnumFullIDList;
  vPIDL: PItemIDList;
  vFileInfo: TSHFileInfoW;
  ul: ULONG;
  pn: array[0..1024] of char;
begin
  hr := ActiveX.CoCreateInstance(CLSID_TaskbandPin, nil, CLSCTX_INPROC_SERVER, IID_IPinnedList3, vPinList);
  if hr = S_OK then
  begin
    hr := vPinList.EnumObjects(vEnumList);
    if hr = S_OK then
    begin
      hr := vEnumList.Reset;
      ul := 0;
      repeat
        hr := vEnumList.Next(1, vPIDL, ul);
        if hr = S_OK then
        begin
          FillChar(vFileInfo, SizeOf(vFileInfo), 0);
          ul := SHGetFileInfo(PChar(vPIDL), 0, vFileInfo, SizeOf(vFileInfo), SHGFI_PIDL or SHGFI_DISPLAYNAME);
          if ul > 0 then
          begin
            SHGetPathFromIDList(vPIDL, pn);
            var strName := string(pn); // fullpath to .lnk location
            if IsImmersivePidl(vPIDL) then
              Result.AddPair(vFileInfo.szDisplayName, 'UWP')
            else
              Result.AddPair(vFileInfo.szDisplayName, strName);
            CoTaskMemFree(vPIDL);
          end;
        end;

      until hr <> S_OK;
    end;

  end;

end;

function TTaskbarPinner.PinLnk(lnkPath: string;
  UnPinIfPinned: Boolean): Boolean;
var
  hr: HRESULT;
  vPinList: IPinnedList3;
  vPIDL: PItemIDList;
  vBuff: array[0..1024] of WideChar;
  cc: Cardinal;
begin
  CoInitialize(nil);

  Result := False;

  hr := ActiveX.CoCreateInstance(CLSID_TaskbandPin, nil, CLSCTX_INPROC_SERVER, IID_IPinnedList3, vPinList);
  if Succeeded(hr) then
  begin
    StringToWideChar(lnkPath, vBuff, (High(vBuff) - Low(vBuff) + 1));
    vPIDL := ILCreateFromPath(@vBuff);
    try
      hr := vPinList.IsPinned(PCIDLIST_ABSOLUTE(vPIDL));
      if hr = S_OK then
      begin
        if UnPinIfPinned then
          hr := vPinList.Modify(PCIDLIST_ABSOLUTE(vPIDL), nil, PLMC_EXPLORER);
      end
      else
        hr := vPinList.Modify(nil, PCIDLIST_ABSOLUTE(vPIDL), PLMC_EXPLORER);

      if Succeeded(hr) then
      begin
        vPinList.GetChangeCount(cc); // should we notify registry changed? #TODO
        Result := True;
      end;
    finally
      ILFree(vPIDL);
    end;
  end;

  CoUninitialize;
end;

procedure TTaskbarPinner.SetOnTaskbarPinChange(
  const Value: TOnTaskbarPinChange);
begin
  FOnTaskbarPinChange := Value;
end;

end.

