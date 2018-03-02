unit Funcoes;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StrUtils ;

type
TFuncao = class
public
  class function RetornaTipoCampo(pTipoCampo, pTamanho: string): string;
  class function RetornaNomeCampoFB(pNomeCampo: string): string;
  class function FormataCampoData(pValor: string): TDate;
end;


implementation


class function TFuncao.FormataCampoData(pValor: string): TDate;
var
  iDia, iMes, iAno: word;
  DataRetorno: TDate;
begin
  //2019-01-01
  //1234567890
  iAno := StrToInt(Copy(pValor, 1, 4));
  iMes := StrToInt(Copy(pValor, 6, 2));
  iDia := StrToInt(Copy(pValor, 9, 2));
  DataRetorno := EncodeDate(iAno, iMes, iDia);
  ShowMessage(datetostr(dataretorno));
  Result := DataRetorno;
end;

class function TFuncao.RetornaNomeCampoFB(pNomeCampo: string): string;
  var
    strRetorno: string;
begin
  //strRetorno := Copy(1, 30, pNomeCampo)
  result := '';

end;

class function TFuncao.RetornaTipoCampo(pTipoCampo, pTamanho: string): string;
  var
    strRetorno: string;
begin

  strRetorno := pTipoCampo;

  if (copy(pTipoCampo, 1, 4) = 'bigint') then
    strRetorno := 'integer';
  if (copy(pTipoCampo, 1, 3) = 'int') then
    strRetorno := 'integer';
  if (copy(pTipoCampo, 1, 8) = 'smallint') then
    strRetorno := 'integer';
  if (copy(pTipoCampo, 1, 6) = 'money') then
    strRetorno := 'float';
  if (copy(pTipoCampo, 1, 6) = 'smalldatetime') then
    strRetorno := 'date';

  if (copy(pTipoCampo, 1, 8) = 'nvarchar') then
    strRetorno := 'BLOB SUB_TYPE 1 SEGMENT SIZE 80';
  if (copy(pTipoCampo, 1, 9) = 'varbinary') then
    strRetorno := 'BLOB SUB_TYPE 1 SEGMENT SIZE 80';
  if (copy(pTipoCampo, 1, 8) = 'longblob') then
    strRetorno := 'BLOB SUB_TYPE 1 SEGMENT SIZE 80';

  if (strRetorno = 'varchar') or (strRetorno = 'char') then
  begin
      if pTamanho <> '-1' then
        strRetorno := strRetorno   + '(' + pTamanho + ')'
      else
        strRetorno := 'BLOB SUB_TYPE 1 SEGMENT SIZE 80';
  end;

  Result := strRetorno;
end;



end.
