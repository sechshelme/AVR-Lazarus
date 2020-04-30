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
  //  DefineTemplates,  // Als Test;

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

  { TSerialMonitor }

  TSerialMonitor = class(TObject)
  private
    Active: boolean;
  public
    constructor Create;
    function RunHandler(Sender: TObject; var Handled: boolean): TModalResult;
    function RunNoDebugHandler(Sender: TObject; var Handled: boolean): TModalResult;
    procedure StopHandler(Sender: TObject);
  end;

function TSerialMonitor.RunHandler(Sender: TObject; var Handled: boolean): TModalResult;
begin
  if Assigned(Serial_Monitor_Form) then begin
    if Serial_Monitor_Form.Timer1.Enabled then begin
      Active := True;
      Serial_Monitor_Form.CloseSerial;
    end else begin
      Active := False;
    end;
  end;
end;

function TSerialMonitor.RunNoDebugHandler(Sender: TObject; var Handled: boolean): TModalResult;
begin
  if Assigned(Serial_Monitor_Form) then begin
    if Serial_Monitor_Form.Timer1.Enabled then begin
      Active := True;
      Serial_Monitor_Form.CloseSerial;
    end else begin
      Active := False;
    end;
  end;
end;

procedure TSerialMonitor.StopHandler(Sender: TObject);
begin
  if Assigned(Serial_Monitor_Form) then begin
    if Active then begin
      Serial_Monitor_Form.OpenSerial;
    end;
  end;
end;

constructor TSerialMonitor.Create;
begin
  inherited Create;
  Active := False;
end;

var
  SerialMonitor: TSerialMonitor;

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

procedure RegisterSerialMonitor(Sender: TObject);
//var
//  LazProject: TLazProject;
begin
  if not Assigned(Serial_Monitor_Form) then begin
    Serial_Monitor_Form := TSerial_Monitor_Form.Create(nil);
//    ShowMessage('create');
  end else begin
//    ShowMessage('no create');
  end;

  Serial_Monitor_Form.Show;
end;

procedure Register;
const
  AVR_Title = Title + 'AVR-Optionen (Arduino)';
  ARM_Title = Title + 'ARM-Optionen (STM32)';
  Embedded_Titel = Title + 'CPU-Info';

begin
  Embedded_IDE_Options := TEmbedded_IDE_Options.Create;
  //  Embedded_IDE_Options.Load;

  AVR_ProjectOptions := TAVR_ProjectOptions.Create;
  RegisterProjectDescriptor(TProjectAVRApp.Create);

  ARM_ProjectOptions := TARM_ProjectOptions.Create;
  RegisterProjectDescriptor(TProjectARMApp.Create);


  // Run ( without or with debugger ) hooks
  SerialMonitor := TSerialMonitor.Create;
  LazarusIDE.AddHandlerOnRunDebug(@SerialMonitor.RunHandler);
  LazarusIDE.AddHandlerOnRunWithoutDebugInit(@SerialMonitor.RunNoDebugHandler);
  LazarusIDE.AddHandlerOnRunFinished(@SerialMonitor.StopHandler, True);


  // IDE Option
  Embbed_IDE_OptionsFrameID :=
    RegisterIDEOptionsEditor(GroupEnvironment, TEmbedded_IDE_Options_Frame, Embbed_IDE_OptionsFrameID)^.Index;

  // Menu
  RegisterIdeMenuCommand(mnuProject, AVR_Title, AVR_Title + '...', nil, @ShowAVROptionsDialog);
  RegisterIdeMenuCommand(mnuProject, ARM_Title, ARM_Title + '...', nil, @ShowARMOptionsDialog);
  RegisterIdeMenuCommand(mnuProject, Embedded_Titel, Embedded_Titel + '...', nil, @ShowCPU_Info);    // Anderer Ort ??????????

  RegisterIdeMenuCommand(mnuProject, Title + 'Serial-Monitor', Title + 'Serial-Monitor...', nil, @RegisterSerialMonitor);        // Anderer Ort ??????????
end;


end.
