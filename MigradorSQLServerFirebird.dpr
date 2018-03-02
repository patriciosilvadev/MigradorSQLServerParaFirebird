program MigradorSQLServerFirebird;

uses
  Forms,
  MenuMigrador in 'MenuMigrador.pas' {FMenuMigrador},
  Funcoes in 'Funcoes.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFMenuMigrador, FMenuMigrador);
  Application.Run;
end.
