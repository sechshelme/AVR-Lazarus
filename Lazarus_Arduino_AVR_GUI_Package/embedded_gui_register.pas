unit Embedded_GUI_Register;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  // LCL
  Forms, Controls, StdCtrls, Dialogs, ExtCtrls,
  // LazUtils
  LazLoggerBase,
  // IdeIntf
  ProjectIntf, CompOptsIntf, LazIDEIntf, IDEOptionsIntf, IDEOptEditorIntf, MenuIntf,
  DefineTemplates,  // Als Test;

  // Embedded ( Eigene Units )
  Embedded_GUI_AVR_Register,
  Embedded_GUI_ARM_Register,
  Embedded_GUI_IDE_Options,
  Embedded_GUI_Common,
  Embedded_GUI_AVR_Common, Embedded_GUI_AVR_Project_Options_Form,
  Embedded_GUI_ARM_Common, Embedded_GUI_ARM_Project_Options_Form,
  Embedded_GUI_CPU_Info_Form,
  Embedded_GUI_SubArch_List,
  Embedded_GUI_Serial_Monitor;

var
  Embbed_IDE_OptionsFrameID: integer = 1000;

procedure Register;

implementation

type
  TLSW = class(TObject)
  private
    procedure DoOpen;
    procedure DoClose;
  public
    function RunHandler(Sender: TObject; var Handled: boolean): TModalResult;
    function RunNoDebugHandler(Sender: TObject; var Handled: boolean): TModalResult;
    procedure StopHandler(Sender: TObject);
  end;

function TLSW.RunHandler(Sender: TObject; var Handled: boolean): TModalResult;
begin
  DoClose;
end;

function TLSW.RunNoDebugHandler(Sender: TObject; var Handled: boolean): TModalResult;
begin
  DoClose;
end;

procedure TLSW.StopHandler(Sender: TObject);
begin
  DoOpen;
end;

procedure TLSW.DoOpen;
begin
//  ShowMessage('Serial Öffnen');
  //  if Assigned(SerialMonitor) then
  //    SerialMonitor.RequestActivateMonitor(True);
end;

procedure TLSW.DoClose;
begin
//  ShowMessage('Serial Schliessen');
  //  if Assigned(SerialMonitor) then
  //    SerialMonitor.RequestActivateMonitor(False);
end;

var
  LSW: TLSW;
//////// End TLSW


procedure ShowAVROptionsDialog(Sender: TObject);
var
  LazProject: TLazProject;
  ProjOptiForm: TAVR_Project_Options_Form;
begin
  ProjOptiForm := TAVR_Project_Options_Form.Create(nil);

  LazProject := LazarusIDE.ActiveProject;

  if (LazProject.LazCompilerOptions.TargetCPU <> 'avr') or
    (LazProject.LazCompilerOptions.TargetOS <> 'embedded') then begin
    if MessageDlg('Warnung', 'Es handelt sich nicht um ein AVR Embedded Project.' +
      LineEnding + 'Diese Funktion kann aktuelles Projekt zerstören' +
      LineEnding + LineEnding + 'Trotzdem ausführen ?', mtWarning,
      [mbYes, mbNo], 0) = mrNo then begin
      ProjOptiForm.Free;
      Exit;
    end;
  end;

  AVR_ProjectOptions.Load(LazProject);

  ProjOptiForm.LoadDefaultMask;
  ProjOptiForm.ProjectOptionsToMask;

  if ProjOptiForm.ShowModal = mrOk then begin
    ProjOptiForm.MaskToProjectOptions;
    AVR_ProjectOptions.Save(LazProject);
    LazProject.LazCompilerOptions.GenerateDebugInfo := False;
  end;

  ProjOptiForm.Free;
end;

procedure ShowARMOptionsDialog(Sender: TObject);
var
  LazProject: TLazProject;
  ProjOptiForm: TARM_Project_Options_Form;
begin
  ProjOptiForm := TARM_Project_Options_Form.Create(nil);

  LazProject := LazarusIDE.ActiveProject;

  if (LazProject.LazCompilerOptions.TargetCPU <> 'arm') or
    (LazProject.LazCompilerOptions.TargetOS <> 'embedded') then begin
    if MessageDlg('Warnung', 'Es handelt sich nicht um ein ARM Embedded Project.' +
      LineEnding + 'Diese Funktion kann aktuelles Projekt zerstören' +
      LineEnding + LineEnding + 'Trotzdem ausführen ?', mtWarning,
      [mbYes, mbNo], 0) = mrNo then begin
      ProjOptiForm.Free;
      Exit;
    end;
  end;

  ARM_ProjectOptions.Load(LazProject);

  ProjOptiForm.LoadDefaultMask;
  ProjOptiForm.ProjectOptionsToMask;

  if ProjOptiForm.ShowModal = mrOk then begin
    ProjOptiForm.MaskToProjectOptions;
    ARM_ProjectOptions.Save(LazProject);
    LazProject.LazCompilerOptions.GenerateDebugInfo := False;
  end;

  ProjOptiForm.Free;
end;

procedure ShowCPU_Info(Sender: TObject);
var
  Form: TCPU_InfoForm;
begin
  Form := TCPU_InfoForm.Create(nil);
  //  Form.Load(AVR_ControllerDataList);        // Lazarus auslesen ??????????
  Form.ComboBox1.ItemIndex := 0;
  Form.ComboBox1Select(Sender);
  Form.ShowModal;
  Form.Free;
end;

procedure ShowSerialMonitor(Sender: TObject);
var
  LazProject: TLazProject;
  Form: TSerial_Monitor_Form;
begin
  Form := TSerial_Monitor_Form.Create(nil);

  LazProject := LazarusIDE.ActiveProject;

  AVR_ProjectOptions.Load(LazProject);

  //  Form.LoadDefaultMask;
  //  Form.ProjectOptionsToMask;

  if Form.ShowModal = mrOk then begin
    //    Form.MaskToProjectOptions;
    AVR_ProjectOptions.Save(LazProject);
  end;

  Form.Free;
end;

procedure Register;

const
  AVR_Title = Title + 'AVR-Optionen (Arduino)';
  ARM_Title = Title + 'ARM-Optionen (STM32)';
  Embedded_Titel = Title + 'CPU-Info';

begin
  Embedded_IDE_Options := TEmbedded_IDE_Options.Create;
  Embedded_IDE_Options.Load;

  AVR_ProjectOptions := TAVR_ProjectOptions.Create;
  RegisterProjectDescriptor(TProjectAVRApp.Create);


  ARM_ProjectOptions := TARM_ProjectOptions.Create;
  RegisterProjectDescriptor(TProjectARMApp.Create);


  // Run ( without or with debugger ) hooks
  LazarusIDE.AddHandlerOnRunDebug(@LSW.RunHandler);
  LazarusIDE.AddHandlerOnRunWithoutDebugInit(@LSW.RunNoDebugHandler);
  LazarusIDE.AddHandlerOnRunFinished(@LSW.StopHandler, True);


  // IDE Option
  Embbed_IDE_OptionsFrameID :=
    RegisterIDEOptionsEditor(GroupEnvironment, TEmbedded_IDE_Options_Frame,
    Embbed_IDE_OptionsFrameID)^.Index;

  // Menu
  RegisterIdeMenuCommand(mnuProject, AVR_Title, AVR_Title + '...',
    nil, @ShowAVROptionsDialog);
  RegisterIdeMenuCommand(mnuProject, ARM_Title, ARM_Title + '...',
    nil, @ShowARMOptionsDialog);
  RegisterIdeMenuCommand(mnuProject, Embedded_Titel, Embedded_Titel +
    '...', nil, @ShowCPU_Info);    // Anderer Ort ??????????

  RegisterIdeMenuCommand(mnuProject, Title + 'Serial-Monitor', Title +
    'Serial-Monitor...', nil, @ShowSerialMonitor);        // Anderer Ort ??????????
end;


end.
