program Project1;

{$O-}

uses
  intrinsics;

type
  TMaske = array[0..7] of byte;

const
  maxZiffern = 10;
  Ziffern: array[0..maxZiffern - 1] of TMaske = ((
    %11100000, %10100000, %10100000, %10100000, %11100000, %00000000, %00000000, %00000000), (
    %01000000, %11000000, %01000000, %01000000, %01000000, %00000000, %00000000, %00000000), (
    %11100000, %00100000, %11100000, %10000000, %11100000, %00000000, %00000000, %00000000), (
    %11100000, %00100000, %11100000, %00100000, %11100000, %00000000, %00000000, %00000000), (
    %10100000, %10100000, %11100000, %00100000, %00100000, %00000000, %00000000, %00000000), (
    %11100000, %10000000, %11100000, %00100000, %11100000, %00000000, %00000000, %00000000), (
    %11100000, %10000000, %11100000, %10100000, %11100000, %00000000, %00000000, %00000000), (
    %11100000, %00100000, %00100000, %00100000, %00100000, %00000000, %00000000, %00000000), (
    %11100000, %10100000, %11100000, %10100000, %11100000, %00000000, %00000000, %00000000), (
    %11100000, %10100000, %11100000, %00100000, %11100000, %00000000, %00000000, %00000000));


type
  TSPIGPIO = bitpacked record
    p0, p1, SlaveSelect, MOSI, MISO, Clock, p6, p7: boolean;
  end;

var
  SPI_Port: TSPIGPIO absolute PORTB;
  SPI_DDR: TSPIGPIO absolute DDRB;


  procedure SPIWriteData(p: PByte; len: byte);
  var
    i: byte;
  begin
    SPI_Port.SlaveSelect := False;
    for i := len - 1 downto 0 do begin
      SPDR := p[i];
      while (SPSR and (1 shl SPIF)) = 0 do begin
      end;
    end;
    SPI_Port.SlaveSelect := True;
  end;


var
  p,
  Zahl: integer;
  Zaehler:UInt16;
  Data: array[0..126] of byte;

procedure Timer2_Interrupt; public Name 'TIMER2_OVF_ISR'; interrupt;
begin
  TCNT2 := 70;
  Inc(p);
  if p >= 8 then begin
    p := 0;
  end;

  Data[0] := 1 shl p;
  Data[1] := Ziffern[Zahl, p] or ((Ziffern[(Zahl + 2) mod 10, p]) shr 5);
  Data[2] := 1 shl p;
  Data[3] := (Ziffern[(Zahl + 4) mod 10, p]) or ((Ziffern[(Zahl + 6) mod 10, p]) shr 5);

  SPIWriteData(@Data, Length(Data));
end;



begin
  SPI_DDR.MOSI := True;
  SPI_DDR.Clock := True;
  SPI_DDR.SlaveSelect := True;

  // Timer 2
  TCCR2A := %00;               // Normaler Timer
  TCCR2B := %101;              // Clock / 1024
  TIMSK2 := (1 shl TOIE2);     // Enable Timer2 Interrupt.
  avr_sei;

  // SPI
  SPCR := (1 shl SPE) or (1 shl MSTR) or (%00 shl SPR);
  SPSR := (1 shl SPI2X);  // SCK x 2 auf 1 MHZ

  repeat
    Inc(Zaehler);
    if Zaehler >= 60600 then begin
      Zaehler := 0;
    end;

    if Zaehler = 0 then begin
      Inc(Zahl);
      if Zahl >= 10 then begin
        Zahl := 0;
      end;
    end;

  until 1 = 2;
end.
