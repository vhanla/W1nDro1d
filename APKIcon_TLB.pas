unit APKIcon_TLB;

// ************************************************************************ //
// WARNING
// -------
// The types declared in this file were generated from data read from a
// Type Library. If this type library is explicitly or indirectly (via
// another type library referring to this type library) re-imported, or the
// 'Refresh' command of the Type Library Editor activated while editing the
// Type Library, the contents of this file will be regenerated and all
// manual modifications will be lost.
// ************************************************************************ //

// $Rev: 98336 $
// File generated on 08/11/2021 09:59:16 p. m. from Type Library described below.

// ************************************************************************  //
// Type Lib: Q:\Proyectos\W1nDro1d\APKIcon (1)
// LIBID: {C33485E7-F1BF-4B06-BABD-29192A42CF0B}
// LCID: 0
// Helpfile:
// HelpString:
// DepndLst:
//   (1) v2.0 stdole, (C:\Windows\SysWOW64\stdole2.tlb)
// SYS_KIND: SYS_WIN32
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers.
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
{$ALIGN 4}

interface

uses Winapi.Windows, System.Classes, System.Variants, System.Win.StdVCL, Vcl.Graphics, Vcl.OleServer, Winapi.ActiveX;


// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:
//   Type Libraries     : LIBID_xxxx
//   CoClasses          : CLASS_xxxx
//   DISPInterfaces     : DIID_xxxx
//   Non-DISP interfaces: IID_xxxx
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  APKIconMajorVersion = 1;
  APKIconMinorVersion = 0;

  LIBID_APKIcon: TGUID = '{C33485E7-F1BF-4B06-BABD-29192A42CF0B}';

  IID_IAPKIcon: TGUID = '{27BAA846-0F3A-4D42-AF31-7B9E60ADE9FF}';
  CLASS_APKIcon_: TGUID = '{3CDC901D-6551-43CE-A82A-1A643D58BED0}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary
// *********************************************************************//
  IAPKIcon = interface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library
// (NOTE: Here we map each CoClass to its Default Interface)
// *********************************************************************//
  APKIcon_ = IAPKIcon;


// *********************************************************************//
// Interface: IAPKIcon
// Flags:     (256) OleAutomation
// GUID:      {27BAA846-0F3A-4D42-AF31-7B9E60ADE9FF}
// *********************************************************************//
  IAPKIcon = interface(IUnknown)
    ['{27BAA846-0F3A-4D42-AF31-7B9E60ADE9FF}']
  end;

// *********************************************************************//
// The Class CoAPKIcon_ provides a Create and CreateRemote method to
// create instances of the default interface IAPKIcon exposed by
// the CoClass APKIcon_. The functions are intended to be used by
// clients wishing to automate the CoClass objects exposed by the
// server of this typelibrary.
// *********************************************************************//
  CoAPKIcon_ = class
    class function Create: IAPKIcon;
    class function CreateRemote(const MachineName: string): IAPKIcon;
  end;

implementation

uses System.Win.ComObj;

class function CoAPKIcon_.Create: IAPKIcon;
begin
  Result := CreateComObject(CLASS_APKIcon_) as IAPKIcon;
end;

class function CoAPKIcon_.CreateRemote(const MachineName: string): IAPKIcon;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_APKIcon_) as IAPKIcon;
end;

end.

