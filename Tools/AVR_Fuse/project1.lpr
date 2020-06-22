program project1;

{$mode objfpc}{$H+}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  Embedded_GUI_AVR_Fuse_Form,
  Embedded_GUI_AVR_Fuse_Common, Embedded_GUI_AVR_Fuse_Burn_Form, 
Embedded_GUI_AVR_Fuse_TabSheet;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TForm_AVR_Fuse, Form_AVR_Fuse);
//  Application.CreateForm(TForm_AVR_Fuse_Burn, Form_AVR_Fuse_Burn);
  Application.Run;
end.


