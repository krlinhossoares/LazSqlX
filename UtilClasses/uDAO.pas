{

*** Classe DAO *** ...

Esta classe tem como objetivo fazer dinamicamente a persistencia de objetos nas tabelas do banco de dados.

Esta classe foi criada usando as técnicas de leitura de Metadata da tabela do banco de dados e
usando as técnicas de RTTI do Delphi.

Para utilizar a classe DAO o objeto a ser persistido deve ter duas particularidades:
1.Herdar TPersistent.
2.As propriedades que serão lidas pelo objeto DAO devem estar com o acesso Published.

Para fazer a persistência do objeto simplesmente siga o exemplo abaixo:
procedure TArtigoController.RetornarArtigo(var artigo: TARTIGO);
var
artigoDAO : TDAO;
begin
  artigoDAO := TDAO.Create(glMaster, 'TBARTIGO');
  try
    if not (artigoDAO.Return(TObject(artigo))) then
    begin
      glMaster.Erros.ShowErro;
      Exit;
    end;
  finally
    FreeAndNil(artigoDAO);
  end;
end;

*** INFORMAÇÕES PARA HERDAR O OBJETO TDAO E INFORMAR AS PROPRIEDADES ESPECIAIS ***

No caso de o objeto a ser persistido não ter propriedades especiais o mesmo pode ser usado
diretamente com a classe TDAO sem necessitar de um objeto herdado.

Propriedades que NÃO são especiais são as propriedades com tipos primitivos:
String, Integer, Smallint, Double, Real, TDateTime, TDate, TTime...

Propriedades especiais são objetos dentro do objeto os quais o RTTI não consegue ler dinamicamente:
Ex: TBCD, TPessoa, TUm...
Também podem ser colocadas propriedades com tipos primitivos que tenham que receber um tratamento especial.

Se o objeto a ser persistido tiver propriedades especiais então deve ser criado um objeto que
herde TDAO e devem ser indicadas as propriedades especiais conforme exemplo abaixo:

-----------------------------------------------------------------------------------------------------------------------------
uses
  uDAO;

TClasseFilha = class(TDAO)
private
  function GetSpecialParamFields: string; override;
  procedure SpecialParamInsertUpdate(obj: TObject); override;
  procedure SpecialFieldsReturnList(var obj: TObject); override;
public

end;

implementation

function TSubClasse.GetSpecialParamFields: string;
begin
  Result := ';CAMPO1;CAMPO2;';
end;

procedure TSubClasse.SpecialParamInsertUpdate(obj: TObject);
begin
  Self.ibSQL.ParamByName('CAMPO1').As(colocar o tipo correspondente) := TClassePersistent(obj).CAMPO1;
  Self.ibSQL.ParamByName('CAMPO2').As(colocar o tipo correspondente) := TClassePersistent(obj).CAMPO2;
end;

procedure TSubClasse.SpecialFieldsReturnList(var obj: TObject);
begin
  TClassePersistent(obj).CAMPO1 := Self.ibQy.FieldByName('CAMPO1').As(colocar o tipo correspondente);
  TClassePersistent(obj).CAMPO2 := Self.ibQy.FieldByName('CAMPO2').As(colocar o tipo correspondente);
end;

end.
-----------------------------------------------------------------------------------------------------------------------------
}

unit uDAO;

interface

uses
  SysUtils, Classes, Contnrs, IBQuery, IBSQL, FMTBcd, TypInfo,
  uMaster, uConexao, uErros, uErrosRG;

  type

  TValueType = (tpString, tpInteger, tpFloat, tpDateTime, tpBCd, tpNull);

  TTableField = class
  private
    FFK: Boolean;
    FPK: Boolean;
    Fprecision: Integer;
    Fscale: Integer;
    Ftp: Integer;
    Fname: string;
    FtpQy: TValueType;
  public
    property name: string read Fname write Fname;
    property tp: Integer read Ftp write Ftp;
    property precision: Integer read Fprecision write Fprecision;
    property scale: Integer read Fscale write Fscale;
    property tpQy: TValueType read FtpQy write FtpQy;
    property PK: Boolean read FPK write FPK;
    property FK: Boolean read FFK write FFK;
  end;

  TTable = class
  private
    table: String;
    tableFields: TObjectList;
    pk: TStringList;
    fk: TStringList;
  public
    destructor Destroy;
    function LoadTable(Con:TConexao; table: string; var Erros: TErros): Boolean;
  end;

  TDAO = class
  private
  Con: TConexao;
  Erros: TErros;
  tableName: string;
  table: TTable;
  SqlIns: string;
  SqlUpd: string;
  SqlDel: string;
  SqlRet: string;
  function SqlInsert(): string;
  function SqlUpdate(): string;
  function SqlDelete(): string;
  function SqlReturn(): string;
  procedure ParamInsertUpdate(obj: TObject);
  procedure ParamDelete(obj: TObject);
  procedure ParamReturn(obj: TObject);
  procedure FieldsReturnList(var obj: TObject);
  protected
  ibSQL: TIBSQL;
  ibQy: TIBQuery;
  function GetSpecialParamFields(): string; virtual;
  procedure SpecialParamInsertUpdate(obj: TObject); virtual;
  procedure SpecialFieldsReturnList(var obj: TObject); virtual;
  public
  constructor Create(); overload;
  constructor Create(Master: TMaster; tabela: string); overload;
  destructor Destroy();
  function Insert(obj: TObject): Boolean;
  function Update(obj: TObject): Boolean;
  function Delete(obj: TObject): Boolean;
  function Return(var obj: TObject): Boolean;
  function List(classType: TClass; condition: string; var list: TObjectList): Boolean;
  end;

implementation

destructor TTable.Destroy;
begin
  inherited;
  FreeAndNil(Self.tableFields);
  FreeAndNil(Self.pk);
  FreeAndNil(Self.fk);
end;

function TTable.LoadTable(Con:TConexao; table: string; var Erros: TErros): Boolean;
var
  ibQy: TIBQuery;
  tableField: TTableField;
  i: Integer;
begin

  Erros.LimparErros;
  Erros.ErroTecnico := '[ TTable.LoadTable ]';

  Result            := false;

  Self.table := table;

  Self.tableFields := TOBjectList.Create;
  Self.pk          := TStringList.Create;
  Self.fk          := TStringList.Create;

  ibQy := TIBQuery.Create(nil);

  try

    ibQy.Database    := Con.DB;
    ibQy.Transaction := Con.Trans;

    try
      //Carregar lista de Primary Keys
      ibQy.Close;
      ibQy.Sql.Text :=  ' select idx.RDB$FIELD_NAME PK                                            '+
                        ' from RDB$RELATION_CONSTRAINTS tc                                        '+
                        ' join RDB$INDEX_SEGMENTS idx on (idx.RDB$INDEX_NAME = tc.RDB$INDEX_NAME) '+
                        ' where tc.RDB$CONSTRAINT_TYPE = ''PRIMARY KEY''                          '+
                        ' and tc.RDB$RELATION_NAME = :TABELA                                      '+
                        ' order by idx.RDB$FIELD_POSITION                                         ';

      ibQy.ParamByName('TABELA').AsString := Self.table;

      ibQy.Open;

      ibQy.First;
      while not ibQy.Eof do
      begin
        Self.pk.Add(Trim(ibQy.FieldByName('PK').AsString));
        ibQy.Next;
      end;

      //Carregar lista de Foreign Keys
      ibQy.Close;
      ibQy.Sql.Text :=  ' select distinct isc.rdb$field_name AS FK                                                          '+
                        ' from rdb$ref_constraints AS rc                                                                    '+
                        ' inner join rdb$relation_constraints AS rcc on (rc.rdb$constraint_name = rcc.rdb$constraint_name)  '+
                        ' inner join rdb$index_segments AS isc on (rcc.rdb$index_name = isc.rdb$index_name)                 '+
                        ' inner join rdb$relation_constraints AS rcp on (rc.rdb$const_name_uq  = rcp.rdb$constraint_name)   '+
                        ' inner join rdb$index_segments AS isp on (rcp.rdb$index_name = isp.rdb$index_name)                 '+
                        ' WHERE rcc.rdb$relation_name = :TABELA                                                             '+
                        ' and isp.rdb$field_name <> ''CDEMPRESA''                                                           '+
                        ' and isc.rdb$field_name <> ''CDEMPRESA''                                                           ';

      ibQy.ParamByName('TABELA').AsString := Self.table;

      ibQy.Open;

      ibQy.First;
      while not ibQy.Eof do
      begin
        Self.fk.Add(Trim(ibQy.FieldByName('FK').AsString));
        ibQy.Next;
      end;

      //Carregar campos da tabela
      ibQy.Close;
      ibQy.Sql.Text :=  ' SELECT r.RDB$FIELD_NAME AS name,                                   '+
                        ' f.RDB$FIELD_TYPE AS tp,                                            '+
                        ' f.RDB$FIELD_PRECISION as field_precision,                          '+
                        ' f.RDB$FIELD_SCALE as scale                                         '+
                        ' FROM RDB$RELATION_FIELDS r                                         '+
                        ' LEFT JOIN RDB$FIELDS f ON (r.RDB$FIELD_SOURCE = f.RDB$FIELD_NAME)  '+
                        ' WHERE r.RDB$RELATION_NAME= :TABELA                                 '+
                        ' ORDER BY r.RDB$FIELD_POSITION;                                     ';

      ibQy.ParamByName('TABELA').AsString := Self.table;

      ibQy.Open;

      ibQy.First;
      while not ibQy.Eof do
      begin

        tableField := TTableField.Create;

        tableField.name      := Trim(ibQy.FieldByName('name').AsString);
        tableField.tp        := ibQy.FieldByName('tp').AsInteger;
        tableField.precision := ibQy.FieldByName('field_precision').AsInteger;
        tableField.scale     := ibQy.FieldByName('scale').AsInteger;

        tableField.PK := False;
        for i:=0 to Self.pk.Count-1 do
        begin
          if (Trim(Self.pk[i]) = tableField.name) then
          begin
            tableField.PK := True;
            Break;
          end;
        end;

        tableField.FK := False;
        for i:=0 to Self.fk.Count-1 do
        begin
          if (Trim(Self.fk[i]) = tableField.name) then
          begin
            tableField.FK := True;
            Break;
          end;
        end;

        if (tableField.tp = 14) or (tableField.tp = 37) then
        begin
          tableField.tpQy := tpString;
        end
        else if (tableField.tp = 7) or ((tableField.tp = 8) and (tableField.precision = 0)) then
        begin
          tableField.tpQy := tpInteger;
        end
        else if ((tableField.tp = 8) and (tableField.precision > 0)) or (tableField.tp = 10) or (tableField.tp = 27) then
        begin
          tableField.tpQy := tpFloat;
        end
        else if (tableField.tp = 12) or (tableField.tp = 13) or (tableField.tp = 35) then
        begin
          tableField.tpQy := tpDateTime;
        end
        else if (tableField.tp = 16) then
        begin
          tableField.tpQy := tpBCD;
        end
        else
        begin
          tableField.tpQy := tpNull;
        end;

        Self.tableFields.Add(tableField);

        ibQy.Next;
      end;

    except
      on E: Exception do
      begin
        Erros.mensagemAmigavel   := 'Erro ao Carregar Tabela: '+Self.table+'!';
        Erros.ErroTecnico        := '[TTable.LoadTable - Table: '+Self.table+' ] ' + E.Message;
        Erros.SQL                := ibQy.SQL.Text;
        //Erros.Params             := montaParametrosGlErros(Con, ibQy);
        Result                   := False;
        Exit;
      end;
    end;

    Erros.LimparErros;
    Result := True;

  finally
   FreeAndNil(ibQy);
  end;

end;

constructor TDAO.Create();
begin
  inherited;
end;

constructor TDAO.Create(Master: TMaster; tabela: string);
begin
  Self.tableName := '';

  if Self.table <> nil then
    FreeAndNil(Self.table);
    
  Self.SqlIns := '';
  Self.SqlUpd := '';
  Self.SqlDel := '';
  Self.SqlRet := '';

  Self.Con       := Master.Con;
  Self.Erros     := Master.Erros;
  Self.tableName := tabela;
end;

destructor TDAO.Destroy;
begin
  if Self.table <> nil then
    FreeAndNil(self.table);
end;

function TDAO.SqlInsert: string;
var
  i: Integer;
  sql: string;
begin

  if (Self.SqlIns = '') then
  begin
    sql := 'insert into '+Self.tableName+' (';

    for i:=0 to Self.table.tableFields.Count-1 do
    begin
      if (i < Self.table.tableFields.Count-1) then
        sql := sql + TTableField(Self.table.tableFields.Items[i]).name + ', '
      else
        sql := sql + TTableField(Self.table.tableFields.Items[i]).name + ') ';
    end;

    sql := sql + 'values (';

    for i:=0 to Self.table.tableFields.Count-1 do
    begin
      if (i < Self.table.tableFields.Count-1) then
        sql := sql + ':'+TTableField(Self.table.tableFields.Items[i]).name + ', '
      else
        sql := sql + ':'+TTableField(Self.table.tableFields.Items[i]).name + ')';
    end;

    sql := sql + ';';

    Self.SqlIns := sql;
  end;

  Result := Self.SqlIns;
end;

function TDAO.SqlUpdate: string;
var
  i: Integer;
  sql: string;
begin
  if (Self.SqlUpd = '') then
  begin
    sql := 'update '+Self.tableName+' set ';

    for i:=0 to Self.table.tableFields.Count-1 do
    begin
      if (TTableField(Self.table.tableFields.Items[i]).PK = False) then
        sql := sql + TTableField(Self.table.tableFields.Items[i]).name + ' = :'+TTableField(Self.table.tableFields.Items[i]).name + ', ';
    end;

    sql := Copy(Trim(sql), 1, length(Trim(sql))-1);

    sql := sql + ' where ';

    for i:=0 to Self.table.tableFields.Count-1 do
    begin
      if (TTableField(Self.table.tableFields.Items[i]).PK = True) then
        sql := sql + TTableField(Self.table.tableFields.Items[i]).name + ' = :'+TTableField(Self.table.tableFields.Items[i]).name + ' and ';
    end;

    sql := Copy(Trim(sql), 1, length(Trim(sql))-4);

    sql := sql + ';';

    Self.SqlUpd := sql;
  end;

  Result := Self.SqlUpd;
end;

function TDAO.SqlDelete: string;
var
  i: Integer;
  sql: string;
begin

  if (Self.SqlDel = '') then
  begin
    sql := 'delete from '+Self.tableName+' where ';

    for i:=0 to Self.table.tableFields.Count-1 do
    begin
      if (TTableField(Self.table.tableFields.Items[i]).PK = True) then
        sql := sql + TTableField(Self.table.tableFields.Items[i]).name + ' = :'+TTableField(Self.table.tableFields.Items[i]).name + ' and ';
    end;

    sql := Copy(Trim(sql), 1, length(Trim(sql))-4);

    sql := sql + ';';

    Self.SqlDel := sql;
  end;

  Result := Self.SqlDel;
end;

function TDAO.SqlReturn: string;
var
  i: Integer;
  sql: string;
begin

  if (Self.SqlRet = '') then
  begin
    sql := 'select * from '+Self.tableName+' where ';

    for i:=0 to Self.table.tableFields.Count-1 do
    begin
      if (TTableField(Self.table.tableFields.Items[i]).PK = True) then
        sql := sql + TTableField(Self.table.tableFields.Items[i]).name + ' = :'+TTableField(Self.table.tableFields.Items[i]).name + ' and ';
    end;

    sql := Copy(Trim(sql), 1, length(Trim(sql))-4);

    sql := sql + ';';

    Self.SqlRet := sql;
  end;

  Result := Self.SqlRet;
end;

procedure TDAO.ParamInsertUpdate(obj: TObject);
var
  i: Integer;
begin

  for i:=0 to Self.table.tableFields.Count-1 do
  begin

    if (TTableField(Self.table.tableFields.Items[i]).tpQy = tpString) then
    begin
      if (string(GetPropValue(obj, TTableField(Self.table.tableFields.Items[i]).name)) <> '') then
        Self.ibSql.ParamByName(TTableField(Self.table.tableFields.Items[i]).name).AsString :=
        string(GetPropValue(obj, TTableField(Self.table.tableFields.Items[i]).name))
      else
        Self.ibSql.ParamByName(TTableField(Self.table.tableFields.Items[i]).name).Clear;
    end
    else if (TTableField(Self.table.tableFields.Items[i]).tpQy = tpInteger) then
    begin
      if (((TTableField(Self.table.tableFields.Items[i]).PK) or (TTableField(Self.table.tableFields.Items[i]).FK)) and
         (Integer(GetPropValue(obj, TTableField(Self.table.tableFields.Items[i]).name)) > 0))
      then
        Self.ibSql.ParamByName(TTableField(Self.table.tableFields.Items[i]).name).AsInteger :=
        Integer(GetPropValue(obj, TTableField(Self.table.tableFields.Items[i]).name))
      else
        Self.ibSql.ParamByName(TTableField(Self.table.tableFields.Items[i]).name).Clear;
    end
    else if (TTableField(Self.table.tableFields.Items[i]).tpQy = tpFloat) then
      Self.ibSql.ParamByName(TTableField(Self.table.tableFields.Items[i]).name).AsFloat :=
      Double(GetPropValue(obj, TTableField(Self.table.tableFields.Items[i]).name))
    else if (TTableField(Self.table.tableFields.Items[i]).tpQy = tpDateTime) then
    begin
      if (TDateTime(GetPropValue(obj, TTableField(Self.table.tableFields.Items[i]).name)) > 0) then
        Self.ibSql.ParamByName(TTableField(Self.table.tableFields.Items[i]).name).AsDateTime :=
        TDateTime(GetPropValue(obj, TTableField(Self.table.tableFields.Items[i]).name))
      else
        Self.ibSql.ParamByName(TTableField(Self.table.tableFields.Items[i]).name).Clear;
    end
    else
    begin
      if (Pos(';'+TTableField(Self.table.tableFields.Items[i]).name+';', Self.GetSpecialParamFields) = 0) then
        Self.ibSql.ParamByName(TTableField(Self.table.tableFields.Items[i]).name).AsVariant :=
        GetPropValue(obj, TTableField(Self.table.tableFields.Items[i]).name);
    end;
  end;
end;

procedure TDAO.ParamDelete(obj: TObject);
var
  i: Integer;
begin
  for i:=0 to Self.table.tableFields.Count-1 do
  begin
    if (TTableField(Self.table.tableFields.Items[i]).PK = True) then
    begin
      if (TTableField(Self.table.tableFields.Items[i]).tpQy = tpString) then
        Self.ibSql.ParamByName(TTableField(Self.table.tableFields.Items[i]).name).AsString :=
          string(GetPropValue(obj, TTableField(Self.table.tableFields.Items[i]).name))
      else if (TTableField(Self.table.tableFields.Items[i]).tpQy = tpInteger) then
        Self.ibSql.ParamByName(TTableField(Self.table.tableFields.Items[i]).name).AsInteger :=
          Integer(GetPropValue(obj, TTableField(Self.table.tableFields.Items[i]).name))
      else if (TTableField(Self.table.tableFields.Items[i]).tpQy = tpFloat) then
        Self.ibSql.ParamByName(TTableField(Self.table.tableFields.Items[i]).name).AsFloat :=
          Double(GetPropValue(obj, TTableField(Self.table.tableFields.Items[i]).name))
      else if (TTableField(Self.table.tableFields.Items[i]).tpQy = tpDateTime) then
        Self.ibSql.ParamByName(TTableField(Self.table.tableFields.Items[i]).name).AsDateTime :=
          TDateTime(GetPropValue(obj, TTableField(Self.table.tableFields.Items[i]).name));
    end;
  end;
end;

procedure TDAO.ParamReturn(obj: TObject);
var
  i: Integer;
begin
  for i:=0 to Self.table.tableFields.Count-1 do
  begin
    if (TTableField(Self.table.tableFields.Items[i]).PK = True) then
    begin
      if (TTableField(Self.table.tableFields.Items[i]).tpQy = tpString) then
        Self.ibQy.ParamByName(TTableField(Self.table.tableFields.Items[i]).name).AsString :=
          string(GetPropValue(obj, TTableField(Self.table.tableFields.Items[i]).name))
      else if (TTableField(Self.table.tableFields.Items[i]).tpQy = tpInteger) then
        Self.ibQy.ParamByName(TTableField(Self.table.tableFields.Items[i]).name).AsInteger :=
          Integer(GetPropValue(obj, TTableField(Self.table.tableFields.Items[i]).name))
      else if (TTableField(Self.table.tableFields.Items[i]).tpQy = tpFloat) then
        Self.ibQy.ParamByName(TTableField(Self.table.tableFields.Items[i]).name).AsFloat :=
          Double(GetPropValue(obj, TTableField(Self.table.tableFields.Items[i]).name))
      else if (TTableField(Self.table.tableFields.Items[i]).tpQy = tpDateTime) then
        Self.ibQy.ParamByName(TTableField(Self.table.tableFields.Items[i]).name).AsDateTime :=
          TDateTime(GetPropValue(obj, TTableField(Self.table.tableFields.Items[i]).name))
      else if (TTableField(Self.table.tableFields.Items[i]).tpQy = tpNull) then
        Self.ibQy.ParamByName(TTableField(Self.table.tableFields.Items[i]).name).Clear;
    end;
  end;
end;

procedure TDAO.FieldsReturnList(var obj: TObject);
var
  i: Integer;
begin
  for i:=0 to Self.table.tableFields.Count-1 do
  begin
    if (TTableField(Self.table.tableFields.Items[i]).tpQy = tpString) then
      SetPropValue(obj, TTableField(Self.table.tableFields.Items[i]).name,
      Self.ibQy.FieldByName(TTableField(Self.table.tableFields.Items[i]).name).AsString)
    else if (TTableField(Self.table.tableFields.Items[i]).tpQy = tpInteger) then
      SetPropValue(obj, TTableField(Self.table.tableFields.Items[i]).name,
      Self.ibQy.FieldByName(TTableField(Self.table.tableFields.Items[i]).name).AsInteger)
    else if (TTableField(Self.table.tableFields.Items[i]).tpQy = tpFloat) then
      SetPropValue(obj, TTableField(Self.table.tableFields.Items[i]).name,
      Self.ibQy.FieldByName(TTableField(Self.table.tableFields.Items[i]).name).AsFloat)
    else if (TTableField(Self.table.tableFields.Items[i]).tpQy = tpDateTime) then
      SetPropValue(obj, TTableField(Self.table.tableFields.Items[i]).name,
      Self.ibQy.FieldByName(TTableField(Self.table.tableFields.Items[i]).name).AsDateTime)
    else
    begin
      if (Pos(';'+TTableField(Self.table.tableFields.Items[i]).name+';', Self.GetSpecialParamFields) = 0) then
        SetPropValue(obj, TTableField(Self.table.tableFields.Items[i]).name,
        Self.ibQy.FieldByName(TTableField(Self.table.tableFields.Items[i]).name).AsVariant)
    end;
  end;
end;

function TDAO.GetSpecialParamFields: string;
begin
  //Result := ';FIELD1;FIELD2;FIELD3;';
  Result := '';
end;

procedure TDAO.SpecialParamInsertUpdate(obj: TObject);
begin
  //Self.ibSQL.ParamByName('FIELD').asVariant := TClass(obj).Property;
end;

procedure TDAO.SpecialFieldsReturnList(var obj: TObject);
begin
  //TClass(obj).Property := Self.ibQy.FieldByName('FIELD').asVariant;
end;

function TDAO.Insert(obj: TObject): Boolean;
begin

  if Self.table = nil then
  begin
    Self.table := TTable.Create;
    if not (Self.table.LoadTable(Self.Con, Self.tableName, Self.Erros)) then
    begin
      Result := False;
      Exit;
    end;
  end;

  Self.Erros.LimparErros;
  Self.Erros.ErroTecnico := '[TDAO.Insert - Objeto: ' + obj.ClassName + ' - Tabela: '+Self.tableName+']' ;

  Result            := false;

  Self.ibSql        := TIBSQL.Create(nil);

  try
   Self.ibSql.Database    := Self.Con.DB;
   Self.ibSql.Transaction := Self.Con.Trans;

    try
      Self.ibSql.Close;

      Self.ibSql.Sql.Text := Self.SqlInsert;

      Self.ParamInsertUpdate(obj);

      if (Self.GetSpecialParamFields <> '') then
        Self.SpecialParamInsertUpdate(obj);

      Self.ibSql.ExecQuery;
    except
      on E: Exception do
      begin
        Self.Erros.mensagemAmigavel := 'Erro ao Inserir Objeto: ' + obj.ClassName + ' na Tabela: '+Self.tableName;
        Self.Erros.ErroTecnico      := '[TDAO.Insert] ' + E.Message;
        Self.Erros.SQL              := Self.ibSql.SQL.Text;
        Self.Erros.Params           := montaParametrosGlErros(Self.Con, ibSql);
        Result                      := false;
        Exit;
      end;
    end;

    Self.Erros.LimparErros;
    Result := True;

  finally
    FreeAndNil(Self.ibSql);
  end;

end;

function TDAO.Update(obj: TObject): Boolean;
begin

  if Self.table = nil then
  begin
    Self.table := TTable.Create;
    if not (Self.table.LoadTable(Self.Con, Self.tableName, Self.Erros)) then
    begin
      Result := False;
      Exit;
    end;
  end;

  Self.Erros.LimparErros;
  Self.Erros.ErroTecnico := '[TDAO.Update - Objeto: ' + obj.ClassName + ' - Tabela: '+Self.tableName+']' ;

  Result            := false;

  Self.ibSql        := TIBSQL.Create(nil);

  try
   Self.ibSql.Database    := Self.Con.DB;
   Self.ibSql.Transaction := Self.Con.Trans;

    try
      Self.ibSql.Close;

      Self.ibSql.Sql.Text := Self.SqlUpdate;

      Self.ParamInsertUpdate(obj);

      if (Self.GetSpecialParamFields <> '') then
        Self.SpecialParamInsertUpdate(obj);

      Self.ibSql.ExecQuery;
    except
      on E: Exception do
      begin
        Self.Erros.mensagemAmigavel := 'Erro ao Atualizar Objeto: ' + obj.ClassName + ' na Tabela: '+Self.tableName;
        Self.Erros.ErroTecnico      := '[TDAO.Update] ' + E.Message;
        Self.Erros.SQL              := Self.ibSql.SQL.Text;
        Self.Erros.Params           := montaParametrosGlErros(Self.Con, ibSql);
        Result                      := false;
        Exit;
      end;
    end;

    Self.Erros.LimparErros;
    Result := True;

  finally
    FreeAndNil(Self.ibSql);
  end;

end;

function TDAO.Delete(obj: TObject): Boolean;
begin

  if Self.table = nil then
  begin
    Self.table := TTable.Create;
    if not (Self.table.LoadTable(Self.Con, Self.tableName, Self.Erros)) then
    begin
      Result := False;
      Exit;
    end;
  end;

  Self.Erros.LimparErros;
  Self.Erros.ErroTecnico := '[TDAO.Delete - Objeto: ' + obj.ClassName + ' - Tabela: '+Self.tableName+']' ;

  Result            := false;

  Self.ibSql        := TIBSQL.Create(nil);

  try
   Self.ibSql.Database    := Self.Con.DB;
   Self.ibSql.Transaction := Self.Con.Trans;

    try
      Self.ibSql.Close;

      Self.ibSql.Sql.Text := Self.SqlDelete;

      Self.ParamDelete(obj);

      Self.ibSql.ExecQuery;
    except
      on E: Exception do
      begin
        Self.Erros.mensagemAmigavel := 'Erro ao Apagar Objeto: ' + obj.ClassName + ' da Tabela: '+Self.tableName;
        Self.Erros.ErroTecnico      := '[TDAO.Delete] ' + E.Message;
        Self.Erros.SQL              := Self.ibSql.SQL.Text;
        Self.Erros.Params           := montaParametrosGlErros(Self.Con, ibSql);
        Result                      := false;
        Exit;
      end;
    end;

    Self.Erros.LimparErros;
    Result := True;

  finally
    FreeAndNil(Self.ibSql);
  end;

end;

function TDAO.Return(var obj: TObject): Boolean;
begin

  if Self.table = nil then
  begin
    Self.table := TTable.Create;
    if not (Self.table.LoadTable(Self.Con, Self.tableName, Self.Erros)) then
    begin
      Result := False;
      Exit;
    end;
  end;

  Self.Erros.LimparErros;
  Self.Erros.ErroTecnico := '[TDAO.Return - Objeto: ' + obj.ClassName + ' - Tabela: '+Self.tableName+']' ;

  Result            := false;

  Self.ibQy        := TIBQuery.Create(nil);

  try
   Self.ibQy.Database    := Self.Con.DB;
   Self.ibQy.Transaction := Self.Con.Trans;

    try
      Self.ibQy.Close;

      Self.ibQy.Sql.Text := Self.SqlReturn;

      Self.ParamReturn(obj);

      Self.ibQy.Open;

      Self.FieldsReturnList(obj);

      if (Self.GetSpecialParamFields <> '') then
        Self.SpecialFieldsReturnList(obj);

    except
      on E: Exception do
      begin
        Self.Erros.mensagemAmigavel := 'Erro ao Retornar Objeto: ' + obj.ClassName + ' da Tabela: '+Self.tableName;
        Self.Erros.ErroTecnico      := '[TDAO.Return] ' + E.Message;
        Self.Erros.SQL              := Self.ibQy.SQL.Text;
        Self.Erros.Params           := montaParametrosGlErros(Self.Con, ibSql);
        Result                      := false;
        Exit;
      end;
    end;

    Self.Erros.LimparErros;
    Result := True;

  finally
    FreeAndNil(Self.ibQy);
  end;

end;

function TDAO.List(classType: TClass; condition: string; var list: TObjectList): Boolean;
var obj: TObject;
begin

  if Self.table = nil then
  begin
    Self.table := TTable.Create;
    if not (Self.table.LoadTable(Self.Con, Self.tableName, Self.Erros)) then
    begin
      Result := False;
      Exit;
    end;
  end;

  Self.Erros.LimparErros;
  Self.Erros.ErroTecnico := '[TDAO.List - Objeto: ' + classType.ClassName + ' - Tabela: '+Self.tableName+']' ;

  Result            := false;

  Self.ibQy        := TIBQuery.Create(nil);

  try
   Self.ibQy.Database    := Self.Con.DB;
   Self.ibQy.Transaction := Self.Con.Trans;

    try
      Self.ibQy.Close;

      if (condition <> '') then
       Self.ibQy.Sql.Text := 'select * from '+Self.tableName+' where '+ condition + ';'
      else
       Self.ibQy.Sql.Text := 'select * from '+Self.tableName + ';';

      Self.ibQy.Open;

      Self.ibQy.First;
      while not Self.ibQy.Eof do
      begin
         obj := classType.Create;
         Self.FieldsReturnList(obj);
         if (Self.GetSpecialParamFields <> '') then
           Self.SpecialFieldsReturnList(obj);
         list.Add(obj);
        Self.ibQy.Next;
      end;

    except
      on E: Exception do
      begin
        Self.Erros.mensagemAmigavel := 'Erro ao Listar Objetos: ' + classType.ClassName + ' da Tabela: '+Self.tableName;
        Self.Erros.ErroTecnico      := '[TDAO.List] ' + E.Message;
        Self.Erros.SQL              := Self.ibQy.SQL.Text;
        Self.Erros.Params           := montaParametrosGlErros(Self.Con, ibSql);
        Result                      := false;
        Exit;
      end;
    end;

    Self.Erros.LimparErros;
    Result := True;

  finally
    FreeAndNil(Self.ibQy);
  end;

end;

end.
