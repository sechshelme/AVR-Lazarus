unit Embedded_GUI_ARM_Project_Options_Form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, Dialogs, Buttons,
  LazConfigStorage, BaseIDEIntf,
  LazIDEIntf, ProjectIntf, CompOptsIntf, IDEOptionsIntf, IDEOptEditorIntf,
  IDEExternToolIntf,
  //  Laz2_XMLCfg, // Für direkte *.lpi Zugriff

  Embedded_GUI_Common,
  Embedded_GUI_Find_Comports, Embedded_GUI_IDE_Options,
  Embedded_GUI_ARM_Common,
  // Embedded_GUI_ARM_Project_Templates_Form,
  Embedded_GUI_SubArch_List;

type

  { TARM_Project_Options_Form }

  TARM_Project_Options_Form = class(TForm)
    AsmFile_CheckBox: TCheckBox;
    BitBtn1: TBitBtn;
    ARM_FlashBase_ComboBox: TComboBox;
    STLinkPathComboBox: TComboBox;
    ARM_Typ_FPC_ComboBox: TComboBox;
    Button1: TButton;
    CancelButton: TButton;
    ARM_SubArch_ComboBox: TComboBox;
    Label1: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Memo1: TMemo;
    OkButton: TButton;
    TemplatesButton: TButton;
    procedure ARM_SubArch_ComboBoxChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    procedure ChangeARM;
  public
    procedure LoadDefaultMask;
    procedure ProjectOptionsToMask;
    procedure MaskToProjectOptions;
  end;

var
  ARM_Project_Options_Form: TARM_Project_Options_Form;

implementation

{$R *.lfm}

{ TARM_Project_Options_Form }

procedure TARM_Project_Options_Form.FormCreate(Sender: TObject);
var
  Cfg: TConfigStorage;
begin
  Cfg := GetIDEConfigStorage( Embedded_Options_File, True);
  Left := StrToInt(Cfg.GetValue(Key_ARM_ProjectOptions_Left, '100'));
  Top := StrToInt(Cfg.GetValue(Key_ARM_ProjectOptions_Top, '50'));
  Cfg.Free;
end;

procedure TARM_Project_Options_Form.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
var
  Cfg: TConfigStorage;
begin
  Cfg := GetIDEConfigStorage(Embedded_Options_File, False);
  Cfg.SetDeleteValue(Key_ARM_ProjectOptions_Left, IntToStr(Left), '100');
  Cfg.SetDeleteValue(Key_ARM_ProjectOptions_Top, IntToStr(Top), '50');
  Cfg.Free;
end;

procedure TARM_Project_Options_Form.ARM_SubArch_ComboBoxChange(Sender: TObject);
begin
  ChangeARM;
end;

// public

procedure TARM_Project_Options_Form.LoadDefaultMask;
begin

  with STLinkPathComboBox do
  begin
    Items.Add('avrdude');
      {$IFDEF MSWINDOWS}
    Items.Add('c:\stlink\stlink.exe');
      {$ELSE}
    Items.Add('/usr/bin/stlink');
      {$ENDIF}
    //      Text := Embedded_IDE_Options.avrdudePfad;   ??????????????????
  end;

  with ARM_SubArch_ComboBox do
  begin
    Items.CommaText := ARM_SubArch_List;
    ItemIndex := 3;          // ??????????????
    Style := csOwnerDrawFixed;
    Text := 'ARMV7M';
  end;

  with ARM_Typ_FPC_ComboBox do
  begin
    Sorted := True;
    Text := 'STM32F103X8';
  end;

  with ARM_FlashBase_ComboBox do
  begin
    Sorted := True;
    Text := '0x08000000';
    Items.Add('0x00000000');
    Items.Add('0x08000000');
  end;

  //    AVR_Typ_avrdude_Edit.Text := 'STM32F103X8';

  //with ProgrammerComboBox do begin
  //  Items.CommaText := AVR_Programmer;
  //  Text := 'arduino';
  //end;

  //with COMPortComboBox do begin
  //  Items.CommaText := GetSerialPortNames;
  //  Text := '/dev/ttyUSB0';
  //end;

  //with COMPortBaudComboBox do begin
  //  Items.CommaText := '19200,57600,115200';
  //  Text := '57600';
  //end;

  AsmFile_CheckBox.Checked := False;
  //    Disable_Auto_Erase_CheckBox.Checked := False;

end;

procedure TARM_Project_Options_Form.ProjectOptionsToMask;
begin
  ARM_SubArch_ComboBox.Text := ARM_ProjectOptions.ARM_SubArch;
  ARM_Typ_FPC_ComboBox.Text := ARM_ProjectOptions.ARM_FPC_Typ;

  STLinkPathComboBox.Text := ARM_ProjectOptions.stlink_Command.Path;
  //    avrdudeConfigPathComboBox.Text := ARM_ProjectOptions.AvrdudeCommand.ConfigPath;
  //ProgrammerComboBox.Text := ARM_ProjectOptions.AvrdudeCommand.Programmer;
  //COMPortComboBox.Text := AVR_ProjectOptions.AvrdudeCommand.COM_Port;
  //COMPortBaudComboBox.Text := AVR_ProjectOptions.AvrdudeCommand.Baud;
  ARM_FlashBase_ComboBox.Text := ARM_ProjectOptions.stlink_Command.FlashBase;

  AsmFile_CheckBox.Checked := ARM_ProjectOptions.AsmFile;
  //    Disable_Auto_Erase_CheckBox.Checked := AVR_ProjectOptions.AvrdudeCommand.Disable_Auto_Erase;
end;

procedure TARM_Project_Options_Form.MaskToProjectOptions;
begin
  ARM_ProjectOptions.ARM_SubArch := ARM_SubArch_ComboBox.Text;
  ARM_ProjectOptions.ARM_FPC_Typ := ARM_Typ_FPC_ComboBox.Text;

  ARM_ProjectOptions.stlink_Command.Path := STLinkPathComboBox.Text;
  ARM_ProjectOptions.stlink_Command.FlashBase := ARM_FlashBase_ComboBox.Text ;
  //    AVR_ProjectOptions.AvrdudeCommand.ConfigPath := avrdudeConfigPathComboBox.Text;
  //AVR_ProjectOptions.AvrdudeCommand.Programmer := ProgrammerComboBox.Text;
  //AVR_ProjectOptions.AvrdudeCommand.COM_Port := COMPortComboBox.Text;
  //AVR_ProjectOptions.AvrdudeCommand.Baud := COMPortBaudComboBox.Text;
  //AVR_ProjectOptions.AvrdudeCommand.AVR_AVRDude_Typ := AVR_Typ_avrdude_Edit.Text;

  ARM_ProjectOptions.AsmFile := AsmFile_CheckBox.Checked;
  //    AVR_ProjectOptions.AvrdudeCommand.Disable_Auto_Erase :=  Disable_Auto_Erase_CheckBox.Checked;
end;

// private

procedure TARM_Project_Options_Form.ChangeARM;
var
  ind: integer;
begin
  ind := ARM_SubArch_ComboBox.ItemIndex;
  if (ind < 0) or (ind >= Length(ARM_SubArch_List)) then
  begin
    ARM_Typ_FPC_ComboBox.Items.CommaText := '';
  end
  else
  begin
    ARM_Typ_FPC_ComboBox.Items.CommaText := ARM_List[ind];
  end;
end;

end.