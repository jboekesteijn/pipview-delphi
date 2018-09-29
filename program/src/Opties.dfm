object frmOpties: TfrmOpties
  Left = 515
  Top = 383
  BorderStyle = bsDialog
  Caption = 'Opties'
  ClientHeight = 221
  ClientWidth = 423
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object grpBallon: TGroupBox
    Left = 96
    Top = 8
    Width = 320
    Height = 172
    Caption = 'Ballon'
    TabOrder = 4
    object lblPeriode: TLabel
      Left = 8
      Top = 20
      Width = 94
      Height = 13
      Caption = 'Verkeer periode:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblPercentages: TLabel
      Left = 184
      Top = 92
      Width = 40
      Height = 13
      Caption = 'Overig:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblVerkeerVandaag: TLabel
      Left = 184
      Top = 20
      Width = 100
      Height = 13
      Caption = 'Verkeer vandaag:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object chkBalloonOver: TCheckBox
      Left = 12
      Top = 108
      Width = 129
      Height = 17
      Caption = 'Over'
      TabOrder = 5
    end
    object chkBalloonLimiet: TCheckBox
      Left = 12
      Top = 36
      Width = 97
      Height = 17
      Caption = 'Limiet'
      TabOrder = 0
    end
    object chkBalloonVandaagTotaal: TCheckBox
      Left = 188
      Top = 68
      Width = 129
      Height = 17
      Caption = 'Totaal'
      TabOrder = 1
    end
    object chkBalloonOntvangen: TCheckBox
      Left = 12
      Top = 60
      Width = 129
      Height = 17
      Caption = 'Ontvangen'
      TabOrder = 2
    end
    object chkBalloonVerstuurd: TCheckBox
      Left = 12
      Top = 76
      Width = 129
      Height = 17
      Caption = 'Verstuurd'
      TabOrder = 3
    end
    object chkBalloonTotaal: TCheckBox
      Left = 12
      Top = 92
      Width = 129
      Height = 17
      Caption = 'Totaal'
      TabOrder = 4
    end
    object chkBalloonNieuwsServer: TCheckBox
      Left = 188
      Top = 108
      Width = 129
      Height = 17
      Caption = 'Nieuwsserver'
      TabOrder = 6
    end
    object chkBalloonPeriode: TCheckBox
      Left = 188
      Top = 124
      Width = 129
      Height = 17
      Caption = 'Periode'
      TabOrder = 7
    end
    object chkBalloonOverPerDag: TCheckBox
      Left = 12
      Top = 132
      Width = 129
      Height = 17
      Caption = 'Over per dag'
      TabOrder = 8
    end
    object chkBalloonVandaagVerstuurd: TCheckBox
      Left = 188
      Top = 52
      Width = 129
      Height = 17
      Caption = 'Verstuurd'
      TabOrder = 9
    end
    object chkBalloonVandaagOntvangen: TCheckBox
      Left = 188
      Top = 36
      Width = 129
      Height = 17
      Caption = 'Ontvangen'
      TabOrder = 10
    end
  end
  object grpAlgemeen: TGroupBox
    Left = 96
    Top = 8
    Width = 320
    Height = 172
    Caption = 'Algemeen'
    TabOrder = 0
    object lblNaam: TLabel
      Left = 8
      Top = 20
      Width = 54
      Height = 13
      Caption = 'Inlognaam:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      Transparent = True
    end
    object lblWachtwoord: TLabel
      Left = 8
      Top = 52
      Width = 65
      Height = 13
      Caption = 'Wachtwoord:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      Transparent = True
    end
    object lblMinuten: TLabel
      Left = 252
      Top = 105
      Width = 42
      Height = 13
      Caption = 'minuten.'
      Transparent = True
    end
    object ediNaam: TEdit
      Left = 120
      Top = 16
      Width = 185
      Height = 21
      TabOrder = 0
      Text = 'naam'
    end
    object ediWachtwoord: TEditEx
      Left = 120
      Top = 48
      Width = 185
      Height = 21
      TabOrder = 1
      Text = 'wachtwoord'
    end
    object chkVernieuwenBijOpstarten: TCheckBox
      Left = 8
      Top = 83
      Width = 296
      Height = 17
      Caption = 'Gegevens direct vernieuwen bij het starten van PipView.'
      TabOrder = 2
    end
    object chkAutomatischVernieuwen: TCheckBox
      Left = 8
      Top = 104
      Width = 209
      Height = 17
      Caption = 'Gegevens automatisch vernieuwen na'
      TabOrder = 3
      OnClick = chkAutomatischVernieuwenClick
    end
    object ediVernieuwenInterval: TEdit
      Left = 216
      Top = 103
      Width = 29
      Height = 18
      AutoSize = False
      MaxLength = 3
      TabOrder = 4
      Text = '60'
    end
    object chkBlijfIngelogd: TCheckBox
      Left = 8
      Top = 125
      Width = 209
      Height = 17
      Caption = 'Ingelogd blijven op de ZeelandNet-site.'
      TabOrder = 5
    end
    object chkTrayText: TCheckBox
      Left = 8
      Top = 146
      Width = 217
      Height = 17
      Caption = 'Percentage in icoon laten zien als tekst.'
      TabOrder = 6
    end
  end
  object btnCancel: TButton
    Left = 341
    Top = 188
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Annuleren'
    ModalResult = 2
    TabOrder = 2
  end
  object btnOk: TButton
    Left = 258
    Top = 188
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
    OnClick = btnOkClick
  end
  object trvPages: TTreeView
    Left = 8
    Top = 8
    Width = 81
    Height = 205
    HideSelection = False
    HotTrack = True
    Indent = 19
    RowSelect = True
    ShowRoot = False
    TabOrder = 3
    OnChange = trvPagesChange
    Items.Data = {
      02000000210000000000000000000000FFFFFFFFFFFFFFFF0000000000000000
      08416C67656D65656E1F0000000000000000000000FFFFFFFFFFFFFFFF000000
      00000000000642616C6C6F6E}
  end
end
