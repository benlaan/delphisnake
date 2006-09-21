object frmSnakeMain: TfrmSnakeMain
  Left = 437
  Top = 268
  Width = 361
  Height = 303
  Caption = 'Laan-Snake'
  Color = clBtnFace
  Constraints.MinHeight = 257
  Constraints.MinWidth = 289
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Icon.Data = {
    0000010001002020100000000000E80200001600000028000000200000004000
    0000010004000000000080020000000000000000000000000000000000000000
    000000008000008000000080800080000000800080008080000080808000C0C0
    C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF000000
    0000000000000008787777000000000000000000000000082622200000000000
    0000000000000007662222700000000000000000000000033622227000000000
    0000000000000003222222200000000000000000000087222222226000000000
    0000000000087222202222800707000000000008870222222222200000770000
    872020AD222222202222200001100082222222AA222222222222800089700022
    2222222222222222207000007100022222222222220227780000000017008222
    22227888888000000000000810006AA222270000000000000000070100007AAA
    22208000000000000000077780007DAA222027000000000008762710700005A5
    A222220780000008262207807000000222222022020277026FFF580070000007
    2222222222222266FFF1780078000000072222222202062FFF177777F8000000
    0007223236266202222222228700000000000088762622222222220222800000
    0000000000822222222222222070000000000000000822222222222222000000
    0000000000006252222222277000000000000000000072060708800000000000
    00000000000072F0F80000000000000000000000000082827000000000000000
    0000000000000222A6000000000000000000000000008A202200000000000000
    000000000000870007700000000000000000000000088000008000000000FFFF
    E03FFFFFE07FFFFFE01FFFFFE01FFFFFE01FFFFF001FFFFE001AFFE2007CF140
    0079C0000071C00005F380000FF30001FFE700FFFFAF007FFF87003FF8178027
    E017E0022037E0000033F8000003FE000003FFC00001FFFC0001FFFE0003FFFF
    0007FFFF027FFFFF03FFFFFF07FFFFFF83FFFFFF13FFFFFF39FFFFFE7DFF}
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lbBugIndicator: TLabel
    Left = 299
    Top = 208
    Width = 3
    Height = 13
    Anchors = [akRight, akBottom]
  end
  object lbLevelText: TLabel
    Left = 5
    Top = 256
    Width = 26
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Level'
  end
  object gbPlayer1: TGroupBox
    Left = 3
    Top = 206
    Width = 105
    Height = 40
    Anchors = [akLeft, akBottom]
    TabOrder = 1
    object lbScoreP1: TLabel
      Left = 35
      Top = 14
      Width = 65
      Height = 24
      Alignment = taRightJustify
      Caption = '000000 '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object lbPlayer1: TLabel
      Left = 3
      Top = -5
      Width = 87
      Height = 24
      Caption = ' P1 Score '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
  end
  object Grid: TDrawGrid
    Left = 0
    Top = 0
    Width = 353
    Height = 200
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    ColCount = 20
    DefaultColWidth = 10
    DefaultRowHeight = 10
    DefaultDrawing = False
    Enabled = False
    FixedCols = 0
    RowCount = 9
    FixedRows = 0
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clMaroon
    Font.Height = -27
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    GridLineWidth = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine]
    ParentFont = False
    ScrollBars = ssNone
    TabOrder = 0
    OnDrawCell = GridDrawCell
  end
  object gbPlayer2: TGroupBox
    Left = 115
    Top = 206
    Width = 105
    Height = 40
    Anchors = [akLeft, akBottom]
    TabOrder = 2
    object lbHiScoreP1: TLabel
      Left = 35
      Top = 14
      Width = 65
      Height = 24
      Alignment = taRightJustify
      Caption = '000000 '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clInactiveCaption
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object lbHiScore: TLabel
      Left = 3
      Top = -5
      Width = 83
      Height = 24
      Caption = ' Hi Score '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clInactiveCaption
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
  end
  object btnStart: TButton
    Left = 297
    Top = 227
    Width = 51
    Height = 21
    Anchors = [akLeft, akBottom]
    Caption = 'Start'
    Default = True
    TabOrder = 3
    TabStop = False
    OnClick = btnStartClick
  end
  object tbLevel: TTrackBar
    Left = 40
    Top = 249
    Width = 309
    Height = 25
    Hint = 'Difficulty'
    Anchors = [akLeft, akRight, akBottom]
    Max = 7
    Min = 1
    Orientation = trHorizontal
    ParentShowHint = False
    Frequency = 1
    Position = 5
    SelEnd = 0
    SelStart = 0
    ShowHint = True
    TabOrder = 4
    TickMarks = tmBottomRight
    TickStyle = tsAuto
    OnChange = tbLevelChange
  end
  object tmrInterrupt: TTimer
    Enabled = False
    Interval = 100
    OnTimer = tmrInterruptTimer
    Left = 16
    Top = 16
  end
  object tmrBug: TTimer
    Enabled = False
    Interval = 300
    OnTimer = tmrBugTimer
    Left = 48
    Top = 16
  end
end
