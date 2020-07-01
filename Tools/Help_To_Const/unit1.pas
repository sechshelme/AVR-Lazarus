unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, SynEdit,
  Embedded_GUI_Common,
  Embedded_GUI_Help_Form;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button_AVR_Project: TButton;
    Button_ARM_Project1: TButton;
    Button_AVR_Project1: TButton;
    Button_Create: TButton;
    SynEdit1: TSynEdit;
    procedure Button_ARM_Project1Click(Sender: TObject);
    procedure Button_AVR_ProjectClick(Sender: TObject);
    procedure Button_CreateClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

const
  path = '/n4800/DATEN/Programmierung/Lazarus/Tutorials/Embedded/Lazarus_Arduino_AVR_GUI_Package/embedded_gui_help_const.pas';

procedure TForm1.Button_CreateClick(Sender: TObject);
var
  sl: TStringList;
  s: string;
  i: integer;
begin
  sl := TStringList.Create;
  sl.Add('unit Embedded_GUI_Help_Const;');
  sl.Add('');
  sl.Add('interface');
  sl.Add('');
  sl.Add('const');
  sl.Add('  HelpText =');
  for i := 0 to SynEdit1.Lines.Count - 1 do begin
    sl.Add('    '#39 + SynEdit1.Lines[i] + #39' + LineEnding +');
  end;
  s := sl[sl.Count - 1];
  Delete(s, Length(s) - 14, 15);
  sl[sl.Count - 1] := s + ';';
  sl.Add('');
  sl.Add('implementation');
  sl.Add('');
  sl.Add('begin');
  sl.Add('end.');
  sl.SaveToFile(path);

  SynEdit1.Lines.SaveToFile('help.hlp');
  sl.Free;
//  HelpForm.Show;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  SaveFormPos_to_XML(Self);
end;

procedure TForm1.Button_AVR_ProjectClick(Sender: TObject);
begin
  HelpForm.Show;
  HelpForm.ShowText('AVR');
end;

procedure TForm1.Button_ARM_Project1Click(Sender: TObject);
begin
  HelpForm.Show;
  HelpForm.ShowText('ARM');
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  LoadFormPos_from_XML(Self);
  SynEdit1.Lines.LoadFromFile('help.hlp');
end;

end.
