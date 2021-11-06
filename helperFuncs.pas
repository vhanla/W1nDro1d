unit helperFuncs;

interface

uses
  System.SysUtils;

  function ExtractDomain(AUrl : string) : string;
  function FormatFileSize(AValue: Int64): string;
  procedure EnableBlurBehindWindow(const AHandle: THandle);

implementation

uses
  Winapi.DwmApi, Winapi.Windows;

const
  ACCENT_DISABLED = 0;
  ACCENT_ENABLE_GRADIENT = 1;
  ACCENT_ENABLE_TRANSPARENTGRADIENT = 2;
  ACCENT_ENABLE_BLURBEHIND = 3;
//  ACCENT_INVALID_STATE = 4

  WCA_CLIENTRENDERING_POLICY = 16;
  WCA_ACCENT_POLICY = 19;

type
  TAccentPolicy = packed record
    AccentState: Integer;
    AccentFlags: Integer;
    GradientColor: Integer;
    AnimationId: Integer;
  end;

  TWindowCompositionAttributeData = packed record
    Attribute: THandle;
    Data: Pointer;
    Size: DWORD;
  end;

function SetWindowCompositionAttribute(hWnd: HWND; var data: TWindowCompositionAttributeData):integer; stdcall;
  external user32 name 'SetWindowCompositionAttribute';

function ExtractDomain(AUrl : string) : string;
 var
   p: Cardinal;
 begin
   Result := '';

   if Trim(AUrl) = '' then exit;

   AUrl := Trim(AUrl)+'/';
   p := Pos('://', AUrl);
   if p > 0 then
    Delete(AUrl, 1, p + Pred(length('://')));
   p := Pos('/', AUrl);
   Result := Copy(AUrl, 1, Pred(p));
 end;

function FormatFileSize(AValue: Int64): string;
const
  K = Int64(1024);
  M = K * K;
  G = K * M;
  T = K * G;
begin
  if AValue < K then Result := Format ( '%d bytes', [AValue] )
  else if AValue < M then Result := Format ( '%f KB', [AValue / K] )
  else if AValue < G then Result := Format ( '%f MB', [AValue / M] )
  else if AValue < T then Result := Format ( '%f GB', [AValue / G] )
  else Result := Format ( '%f TB', [AValue / T] );
end;

procedure EnableBlurBehindWindow(const AHandle: THandle);
var
  accent: TAccentPolicy;
  data: TWindowCompositionAttributeData;
  flag: BOOL;
begin
  ZeroMemory(@accent, SizeOf(TAccentPolicy));
  ZeroMemory(@data, SizeOf(TWindowCompositionAttributeData));
  accent.AccentState := ACCENT_ENABLE_BLURBEHIND;
  data.Attribute := WCA_ACCENT_POLICY;
  data.Size := SizeOf(TAccentPolicy);
  data.Data := @accent;
  SetWindowCompositionAttribute(AHandle, data);

  flag := True;
  data.Attribute := WCA_CLIENTRENDERING_POLICY;
  data.Size := SizeOf(flag);
  data.Data := @flag;
  SetWindowCompositionAttribute(AHandle, data);
end;

end.
