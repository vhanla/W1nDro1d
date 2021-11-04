unit helperFuncs;

interface

uses
  System.SysUtils;

  function ExtractDomain(AUrl : string) : string;
  function FormatFileSize(AValue: Int64): string;

implementation

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

end.
