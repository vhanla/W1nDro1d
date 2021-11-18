object frmInstaller: TfrmInstaller
  Left = 0
  Top = 0
  Caption = 'APK Installer'
  ClientHeight = 445
  ClientWidth = 636
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clHighlight
  Font.Height = -11
  Font.Name = 'Segoe UI Variable Display'
  Font.Style = []
  Font.Quality = fqClearTypeNatural
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poOwnerFormCenter
  StyleElements = [seFont, seClient]
  StyleName = 'Windows'
  OnClick = FormClick
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    636
    445)
  PixelsPerInch = 96
  TextHeight = 15
  object lbAPKDisplayName: TLabel
    Left = 24
    Top = 44
    Width = 481
    Height = 72
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'APK Display Name'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -27
    Font.Name = 'Segoe UI Variable Display Semib'
    Font.Style = [fsBold]
    Font.Quality = fqClearTypeNatural
    ParentFont = False
  end
  object lbPublisher: TLabel
    Left = 24
    Top = 144
    Width = 56
    Height = 17
    Caption = 'Publisher:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI Variable Display'
    Font.Style = []
    Font.Quality = fqClearTypeNatural
    ParentFont = False
  end
  object lbVersion: TLabel
    Left = 24
    Top = 166
    Width = 46
    Height = 17
    Caption = 'Version:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI Variable Display'
    Font.Style = []
    Font.Quality = fqClearTypeNatural
    ParentFont = False
  end
  object lbCertificate: TLabel
    Left = 24
    Top = 122
    Width = 40
    Height = 17
    Caption = 'Signer:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clHighlight
    Font.Height = -13
    Font.Name = 'Segoe UI Variable Display'
    Font.Style = []
    Font.Quality = fqClearTypeNatural
    ParentFont = False
    OnClick = lbCertificateClick
  end
  object lbCapabilities: TLabel
    Left = 24
    Top = 204
    Width = 67
    Height = 17
    Caption = 'Capabilities'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI Variable Display'
    Font.Style = []
    Font.Quality = fqClearTypeNatural
    ParentFont = False
  end
  object eApkImage: TEsImage
    Left = 520
    Top = 49
    Width = 90
    Height = 90
    Anchors = [akTop, akRight]
    Stretch = Fill
  end
  object btnLaunch: TButton
    Left = 497
    Top = 360
    Width = 113
    Height = 30
    Anchors = [akRight, akBottom]
    Caption = 'Launch'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI Variable Display'
    Font.Style = []
    Font.Quality = fqClearTypeNatural
    ParentFont = False
    TabOrder = 1
  end
  object apkInstallerMemo: TMemo
    Left = 24
    Top = 226
    Width = 409
    Height = 143
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    Ctl3D = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGray
    Font.Height = -13
    Font.Name = 'Segoe UI Variable Display'
    Font.Style = []
    Font.Quality = fqClearTypeNatural
    Lines.Strings = (
      'Memo1')
    ParentColor = True
    ParentCtl3D = False
    ParentFont = False
    ReadOnly = True
    TabOrder = 2
    WordWrap = False
  end
  object pnlAbout: TPanel
    Left = 8
    Top = 248
    Width = 273
    Height = 153
    Anchors = [akLeft, akBottom]
    BevelOuter = bvNone
    TabOrder = 3
    Visible = False
    object lbAbout: TLabel
      Left = 16
      Top = 16
      Width = 43
      Height = 21
      Caption = 'About'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Segoe UI Variable Display'
      Font.Style = []
      Font.Quality = fqClearTypeNatural
      ParentFont = False
    end
    object lbInsVersion: TLabel
      Left = 16
      Top = 39
      Width = 130
      Height = 17
      Caption = 'APK Installer 1.0.211028'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI Variable Display'
      Font.Style = []
      Font.Quality = fqClearTypeNatural
      ParentFont = False
    end
    object Label1: TLabel
      Left = 16
      Top = 62
      Width = 217
      Height = 17
      Caption = #169' 2021 Codigobit. All rights reserved.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI Variable Display'
      Font.Style = []
      Font.Quality = fqClearTypeNatural
      ParentFont = False
    end
    object Shape1: TShape
      Left = 0
      Top = 0
      Width = 273
      Height = 153
      Align = alClient
      Pen.Color = clMedGray
      Pen.Mode = pmMask
      Shape = stRoundRect
      ExplicitLeft = 208
      ExplicitTop = 88
      ExplicitWidth = 65
      ExplicitHeight = 65
    end
    object lnkWebSite: TLinkLabel
      Left = 20
      Top = 85
      Width = 64
      Height = 21
      Cursor = crHandPoint
      Caption = '<a href="https://codigobit.net">Codigobit</a>'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clHighlight
      Font.Height = -13
      Font.Name = 'Segoe UI Variable Display'
      Font.Style = []
      Font.Quality = fqClearTypeNatural
      ParentFont = False
      TabOrder = 0
      OnLinkClick = lnkWebSiteLinkClick
    end
    object lnkRepository: TLinkLabel
      Left = 20
      Top = 112
      Width = 113
      Height = 21
      Cursor = crHandPoint
      Caption = 
        '<a href="https://github.com/vhanla/W1nDro1d">GitHub Repository</' +
        'a>'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clHighlight
      Font.Height = -13
      Font.Name = 'Segoe UI Variable Display'
      Font.Style = []
      Font.Quality = fqClearTypeNatural
      ParentFont = False
      TabOrder = 1
      OnLinkClick = lnkRepositoryLinkClick
    end
  end
  object pnlCaption: TPanel
    Left = 0
    Top = 0
    Width = 636
    Height = 30
    Align = alTop
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 4
    OnMouseDown = pnlCaptionMouseDown
    object UWPQuickButton3: TUWPQuickButton
      Left = 546
      Top = 0
      Height = 30
      CustomBackColor.Enabled = False
      CustomBackColor.Color = clBlack
      CustomBackColor.LightColor = 13619151
      CustomBackColor.DarkColor = 3947580
      ButtonStyle = qbsMax
      Caption = #57347
      Align = alRight
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe MDL2 Assets'
      Font.Style = []
      ParentFont = False
      ExplicitLeft = 296
      ExplicitHeight = 32
    end
    object UWPQuickButton2: TUWPQuickButton
      Left = 501
      Top = 0
      Height = 30
      CustomBackColor.Enabled = False
      CustomBackColor.Color = clBlack
      CustomBackColor.LightColor = 13619151
      CustomBackColor.DarkColor = 3947580
      ButtonStyle = qbsMin
      Caption = #57608
      Align = alRight
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe MDL2 Assets'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ExplicitLeft = 296
      ExplicitHeight = 32
    end
    object UWPQuickButton1: TUWPQuickButton
      Left = 591
      Top = 0
      Height = 30
      CustomBackColor.Enabled = False
      CustomBackColor.Color = clBlack
      CustomBackColor.LightColor = 13619151
      CustomBackColor.DarkColor = 3947580
      ButtonStyle = qbsQuit
      Caption = #57610
      Align = alRight
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe MDL2 Assets'
      Font.Style = []
      ParentFont = False
      ExplicitLeft = 296
      ExplicitHeight = 32
    end
  end
  object ActivityIndicator1: TActivityIndicator
    Left = 304
    Top = 168
    Anchors = [akLeft, akTop, akRight, akBottom]
  end
  object Button1: TButton
    Left = 8
    Top = 407
    Width = 33
    Height = 30
    Anchors = [akLeft, akBottom]
    Caption = '?'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI Variable Display'
    Font.Style = []
    Font.Quality = fqClearTypeNatural
    ParentFont = False
    TabOrder = 6
    OnClick = Button1Click
  end
  object btnReUnInstall: TButton
    Left = 378
    Top = 360
    Width = 113
    Height = 29
    Anchors = [akRight, akBottom]
    Caption = 'Install'
    ElevationRequired = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI Variable Display'
    Font.Style = []
    Font.Quality = fqClearTypeNatural
    ParentFont = False
    TabOrder = 0
  end
  object btnLog: TButton
    Left = 47
    Top = 407
    Width = 33
    Height = 30
    Anchors = [akLeft, akBottom]
    Caption = 'Log'
    TabOrder = 8
    OnClick = btnLogClick
  end
  object SynEdit1: TSynEdit
    Left = 8
    Top = 248
    Width = 620
    Height = 153
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Consolas'
    Font.Style = []
    Font.Quality = fqClearTypeNatural
    TabOrder = 7
    Visible = False
    UseCodeFolding = False
    Gutter.Font.Charset = DEFAULT_CHARSET
    Gutter.Font.Color = clWindowText
    Gutter.Font.Height = -11
    Gutter.Font.Name = 'Consolas'
    Gutter.Font.Style = []
    Gutter.RightMargin = 8
    Gutter.ShowLineNumbers = True
    Highlighter = SynUNIXShellScriptSyn1
  end
  object DCAapt: TDosCommand
    InputToOutput = False
    MaxTimeAfterBeginning = 0
    MaxTimeAfterLastOutput = 0
    OnExecuteError = DCAaptExecuteError
    OnNewLine = DCAaptNewLine
    OnTerminated = DCAaptTerminated
    OnTerminateProcess = DCAaptTerminateProcess
    Left = 440
    Top = 56
  end
  object SynUNIXShellScriptSyn1: TSynUNIXShellScriptSyn
    Options.AutoDetectEnabled = False
    Options.AutoDetectLineLimit = 0
    Options.Visible = False
    Left = 272
    Top = 152
  end
  object DCPKCS7: TDosCommand
    InputToOutput = False
    MaxTimeAfterBeginning = 0
    MaxTimeAfterLastOutput = 0
    Left = 368
    Top = 48
  end
end
