object Form1: TForm1
  Left = 8
  Top = 8
  BorderStyle = bsToolWindow
  Caption = 'Mysteries of the Deep Sea'
  ClientHeight = 696
  ClientWidth = 1274
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Edit1: TEdit
    Left = 1191
    Top = 8
    Width = 75
    Height = 21
    TabOrder = 0
    Text = 'Edit1'
  end
  object Edit2: TEdit
    Left = 1191
    Top = 35
    Width = 75
    Height = 21
    TabOrder = 1
    Text = 'Edit2'
  end
  object Timer1: TTimer
    Interval = 100
    OnTimer = Timer1Timer
    Left = 8
    Top = 8
  end
  object Timer2: TTimer
    OnTimer = Timer2Timer
    Left = 56
    Top = 8
  end
end
