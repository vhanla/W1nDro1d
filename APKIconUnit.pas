unit APKIconUnit;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Winapi.Windows, Winapi.ActiveX, System.Win.ComObj, APKIcon_TLB,
  System.Win.StdVCL, Winapi.ShlObj;

type
  TAPKIcon = class(TTypedComObject, IAPKIcon, IExtractIcon, IPersistFile)
  private
    FCurrFile: WideString;
  protected
    //IExtractIcon
    function GetIconLocation(uFlags: UINT; szIconFile: LPWSTR; cchMax: UINT;
      out piIndex: Integer; out pwFlags: UINT): HResult; stdcall;
    function Extract(pszFile: LPCWSTR; nIconIndex: UINT;
      out phiconLarge, phiconSmall: HICON; nIconSize: UINT): HResult; stdcall;
    //IPersist
    function GetClassID(out classID: TCLSID): HResult; stdcall;
    //IPersistFile
    function IsDirty: HResult; stdcall;
    function Load(pszFileName: POleStr; dwMode: Longint): HResult;
      stdcall;
    function Save(pszFileName: POleStr; fRemember: BOOL): HResult;
      stdcall;
    function SaveCompleted(pszFileName: POleStr): HResult;
      stdcall;
    function GetCurFile(out pszFileName: POleStr): HResult;
      stdcall;
  end;

  TIconHandlerFactory = class(TTypedComObjectFactory)
  public
    procedure UpdateRegistry(Register: Boolean); override;
  end;

implementation

uses
  System.SysUtils, System.Win.ComServ, Vcl.Graphics, System.Win.Registry,
  System.Classes;

{ TAPKIcon }

function TAPKIcon.Extract(pszFile: LPCWSTR; nIconIndex: UINT; out phiconLarge,
  phiconSmall: HICON; nIconSize: UINT): HResult;
var
  vIconSize, I: Integer;
  vMaskAnd, vMaskXor: TBitmap;
  vIconInfo: TIconInfo;
  vSL: TStringList;
begin
  // Draw the large icon
  vIconSize := Lo(nIconSize);

  // Create and prepare AND mask
  vMaskAnd := TBitmap.Create;
  try
    vMaskAnd.Monochrome := True;
    vMaskAnd.Width := vIconSize;
    vMaskAnd.Height := vIconSize;

    vMaskAnd.Canvas.Brush.Color := clBlack;
    vMaskAnd.Canvas.FillRect(Rect(0, 0, vIconSize, vIconSize));

    // Create and prepare XOR mask

    vMaskXor := TBitmap.Create;
    try
      vMaskXor.Width := vIconSize;
      vMaskXor.Height := vIconSize;

      vMaskXor.Canvas.Brush.Color := clWhite;
      vMaskXor.Canvas.FillRect(Rect(0, 0, vIconSize, vIconSize));
      vMaskXor.Canvas.Font.Color := clNavy;

      { TODO : Load icon from APK file - needs parsing androidmanifest.xml, get icon path, etc. }
      // Load file FCurrFile
      vSL := TStringList.Create;
      try
        // paint to icon vMaskXOR.canvas....
      finally
        vSL.Free;
      end;

      // Create icon for explorer
      vIconInfo.fIcon := True;
      vIconInfo.xHotspot := 0;
      vIconInfo.yHotspot := 0;
      vIconInfo.hbmMask := vMaskAnd.Handle;
      vIconInfo.hbmColor := vMaskXor.Handle;
      // Return large icon
      phiconLarge := CreateIconIndirect(vIconInfo);
      // Signal success
      Result := S_OK;
    finally
      vMaskAnd.Free;
    end;
  finally
    vMaskXor.Free;
  end;
end;

function TAPKIcon.GetClassID(out classID: TCLSID): HResult;
begin
  classID := CLASS_APKIcon_;
  Result := S_OK;
end;

function TAPKIcon.GetCurFile(out pszFileName: POleStr): HResult;
begin
  Result := E_NOTIMPL;
end;

function TAPKIcon.GetIconLocation(uFlags: UINT; szIconFile: LPWSTR;
  cchMax: UINT; out piIndex: Integer; out pwFlags: UINT): HResult;
begin
  piIndex := 0;
  pwFlags := GIL_DONTCACHE or GIL_NOTFILENAME or GIL_PERINSTANCE;
  Result := S_OK;
end;

function TAPKIcon.IsDirty: HResult;
begin
  Result := E_NOTIMPL;
end;

function TAPKIcon.Load(pszFileName: POleStr; dwMode: Longint): HResult;
begin
  FCurrFile := pszFileName;
  Result := S_OK;
end;

function TAPKIcon.Save(pszFileName: POleStr; fRemember: BOOL): HResult;
begin
  Result := E_NOTIMPL;
end;

function TAPKIcon.SaveCompleted(pszFileName: POleStr): HResult;
begin
  Result := E_NOTIMPL;
end;

{ TIconHandlerFactory }

procedure TIconHandlerFactory.UpdateRegistry(Register: Boolean);
var
  ClsID: string;
begin
  ClsID := GUIDToString(ClassID);
  inherited UpdateRegistry(Register);

  if Register then
  begin
    with TRegistry.Create do
    try
      RootKey := HKEY_CLASSES_ROOT;
      if OpenKey('apkfile\DefaultIcon', True) then
      try
        WriteString('backup', ReadString(''));
        WriteString('', '%1');
      finally
        CloseKey;
      end;

      if OpenKey('apkfile\shellex\IconHandler', True) then
      try
        WriteString('', ClsID);
      finally
        CloseKey;
      end;
    finally
      Free;
    end;
  end
  else
  begin
    with TRegistry.Create do
    try
      RootKey := HKEY_CLASSES_ROOT;
      if OpenKey('apkfile\DefaultIcon', True) then
      try
        if ValueExists('backup') then
        begin
          WriteString('', ReadString('backup'));
          DeleteValue('backup');
        end;
      finally
        CloseKey;
      end;

      if OpenKey('apkfile\shellex', True) then
      try
        if KeyExists('IconHandler') then
          DeleteKey('IconHandler');
      finally
        CloseKey;
      end;
    finally
      Free;
    end;
  end;
end;

initialization
  TTypedComObjectFactory.Create(ComServer, TAPKIcon, CLASS_APKIcon_,
    ciMultiInstance, tmApartment);
end.
