program LaanSnake;

uses
  ExceptionLog,
  Forms,
  Main in 'Main.pas' {frmSnakeMain};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfrmSnakeMain, frmSnakeMain);
  Application.Run;
end.
