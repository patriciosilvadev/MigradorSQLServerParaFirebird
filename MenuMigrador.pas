//Provider=SQLOLEDB.1;Password=30232800;Persist Security Info=True;User ID=sa;Initial Catalog=DOCUMENT;Data Source=SUPNIVEL3\SQLEXPRESS
//
unit MenuMigrador;

interface

uses
  Windows, Messages, SysUtils, Variants, Graphics,
  Forms, IBCustomDataSet, IBQuery, IBScript, DB,
  Mask, DBCtrls,
  DBClient, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  cxTextEdit, cxMaskEdit, cxButtonEdit, cxDBEdit, strUtils,
  IniFiles, ADODB, Dialogs, IBDatabase, StdCtrls,
  ComCtrls, Grids, DBGrids, ExtCtrls, Controls, Buttons, Classes;

type
  TFMenuMigrador = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    IBTransaction: TIBTransaction;
    IBDatabaseFB: TIBDatabase;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    edtPesquisaTab: TEdit;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    TabSheet3: TTabSheet;
    Panel3: TPanel;
    RichEdit1: TRichEdit;
    Label1: TLabel;
    Resumo: TLabel;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Image1: TImage;
    btnTestaConn: TSpeedButton;
    btnConectaBaseFB: TSpeedButton;
    SpeedButton3: TSpeedButton;
    btnPrepara: TSpeedButton;
    Label2: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    OpenDialog1: TOpenDialog;
    LabelMySQL: TLabel;
    Label13: TLabel;
    dsTabelasSQL: TDataSource;
    dsCampos: TDataSource;
    RichEdit2: TRichEdit;
    btnImporta: TSpeedButton;
    ProgressBar1: TProgressBar;
    Label12: TLabel;
    TabSheet4: TTabSheet;
    GroupBox3: TGroupBox;
    RichEdit3: TRichEdit;
    edtPrefixo: TEdit;
    Label14: TLabel;
    sql_host: TEdit;
    sql_senha: TEdit;
    fb_host: TEdit;
    fb_porta: TEdit;
    fb_usuario: TEdit;
    fb_senha: TEdit;
    sql_database: TEdit;
    fb_database: TcxButtonEdit;
    Conn: TADOConnection;
    qryTabelasSQL: TADOQuery;
    qryCampos: TADOQuery;
    sql_usuario: TEdit;
    Label3: TLabel;
    qryCamposCODIGO: TIntegerField;
    qryCamposCAMPO: TWideStringField;
    qryCamposTIPO: TWideStringField;
    qryCamposTAM: TIntegerField;
    procedure cxDBButtonEdit2PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure SpeedButton3Click(Sender: TObject);
    procedure btnTestaConnClick(Sender: TObject);
    procedure btnConectaBaseFBClick(Sender: TObject);
    procedure dsTabelasSQLDataChange(Sender: TObject; Field: TField);
    procedure DBGrid2DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure btnPreparaClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure edtPesquisaTabEnter(Sender: TObject);
    procedure btnImportaClick(Sender: TObject);
    procedure edtPesquisaTabChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TabSheet2Enter(Sender: TObject);
  private
    ChaveDefinida: string;
    arq_ini : TIniFile;
    CaminhoExe: string;
    procedure CriarTabela(pNomeTabela: string; pScript: WideString);
    function MontaCreateTable(pNomeTabela: string): WideString;
    function MontaInsertInto(pNomeTabela: string): WideString;
    function MontaSelect(pNomeTabela: string): WideString;
    procedure EnviaRegistrosToFirebird(pNomeTabela, pCampoChave: string);
    function TabelaExisteFirebird(pNomeTabela: string): boolean;
    procedure ConectarDataBase;
    function FormataCampoEspecial(pNome, Tipo: string): string;
    function NomeCampoFB(pCampo: string; pIndice: integer):string;
 { Private declarations }
  public
    { Public declarations }

  end;

var
  FMenuMigrador: TFMenuMigrador;

implementation

{$R *.dfm}

uses Funcoes, FuncoesFB;

procedure TFMenuMigrador.cxDBButtonEdit2PropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if OpenDialog1.Execute then
    fb_database.Text := OpenDialog1.FileName;

end;

procedure TFMenuMigrador.DBGrid2DrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  R : TRect;
Begin
  R := Rect;
  Dec(R.Bottom,2);
  If Column.Field = qryCampos.Fields[1] Then
  Begin
    If Not (gdSelected in State) Then
      DBGrid2.Canvas.FillRect(Rect);
    DrawText(DBGrid2.Canvas.Handle,PChar(qryCampos.Fields[1].AsString), Length(qryCampos.Fields[1].AsString),R,DT_WORDBREAK);
  End;
End;

procedure TFMenuMigrador.dsTabelasSQLDataChange(Sender: TObject; Field: TField);
begin
  if (qryTabelasSQL.Active) and (qryTabelasSQL.RecordCount > 0) then
  begin
    qryCampos.Close;
    qryCampos.SQL.Clear;
    qryCampos.SQL.Add('SELECT ORDINAL_POSITION AS CODIGO, COLUMN_NAME CAMPO, DATA_TYPE TIPO, ');
    qryCampos.SQL.Add('       CHARACTER_OCTET_LENGTH AS TAM ');
    qryCampos.SQL.Add('  FROM INFORMATION_SCHEMA.COLUMNS    ');
    qryCampos.SQL.Add(' WHERE TABLE_NAME = :TABLE_NAME      ');
    qryCampos.SQL.Add(' ORDER BY ORDINAL_POSITION;          ');
    qryCampos.Parameters.ParamByName('TABLE_NAME').Value := qryTabelasSQL.Fields[0].AsString;
    qryCampos.Open;

    RichEdit2.Lines.Text := 'a Tabela ' + qryTabelasSQL.Fields[0].AsString +
      ' será criada na base Firebird com o nome: [' + AnsiUpperCase(edtPrefixo.Text) +
        AnsiUpperCase(qryTabelasSQL.Fields[0].AsString) + ']';
  end
  else
  begin
    qryCampos.Close;
    RichEdit2.Lines.Clear;
  end;
end;

procedure TFMenuMigrador.edtPesquisaTabChange(Sender: TObject);
begin
  if (qryTabelasSQL.Active) and (qryTabelasSQL.RecordCount > 0) then
    qryTabelasSQL.Filter := qryTabelasSQL.Fields[0].FieldName + ' like ' + QuotedStr('%' + edtPesquisaTab.Text + '%');
end;

procedure TFMenuMigrador.edtPesquisaTabEnter(Sender: TObject);
begin
  if edtPesquisaTab.Text = 'Pesquisar tabelas' then
    edtPesquisaTab.Clear;
end;

function TFMenuMigrador.FormataCampoEspecial(pNome, Tipo: string): string;
begin
  Result := pNome;

  if Tipo = 'date' then
    Result := 'CONVERT(VARCHAR(10), ' + pNome+ ', 103) AS ' + pNome;
  if Tipo = 'time' then
    Result := 'CAST('+ pNome + ' AS VARCHAR(5)) AS ' + pNome;

end;

procedure TFMenuMigrador.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
   arq_ini.WriteString('SQL', 'HOST', sql_host.Text);
   arq_ini.WriteString('SQL', 'USUARIO', sql_usuario.Text);
   arq_ini.WriteString('SQL', 'SENHA', sql_senha.Text);
   arq_ini.WriteString('SQL', 'DATABASE', sql_database.Text);

   arq_ini.WriteString('FIREBIRD', 'HOST', fb_host.Text);
   arq_ini.WriteString('FIREBIRD', 'PORTA', fb_porta.Text);   
   arq_ini.WriteString('FIREBIRD', 'USUARIO', fb_usuario.Text);
   arq_ini.WriteString('FIREBIRD', 'SENHA', fb_senha.Text);
   arq_ini.WriteString('FIREBIRD', 'DATABASE', fb_database.Text);

   arq_ini.WriteString('MIGRACAO', 'PREFIXO_TABELA_DESTINO', edtPrefixo.Text);
end;

procedure TFMenuMigrador.FormCreate(Sender: TObject);
begin
  PageControl1.ActivePageIndex := 0;

 try
   CaminhoExe := ExtractFilePath(Application.ExeName);

   arq_ini := TIniFile.Create(CaminhoExe + 'CONFIG.ini');
   sql_host.Text := arq_ini.ReadString('SQL', 'HOST', 'localhost');
   sql_usuario.Text := arq_ini.ReadString('SQL', 'USUARIO', 'sa');
   sql_senha.Text := arq_ini.ReadString('SQL', 'SENHA', '30232800');
   sql_database.Text := arq_ini.ReadString('SQL', 'DATABASE', 'INTEGRADO');

   fb_host.Text := arq_ini.ReadString('FIREBIRD', 'HOST', 'localhost');
   fb_porta.Text := arq_ini.ReadString('FIREBIRD', 'PORTA', '3050');
   fb_usuario.Text := arq_ini.ReadString('FIREBIRD', 'USUARIO', 'SYSDBA');
   fb_senha.Text := arq_ini.ReadString('FIREBIRD', 'SENHA', 'masterkey');
   fb_database.Text := arq_ini.ReadString('FIREBIRD', 'DATABASE', '');

   edtPrefixo.Text := arq_ini.ReadString('MIGRACAO', 'PREFIXO_TABELA_DESTINO', 'ESCRIBA_');

  except
    on e:exception do
      ShowMessage('Erro ao entrar no aplicativo: ' + e.Message);
  end;
end;

procedure TFMenuMigrador.btnTestaConnClick(Sender: TObject);
begin
  try
    ConectarDataBase;
    qryTabelasSQL.Open;
    LabelMySQL.Caption := 'SQL Conectado';
    RichEdit1.Lines.Add('Base SQL conectado;');
  except
    On e: exception do
    begin
      MessageDlg('Erro ao conectar ao banco de dados SQL' +
        chr(10) + 'Erro: ' + e.message, mtError, [mbOK], 0);
      LabelMySQL.Caption := 'NÃO Conectado';
    end;
  end;

end;

procedure TFMenuMigrador.btnConectaBaseFBClick(Sender: TObject);
begin
  if Trim(fb_host.Text) + Trim(fb_database.Text) = EmptyStr then
  begin
    ShowMessage('Digite os dados de conexão.');
    Exit;
  end;

  try
    IBDatabaseFB.Close;
    IBDatabaseFB.DatabaseName := fb_host.Text + ':' + fb_database.Text;
    IBDatabaseFB.Params.Clear;
    IBDatabaseFB.Params.Add('user_name=' + fb_usuario.Text);
    IBDatabaseFB.Params.Add('password=' + fb_senha.Text);
    IBDatabaseFB.Open;
    RichEdit1.Lines.Add('Base Firebird conctado;');
    Label13.Caption := 'FB Conectado'
  except
    On e: exception do
    begin
      MessageDlg('Erro ao conectar ao banco de dados FIREBIRD' +
        chr(10) + 'Erro: ' + e.message, mtError, [mbOK], 0);
      Label13.Caption := 'NÃO Conectado';
    end;
  end;


end;

procedure TFMenuMigrador.SpeedButton3Click(Sender: TObject);
begin
  Close;
end;

procedure TFMenuMigrador.btnImportaClick(Sender: TObject);
begin
  EnviaRegistrosToFirebird(qryTabelasSQL.Fields[0].AsString, ChaveDefinida);
end;

procedure TFMenuMigrador.btnPreparaClick(Sender: TObject);
var
  script:widestring;
begin
  if Trim(edtPrefixo.Text) = EmptyStr then
  begin
    ShowMessage('Preencha o campo [PREFIXO], esta informação será usada para formar o nome da tabela no banco de destino (FB)');
    PageControl1.ActivePageIndex := 0;
    edtPrefixo.SetFocus;
    edtPrefixo.Color := $0080FFFF;
    Exit;
  end;
  btnConectaBaseFBClick(Sender);
  Script := MontaCreateTable(qryTabelasSQL.Fields[0].AsString);
  RichEdit3.Lines.SetText(pchar(script));
  CriarTabela(qryTabelasSQL.Fields[0].AsString, Script);
end;

function TFMenuMigrador.TabelaExisteFirebird(pNomeTabela: string): boolean;
var
  IBQuery: TIBQuery;
begin
  try
    IBQuery := TIBQuery.Create(Self);
    IBQuery.Database := IBDatabaseFB;
    IBQuery.SQL.Text := 'SELECT RDB$RELATION_NAME FROM RDB$RELATIONS WHERE RDB$RELATION_NAME = ' +
      QuotedStr(AnsiUpperCase(edtPrefixo.Text) + AnsiUpperCase(pNomeTabela));
    IBQuery.open;
    Result := not IBQuery.IsEmpty;
  except
    on e: exception do
      showmessage('Erro ao verificar a existência da tabela no Firebird' + 
        chr(10) + 'Erro: ' + E.Message);
  end;
end;

procedure TFMenuMigrador.TabSheet2Enter(Sender: TObject);
begin
  btnTestaConnClick(SENDER);
end;

procedure TFMenuMigrador.CriarTabela(pNomeTabela: string; pScript: WideString);
var
  IBQuery: TIBQuery;
begin
  if TabelaExisteFirebird(pNomeTabela) then
  begin
    btnImporta.Enabled := True;
    RichEdit1.Lines.Add('Tabela ' + AnsiUpperCase(edtPrefixo.Text) + pNomeTabela + ' já existe na base Firebird');
    Exit;
  end;

  try
    IBQuery := TIBQuery.Create(Self);
    IBQuery.Database := IBDatabaseFB;
    IBQuery.SQL.Text := pScript;
    IBQuery.ExecSQL;
    RichEdit1.Lines.Add('Tabela ' + AnsiUpperCase(edtPrefixo.Text) + pNomeTabela + ' criada com sucesso na base Firebird');
    btnImporta.Enabled := True;
  except
    on e: exception do
      ShowMessage('Erro ao criar tabela no Firebird' + chr(10) + 'Erro' + e.Message);
  end;

  TFuncoesFB.AtualizaTransacao(IBTransaction);
end;

function TFMenuMigrador.MontaCreateTable(pNomeTabela: string) : WideString;
var
  slScript: TStringList;
  strCampo: string;
  strScriptDDL: string;
  i: integer;
  strNomeTabelaDestino: string;
  iQtdeCarac: integer;
begin
  strScriptDDL := '';
  ChaveDefinida := '';
  strNomeTabelaDestino := AnsiUpperCase(edtPrefixo.Text + pNomeTabela);
  slScript := TStringList.Create;
  slScript.Add('CREATE TABLE ' + strNomeTabelaDestino + ' ( ');

  qryCampos.First;
  i := 1;
  while not qryCampos.eof do
  begin
    iQtdeCarac := Length(qryCampos.FieldByName('CAMPO').AsString);
    strCampo := NomeCampoFB(qryCampos.FieldByName('CAMPO').AsString, i);

    strScriptDDL := '  ' + strCampo + ' ' + TFuncao.RetornaTipoCampo(qryCampos.FieldByName('TIPO').AsString,
      qryCampos.FieldByName('TAM').AsString);

//    if (qryCampos.FieldByName('key').Value = 'PRI') then
//    begin
//      if ChaveDefinida = '' then
//        ChaveDefinida := qryCampos.FieldByName('CAMPO').AsString
//      else
//        ChaveDefinida := ChaveDefinida + ', ' + qryCampos.FieldByName('CAMPO').AsString;
//    end;

    if (i < qryCampos.RecordCount) or (ChaveDefinida <> '') then
      strScriptDDL := strScriptDDL + ',';

    slScript.Add(strScriptDDL);

    inc(i, 1);
    qrycampos.Next;
  end;

//  if ChaveDefinida <> '' then
//    slScript.Add('  CONSTRAINT PK_' + strNomeTabelaDestino + ' PRIMARY KEY (' + ChaveDefinida + ') ');

  slScript.Add(');');
  ShowMessage(slScript.GetText);
  Result := slScript.GetText;
end;

function TFMenuMigrador.MontaInsertInto(pNomeTabela: string) : WideString;
var
  strCampo, strCampo2: string;
  i: integer;
begin
  strCampo := '';
  strCampo2 := '';
  qryCampos.First;
  i := 1;
  while not qryCampos.eof do
  begin
    strCampo := strCampo + NomeCampoFB(qryCampos.FieldByName('campo').AsString, i);
    strCampo2 := strCampo2 + ':' + NomeCampoFB(qryCampos.FieldByName('campo').AsString, i);

    if i <  qryCampos.RecordCount then
    begin
      strCampo := strCampo + ',';
      strCampo2 := strCampo2 + ',';
    end
    else
    begin
      strCampo := strCampo + ')';
      strCampo2 := strCampo2 + ');';
    end;

    inc(i, 1);
    qrycampos.Next;
  end;

  Result := ' INSERT INTO ' + AnsiUpperCase(edtPrefixo.Text) + pNomeTabela + ' (' + strCampo +
    ' VALUES ( ' + strCampo2;
end;

function TFMenuMigrador.MontaSelect(pNomeTabela: string): WideString;
var
  strCampo: string;
  i: integer;
begin
  strCampo := '';
  qryCampos.First;
  i := 1;
  while not qryCampos.eof do
  begin

    strCampo := strCampo + FormataCampoEspecial(qryCampos.FieldByName('campo').AsString,
      qryCampos.FieldByName('tipo').AsString);

    if i <  qryCampos.RecordCount then
    begin
      strCampo := strCampo + ',';
    end
    else
    begin
      strCampo := strCampo + ' from ' + pNomeTabela + ';';
    end;

    inc(i, 1);
    qrycampos.Next;
  end;

  Result := ' SELECT ' + strCampo;
end;

function TFMenuMigrador.NomeCampoFB(pCampo: string;
  pIndice: integer): string;
begin
  if Length(pCampo) < 31 then
    Result := pCampo
  else
    Result := Copy(pCampo, 1, 28) + IntToStr(pIndice);
end;

procedure TFMenuMigrador.EnviaRegistrosToFirebird(pNomeTabela, pCampoChave: string);
var
  qrySQL: TADOQuery;
  qryFirebird: TIBQuery;
  i, iCampo: integer;
  strFirebirdSQLText: string;
  strCampoAtual, strValorAtual: string;
  strCampo: string;
begin
  qrySQL := TADOQuery.Create(Self);
  TFuncoesFB.AtualizaTransacao(IBTransaction);
  TFuncoesFB.IniciaTransacao(IBTransaction);
  Cursor := crHourGlass;
  try
    qrySQL.Connection := Conn;
    qrySQL.SQL.Text := 'SELECT COUNT(1) FROM ' + pNomeTabela;
    qrySQL.Open;

    ProgressBar1.Max := qrySQL.Fields[0].AsInteger;
    RichEdit1.Lines.Add('Qtde de registros para importar: ' + qrySQL.Fields[0].AsString);

    qrySQL.Close;
    qrySQL.SQL.Clear;
    qrySQL.SQL.Text := MontaSelect(pNomeTabela);
    qrySQL.Open;

    strFirebirdSQLText := MontaInsertInto(pNomeTabela);
    RichEdit1.Lines.Add('A importação iniciou às: ' + TimeToStr(Time) + ' aguarde...');

    while not qrySQL.eof do
    begin
      qryFirebird := TIBQuery.Create(Self);
      qryFirebird.Database := IBDatabaseFB;
      qryFirebird.Transaction := IBTransaction;
      qryFirebird.SQL.Text := strFirebirdSQLText;
      try
        for iCampo := 0 to qrySQL.Fields.Count -1 do
        begin
          if not qrySQL.Fields[iCampo].IsNull then
          begin
            strCampo := NomeCampoFB(qrySQL.Fields[iCampo].FieldName, iCampo + 1);

            case qrySQL.Fields[iCampo].DataType of
              ftAutoInc, ftSmallint, ftInteger, ftWord, ftLargeint, ftLongWord, ftShortint, ftByte, ftBoolean:
              begin
                qryFirebird.ParamByName(strCampo).AsInteger := qrySQL.Fields[iCampo].AsInteger;
              end;
              ftFMTBcd, ftFloat, ftCurrency, ftBCD , ftExtended :
              begin
                qryFirebird.ParamByName(strCampo).AsFloat := qrySQL.Fields[iCampo].AsFloat;
              end;
              ftDate, ftTime, ftDateTime, ftTimeStamp:
              begin
                qryFirebird.ParamByName(strCampo).AsDateTime := TFuncao.FormataCampoData(qrySQL.Fields[iCampo].AsString);
              end;
              ftString, ftBlob, ftMemo, ftWideString, ftFixedWideChar, ftWideMemo, ftBytes, ftVarBytes :
              begin
                qryFirebird.ParamByName(strCampo).aSANsIString := qrySQL.Fields[iCampo].ASANSIString;
              end;
              else
              begin
                qryFirebird.ParamByName(strCampo).ASANSIstring := qrySQL.Fields[iCampo].ASANSIstring;
              end;
            end;
          end;
        end;
        qryFirebird.ExecSQL;
        qrySQL.Next;
        ProgressBar1.Position := ProgressBar1.Position + 1;
        Self.Refresh;
        Application.ProcessMessages;
      finally
        FreeAndNil(qryFirebird);
        Cursor := crDefault;
      end;
    end;
  except

    ON E:Exception do
    begin
      ShowMessage('Erro : ' + e.Message + ' Campo atual: ' + strCampoAtual + ' Valor : ' + strValorAtual);
    end;
  end;

  TFuncoesFB.ComitaTransacao(IBTransaction);
  RichEdit1.Lines.Add('A importação terminou às: ' + TimeToStr(Time));
end;

procedure TFMenuMigrador.ConectarDataBase;
var
  vBanco, vServidor, vSenha, vUsuario:string;
begin
  try
    vServidor := sql_host.Text;
    vBanco := sql_database.Text;
    vSenha := sql_senha.Text;
    vUsuario := sql_usuario.Text;

    Conn.Connected := False;
    Conn.ConnectionString := EmptyStr;
    Conn.LoginPrompt := False;
    Conn.ConnectionString := 'Provider=SQLOLEDB.1;Password=' + vSenha + ';' +
    'Persist Security Info=True;User ID=' + vUsuario + ';'+
    'Initial Catalog='+ vBanco +';'+
    'Data Source=' + vServidor;
    if not(Conn.Connected) then
      Conn.Connected := True;
  Except
    on e : exception do
      MessageDlg('Erro ao conectar banco de dados!' + e.Message, mtError, [mbOK], 0);
  end;

end;

end.
