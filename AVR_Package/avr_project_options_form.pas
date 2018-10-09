unit AVR_Project_Options_Form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, Dialogs, Buttons,
  LazConfigStorage, BaseIDEIntf,
  LazIDEIntf, ProjectIntf, CompOptsIntf, IDEOptionsIntf, IDEOptEditorIntf,
  IDEExternToolIntf,
  Laz2_XMLCfg, // Für direkte *.lpi Zugriff

  AVR_IDE_Options, AVR_Common;

type

  { TProjectOptionsForm }

  TProjectOptionsForm = class(TForm)
    AsmFile_CheckBox: TCheckBox;
    avrdudeConfigPathComboBox: TComboBox;
    avrdudePathComboBox: TComboBox;
    AVR_Typ_ComboBox: TComboBox;
    Button1: TButton;
    Button2: TButton;
    TemplatesButton: TButton;
    COMPortBaudComboBox: TComboBox;
    COMPortComboBox: TComboBox;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    OkButton: TButton;
    CancelButton: TButton;
    OpenDialogAVRConfigPath: TOpenDialog;
    OpenDialogAVRPath: TOpenDialog;
    ProgrammerComboBox: TComboBox;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure TemplatesButtonClick(Sender: TObject);
  private

  public
    procedure LoadDefaultMask;
    procedure ProjectOptionsToMask;
    procedure MaskToProjectOptions;
  end;

var
  ProjectOptionsForm: TProjectOptionsForm;

implementation

{$R *.lfm}

{ TProjectOptionsForm }

procedure TProjectOptionsForm.CancelButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TProjectOptionsForm.TemplatesButtonClick(Sender: TObject);
var
  Form: TForm;
  okB, cancelB: TBitBtn;
  cb: TListBox;
  l: TLabel;
begin
  Form := TForm.Create(nil);
  with Form do begin
    Position := poScreenCenter;
    ClientWidth := 400;
    ClientHeight := 300;
  end;

  l := TLabel.Create(Form);
  with l do begin
    Left := 10;
    Top := 25;
    Text := 'Board:';
    Parent := Form;
  end;

  okB := TBitBtn.Create(Form);
  with okB do begin
    Kind := bkOK;
    //    Caption:='Ok';
    Width := 75;
    Height := 25;
    Left := Form.ClientWidth - 100;
    Top := Form.ClientHeight - 50;
    Anchors := [akRight, akBottom];
    Parent := Form;
  end;

  cancelB := TBitBtn.Create(Form);
  with cancelB do begin
    Kind := bkCancel;
    //    Caption:='Cancel';
    Width := 75;
    Height := 25;
    Left := Form.ClientWidth - 200;
    Top := Form.ClientHeight - 50;
    Anchors := [akRight, akBottom];
    Parent := Form;
  end;

  cb := TListBox.Create(Form);
  with cb do begin
    Parent := Form;
    Top := 50;
    Left := 10;
    Width := Form.ClientWidth - 20;
    Height := Form.ClientHeight - 110;
    Anchors := [akLeft, akTop, akRight, akBottom];
    Text := 'Arduino UNO';
    Items.Add(Text);
    Items.Add('Arduino Nano (old Bootloader)');
    Items.Add('Arduino Nano');
  end;

  if Form.ShowModal = mrOk then begin
    case cb.ItemIndex of
      0: begin
        ProgrammerComboBox.Text := 'arduino';
        COMPortComboBox.Text := '/dev/ttyACM0';
        COMPortBaudComboBox.Text := '115200';
        AVR_Typ_ComboBox.Text := 'ATMEGA328P';
      end;
      1: begin
        ProgrammerComboBox.Text := 'arduino';
        COMPortComboBox.Text := '/dev/ttyUSB0';
        COMPortBaudComboBox.Text := '57600';
        AVR_Typ_ComboBox.Text := 'ATMEGA328P';
      end;
      2: begin
        ProgrammerComboBox.Text := 'arduino';
        COMPortComboBox.Text := '/dev/ttyUSB0';
        COMPortBaudComboBox.Text := '115200';
        AVR_Typ_ComboBox.Text := 'ATMEGA328P';
      end;
    end;
  end;

  Form.Free;
end;

procedure TProjectOptionsForm.LoadDefaultMask;
begin

  with avrdudePathComboBox do begin
    Items.Add('avrdude');
    Items.Add('/usr/bin/avrdude');
    Text := AVR_Options.avrdudePfad;
  end;

  with avrdudeConfigPathComboBox do begin
    Items.Add('/etc/avrdude.conf');
    Items.Add('avrdude.conf');
    Text := AVR_Options.avrdudeConfigPath;
  end;

  with ProgrammerComboBox do begin
    Items.Add('arduino');
    Items.Add('usbasp');
    Items.Add('stk500v1');
    Text := 'arduino';
  end;

  with COMPortComboBox do begin
    Items.DelimitedText := ',';
    Items.DelimitedText := GetSerialPortNames;
    Text := '/dev/ttyUSB0';
  end;

  with COMPortBaudComboBox do begin
    Items.CommaText := '57600,115200';
    Text := '57600';
  end;

  with AVR_Typ_ComboBox do begin
    Items.CommaText := AVR5_Typ;
    Sorted := True;
    Text := 'ATMEGA328P';
  end;

  AsmFile_CheckBox.Checked := False;

end;

procedure TProjectOptionsForm.ProjectOptionsToMask;
begin

  with avrdudePathComboBox do begin
    Text := ProjectOptions.AvrdudeCommand.Path;
  end;

  with avrdudeConfigPathComboBox do begin
    Text := ProjectOptions.AvrdudeCommand.ConfigPath;
  end;

  with ProgrammerComboBox do begin
    Text := ProjectOptions.AvrdudeCommand.Programmer;
  end;

  with COMPortComboBox do begin
    Text := ProjectOptions.AvrdudeCommand.COM_Port;
  end;

  with COMPortBaudComboBox do begin
    Text := ProjectOptions.AvrdudeCommand.Baud;
  end;

  with AVR_Typ_ComboBox do begin
    Text := ProjectOptions.AVRType;
  end;

  AsmFile_CheckBox.Checked := ProjectOptions.AsmFile;

end;

procedure TProjectOptionsForm.MaskToProjectOptions;
begin
  ProjectOptions.AvrdudeCommand.Path := avrdudePathComboBox.Text;
  ProjectOptions.AvrdudeCommand.ConfigPath := avrdudeConfigPathComboBox.Text;
  ProjectOptions.AvrdudeCommand.Programmer := ProgrammerComboBox.Text;
  ProjectOptions.AvrdudeCommand.COM_Port := COMPortComboBox.Text;
  ProjectOptions.AvrdudeCommand.Baud := COMPortBaudComboBox.Text;

  ProjectOptions.AVRType := AVR_Typ_ComboBox.Text;
  ProjectOptions.AsmFile := AsmFile_CheckBox.Checked;
end;

procedure TProjectOptionsForm.OkButtonClick(Sender: TObject);
begin
  //  Close;
end;

procedure TProjectOptionsForm.FormCreate(Sender: TObject);

var
  Cfg: TConfigStorage;
begin
  Cfg := GetIDEConfigStorage(AVR_Options_File, True);
  Left := StrToInt(Cfg.GetValue(Key_ProjectOptions_Left, '100'));
  Top := StrToInt(Cfg.GetValue(Key_ProjectOptions_Top, '50'));
  Cfg.Free;
end;

procedure TProjectOptionsForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  Cfg: TConfigStorage;
begin
  Cfg := GetIDEConfigStorage(AVR_Options_File, False);
  Cfg.SetDeleteValue(Key_ProjectOptions_Left, IntToStr(Left), '100');
  Cfg.SetDeleteValue(Key_ProjectOptions_Top, IntToStr(Top), '50');
  Cfg.Free;
end;

procedure TProjectOptionsForm.Button1Click(Sender: TObject);
begin
  OpenDialogAVRPath.FileName := avrdudePathComboBox.Text;
  if OpenDialogAVRPath.Execute then begin
    avrdudePathComboBox.Text := OpenDialogAVRPath.FileName;
  end;
end;

procedure TProjectOptionsForm.Button2Click(Sender: TObject);
begin
  OpenDialogAVRConfigPath.FileName := avrdudeConfigPathComboBox.Text;
  if OpenDialogAVRConfigPath.Execute then begin
    avrdudeConfigPathComboBox.Text := OpenDialogAVRConfigPath.FileName;
  end;
end;

end.
