program fishnemo;

uses
  Forms,
  main in 'main.pas' {Form1},
  Fish in 'Fish.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
