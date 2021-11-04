object frmWeb: TfrmWeb
  Left = 0
  Top = 0
  Caption = 'PlayStore'
  ClientHeight = 485
  ClientWidth = 704
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 704
    Height = 485
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = 'Browser'
      object WebBrowser1: TWebBrowser
        Left = 0
        Top = 0
        Width = 696
        Height = 457
        Align = alClient
        TabOrder = 0
        OnNewWindow2 = WebBrowser1NewWindow2
        ExplicitWidth = 702
        ExplicitHeight = 483
        ControlData = {
          4C000000EF4700003B2F00000000000000000000000000000000000000000000
          000000004C000000000000000000000001000000E0D057007335CF11AE690800
          2B2E126208000000000000004C0000000114020000000000C000000000000046
          8000000000000000000000000000000000000000000000000000000000000000
          00000000000000000100000000000000000000000000000000000000}
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Downloads'
      ImageIndex = 1
      object UWPDownloader1: TUWPDownloader
        Left = 0
        Top = 0
        Width = 696
        Align = alTop
        Caption = 'Downloading'
        TabOrder = 0
        AniSet.AniKind = akOut
        AniSet.AniFunctionKind = afkQuartic
        AniSet.DelayStartTime = 0
        AniSet.Duration = 250
        AniSet.Step = 25
        OnDownloaded = UWPDownloader1Downloaded
        URL = ''
        Header = ''
        UserAgent = ''
        SavePath = ''
        IconFont.Charset = DEFAULT_CHARSET
        IconFont.Color = clWindowText
        IconFont.Height = -21
        IconFont.Name = 'Segoe MDL2 Assets'
        IconFont.Style = []
        CustomBackColor.Enabled = False
        CustomBackColor.LightNone = 15132390
        CustomBackColor.LightHover = 13619151
        CustomBackColor.LightPress = 8947848
        CustomBackColor.LightSelectedNone = 127
        CustomBackColor.LightSelectedHover = 103
        CustomBackColor.LightSelectedPress = 89
        CustomBackColor.DarkNone = 2039583
        CustomBackColor.DarkHover = 3487029
        CustomBackColor.DarkPress = 5000268
        CustomBackColor.DarkSelectedNone = 89
        CustomBackColor.DarkSelectedHover = 103
        CustomBackColor.DarkSelectedPress = 127
        FontIcon = #59219
        DownloadStartIcon = #57624
        DownloadPauseIcon = #57603
        DownloadCancelIcon = #57610
        DownloadRestartIcon = #57673
        Detail = 'Detail'
        ExtraDetail = ''
        Status = ''
        ProgressTop = 'Message 1'
        ProgressBottom = '0kb/s'
      end
    end
  end
end
