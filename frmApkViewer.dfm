object frmApkViewerWnd: TfrmApkViewerWnd
  Left = 0
  Top = 0
  Caption = 'APK Viewer '
  ClientHeight = 363
  ClientWidth = 662
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object SplitView1: TSplitView
    Left = 0
    Top = 0
    Width = 200
    Height = 344
    OpenedWidth = 200
    Placement = svpLeft
    TabOrder = 0
    ExplicitLeft = 320
    ExplicitTop = 136
    ExplicitHeight = 41
    object TreeView1: TTreeView
      Left = 0
      Top = 0
      Width = 200
      Height = 344
      Align = alClient
      Indent = 19
      TabOrder = 0
      ExplicitLeft = 32
      ExplicitTop = 72
      ExplicitWidth = 121
      ExplicitHeight = 97
    end
  end
  object CardPanel1: TCardPanel
    Left = 200
    Top = 0
    Width = 462
    Height = 344
    Align = alClient
    ActiveCard = Card1
    Caption = 'CardPanel1'
    TabOrder = 1
    ExplicitLeft = 256
    ExplicitTop = 48
    ExplicitWidth = 300
    ExplicitHeight = 200
    object Card1: TCard
      Left = 1
      Top = 1
      Width = 460
      Height = 342
      Caption = 'Card1'
      CardIndex = 0
      TabOrder = 0
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 185
      ExplicitHeight = 41
      object PageControl1: TPageControl
        Left = 0
        Top = 0
        Width = 460
        Height = 342
        ActivePage = TabSheet1
        Align = alClient
        TabOrder = 0
        ExplicitHeight = 361
        object TabSheet1: TTabSheet
          Caption = 'TabSheet1'
          object SynEdit1: TSynEdit
            Left = 0
            Top = 0
            Width = 452
            Height = 314
            Align = alClient
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Consolas'
            Font.Style = []
            Font.Quality = fqClearTypeNatural
            TabOrder = 0
            UseCodeFolding = False
            Gutter.Font.Charset = DEFAULT_CHARSET
            Gutter.Font.Color = clWindowText
            Gutter.Font.Height = -11
            Gutter.Font.Name = 'Consolas'
            Gutter.Font.Style = []
            Highlighter = SynJavaSyn1
            Lines.Strings = (
              'SynEdit1')
            ExplicitLeft = 128
            ExplicitTop = 88
            ExplicitWidth = 200
            ExplicitHeight = 150
          end
        end
      end
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 344
    Width = 662
    Height = 19
    Panels = <
      item
        Width = 50
      end>
    ExplicitLeft = 336
    ExplicitTop = 200
    ExplicitWidth = 0
  end
  object MainMenu1: TMainMenu
    Left = 248
    Top = 80
    object File1: TMenuItem
      Caption = 'File'
      object Open1: TMenuItem
        Caption = 'Open'
      end
      object Close1: TMenuItem
        Caption = 'Close'
      end
      object Save1: TMenuItem
        Caption = 'Save'
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Caption = 'Exit'
      end
    end
    object Edit1: TMenuItem
      Caption = 'Edit'
      object N2: TMenuItem
        Caption = '-'
      end
      object N3: TMenuItem
        Caption = '-'
      end
    end
    object Help1: TMenuItem
      Caption = 'Help'
    end
  end
  object SynJavaSyn1: TSynJavaSyn
    Options.AutoDetectEnabled = False
    Options.AutoDetectLineLimit = 0
    Options.Visible = False
    Left = 309
    Top = 121
  end
end
