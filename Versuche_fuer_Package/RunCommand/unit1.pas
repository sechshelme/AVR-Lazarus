unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, process, Serial,
  Embedded_GUI_Run_Command;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button_Reset: TButton;
    DUE: TButton;
    avr: TButton;
    Memo1: TMemo;
    procedure avrClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button_ResetClick(Sender: TObject);
    procedure DUEClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    RunCommandForm: TRun_Command_Form;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
var
  s: string;
begin
  //  RunCommand('avrdude', ['-patmega328p', '-cusbasp', '-v'], s,[poWaitOnExit, poUsePipes]);
  //  if RunCommand('/bin/bash',['-c','echo $PATH'],s) then begin
  if RunCommand('avrdude', ['-patmega328p', '-cusbasp', '-v'], s) then begin
    // if RunCommand('avrdude', ['-patmega328p', '-cusbasp', '-v'], s, [poWaitOnExit]) then begin
    Memo1.Lines.Add('geklappt ! ');
    Memo1.Lines.Add(s);
  end;
end;

procedure TForm1.Button_ResetClick(Sender: TObject);
var
  SerialHandle: TSerialHandle;
begin
  SerialHandle := SerOpen('/dev/ttyACM0');
  SerSetParams(SerialHandle, 1200, 8, NoneParity, 1, []);

  SerSetDTR(SerialHandle, True);
  SerSetDTR(SerialHandle, False);
  Sleep(500);
  SerClose(SerialHandle);
  Sleep(500);

  Caption := 'reset';
end;

procedure TForm1.DUEClick(Sender: TObject);
const
  bos161 = '/n4800/DATEN/Programmierung/Lazarus/Tutorials/Embedded/bossac/BOSSA-1.6.1/bin/bossac';
  bos191 = '/n4800/DATEN/Programmierung/Lazarus/Tutorials/Embedded/bossac/BOSSA-1.9.1/bin/bossac';
  bos170 = '/n4800/DATEN/Programmierung/Lazarus/Tutorials/Embedded/bossac/BOSSA-1.7.0/bin/bossac';
  binMIR = '/n4800/DATEN/Programmierung/Lazarus/Tutorials/Embedded/ARM/Arduino_DUE/von_MIR/Project1.bin';
  binArduino = '/tmp/arduino_build_303924/Blink.ino.bin';
  com = 'ttyACM0';
var
  SerialHandle: TSerialHandle;
begin
  if not Assigned(RunCommandForm) then begin
    RunCommandForm := TRun_Command_Form.Create(nil);
  end;

  SerialHandle := SerOpen('/dev/' + com);
  SerSetParams(SerialHandle, 1200, 8, NoneParity, 1, []);

  SerSetDTR(SerialHandle, True);
  SerSetDTR(SerialHandle, False);
  Sleep(500);
  SerClose(SerialHandle);
  Sleep(500);

  //  RunCommandForm.RunCommand(bos191 + ' --port=' + com + ' -U false -e -w -v -b ' + binArduino + ' -R');
  RunCommandForm.RunCommand(bos170 + ' -e -w -v -b ' + binMIR + ' -R');

  //  RunCommandForm.RunCommand'/home/tux/.arduino15/packages/arduino/tools/bossac/1.6.1-arduino/bossac -i -d --port=ttyACM0 -U false -e -w -v -b /tmp/arduino_build_309523/Blink.ino.bin -R')
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
end;

procedure TForm1.avrClick(Sender: TObject);
var
  SerialHandle: TSerialHandle;
const
  bos = '/home/tux/.arduino15/packages/arduino/tools/bossac/1.6.1-arduino/bossac';
  bin0 = '/tmp/arduino_build_798287/Blink.ino.bin';
  bin1 = '/n4800/DATEN/Programmierung/Lazarus/Tutorials/Embedded/ARM/Arduino_DUE/erste_Versuche/Project1.bin';
begin
  if not Assigned(RunCommandForm) then begin
    RunCommandForm := TRun_Command_Form.Create(nil);
  end;

  SerialHandle := SerOpen('/dev/ttyACM0');
  SerSetParams(SerialHandle, 1200, 8, NoneParity, 1, []);

  SerSetDTR(SerialHandle, True);
  SerSetDTR(SerialHandle, False);
  Sleep(500);
  SerClose(SerialHandle);
  Sleep(500);


  //  RunCommandForm.RunCommand('avrdude -patmega32u4 -v -cavr109 -P/dev/ttyACM0 -b57600 -D -Uflash:w:/home/tux/Dropbox/Sloeber_Projecte/sloeber-workspace/leonardo_test/Release/leonardo_test.hex:i');
  //RunCommandForm.RunCommand('/home/tux/.arduino15/packages/arduino/tools/bossac/1.6.1-arduino/bossac -i -d --port=ttyACM0 -U false -e -w -v -b /tmp/arduino_build_798287/Blink.ino.bin -R');
  //  RunCommandForm.RunCommand(bos +' -i -d --port=ttyACM0 -U false -e -w -v -b ' + bin0 + ' -R');
  //RunCommandForm.RunCommand(bos +' -i -d --port=ttyACM0 -U false -e -w -v -b ' + bin1 + ' -R');
  RunCommandForm.RunCommand(bos + ' -i -d --port=ttyACM0 -e -w -v -b ' + bin1 + '');

  // Programmming
  // /home/tux/.arduino15/packages/arduino/tools/bossac/1.6.1-arduino/bossac -i -d --port=ttyACM0 -U false -e -w -v -b /tmp/arduino_build_798287/Blink.ino.bin -R

  // Native
  // /home/tux/.arduino15/packages/arduino/tools/bossac/1.6.1-arduino/bossac -i -d --port=ttyACM0 -U true -e -w -v -b /tmp/arduino_build_798287/Blink.ino.bin -R


  Caption := RunCommandForm.ExitCode.ToString;
end;

end.
