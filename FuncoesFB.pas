unit FuncoesFB;

interface

uses Variants, Controls, Forms, Messages, SysUtils, Dialogs, Windows,
  Classes, IBQuery, IBDatabase, DBClient;

type

	TFuncoesFB = class
	  class procedure AtualizaTransacao(Transacao: TIBTransaction);
	  class procedure IniciaTransacao(Transacao: TIBTransaction);
	  class procedure ComitaTransacao(Transacao: TIBTransaction);
	  class procedure RollbackTransacao(Transacao: TIBTransaction);
	end;

implementation

{TFuncoesFB}

class procedure TFuncoesFB.AtualizaTransacao(Transacao: TIBTransaction);
begin
  if not Transacao.InTransaction then
    Transacao.StartTransaction;
  if Transacao.InTransaction then
    Transacao.Commit;
end;

class procedure TFuncoesFB.ComitaTransacao(Transacao: TIBTransaction);
begin
  if Transacao.InTransaction then
    Transacao.Commit;
end;

class procedure TFuncoesFB.IniciaTransacao(Transacao: TIBTransaction);
begin
  if not Transacao.InTransaction then
    Transacao.StartTransaction;
end;

class procedure TFuncoesFB.RollbackTransacao(Transacao: TIBTransaction);
begin
  if Transacao.InTransaction then
    Transacao.Rollback;
end;

end.