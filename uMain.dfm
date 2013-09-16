object fMain: TfMain
  Left = 0
  Top = 0
  Caption = 'TMQTTClient Test Project'
  ClientHeight = 413
  ClientWidth = 426
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object lblHeader: TLabel
    Left = 8
    Top = 0
    Width = 410
    Height = 34
    Alignment = taCenter
    AutoSize = False
    Caption = 'Sample Client'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -21
    Font.Name = 'Tahoma'
    Font.Style = [fsBold, fsUnderline]
    ParentFont = False
    Layout = tlCenter
  end
  object lnlMQTTInfo: TLabel
    Left = 8
    Top = 337
    Width = 194
    Height = 13
    Caption = 'For more information about MQTT goto: '
  end
  object lblMQTTUrl: TLabel
    Left = 208
    Top = 337
    Width = 102
    Height = 13
    Cursor = crHandPoint
    Caption = 'http://www.mqtt.org'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsUnderline]
    ParentFont = False
    OnClick = lblUrlClick
  end
  object lblPrimarilyTested: TLabel
    Left = 8
    Top = 356
    Width = 154
    Height = 13
    Caption = 'Server primarily tested against: '
  end
  object lblRSMBUrl: TLabel
    Left = 168
    Top = 356
    Width = 181
    Height = 13
    Cursor = crHandPoint
    Caption = 'http://alphaworks.ibm.com/tech/rsmb'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsUnderline]
    ParentFont = False
    OnClick = lblUrlClick
  end
  object lblLimits: TLabel
    Left = 8
    Top = 375
    Width = 398
    Height = 13
    Caption = 
      'This Sample is not comprehensive of either the TMQTTClient nor t' +
      'he MQTT Protocol'
  end
  object lblLimits2: TLabel
    Left = 8
    Top = 392
    Width = 288
    Height = 13
    Caption = 'but is a good place to start in learning how to use the client.'
  end
  object lblSynapse: TLabel
    Left = 8
    Top = 40
    Width = 402
    Height = 13
    Caption = 
      'You will need the Synapse Internet components to be in your proj' +
      'ect search paths. '
  end
  object btnConnect: TButton
    Left = 343
    Top = 56
    Width = 75
    Height = 25
    Caption = 'Connect'
    TabOrder = 0
    OnClick = btnConnectClick
  end
  object btnDisconnect: TButton
    Left = 343
    Top = 87
    Width = 75
    Height = 25
    Caption = 'Disconnect'
    TabOrder = 1
    OnClick = btnDisconnectClick
  end
  object btnPublish: TButton
    Left = 343
    Top = 150
    Width = 75
    Height = 25
    Caption = 'Publish'
    TabOrder = 2
    OnClick = btnPublishClick
  end
  object eTopic: TEdit
    Left = 8
    Top = 152
    Width = 121
    Height = 21
    TabOrder = 3
    Text = '/dev/test'
  end
  object eMessage: TEdit
    Left = 135
    Top = 152
    Width = 202
    Height = 21
    TabOrder = 4
    Text = 'This is a test Message'
  end
  object eIP: TEdit
    Left = 8
    Top = 58
    Width = 202
    Height = 21
    TabOrder = 5
    Text = 'mallard'
  end
  object ePort: TEdit
    Left = 216
    Top = 58
    Width = 121
    Height = 21
    TabOrder = 6
    Text = '1883'
  end
  object btnPing: TButton
    Left = 343
    Top = 118
    Width = 75
    Height = 25
    Caption = 'Ping'
    TabOrder = 7
    OnClick = btnPingClick
  end
  object btnSubscribe: TButton
    Left = 343
    Top = 179
    Width = 75
    Height = 25
    Caption = 'Subscribe'
    TabOrder = 8
    OnClick = btnSubscribeClick
  end
  object eSubTopic: TEdit
    Left = 135
    Top = 179
    Width = 202
    Height = 21
    TabOrder = 9
    Text = '/dev/test'
  end
  object mStatus: TMemo
    Left = 8
    Top = 210
    Width = 409
    Height = 121
    TabOrder = 10
  end
end
