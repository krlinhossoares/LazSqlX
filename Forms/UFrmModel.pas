unit UFrmModel;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, SynHighlighterPas, SynHighlighterAny,
  SynCompletion, SynHighlighterJava, SynHighlighterSQL, Forms, Controls,
  Graphics, Dialogs, Math, ComCtrls, ExtCtrls, StdCtrls, ZDataset, ZConnection,
  AsTableInfo, AsCrudInfo, AsSqlGenerator, AsDbType, StrUtils;

type

  { TFrmModel }

  TFrmModel = class(TForm)
    ApplicationImages: TImageList;
    LbProjeto: TLabel;
    LbDirModel: TLabel;
    LbDirDAO: TLabel;
    PageControl1: TPageControl;
    Panel1: TPanel;
    PascalSyntax: TSynPasSyn;
    SynEditModel: TSynEdit;
    SynEditDAO: TSynEdit;
    JavaSyntax: TSynJavaSyn;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    ToolBar1: TToolBar;
    ToolButton2: TToolButton;
    procedure FormShow(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
  private
    { private declarations }
    UnitNameDAO, ClassNameDAO, VarDAO, UnitNameModel, ClassNameModel, VarModel: string;
    MmLazyCodeFunctions: TStringList;

    function FieldExist(FieldsKey: TStringList; Field: string): boolean;
    procedure GenerateLazy;
    function GenerateSqlQuery(queryType: TQueryType): TStringList;
    procedure EscreveSqlSynEditDao(StrList: TStringList);
    procedure GenerateSqlQueryDeleteRecord;
    procedure GenerateSqlQueryGetRecord;
    procedure GenerateSqlQueryInsert;
    procedure GenerateSqlQueryListaRecords;
    procedure GenerateSqlQueryUpdate;
    procedure GeneratorCodeProcDelete;
    procedure GeneratorCodeProcGetItem;
    procedure GeneratorCodeProcInsert;
    procedure GeneratorCodeProcList;
    procedure GeneratorCodeProcUpdate;
    procedure GeneratorCodeGetTableNameAttributes;
    procedure GeneratorCodeGetIsPrimaryKey;
    procedure GeneratorCodeGetIsFieldReadOnly;
    procedure GeneratorDAOClass;
    procedure GeneratorPascalClass;
    function IFNull(FieldInfo: TAsFieldInfo): string;
    function Limpa(S: string): string;
    function LPad(S: string; Ch: char; Len: integer): string;
    function RPad(S: string; Ch: char; Len: integer): string;



    function TypeDBToTypePascal(S: string): string;
    function TypeDBToTypePascalParams(Field: TAsFieldInfo): string;
    function TypeDBToTypePascalFields(Field: TAsFieldInfo): string;

    function TypeDBFirebirdToPascal(S: string): string;
    function TypeDBFirebirdToPascalParams(S: string): string;
    function TypeDBFirebirdToPascalFields(S: string): string;

    function TypeDBMySqlToPascal(S: string): string;
    function TypeDBMySQLToPascalParams(S: string): string;




    procedure WriteCreateQuery;
    function WithVar(s: string): string;
    function WithOut(s: string): string;
    procedure WriteCreateSQL;
    procedure WriteDestroyQuery;
  public
    { public declarations }
    SchemaText: string;
    TablesInfos: TAsTableInfos;
    InfoTable: TAsTableInfo;
    InfoCrud: TCRUDInfo;
    Projeto: string;

  end;

var
  FrmModel: TFrmModel;

implementation

uses MainFormU;

const
  Ident = '  ';

{$R *.lfm}

{ TFrmModel }

procedure TFrmModel.FormShow(Sender: TObject);
begin
  LbProjeto.Caption := '           Projeto: ' + Projeto;
  LbDirModel.Caption := '   Diretório Model: ' + InfoCrud.DirModel;
  LbDirDAO.Caption := '     Diretório DAO: ' + InfoCrud.DirDAO;
  GeneratorPascalClass;
  GeneratorDAOClass;
  Self.Top := 0;
  Self.Left := 0;
end;

procedure TFrmModel.ToolButton2Click(Sender: TObject);
begin
  SynEditDAO.Lines.SaveToFile(InfoCrud.DirDAO + UnitNameDAO + '.pas');
  SynEditModel.Lines.SaveToFile(InfoCrud.DirModel + UnitNameModel + '.pas');
end;

function TFrmModel.TypeDBToTypePascal(S: string): string;
begin
  case MainForm.FDBInfo.DbType of
    dtFirebirdd: Result := TypeDBFirebirdToPascal(S);
    dtMariaDB, dtMySQL: Result := TypeDBMySqlToPascal(S);
    dtSQLite: Result := '';
    dtMsSql: Result := '';
    dtOracle: Result := '';
    dtPostgreSql: Result := '';
  end;
end;

function TFrmModel.TypeDBFirebirdToPascal(S: string): string;
begin
  if (UpperCase(S) = 'VARCHAR') or (UpperCase(S) = 'BLOB') then
    Result := 'String'
  else if (UpperCase(S) = 'CHAR') then
    Result := 'String'
  else if Pos('NUMERIC', UpperCase(S)) > 0 then
    Result := 'Double'
  else if Pos('TIMESTAMP', UpperCase(S)) > 0 then
    Result := 'TDateTime'
  else if Pos('DATE', UpperCase(S)) > 0 then
    Result := 'TDate'
  else if Pos('TIME', UpperCase(S)) > 0 then
    Result := 'TTime'
  else if Pos('SMALLINT', UpperCase(S)) > 0 then
    Result := 'SmallInt'
  else
    Result := UpperCase(Copy(S, 1, 1)) + LowerCase(Copy(S, 2, Length(S)));
  //Apenas a primeira letra em maiuscula
end;

function TFrmModel.TypeDBMySqlToPascal(S: string): string;
begin
  if (UpperCase(S) = 'VARCHAR') or (UpperCase(S) = 'BLOB') then
    Result := 'String'
  else if (UpperCase(S) = 'CHAR') then
    Result := 'ShortString'
  else if Pos('Float', UpperCase(S)) > 0 then
    Result := 'Double'
  else if Pos('TIMESTAMP', UpperCase(S)) > 0 then
    Result := 'TDateTime'
  else if Pos('DATE', UpperCase(S)) > 0 then
    Result := 'TDate'
  else if Pos('SMALLINT', UpperCase(S)) > 0 then
    Result := 'SmallInt'
  else if Pos('INT', UpperCase(S)) > 0 then
    Result := 'Integer'
  else
    Result := UpperCase(Copy(S, 1, 1)) + LowerCase(Copy(S, 2, Length(S)));
  //Apenas a primeira letra em maiuscula
end;

function TFrmModel.TypeDBToTypePascalParams(Field: TAsFieldInfo): string;
var
  aux: string;

  function TextOnly(S: string): string;
  var
    i: word;
  begin
    Result := '';
    for i := 0 to Length(S) do
      if S[i] in ['a'..'z', 'A'..'Z'] then
        Result := Result + S[i];
  end;

begin
  Result := '';
  aux := LowerCase(TAsFieldInfo(Field).FieldType);
  aux := TextOnly(aux);

  case MainForm.FDBInfo.DbType of
    dtFirebirdd: Result := TypeDBFirebirdToPascalParams(Aux);
    dtMariaDB, dtMySQL: Result := TypeDBMySQLToPascalParams(Aux);
    dtSQLite: Result := '';
    dtMsSql: Result := '';
    dtOracle: Result := '';
    dtPostgreSql: Result := '';
  end;

  if Result = '' then
    Result := 'ERRO_FIELDTYPE_NAO_DEFINIDO';

end;

function TFrmModel.TypeDBToTypePascalFields(Field: TAsFieldInfo): string;
var
  aux: string;

  function TextOnly(S: string): string;
  var
    i: word;
  begin
    Result := '';
    for i := 0 to Length(S) do
      if S[i] in ['a'..'z', 'A'..'Z'] then
        Result := Result + S[i];
  end;

begin
  Result := '';
  aux := LowerCase(TAsFieldInfo(Field).FieldType);
  aux := TextOnly(aux);

  case MainForm.FDBInfo.DbType of
    dtFirebirdd: Result := TypeDBFirebirdToPascalFields(Aux);
    dtMariaDB, dtMySQL: Result := TypeDBMySQLToPascalParams(Aux);
    dtSQLite: Result := '';
    dtMsSql: Result := '';
    dtOracle: Result := '';
    dtPostgreSql: Result := '';
  end;

  if Result = '' then
    Result := 'ERRO_FIELDTYPE_NAO_DEFINIDO';
end;

function TFrmModel.TypeDBFirebirdToPascalParams(S: string): string;
begin
  if S = 'Unknow' then
    Result := 'ERRO_FIELDTYPE_NAO_DEFINIDO'
  else if S = 'integer' then
    Result := 'AsInteger'
  else if S = 'smallint' then
    Result := 'AsInteger'
  else if S = 'word' then
    Result := 'AsInteger'
  else if S = 'string' then
    Result := 'AsString'
  else if S = 'varchar' then
    Result := 'AsString'
  else if S = 'char' then
    Result := 'AsString'
  else if S = 'float' then
    Result := 'AsFloat'
  else if S = 'currency' then
    Result := 'AsFloat'
  else if S = 'date' then
    Result := 'AsDateTime'
  else if S = 'time' then
    Result := 'AsTime'
  else if S = 'dateTime' then
    Result := 'AsDateTime'
  else if S = 'blob' then
    Result := 'AsString'
  else if S = 'memo' then
    Result := 'AsString'
  else if S = 'widestring' then
    Result := 'AsString'
  else if S = 'widememo' then
    Result := 'AsString'
  else if S = 'fixedwidechar' then
    Result := 'AsString'
  else if S = 'boolean' then
    Result := 'AsBoolean'
  else if S = 'timestamp' then
    Result := 'AsDateTime'
  else if S = 'bytes' then
    Result := 'AsInteger'
  else if S = 'bcd' then
    Result := 'AsBCD'
  else if S = 'fixedchar' then
    Result := 'AsString'
  else if S = 'numeric' then
    Result := 'AsFloat'
  else if S = 'double' then
    Result := 'AsFloat';
end;

function TFrmModel.TypeDBFirebirdToPascalFields(S: string): string;
begin
  if S = 'Unknow' then
    Result := 'ERRO_FIELDTYPE_NAO_DEFINIDO'
  else if S = 'integer' then
    Result := 'AsInteger'
  else if S = 'smallint' then
    Result := 'AsInteger'
  else if S = 'word' then
    Result := 'AsInteger'
  else if S = 'string' then
    Result := 'AsString'
  else if S = 'varchar' then
    Result := 'AsString'
  else if S = 'char' then
    Result := 'AsString'
  else if S = 'float' then
    Result := 'AsFloat'
  else if S = 'currency' then
    Result := 'AsFloat'
  else if S = 'date' then
    Result := 'AsDateTime'
  else if S = 'time' then
    Result := 'AsDateTime'
  else if S = 'dateTime' then
    Result := 'AsDateTime'
  else if S = 'blob' then
    Result := 'AsString'
  else if S = 'memo' then
    Result := 'AsString'
  else if S = 'widestring' then
    Result := 'AsString'
  else if S = 'widememo' then
    Result := 'AsString'
  else if S = 'fixedwidechar' then
    Result := 'AsString'
  else if S = 'boolean' then
    Result := 'AsBoolean'
  else if S = 'timestamp' then
    Result := 'AsDateTime'
  else if S = 'bytes' then
    Result := 'AsInteger'
  else if S = 'bcd' then
    Result := 'AsBCD'
  else if S = 'fixedchar' then
    Result := 'AsString'
  else if S = 'numeric' then
    Result := 'AsFloat'
  else if S = 'double' then
    Result := 'AsFloat';
end;

function TFrmModel.TypeDBMySQLToPascalParams(S: string): string;
begin
  if S = 'Unknow' then
    Result := 'ERRO_FIELDTYPE_NAO_DEFINIDO'
  else if S = 'int' then
    Result := 'AsInteger'
  else if S = 'smallint' then
    Result := 'AsInteger'
  else if S = 'word' then
    Result := 'AsInteger'
  else if S = 'string' then
    Result := 'AsString'
  else if S = 'varchar' then
    Result := 'AsString'
  else if S = 'char' then
    Result := 'AsString'
  else if S = 'float' then
    Result := 'AsFloat'
  else if S = 'currency' then
    Result := 'AsFloat'
  else if S = 'date' then
    Result := 'AsDateTime'
  else if S = 'time' then
    Result := 'AsDateTime'
  else if S = 'dateTime' then
    Result := 'AsDateTime'
  else if S = 'blob' then
    Result := 'AsString'
  else if S = 'memo' then
    Result := 'AsString'
  else if S = 'widestring' then
    Result := 'AsString'
  else if S = 'widememo' then
    Result := 'AsString'
  else if S = 'fixedwidechar' then
    Result := 'AsString'
  else if S = 'boolean' then
    Result := 'AsBoolean'
  else if S = 'timestamp' then
    Result := 'AsDateTime'
  else if S = 'bytes' then
    Result := 'AsInteger'
  else if S = 'bcd' then
    Result := 'AsBCD'
  else if S = 'fixedchar' then
    Result := 'AsString'
  else if S = 'numeric' then
    Result := 'AsFloat';
end;

function TFrmModel.LPad(S: string; Ch: char; Len: integer): string;
var
  RestLen: integer;
begin
  Result := S;
  RestLen := Len - Length(s);
  if RestLen < 1 then
    Exit;
  Result := S + StringOfChar(Ch, RestLen);
end;

function TFrmModel.RPad(S: string; Ch: char; Len: integer): string;
var
  RestLen: integer;
begin
  Result := S;
  RestLen := Len - Length(s);
  if RestLen < 1 then
    Exit;
  Result := StringOfChar(Ch, RestLen) + S;
end;

procedure TFrmModel.GeneratorPascalClass;
var
  I, J, K: integer;
  MaxField, MaxType, MaxVar: integer;
  StrFunctionNameInsert, StrFunctionNameUpdate, StrFunctionNameDelete,
  StrFunctionNameGet, StrFunctionNameList, vAuxField, vAuxType, vAuxOldType: string;
  Aux, UnitLazyAnt: string;
  InfoTableAux: TAsTableInfo;
begin
  MaxField := 0;
  MaxType := 0;
  MaxVar := 0;
  {$Region 'Variaveis para geração Lazy'}
  MmLazyCodeFunctions := TStringList.Create;
  {$EndRegion}

  for I := 0 to InfoTable.AllFields.Count - 1 do
  begin
    if MaxField < Length(InfoTable.AllFields[I].FieldName) then
      MaxField := Length(InfoTable.AllFields[I].FieldName);
    if MaxType < Length(TypeDBToTypePascal(InfoTable.AllFields[I].FieldType)) then
      MaxType := Length(TypeDBToTypePascal(InfoTable.AllFields[I].FieldType));
    if MaxVar < (Length(InfoTable.AllFields[I].FieldName) + 1) then
      MaxVar := (Length(InfoTable.AllFields[I].FieldName) + 1);
  end;
  UnitNameModel := 'U' + Copy(InfoTable.Tablename, InfoCrud.CopyTableName,
    Length(InfoTable.TableName));
  ClassNameModel := 'T' + Trim(Copy(InfoTable.Tablename, InfoCrud.CopyTableName,
    Length(InfoTable.TableName)));
  VarModel := Trim(Copy(InfoTable.Tablename, InfoCrud.CopyTableName,
    Length(InfoTable.TableName)));
  UnitNameDAO := 'U' + Copy(InfoTable.Tablename, InfoCrud.CopyTableName,
    Length(InfoTable.TableName)) + 'DAO';
  ClassNameDAO := 'T' + Trim(Copy(InfoTable.Tablename, InfoCrud.CopyTableName,
    Length(InfoTable.TableName))) + 'DAO';
  VarDAO := Trim(Copy(InfoTable.Tablename, InfoCrud.CopyTableName,
    Length(InfoTable.TableName))) + 'DAO';
  SynEditModel.Lines.Clear;
  for I := 0 to InfoCrud.CabecalhoCode.Count - 1 do
    SynEditDAO.Lines.Add(InfoCrud.CabecalhoCode.Strings[I] + #13);
  SynEditModel.Lines.Add('Unit ' + UnitNameModel + ';');
  SynEditModel.Lines.Add('');
  SynEditModel.Lines.Add('interface');
  SynEditModel.Lines.Add('');
  SynEditModel.Lines.Add('uses ');
  SynEditModel.Lines.Add(Ident + 'Rtti, ' + InfoCrud.UsesDefault);
  if InfoCrud.GenerateLazyDependencies then
  begin
    if InfoTable.ImportedKeys.Count > 0 then
    begin
      SynEditModel.Lines[SynEditModel.Lines.Count - 1] :=
        StringReplace(SynEditModel.Lines[SynEditModel.Lines.Count - 1], ';', ', ', [rfReplaceAll]);
      SynEditModel.Lines.Add(Ident + Ident + '//Uses unidades Lazy ');
      for I := 0 to InfoTable.ImportedKeys.Count - 1 do
      begin
        if UnitLazyAnt <> InfoTable.ImportedKeys[I].ForeignTableName then
        begin
          InfoTableAux := TablesInfos.LoadTable(SchemaText,
            InfoTable.ImportedKeys[I].ForeignTableName, False);
          try
            UnitLazyAnt := InfoTableAux.Tablename;
            Aux := Aux + 'U' + Copy(InfoTableAux.Tablename, InfoCrud.CopyTableName,
              Length(InfoTableAux.Tablename)) + ', ';
          finally
            FreeAndNil(InfoTableAux);
          end;
        end;
      end;
      Aux[Length(Aux) - 1] := ';';
      SynEditModel.Lines.Add(Ident + Aux);
    end;
  end;

  SynEditModel.Lines.Add('');
  SynEditModel.Lines.Add('type');
  SynEditModel.Lines.Add(ident + '[TTableName('+QuotedStr(InfoTable.Tablename)+')]');
  SynEditModel.Lines.Add(ident + ClassNameModel + '= class');
  //SynEditModel.Lines.Add('');
  SynEditModel.Lines.Add(ident + 'private');

  SynEditModel.Lines.Add(ident + ident + 'F' +
    Trim(StringReplace(InfoCrud.Connection, 'var', '', [rfReplaceAll])) + ';');
  if Trim(InfoCrud.ReturnException) <> '' then
    SynEditModel.Lines.Add(ident + ident + 'F' +
      Trim(StringReplace(InfoCrud.ReturnException, 'var', '', [rfReplaceAll])) + ';');

  //Cria Variaveis das Propriedades.
  for I := 0 to InfoTable.AllFields.Count - 1 do
  begin
    SynEditModel.Lines.Add(Ident + Ident + 'F' +
      LPad(InfoTable.AllFields[I].FieldName, ' ', MaxVar) + ': ' +
      LPad(TypeDBToTypePascal(InfoTable.AllFields[I].FieldType), ' ', MaxType) + ';');
  end;

  SynEditModel.Lines.Add(Ident + Ident + 'F' + LPad('Original', ' ', MaxVar) +
    ': ' + LPad(ClassNameModel, ' ', MaxType) + ';');
  if InfoCrud.GenerateLazyDependencies then
  begin
    if InfoTable.ImportedKeys.Count > 0 then
    begin
      {$Region 'Cria Variaveis Lazy'}
      SynEditModel.Lines.Add(Ident + Ident + '//Variaveis Lazy ');
      for J := 0 to InfoTable.ImportedKeys.Count - 1 do
      begin
        Application.ProcessMessages;
        if UnitLazyAnt <> InfoTable.ImportedKeys[J].ConstraintName then
        begin
          InfoTableAux := TablesInfos.LoadTable(SchemaText,
            InfoTable.ImportedKeys[J].ForeignTableName, False);
          try
            UnitLazyAnt := InfoTable.ImportedKeys[J].ConstraintName;

            Aux := Copy(UnitLazyAnt, Length(UnitLazyAnt), 1);
            try
              StrToInt(Aux); //Devido a poder ter mais de uma FK com a mesma tabela
            except
              Aux := '';
            end;

            SynEditModel.Lines.Add(Ident + Ident + 'F' +
              LPad(Copy(InfoTableAux.Tablename, InfoCrud.CopyTableName,
              Length(InfoTableAux.Tablename)) + Aux, ' ', MaxField) + ': ' +
              LPad('T' + Copy(InfoTableAux.Tablename, InfoCrud.CopyTableName,
              Length(InfoTableAux.Tablename)), ' ', MaxType) + ';');
            Application.ProcessMessages;
          finally
            FreeAndNil(InfoTableAux);
          end;
        end;
      end;
      {$ENDREGION}

      UnitLazyAnt := '';
      {$Region 'Gera Functions Get Lazy'}
      SynEditModel.Lines.Add(Ident + Ident + '//Function Get Lazy Propertys');
      for J := 0 to InfoTable.ImportedKeys.Count - 1 do
      begin
        Application.ProcessMessages;
        if UnitLazyAnt <> InfoTable.ImportedKeys[J].ConstraintName then
        begin
          InfoTableAux := TablesInfos.LoadTable(SchemaText,
            InfoTable.ImportedKeys[J].ForeignTableName, False);
          try
            UnitLazyAnt := InfoTable.ImportedKeys[J].ConstraintName;

            Aux := Copy(UnitLazyAnt, Length(UnitLazyAnt), 1);
            try
              StrToInt(Aux); //Devido a poder ter mais de uma FK com a mesma tabela
            except
              Aux := '';
            end;
            SynEditModel.Lines.Add(Ident + Ident + 'function ' +
              LPad('Get' + Copy(InfoTableAux.Tablename, InfoCrud.CopyTableName,
              Length(InfoTableAux.Tablename)) + Aux, ' ', MaxVar) + ': ' +
              LPad('T' + Copy(InfoTableAux.Tablename, InfoCrud.CopyTableName,
              Length(InfoTableAux.Tablename)), ' ', MaxType) + ';');
            Application.ProcessMessages;
          finally
            FreeAndNil(InfoTableAux);
          end;
        end;
      end;
      {$EndRegion}
    end;
  end;
  SynEditModel.Lines.Add(ident + 'published');
  //Cria Propriedades.
  SynEditModel.Lines.Add(Ident + Ident + '//Propertys Model');
  for I := 0 to InfoTable.AllFields.Count - 1 do
  begin
    if InfoTable.AllFields[I].IsPrimaryKey then
      SynEditModel.Lines.Add(Ident + Ident + '[TPrimaryKey]');
    SynEditModel.Lines.Add(Ident + Ident + 'Property ' +
      LPad(InfoTable.AllFields[I].FieldName, ' ', MaxField) + ': ' +
      LPad(TypeDBToTypePascal(InfoTable.AllFields[I].FieldType), ' ', MaxType) +
      ' read F' + LPad(InfoTable.AllFields[I].FieldName, ' ', MaxVar) +
      ' write F' + LPad(InfoTable.AllFields[I].FieldName, ' ', MaxVar) + ';');
  end;
  SynEditModel.Lines.Add('');

  UnitLazyAnt := '';
  if InfoCrud.GenerateLazyDependencies then
  begin
    if InfoTable.ImportedKeys.Count > 0 then
    begin
      {$Region 'Geração das Property Lazy'}
      SynEditModel.Lines.Add(Ident + Ident + '//Propertys Lazy ');
      for J := 0 to InfoTable.ImportedKeys.Count - 1 do
      begin
        Application.ProcessMessages;
        if UnitLazyAnt <> InfoTable.ImportedKeys[J].ConstraintName then
        begin
          InfoTableAux := TablesInfos.LoadTable(SchemaText,
            InfoTable.ImportedKeys[J].ForeignTableName, False);
          try
            UnitLazyAnt := InfoTable.ImportedKeys[J].ConstraintName;

            Aux := Copy(UnitLazyAnt, Length(UnitLazyAnt), 1);
            try
              StrToInt(Aux); //Devido a poder ter mais de uma FK com a mesma tabela
            except
              Aux := '';
            end;
            SynEditModel.Lines.Add(Ident + Ident + '[TFieldReadOnly]');
            SynEditModel.Lines.Add(Ident + Ident + 'Property ' +
              LPad(Copy(InfoTableAux.Tablename, InfoCrud.CopyTableName,
              Length(InfoTableAux.Tablename)) + Aux, ' ', MaxField) + ': ' +
              LPad('T' + Copy(InfoTableAux.Tablename, InfoCrud.CopyTableName,
              Length(InfoTableAux.Tablename)), ' ', MaxType) + ' read ' +
              LPad('Get' + Copy(InfoTableAux.Tablename, InfoCrud.CopyTableName,
              Length(InfoTableAux.Tablename)) + Aux, ' ', MaxVar) + ';');
            Application.ProcessMessages;
          finally
            FreeAndNil(InfoTableAux);
          end;
        end;
      end;
      {$ENDREGION}
    end;
  end;

  //Cria Funcoes e Procedures CRUD;
  SynEditModel.Lines.Add(ident + 'public');
  SynEditModel.Lines.Add(Ident + Ident +
    '//Não fazer alteracoes na propriedade Original.');
  SynEditModel.Lines.Add(Ident + Ident +
    '//Pois a mesma é utilizada para montar o UPDATE apenas dos campos alterados.');
  SynEditModel.Lines.Add(Ident + Ident + '[TFieldReadOnly]');
  SynEditModel.Lines.Add(Ident + Ident + 'Property ' +
    LPad('Original', ' ', MaxField) + ': ' + LPad(ClassNameModel, ' ', MaxType) +
    ' read F' + LPad('Original', ' ', MaxVar) + ' write F' +
    LPad('Original', ' ', MaxVar) + ';');
  SynEditModel.Lines.Add(Ident + Ident + '//*********************************');


  SynEditModel.Lines.Add(Ident + Ident + '//Functions and Procedures Model CRUD');

  if InfoCrud.ProcInsert.Enable then
  begin
    StrFunctionNameInsert := InfoCrud.ProcInsert.ProcName + '(';
    if StrFunctionNameInsert <> InfoCrud.ProcInsert.ProcName + '(' then
      StrFunctionNameInsert := StrFunctionNameInsert + ';' + InfoCrud.Connection
    else
      StrFunctionNameInsert := StrFunctionNameInsert + InfoCrud.Connection;

    if StrFunctionNameInsert <> InfoCrud.ProcInsert.ProcName + '(' then
      StrFunctionNameInsert :=
        StrFunctionNameInsert + '; ' + WithVar(VarModel) + ': ' + ClassNameModel
    else
      StrFunctionNameInsert :=
        StrFunctionNameInsert + WithVar(VarModel) + ': ' + ClassNameModel;

    if (StrFunctionNameInsert <> InfoCrud.ProcInsert.ProcName + '(') and
      (InfoCrud.HasReturnException) then
      StrFunctionNameInsert :=
        StrFunctionNameInsert + ';' + WithVar(InfoCrud.ReturnException)
    else
      StrFunctionNameInsert :=
        StrFunctionNameInsert + WithVar(InfoCrud.ReturnException);

    SynEditModel.Lines.Add(Ident + Ident + 'function ' + StrFunctionNameInsert +
      '):Boolean;');
    StrFunctionNameInsert :=
      'function ' + ClassNameModel + '.' + StrFunctionNameInsert + '):Boolean;';

  end;

  if InfoCrud.ProcUpdate.Enable then
  begin
    StrFunctionNameUpdate := InfoCrud.ProcUpdate.ProcName + '(';

    if StrFunctionNameUpdate <> InfoCrud.ProcUpdate.ProcName + '(' then
      StrFunctionNameUpdate := StrFunctionNameUpdate + ';' + InfoCrud.Connection
    else
      StrFunctionNameUpdate := StrFunctionNameUpdate + InfoCrud.Connection;

    if StrFunctionNameUpdate <> InfoCrud.ProcUpdate.ProcName + '(' then
      StrFunctionNameUpdate :=
        StrFunctionNameUpdate + '; ' + WithVar(VarModel) + ': ' + ClassNameModel
    else
      StrFunctionNameUpdate :=
        StrFunctionNameUpdate + WithVar(VarModel) + ': ' + ClassNameModel;

    if (StrFunctionNameUpdate <> InfoCrud.ProcUpdate.ProcName + '(') and
      (InfoCrud.HasReturnException) then
      StrFunctionNameUpdate :=
        StrFunctionNameUpdate + ';' + WithVar(InfoCrud.ReturnException)
    else
      StrFunctionNameUpdate := StrFunctionNameUpdate + WithVar(InfoCrud.ReturnException);

    SynEditModel.Lines.Add(Ident + Ident + 'function ' + StrFunctionNameUpdate +
      '):Boolean;');
    StrFunctionNameUpdate := 'function ' + ClassNameModel +
      '.' + StrFunctionNameUpdate + '):Boolean;';

  end;

  if InfoCrud.ProcDelete.Enable then
  begin
    StrFunctionNameDelete := InfoCrud.ProcDelete.ProcName + '(';
    if StrFunctionNameDelete <> InfoCrud.ProcDelete.ProcName + '(' then
      StrFunctionNameDelete := StrFunctionNameDelete + ';' + InfoCrud.Connection
    else
      StrFunctionNameDelete := StrFunctionNameDelete + InfoCrud.Connection;

    if StrFunctionNameDelete <> InfoCrud.ProcDelete.ProcName + '(' then
      StrFunctionNameDelete :=
        StrFunctionNameDelete + '; ' + WithVar(VarModel) + ': ' + ClassNameModel
    else
      StrFunctionNameDelete :=
        StrFunctionNameDelete + WithVar(VarModel) + ': ' + ClassNameModel;

    if (StrFunctionNameDelete <> InfoCrud.ProcDelete.ProcName + '(') and
      (InfoCrud.HasReturnException) then
      StrFunctionNameDelete :=
        StrFunctionNameDelete + ';' + WithVar(InfoCrud.ReturnException)
    else
      StrFunctionNameDelete := StrFunctionNameDelete + WithVar(InfoCrud.ReturnException);

    SynEditModel.Lines.Add(Ident + Ident + 'function ' + StrFunctionNameDelete +
      '):Boolean;');
    StrFunctionNameDelete := 'function ' + ClassNameModel + '.' +
      StrFunctionNameDelete + '):Boolean;';

  end;

  if InfoCrud.ProcGetRecord.Enable then
  begin
    StrFunctionNameGet := InfoCrud.ProcGetRecord.ProcName + '(';

    if StrFunctionNameGet <> InfoCrud.ProcGetRecord.ProcName + '(' then
      StrFunctionNameGet := StrFunctionNameGet + ';' + InfoCrud.Connection
    else
      StrFunctionNameGet := StrFunctionNameGet + InfoCrud.Connection;

    if StrFunctionNameGet <> InfoCrud.ProcGetRecord.ProcName + '(' then
      StrFunctionNameGet := StrFunctionNameGet + '; ' + WithVar(VarModel) +
        ': ' + ClassNameModel
    else
      StrFunctionNameGet := StrFunctionNameGet + WithVar(VarModel) +
        ': ' + ClassNameModel;

    if (StrFunctionNameGet <> InfoCrud.ProcGetRecord.ProcName + '(') and
      (InfoCrud.HasReturnException) then
      StrFunctionNameGet := StrFunctionNameGet + ';' + WithVar(InfoCrud.ReturnException)
    else
      StrFunctionNameGet := StrFunctionNameGet + WithVar(InfoCrud.ReturnException);

    SynEditModel.Lines.Add(Ident + Ident + 'function ' +
      StrFunctionNameGet + '):Boolean;');
    StrFunctionNameGet := 'function ' + ClassNameModel + '.' + StrFunctionNameGet +
      '):Boolean;';

  end;

  if InfoCrud.ProcListRecords.Enable then
  begin
    StrFunctionNameList := InfoCrud.ProcListRecords.ProcName + '(';
    if StrFunctionNameList <> InfoCrud.ProcListRecords.ProcName + '(' then
      StrFunctionNameList := StrFunctionNameList + ';' + InfoCrud.Connection
    else
      StrFunctionNameList := StrFunctionNameList + InfoCrud.Connection;

    if StrFunctionNameList <> InfoCrud.ProcListRecords.ProcName + '(' then
      StrFunctionNameList := StrFunctionNameList + '; out ObjLst: TObjectList; ' +
        'WhereSQL: String'
    else
      StrFunctionNameList := StrFunctionNameList + ' out ObjLst: TObjectList; ' +
        'WhereSQL: String';

    if (StrFunctionNameList <> InfoCrud.ProcListRecords.ProcName + '(') and
      (InfoCrud.HasReturnException) then
      StrFunctionNameList := StrFunctionNameList + ';' +
        WithVar(InfoCrud.ReturnException)
    else
      StrFunctionNameList := StrFunctionNameList + WithVar(InfoCrud.ReturnException);

    SynEditModel.Lines.Add(Ident + Ident + 'class function ' +
      StrFunctionNameList + '):Boolean;');
    StrFunctionNameList := 'class function ' + ClassNameModel +
      '.' + StrFunctionNameList + '):Boolean;';

  end;

  SynEditModel.Lines.Add('');
  SynEditModel.Lines.Add(Ident + Ident + 'procedure Assign(const Source: ' +
    ClassNameModel + ');');
  SynEditModel.Lines.Add(Ident + Ident + 'function isModify:boolean;');

  //Metodos Create...
  SynEditModel.Lines.Add('');
  SynEditModel.Lines.Add(Ident + Ident + '//Metodos Construtores e Destrutores');
  SynEditModel.Lines.Add(Ident + Ident + 'Constructor Create;' +
    ifthen(InfoTable.PrimaryKeys.Count > 0, ' Overload; ', ''));

  vAuxField := '';
  vAuxOldType := '';
  for I := InfoTable.PrimaryKeys.Count - 1 downto 0 do
    //Metodo Create passando todas as chaves da tabela...
  begin
    vAuxType := TypeDBToTypePascal(InfoTable.PrimaryKeys.Items[i].FieldType);
    vAuxField := 'A' + InfoTable.PrimaryKeys.Items[I].FieldName +
      IfThen(vAuxType = vAuxOldType, ', ', ': ' + vAuxType + '; ') + vAuxField;
    vAuxOldType := vAuxType;
  end;
  if Trim(InfoCrud.ReturnException) <> '' then
    SynEditModel.Lines.Add(Ident + Ident + 'Constructor Create(' + InfoCrud.Connection +
      '; ' + WithVar(InfoCrud.ReturnException) + '; ' + Copy(vAuxField, 1,
      length(vAuxField) - 2) + '); Overload;')
  else
    SynEditModel.Lines.Add(Ident + Ident + 'Constructor Create(' + InfoCrud.Connection +
      '; ' + Copy(vAuxField, 1, length(vAuxField) - 2) + '); Overload;');

  SynEditModel.Lines.Add(Ident + Ident + 'Constructor Create(const Source: ' +
    ClassNameModel + '); Overload;');

  if Trim(InfoCrud.ReturnException) <> '' then
    SynEditModel.Lines.Add(Ident + Ident + 'Constructor Create(' + InfoCrud.Connection +
      '; ' + WithVar(InfoCrud.ReturnException) + '); Overload;')
  else
    SynEditModel.Lines.Add(Ident + Ident + 'Constructor Create(' +
      InfoCrud.Connection + '); Overload;');

  SynEditModel.Lines.Add(Ident + Ident + 'Destructor Destroy; override; ');




  SynEditModel.Lines.Add(ident + 'end; ');
  SynEditModel.Lines.Add(ident + '');
  SynEditModel.Lines.Add('implementation');
  SynEditModel.Lines.Add(ident + '');
  SynEditModel.Lines.Add('uses ');
  SynEditModel.Lines.Add(Ident + UnitNameDAO + ';');
  SynEditModel.Lines.Add(ident + '');
  //SynEditModel.Lines.Add('Var ');
  //SynEditModel.Lines.Add(ident + VarDAO + ': ' + ClassNameDAO + ';');

  // ***INICIO*** Implementacao dos metodos Construtores e Destrutores
  SynEditModel.Lines.Add(ident + '');
  SynEditModel.Lines.Add('Constructor ' + ClassNameModel + '.' + 'Create;');
  SynEditModel.Lines.Add('begin');
  SynEditModel.Lines.Add(ident + 'raise Exception.Create(''Favor utilizar metodo Create passando a classe de conexao como parametro.'');');
  SynEditModel.Lines.Add('end;');

  vAuxField := '';
  vAuxOldType := '';
  for I := InfoTable.PrimaryKeys.Count - 1 downto 0 do
  begin
    vAuxType := TypeDBToTypePascal(InfoTable.PrimaryKeys.Items[i].FieldType);
    vAuxField := 'A' + InfoTable.PrimaryKeys.Items[I].FieldName +
      IfThen(vAuxType = vAuxOldType, ', ', ': ' + vAuxType + '; ') + vAuxField;
    vAuxOldType := vAuxType;
  end;

  SynEditModel.Lines.Add(ident + '');
  if Trim(InfoCrud.ReturnException) <> '' then
    SynEditModel.Lines.Add('Constructor ' + ClassNameModel + '.' +
      'Create(' + InfoCrud.Connection + '; ' + WithVar(InfoCrud.ReturnException) +
      '; ' + Copy(vAuxField, 1, length(vAuxField) - 2) + '); ')
  else
    SynEditModel.Lines.Add('Constructor ' + ClassNameModel + '.' +
      'Create(' + InfoCrud.Connection + '; ' + Copy(vAuxField, 1, length(vAuxField) - 2) + '); ');
  SynEditModel.Lines.Add('begin');
  SynEditModel.Lines.Add(ident + 'Inherited Create;');


  MaxVar := 0;
  for I := 0 to InfoTable.PrimaryKeys.Count - 1 do
    if MaxVar < (Length('Self.' + InfoTable.PrimaryKeys.Items[I].FieldName) + 1) then
      MaxVar := (Length('Self.' + InfoTable.PrimaryKeys.Items[I].FieldName) + 1);


  for I := 0 to InfoTable.PrimaryKeys.Count - 1 do
    SynEditModel.Lines.Add(ident +
      LPad('Self.' + InfoTable.PrimaryKeys.Items[I].FieldName, ' ', MaxVar) +
      ' := ' + 'A' + InfoTable.PrimaryKeys.Items[I].FieldName + ';');
  SynEditModel.Lines.Add(ident + 'Self' + '.' + 'F' +
    Trim(IfThen(Pos('var',
    InfoCrud.Connection) > 0,
    StringReplace(
    Copy(InfoCrud.Connection, Pos('var', InfoCrud.Connection) + 3,
    Pos(':',
    InfoCrud.Connection) - 2), ':', '', [rfReplaceAll]),
    StringReplace(
    Copy(InfoCrud.Connection, 0, Pos(':', InfoCrud.Connection) - 1), 'var',
    '', [rfReplaceAll]))
    ) +
    ' := ' +
    StringReplace(
    Copy(InfoCrud.Connection, 0, Pos(':', InfoCrud.Connection) - 1), 'var',
    '', [rfReplaceAll]) + ';');
  if Trim(InfoCrud.ReturnException) <> '' then
  begin
    SynEditModel.Lines.Add(ident + 'Self' + '.' + 'F' +
      Trim(IfThen(Pos('var',
      InfoCrud.ReturnException) > 0,
      StringReplace(
      Copy(InfoCrud.Connection, Pos('var', InfoCrud.ReturnException) + 3,
      Pos(':',
      InfoCrud.ReturnException) - 1), ':', '', [rfReplaceAll]),
      StringReplace(
      Copy(InfoCrud.ReturnException, 0, Pos(':', InfoCrud.ReturnException) - 1),
      'var', '', [rfReplaceAll]))
      ) + ' := ' +
      StringReplace(
      Copy(InfoCrud.ReturnException, 0, Pos(':', InfoCrud.ReturnException) - 1),
      'var', '', [rfReplaceAll]) + ';');
  end;
  SynEditModel.Lines.Add('end;');

  {$Region 'Instancia o objeto fazendo um assign '}
  SynEditModel.Lines.Add(ident + '');
  SynEditModel.Lines.Add('Constructor ' + ClassNameModel + '.' +
    'Create(const Source: ' + ClassNameModel + ');');
  SynEditModel.Lines.Add('begin');
  SynEditModel.Lines.Add(ident + 'Inherited Create;');
  SynEditModel.Lines.Add(ident + 'Self' + '.' + 'Assign(Source);');
  SynEditModel.Lines.Add('end;');
  {$endRegion}

  SynEditModel.Lines.Add(ident + '');

  if Trim(InfoCrud.ReturnException) <> '' then
    SynEditModel.Lines.Add('Constructor ' + ClassNameModel + '.' +
      'Create(' + InfoCrud.Connection + '; ' + WithVar(InfoCrud.ReturnException) + '); ')
  else
    SynEditModel.Lines.Add('Constructor ' + ClassNameModel + '.' +
      'Create(' + InfoCrud.Connection + '); ');
  SynEditModel.Lines.Add('begin');
  SynEditModel.Lines.Add(ident + 'Inherited Create;');
  SynEditModel.Lines.Add(ident + 'Self' + '.' + 'F' + Trim(IfThen(Pos('var', InfoCrud.Connection) > 0, StringReplace(
    Copy(InfoCrud.Connection, Pos('var', InfoCrud.Connection) + 3, Pos(':', InfoCrud.Connection) - 2), ':', '', [rfReplaceAll]),
    StringReplace(Copy(InfoCrud.Connection, 0, Pos(':', InfoCrud.Connection) - 1), 'var', '', [rfReplaceAll]))) +' := ' +
    StringReplace(Copy(InfoCrud.Connection, 0, Pos(':', InfoCrud.Connection) - 1), 'var', '', [rfReplaceAll]) + ';');
  if (InfoCrud.SelectDefault1.Field <> '') or
    (InfoCrud.SelectDefault2.Field <> '') or
    (InfoCrud.SelectDefault3.Field <> '') then
  begin
    if (InfoCrud.SelectDefault1.Field <> '') then
      SynEditModel.Lines.Add(ident + 'Self' + '.' + InfoCrud.SelectDefault1.Field + ' := ' + InfoCrud.SelectDefault1.Value +';');
    if (InfoCrud.SelectDefault2.Field <> '') then
      SynEditModel.Lines.Add(ident + 'Self' + '.' + InfoCrud.SelectDefault2.Field + ' := ' + InfoCrud.SelectDefault2.Value +';');
    if (InfoCrud.SelectDefault3.Field <> '') then
        SynEditModel.Lines.Add(ident + 'Self' + '.' + InfoCrud.SelectDefault3.Field + ' := ' + InfoCrud.SelectDefault3.Value +';');
  end;

  if Trim(InfoCrud.ReturnException) <> '' then
  begin
    SynEditModel.Lines.Add(ident + 'Self' + '.' + 'F' +
      Trim(IfThen(Pos('var',
      InfoCrud.ReturnException) > 0,
      StringReplace(
      Copy(InfoCrud.Connection, Pos('var', InfoCrud.ReturnException) + 3,
      Pos(':',
      InfoCrud.ReturnException) - 1), ':', '', [rfReplaceAll]),
      StringReplace(
      Copy(InfoCrud.ReturnException, 0, Pos(':', InfoCrud.ReturnException) - 1),
      'var', '', [rfReplaceAll]))
      ) + ' := ' +
      StringReplace(
      Copy(InfoCrud.ReturnException, 0, Pos(':', InfoCrud.ReturnException) - 1),
      'var', '', [rfReplaceAll]) + ';');
  end;
  SynEditModel.Lines.Add('end;');

  SynEditModel.Lines.Add(ident + '');
  SynEditModel.Lines.Add('Destructor ' + ClassNameModel + '.' + 'Destroy;');
  SynEditModel.Lines.Add('begin');
  if InfoCrud.GenerateLazyDependencies then
  begin
    UnitLazyAnt := '';
    {$REGION 'Gera Destroy Variaveis Lazy'}
    for J := 0 to InfoTable.ImportedKeys.Count - 1 do
    begin
      Application.ProcessMessages;
      if UnitLazyAnt <> InfoTable.ImportedKeys[J].ConstraintName then
      begin
        InfoTableAux := TablesInfos.LoadTable(SchemaText,
          InfoTable.ImportedKeys[J].ForeignTableName, False);
        try
          UnitLazyAnt := InfoTable.ImportedKeys[J].ConstraintName;
          Aux := Copy(UnitLazyAnt, Length(UnitLazyAnt), 1);
          try
            StrToInt(Aux); //Devido a poder ter mais de uma FK com a mesma tabela
          except
            Aux := '';
          end;
          SynEditModel.Lines.Add(Ident + 'if Assigned(F' + Copy(
            InfoTableAux.Tablename, InfoCrud.CopyTableName, Length(InfoTableAux.Tablename)) +
            Aux + ') then ');
          SynEditModel.Lines.Add(Ident + Ident +
            'FreeAndNil(F' + Copy(InfoTableAux.Tablename, InfoCrud.CopyTableName,
            Length(InfoTableAux.Tablename)) + Aux + ');');
        finally
          FreeAndNil(InfoTableAux);
        end;
      end;
    end;
    {$EndRegion}
  end;
  SynEditModel.Lines.Add(ident + 'if Assigned(FOriginal) then');
  SynEditModel.Lines.Add(ident + ident + 'FreeAndNil(FOriginal);');
  SynEditModel.Lines.Add(ident + 'Inherited;');
  SynEditModel.Lines.Add('end;');
  // ***FIM*** Implementacao dos metodos Construtores e Destrutores

  //Gerando Functions Code
  if InfoCrud.ProcInsert.Enable then
  begin
    SynEditModel.Lines.Add(ident + '');
    SynEditModel.Lines.Add(StrFunctionNameInsert);
    SynEditModel.Lines.Add('begin');
    StrFunctionNameInsert := Ident + 'Result := ' + ClassNameDAO +
      '.' + InfoCrud.ProcInsert.ProcName + '(';
    if (StrFunctionNameInsert <> Ident + 'Result := ' + ClassNameDAO +
      '.' + InfoCrud.ProcInsert.ProcName + '(') and
      (Trim(Copy(InfoCrud.Connection, 1, Pos(':', InfoCrud.Connection) - 1)) <> '') then
      StrFunctionNameInsert := StrFunctionNameInsert +
        ',' + Limpa(Copy(InfoCrud.Connection, 1, Pos(':', InfoCrud.Connection) - 1))
    else
      StrFunctionNameInsert := StrFunctionNameInsert +
        Limpa(Copy(InfoCrud.Connection, 1, Pos(':', InfoCrud.Connection) - 1));

    if (StrFunctionNameInsert <> Ident + 'Result := ' + ClassNameDAO +
      '.' + InfoCrud.ProcUpdate.ProcName + '(') then
      StrFunctionNameInsert := StrFunctionNameInsert + ', ' + VarModel
    else
      StrFunctionNameInsert := StrFunctionNameInsert + VarModel;

    if (StrFunctionNameInsert <> Ident + 'Result := ' + ClassNameDAO +
      '.' + InfoCrud.ProcInsert.ProcName + '(') and
      (Trim(Copy(InfoCrud.ReturnException, 1, Pos(':', InfoCrud.ReturnException) - 1)) <>
      '') then
      StrFunctionNameInsert := StrFunctionNameInsert + ', ' +
        Copy(InfoCrud.ReturnException, 1, Pos(':', InfoCrud.ReturnException) - 1)
    else
      StrFunctionNameInsert := StrFunctionNameInsert +
        Copy(InfoCrud.ReturnException, 1, Pos(':', InfoCrud.ReturnException) - 1);

    StrFunctionNameInsert := StrFunctionNameInsert + ');';
    SynEditModel.Lines.Add(StrFunctionNameInsert);
    SynEditModel.Lines.Add('end;');
  end;
  if InfoCrud.ProcUpdate.Enable then
  begin
    SynEditModel.Lines.Add(ident + '');
    SynEditModel.Lines.Add(StrFunctionNameUpdate);
    SynEditModel.Lines.Add('begin');

    StrFunctionNameUpdate := Ident + 'Result := ' + ClassNameDAO +
      '.' + InfoCrud.ProcUpdate.ProcName + '(';
    if (StrFunctionNameUpdate <> Ident + 'Result := ' + ClassNameDAO +
      '.' + InfoCrud.ProcUpdate.ProcName + '(') and
      (Trim(Copy(InfoCrud.Connection, 1, Pos(':', InfoCrud.Connection) - 1)) <> '') then
      StrFunctionNameUpdate := StrFunctionNameUpdate +
        ',' + Limpa(Copy(InfoCrud.Connection, 1, Pos(':', InfoCrud.Connection) - 1))
    else
      StrFunctionNameUpdate := StrFunctionNameUpdate +
        Limpa(Copy(InfoCrud.Connection, 1, Pos(':', InfoCrud.Connection) - 1));

    if (StrFunctionNameUpdate <> Ident + 'Result := ' + ClassNameDAO +
      '.' + InfoCrud.ProcUpdate.ProcName + '(') then
      StrFunctionNameUpdate := StrFunctionNameUpdate + ', ' + VarModel
    else
      StrFunctionNameUpdate := StrFunctionNameUpdate + VarModel;

    if (StrFunctionNameUpdate <> Ident + 'Result := ' + ClassNameDAO +
      '.' + InfoCrud.ProcUpdate.ProcName + '(') and
      (Trim(Copy(InfoCrud.ReturnException, 1, Pos(':', InfoCrud.ReturnException) -
      1)) <> '') then
      StrFunctionNameUpdate := StrFunctionNameUpdate + ', ' +
        Copy(InfoCrud.ReturnException, 1, Pos(':', InfoCrud.ReturnException) - 1)
    else
      StrFunctionNameUpdate := StrFunctionNameUpdate +
        Copy(InfoCrud.ReturnException, 1, Pos(':', InfoCrud.ReturnException) - 1);

    StrFunctionNameUpdate := StrFunctionNameUpdate + ');';
    SynEditModel.Lines.Add(StrFunctionNameUpdate);

    SynEditModel.Lines.Add('end;');
  end;
  if InfoCrud.ProcDelete.Enable then
  begin
    SynEditModel.Lines.Add(ident + '');
    SynEditModel.Lines.Add(StrFunctionNameDelete);
    SynEditModel.Lines.Add('begin');

    StrFunctionNameDelete := Ident + 'Result := ' + ClassNameDAO +
      '.' + InfoCrud.ProcDelete.ProcName + '(';

    if (StrFunctionNameDelete <> (Ident + 'Result := ' + ClassNameDAO +
      '.' + InfoCrud.ProcDelete.ProcName + '(')) and
      (Trim(Copy(InfoCrud.Connection, 1, Pos(':', InfoCrud.Connection) - 1)) <> '') then
      StrFunctionNameDelete :=
        StrFunctionNameDelete + ', ' +
        Limpa(Copy(InfoCrud.Connection, 1, Pos(':', InfoCrud.Connection) - 1))
    else
      StrFunctionNameDelete :=
        StrFunctionNameDelete + Limpa(Copy(InfoCrud.Connection,
        1, Pos(':', InfoCrud.Connection) - 1));

    if (StrFunctionNameDelete <> Trim(Ident + 'Result := ' + ClassNameDAO +
      '.' + InfoCrud.ProcDelete.ProcName + '(')) then
      StrFunctionNameDelete := StrFunctionNameDelete + ', ' + VarModel
    else
      StrFunctionNameDelete := StrFunctionNameDelete + VarModel;

    if (StrFunctionNameDelete <> Trim(Ident + 'Result := ' + ClassNameDAO +
      '.' + InfoCrud.ProcDelete.ProcName + '(')) and
      (Trim(Copy(InfoCrud.ReturnException, 1, Pos(':', InfoCrud.ReturnException) - 1)) <>
      '') then
      StrFunctionNameDelete :=
        StrFunctionNameDelete + ', ' + Copy(InfoCrud.ReturnException, 1,
        Pos(':', InfoCrud.ReturnException) - 1)
    else
      StrFunctionNameDelete :=
        StrFunctionNameDelete + Copy(InfoCrud.ReturnException, 1,
        Pos(':', InfoCrud.ReturnException) - 1);

    StrFunctionNameDelete := StrFunctionNameDelete + ');';
    SynEditModel.Lines.Add(StrFunctionNameDelete);
    SynEditModel.Lines.Add('end;');
  end;

  if InfoCrud.ProcGetRecord.Enable then
  begin
    SynEditModel.Lines.Add(ident + '');
    SynEditModel.Lines.Add(StrFunctionNameGet);
    SynEditModel.Lines.Add('begin');

    StrFunctionNameGet := Ident + 'Result := ' + ClassNameDAO + '.' +
      InfoCrud.ProcGetRecord.ProcName + '(';

    if (StrFunctionNameGet <> Ident + 'Result := ' + ClassNameDAO +
      '.' + InfoCrud.ProcGetRecord.ProcName + '(') and
      (Trim(Copy(InfoCrud.Connection, 1, Pos(':', InfoCrud.Connection) - 1)) <> '') then
      StrFunctionNameGet := StrFunctionNameGet + ', ' +
        Limpa(Copy(InfoCrud.Connection, 1, Pos(':', InfoCrud.Connection) - 1))
    else
      StrFunctionNameGet := StrFunctionNameGet +
        Limpa(Copy(InfoCrud.Connection, 1, Pos(':', InfoCrud.Connection) - 1));

    if (StrFunctionNameGet <> Ident + 'Result := ' + ClassNameDAO +
      '.' + InfoCrud.ProcGetRecord.ProcName + '(') then
      StrFunctionNameGet := StrFunctionNameGet + ', ' + VarModel
    else
      StrFunctionNameGet := StrFunctionNameGet + VarModel;


    if (StrFunctionNameGet <> (Ident + 'Result := ' + ClassNameDAO +
      '.' + InfoCrud.ProcGetRecord.ProcName + '(')) and
      (Trim(Copy(InfoCrud.ReturnException, 1, Pos(':', InfoCrud.ReturnException) -
      1)) <> '') then
      StrFunctionNameGet := StrFunctionNameGet + ', ' +
        Copy(InfoCrud.ReturnException, 1, Pos(':', InfoCrud.ReturnException) - 1)
    else
      StrFunctionNameGet := StrFunctionNameGet +
        Copy(InfoCrud.ReturnException, 1, Pos(':', InfoCrud.ReturnException) - 1);

    StrFunctionNameGet := StrFunctionNameGet + ');';
    SynEditModel.Lines.Add(StrFunctionNameGet);

    SynEditModel.Lines.Add('end;');
  end;
  if InfoCrud.ProcListRecords.Enable then
  begin
    SynEditModel.Lines.Add(ident + '');
    SynEditModel.Lines.Add(StrFunctionNameList);
    SynEditModel.Lines.Add('begin');

    StrFunctionNameList := Ident + 'Result := ' + ClassNameDAO + '.' +
      InfoCrud.ProcListRecords.ProcName + '(';

    if (StrFunctionNameList <> Ident + 'Result := ' + ClassNameDAO +
      '.' + InfoCrud.ProcListRecords.ProcName + '(') and
      (Trim(Copy(InfoCrud.Connection, 1, Pos(':', InfoCrud.Connection) - 1)) <> '') then
      StrFunctionNameList := StrFunctionNameList + ', ' +
        Limpa(Copy(InfoCrud.Connection, 1, Pos(':', InfoCrud.Connection) - 1))
    else
      StrFunctionNameList := StrFunctionNameList +
        Limpa(Copy(InfoCrud.Connection, 1, Pos(':', InfoCrud.Connection) - 1));

    if (StrFunctionNameList <> Ident + 'Result := ' + ClassNameDAO +
      '.' + InfoCrud.ProcListRecords.ProcName + '(') then
      StrFunctionNameList := StrFunctionNameList + ', ObjLst, WhereSQL'
    else
      StrFunctionNameList := StrFunctionNameList + 'ObjLst, WhereSQL';

    if (StrFunctionNameList <> Trim(Ident + 'Result := ' + ClassNameDAO +
      '.' + InfoCrud.ProcListRecords.ProcName + '(')) and
      (Trim(Copy(InfoCrud.ReturnException, 1, Pos(':', InfoCrud.ReturnException) -
      1)) <> '') then
      StrFunctionNameList := StrFunctionNameList + ', ' +
        Copy(InfoCrud.ReturnException, 1, Pos(':', InfoCrud.ReturnException) - 1)
    else
      StrFunctionNameList := StrFunctionNameList +
        Copy(InfoCrud.ReturnException, 1, Pos(':', InfoCrud.ReturnException) - 1);

    StrFunctionNameList := StrFunctionNameList + ');';
    SynEditModel.Lines.Add(StrFunctionNameList);

    SynEditModel.Lines.Add('end;');
  end;

  SynEditModel.Lines.Add(ident + '');

  {$region 'Metodo Assign'}
  ;
  SynEditModel.Lines.Add('procedure ' + ClassNameModel + '.Assign(const Source: ' +
    ClassNameModel + ');  ');
  SynEditModel.Lines.Add(
    'var                                                                     ');
  SynEditModel.Lines.Add(
    '  PropList: TPropList;                                                  ');
  SynEditModel.Lines.Add(
    '  PropCount, i: integer;                                                ');
  SynEditModel.Lines.Add(
    '  Value: variant;                                                       ');
  SynEditModel.Lines.Add(
    'begin                                                                   ');
  SynEditModel.Lines.Add(
    '  PropCount := GetPropList(Source.ClassInfo, tkAny, @PropList);         ');
  SynEditModel.Lines.Add(
    '  for i := 0 to PropCount - 1 do                                        ');
  SynEditModel.Lines.Add(
    '  begin                                                                 ');
  SynEditModel.Lines.Add(
    '    if (PropList[i]^.SetProc <> nil) then                               ');
  //Verifica se possui acesso a escrita na propriedade
  SynEditModel.Lines.Add(
    '    begin                                                               ');
  SynEditModel.Lines.Add(
    '      Value := GetPropValue(Source, PropList[i]^.Name);                 ');
  SynEditModel.Lines.Add(
    '      SetPropValue(Self, PropList[i]^.Name, Value);                     ');
  SynEditModel.Lines.Add(
    '    end;                                                                ');
  SynEditModel.Lines.Add(
    '  end;                                                                  ');
  SynEditModel.Lines.Add(
    '                                                                        ');
  SynEditModel.Lines.Add(
    'end;                                                                    ');
  SynEditModel.Lines.Add(
    '                                                                        ');
  {$endRegion}

  {$region 'Metodo IsModify'}
  ;
  SynEditModel.Lines.Add('function ' + ClassNameModel + '.IsModify:boolean;');
  SynEditModel.Lines.Add('var                                                                     ');
  SynEditModel.Lines.Add('  {$Region ''Variaveis RTTI NewValue''}                                 ');
  SynEditModel.Lines.Add('  CtxRtti     : TRttiContext;                                           ');
  SynEditModel.Lines.Add('  TpRtti      : TRttiType;                                              ');
  SynEditModel.Lines.Add('  PropRtti    : TRttiProperty;                                          ');
  SynEditModel.Lines.Add('  PropNameRtti: String;                                                 ');
  SynEditModel.Lines.Add('  {$ENDREGION}                                                          ');
  SynEditModel.Lines.Add('  function GetOldValue: String;                                            ');
  SynEditModel.Lines.Add('  var                                                                      ');
  SynEditModel.Lines.Add('    CtxRttiOld: TRttiContext;                                              ');
  SynEditModel.Lines.Add('    TpRttiOld: TRttiType;                                                  ');
  SynEditModel.Lines.Add('    PropRttiOld: TRttiProperty;                                            ');
  SynEditModel.Lines.Add('  begin                                                                    ');
  SynEditModel.Lines.Add('    Result := '''';                                                          ');
  SynEditModel.Lines.Add('    CtxRttiOld  := TRttiContext.Create;                                    ');
  SynEditModel.Lines.Add('    TpRttiOld   := CtxRttiOld.GetType(Self.Original.ClassType);            ');
  SynEditModel.Lines.Add('    PropRttiOld := TpRttiOld.GetProperty(PropNameRtti);                    ');
  SynEditModel.Lines.Add('    Result      := VarToStr(PropRttiOld.GetValue(Self.Original).AsVariant);');
  SynEditModel.Lines.Add('  end;                                                                  ');
  SynEditModel.Lines.Add('begin                                                                   ');
  SynEditModel.Lines.Add('  CtxRtti  := TRttiContext.Create;                                      ');
  SynEditModel.Lines.Add('  TpRtti   := CtxRtti.GetType(Self.ClassType);                          ');
  SynEditModel.Lines.Add('  Result   := False;                                                    ');
  SynEditModel.Lines.Add('  for PropRtti in TpRtti.GetProperties do                               ');
  SynEditModel.Lines.Add('  begin                                                                 ');
  SynEditModel.Lines.Add('    PropNameRtti := PropRtti.Name;                                      ');
  SynEditModel.Lines.Add('    if PropRtti.PropertyType.TypeKind in [tkInteger, tkChar,            ');
  SynEditModel.Lines.Add('         tkFloat,   tkString, tkUString]  then                          ');
  SynEditModel.Lines.Add('    begin                                                               ');
  SynEditModel.Lines.Add('      Result := VarToStr(PropRtti.GetValue(Self).AsVariant) <> GetOldValue;  ');
  SynEditModel.Lines.Add('      if Result then                                                      ');
  SynEditModel.Lines.Add('        Break;                                                            ');
  SynEditModel.Lines.Add('    end;                                                                  ');
  SynEditModel.Lines.Add('  end;                                                                  ');
  SynEditModel.Lines.Add('end;                                                                    ');
  SynEditModel.Lines.Add('');
  {$endRegion}

  if InfoCrud.GenerateLazyDependencies then
  begin
    GenerateLazy;
    for J := 0 to MmLazyCodeFunctions.Count - 1 do
      SynEditModel.Lines.Add(MmLazyCodeFunctions.Strings[J]);
  end;

  SynEditModel.Lines.Add(
    'end.                                                                    ');
end;

procedure TFrmModel.WriteCreateQuery;
begin
  SynEditDAO.Lines.Add(Ident + 'Qry := ' + InfoCrud.ClassQuery +
    '.Create(' + InfoCrud.AOwnerCreate + ');');
  SynEditDAO.Lines.Add(Ident + 'try');
  if Trim(InfoCrud.QueryPropDatabase) <> '' then
    SynEditDAO.Lines.Add(Ident + Ident + 'Qry.' + InfoCrud.QueryPropDatabase +
      ':= ' + InfoCrud.QueryConDatabase + ';');
  if Trim(InfoCrud.QueryPropTransaction) <> '' then
    SynEditDAO.Lines.Add(Ident + Ident + 'Qry.' + InfoCrud.QueryPropTransaction +
      ':= ' + InfoCrud.QueryConTransaction + ';');

  SynEditDAO.Lines.Add(Ident + Ident + 'Qry.SQL.Clear;');
end;

procedure TFrmModel.WriteDestroyQuery;
begin
  SynEditDAO.Lines.Add(Ident + Ident + 'FreeAndNil(Qry);');
end;


procedure TFrmModel.WriteCreateSQL;
begin
  SynEditDAO.Lines.Add(Ident + 'Qry := ' + InfoCrud.ClassSQL +
    '.Create(' + InfoCrud.AOwnerCreate + ');');
  SynEditDAO.Lines.Add(Ident + 'try');
  if Trim(InfoCrud.QueryPropDatabase) <> '' then
    SynEditDAO.Lines.Add(Ident + Ident + 'Qry.' + InfoCrud.QueryPropDatabase +
      ':= ' + InfoCrud.QueryConDatabase + ';');
  if Trim(InfoCrud.QueryPropTransaction) <> '' then
    SynEditDAO.Lines.Add(Ident + Ident + 'Qry.' + InfoCrud.QueryPropTransaction +
      ':= ' + InfoCrud.QueryConTransaction + ';');

  SynEditDAO.Lines.Add(Ident + Ident + 'Qry.SQL.Clear;');
end;


function TFrmModel.WithVar(s: string): string;
begin
  Result := '';
  if Trim(S) <> '' then
    Result := ' var ' + Trim(StringReplace(S, ' var ', '', [rfIgnoreCase, rfReplaceAll]));
end;

function TFrmModel.WithOut(s: string): string;
begin
  Result := ' out ' + Trim(StringReplace(S, ' out ', '', [rfIgnoreCase, rfReplaceAll]));
end;

procedure TFrmModel.GeneratorDAOClass;
var
  I, J: integer;
  MaxField, MaxType, MaxVar: integer;
  S: string;
  SQL: TStringList;
  StrFunctionName: string;
begin
  MaxField := 0;
  MaxType := 0;
  MaxVar := 0;

  for I := 0 to InfoTable.AllFields.Count - 1 do
  begin
    if MaxField < Length(InfoTable.AllFields[I].FieldName) then
      MaxField := Length(InfoTable.AllFields[I].FieldName);
    if MaxType < Length(TypeDBToTypePascal(InfoTable.AllFields[I].FieldType)) then
      MaxType := Length(TypeDBToTypePascal(InfoTable.AllFields[I].FieldType));
    if MaxVar < (Length(InfoTable.AllFields[I].FieldName) + 1) then
      MaxVar := (Length(InfoTable.AllFields[I].FieldName) + 1);
  end;

  UnitNameDAO := 'U' + Copy(InfoTable.Tablename, InfoCrud.CopyTableName,
    Length(InfoTable.TableName)) + 'DAO';
  ClassNameDAO := 'T' + Trim(Copy(InfoTable.Tablename, InfoCrud.CopyTableName,
    Length(InfoTable.TableName))) + 'DAO';
  VarDAO := Trim(Copy(InfoTable.Tablename, InfoCrud.CopyTableName,
    Length(InfoTable.TableName))) + 'DAO';

  UnitNameModel := 'U' + Copy(InfoTable.Tablename, InfoCrud.CopyTableName,
    Length(InfoTable.TableName));
  ClassNameModel := 'T' + Trim(Copy(InfoTable.Tablename, InfoCrud.CopyTableName,
    Length(InfoTable.TableName)));
  VarModel := Trim(Copy(InfoTable.Tablename, InfoCrud.CopyTableName,
    Length(InfoTable.TableName)));

  SynEditDAO.Lines.Clear;

  for I := 0 to InfoCrud.CabecalhoCode.Count - 1 do
    SynEditDAO.Lines.Add(InfoCrud.CabecalhoCode.Strings[I] + #13);

  SynEditDAO.Lines.Add('Unit ' + UnitNameDAO + ';');
  SynEditDAO.Lines.Add('');
  SynEditDAO.Lines.Add('interface');
  SynEditDAO.Lines.Add('');
  SynEditDAO.Lines.Add('uses ');
  SynEditDAO.Lines.Add(Ident + UnitNameModel + ', ' + 'Rtti, ' + InfoCrud.UsesDefault);
  SynEditDAO.Lines.Add('');
  SynEditDAO.Lines.Add('type');
  SynEditDAO.Lines.Add(ident + ClassNameDAO + ' = class');
  SynEditDAO.Lines.Add('');
  SynEditDAO.Lines.Add(ident + 'private');

  SynEditDAO.Lines.Add(ident + 'public');
  //Cria Funcoes e Procedures CRUD;
  SynEditDAO.Lines.Add(ident + ident + 'class function GetTableNameAttributes('+VarModel+':' + ClassNameModel+'): String;');
  SynEditDAO.Lines.Add(ident + ident + 'class function IsPrimaryKey(aPropName: String; '+VarModel+':' + ClassNameModel+' ): Boolean;');
  SynEditDAO.Lines.Add(ident + ident + 'class function IsFieldReadOnly(aPropName: String; ' + VarModel+':' + ClassNameModel+' ): Boolean;');



  SynEditDAO.Lines.Add(Ident + Ident + '//Functions and Procedures Model CRUD');

  if InfoCrud.ProcInsert.Enable then
  begin
    StrFunctionName := 'class function ' + InfoCrud.ProcInsert.ProcName + '(';

    if StrFunctionName <> 'class function ' + ClassNameDAO + '.' +
      InfoCrud.ProcInsert.ProcName + '(' then
      StrFunctionName := StrFunctionName + InfoCrud.Connection;

    if StrFunctionName <> 'class function ' + ClassNameDAO + '.' +
      InfoCrud.ProcInsert.ProcName + '(' then
      StrFunctionName := StrFunctionName + ';' + WithVar(VarModel) +
        ': ' + ClassNameModel
    else
      StrFunctionName := StrFunctionName + WithVar(VarModel) + ': ' + ClassNameModel;

    if (StrFunctionName <> 'class function ' + ClassNameDAO + '.' +
      InfoCrud.ProcInsert.ProcName + '(') and (InfoCrud.HasReturnException) then
      StrFunctionName := StrFunctionName + ';' + WithVar(InfoCrud.ReturnException)
    else
      StrFunctionName := StrFunctionName + WithVar(InfoCrud.ReturnException);

    StrFunctionName := StrFunctionName + '):Boolean;';
    SynEditDAO.Lines.Add(Ident + Ident + StrFunctionName);

  end;

  if InfoCrud.ProcUpdate.Enable then
  begin
    StrFunctionName := 'class function ' + InfoCrud.ProcUpdate.ProcName + '(';

    if StrFunctionName <> 'class function ' + ClassNameDAO + '.' +
      InfoCrud.ProcUpdate.ProcName + '(' then
      StrFunctionName := StrFunctionName + InfoCrud.Connection;

    if StrFunctionName <> 'class function ' + ClassNameDAO + '.' +
      InfoCrud.ProcUpdate.ProcName + '(' then
      StrFunctionName := StrFunctionName + ';' + WithVar(VarModel) +
        ': ' + ClassNameModel
    else
      StrFunctionName := StrFunctionName + WithVar(VarModel) + ': ' + ClassNameModel;

    if (StrFunctionName <> 'class function ' + InfoCrud.ProcUpdate.ProcName + '(') and
      (InfoCrud.HasReturnException) then
      StrFunctionName := StrFunctionName + ';' + WithVar(InfoCrud.ReturnException)
    else
      StrFunctionName := StrFunctionName + WithVar(InfoCrud.ReturnException);

    StrFunctionName := StrFunctionName + '):Boolean;';
    SynEditDAO.Lines.Add(Ident + Ident + StrFunctionName);

  end;

  if InfoCrud.ProcDelete.Enable then
  begin
    StrFunctionName := 'class function ' + InfoCrud.ProcDelete.ProcName + '(';

    if StrFunctionName <> 'class function ' + ClassNameDAO + '.' +
      InfoCrud.ProcDelete.ProcName + '(' then
      StrFunctionName := StrFunctionName + InfoCrud.Connection;

    if StrFunctionName <> 'class function ' + ClassNameDAO + '.' +
      InfoCrud.ProcDelete.ProcName + '(' then
      StrFunctionName := StrFunctionName + ';' + WithVar(VarModel) +
        ': ' + ClassNameModel
    else
      StrFunctionName := StrFunctionName + WithVar(VarModel) + ': ' + ClassNameModel;

    if (StrFunctionName <> 'class function ' + ClassNameDAO +
      '.' + InfoCrud.ProcDelete.ProcName + '(') and (InfoCrud.HasReturnException) then
      StrFunctionName := StrFunctionName + ';' + WithVar(InfoCrud.ReturnException)
    else
      StrFunctionName := StrFunctionName + WithVar(InfoCrud.ReturnException);

    StrFunctionname := StrFunctionName + '):Boolean;';
    SynEditDAO.Lines.Add(Ident + Ident + StrFunctionName);
  end;

  if InfoCrud.ProcGetRecord.Enable then
  begin

    StrFunctionName := 'class function ' + InfoCrud.ProcGetRecord.ProcName + '(';

    if StrFunctionName <> 'class function ' + ClassNameDAO + '.' +
      InfoCrud.ProcGetRecord.ProcName + '(' then
      StrFunctionName := StrFunctionName + InfoCrud.Connection;

    if StrFunctionName <> 'class function ' + ClassNameDAO + '.' +
      InfoCrud.ProcGetRecord.ProcName + '(' then
      StrFunctionName := StrFunctionName + ';' + WithVar(VarModel) +
        ': ' + ClassNameModel
    else
      StrFunctionName := StrFunctionName + WithVar(VarModel) + ': ' + ClassNameModel;

    if (StrFunctionName <> 'class function ' + InfoCrud.ProcGetRecord.ProcName + '(') and
      (InfoCrud.HasReturnException) then
      StrFunctionName := StrFunctionName + ';' + WithVar(InfoCrud.ReturnException)
    else
      StrFunctionName := StrFunctionName + WithVar(InfoCrud.ReturnException);

    StrFunctionName := StrFunctionName + '):Boolean;';

    SynEditDAO.Lines.Add(Ident + Ident + StrFunctionName);

  end;

  if InfoCrud.ProcListRecords.Enable then
  begin

    StrFunctionName := 'class function ' + InfoCrud.ProcListRecords.ProcName + '(';

    if StrFunctionName <> 'class function ' + ClassNameDAO + '.' +
      InfoCrud.ProcListRecords.ProcName + '(' then
      StrFunctionName := StrFunctionName + InfoCrud.Connection;

    if StrFunctionName <> 'class function ' +
      InfoCrud.ProcListRecords.ProcName + '(' then
      StrFunctionName := StrFunctionName + '; out ObjLst: TObjectList;' +
        ' WhereSQL: String'
    else
      StrFunctionName := StrFunctionName + ' out ObjLst: TObjectList;' +
        ' WhereSQL: String';

    if (StrFunctionName <> 'class function ' + InfoCrud.ProcListRecords.ProcName +
      '(') and (Trim(InfoCrud.ReturnException) <> '') then
      StrFunctionName := StrFunctionName + ';' + WithVar(InfoCrud.ReturnException)
    else
      StrFunctionName := StrFunctionName + WithVar(InfoCrud.ReturnException);

    StrFunctionName := StrFunctionName + '):Boolean;';

    SynEditDAO.Lines.Add(Ident + Ident + StrFunctionName);

  end;
  SynEditDAO.Lines.Add(ident + 'end; ');
  SynEditDAO.Lines.Add(ident + '');
  SynEditDAO.Lines.Add('implementation');
  SynEditDAO.Lines.Add(ident + '');
  SynEditDAO.Lines.Add(ident + '');
  GeneratorCodeGetTableNameAttributes;
  GeneratorCodeGetIsPrimaryKey;
  GeneratorCodeGetIsFieldReadOnly;
  //Gerando Functions Code
  GeneratorCodeProcInsert;
  GeneratorCodeProcUpdate;
  GeneratorCodeProcDelete;
  GeneratorCodeProcGetItem;
  GeneratorCodeProcList;
  SynEditDAO.Lines.Add(ident + '');
  SynEditDAO.Lines.Add('end.');
end;

function TFrmModel.IFNull(FieldInfo: TAsFieldInfo): string;
begin
  Result := ':' + FieldInfo.FieldName;
end;

function TFrmModel.GenerateSqlQuery(queryType: TQueryType): TStringList;
var
  I: integer;
  vAux: WideString;
begin
  try
    Result := TStringList.Create;
    case queryType of

      qtSelect: //Seleciona Varios registros, porém apenas os campos chave da tabela [List]
      begin

        vAux := '';
        for I := 0 to InfoTable.PrimaryKeys.Count - 1 do
          vAux := vAux + ifThen(I = 0, '', ', ') +
            InfoTable.PrimaryKeys.Items[I].FieldName;

        Result.Add(' SELECT * FROM ' + InfoTable.Tablename + ' ');
      end;
      qtSelectItem:
        //Retorna um unico registro de acordo com sua chave (Retorna todos os campos)
      begin

        Result.Add(' SELECT * FROM ' + InfoTable.Tablename + ' ');

        for I := 0 to InfoTable.PrimaryKeys.Count - 1 do
          Result.Add(Ident + ifthen(I = 0, ' WHERE (', '   AND (') +
            InfoTable.PrimaryKeys.Items[I].FieldName + ' = :' +
            InfoTable.PrimaryKeys.Items[I].FieldName + ')');
      end;

      qtInsert:
      begin
        Result.Add(' INSERT INTO ' + InfoTable.Tablename + '(');

        for I := 0 to InfoTable.AllFields.Count - 1 do
        begin
          if I = InfoTable.AllFields.Count - 1 then
            Result.Add(Ident + InfoTable.AllFields[I].FieldName + ')')
          else
            Result.Add(Ident + InfoTable.AllFields[I].FieldName + ', ');
        end;

        Result.Add(' VALUES (');
        for I := 0 to InfoTable.AllFields.Count - 1 do
        begin
          if I = InfoTable.AllFields.Count - 1 then
            Result.Add(Ident + IfNull(InfoTable.AllFields[I]) + ')')
          else
            Result.Add(Ident + IfNull(InfoTable.AllFields[I]) + ', ');
        end;
      end;

      qtUpdate:
      begin
        Result.Add(' UPDATE ' + InfoTable.Tablename + ' SET ');
        for I := 0 to InfoTable.AllFields.Count - 1 do
        begin
          if InfoTable.PrimaryKeys.GetIndex(InfoTable.AllFields[I].FieldName) = -1 then
          begin
            if I = InfoTable.AllFields.Count - 1 then
              Result.Add(Ident + InfoTable.AllFields[I].FieldName +
                ' = ' + IfNull(InfoTable.AllFields[I]) + '')
            else
              Result.Add(Ident + InfoTable.AllFields[I].FieldName +
                ' = ' + IfNull(InfoTable.AllFields[I]) + ', ');
          end;
        end;
        for I := 0 to InfoTable.PrimaryKeys.Count - 1 do
        begin
          Result.Add(ifthen(I = 0, ' WHERE (', Ident + ' AND (') +
            InfoTable.PrimaryKeys.Items[I].FieldName +
            ' = :' +
            InfoTable.PrimaryKeys.Items[I].FieldName + ')');
        end;
      end;

      qtDelete:
      begin
        Result.Add(' DELETE FROM ' + InfoTable.Tablename);
        for I := 0 to InfoTable.PrimaryKeys.Count - 1 do
        begin
          Result.Add(ifthen(I = 0, ' WHERE (', Ident + ' AND (') +
            InfoTable.PrimaryKeys.Items[I].FieldName +
            ' = :' +
            InfoTable.PrimaryKeys.Items[I].FieldName + ')');
        end;
      end;

    end;
  finally

  end;
end;

procedure TFrmModel.GenerateSqlQueryUpdate;
var
  I: integer;
begin
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'Qry.Sql.Add(' + QuotedStr('UPDATE ') +'+'+ ClassNameDAO+'.GetTableNameAttributes('+VarModel+') + ' + QuotedStr(' SET ') + ');');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident +'{$REGION ' + QuotedStr('RTTI - Gera comando Update conforme necessidade Old e New Value') + '}');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'CtxRtti  := TRttiContext.Create;');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'TpRtti   := CtxRtti.GetType(' + VarModel + '.ClassType);');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'for PropRtti in TpRtti.GetProperties do');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'begin');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'PropNameRtti := PropRtti.Name;');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'if PropRtti.PropertyType.TypeKind in [tkInteger, tkChar,');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'tkFloat,   tkString, tkUString]  then');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + 'if (PropRtti.GetValue(' + VarModel + ').ToString <> GetOldValue) and (not '+ClassNameDAO+'.IsFieldReadOnly(PropNameRtti, ' + VarModel + ')) then');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'Qry.Sql.Add(Separator + propRtti.Name+''= :''+  propRtti.Name);');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'end;');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + '{$EndRegion}');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'Qry.Sql.Add(' + QuotedStr('WHERE') +');');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'StrAux := '''';');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident +'{$REGION ' + QuotedStr('RTTI - Monta Clausula Where') + '}');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'for PropRtti in TpRtti.GetProperties do');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'begin');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'PropNameRtti := PropRtti.Name;');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'if '+ClassNameDAO+'.IsPrimaryKey(PropNameRtti, ' + VarModel + ') then ');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'begin');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + 'Qry.Sql.Add(StrAux + propRtti.Name+''= :''+  propRtti.Name);');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + 'StrAux := '' AND '';');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'end;');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'end;');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + '{$EndRegion}');
end;

procedure TFrmModel.GenerateSqlQueryGetRecord;
var
  I: integer;
begin
  SynEditDAO.Lines.Add(Ident + Ident + Ident + 'Qry.Sql.Add(' + QuotedStr('SELECT * FROM ') + ' + '+ClassNameDAO+'.GetTableNameAttributes('+VarModel+'));');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + 'Qry.Sql.Add(' + QuotedStr('WHERE') +');');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + 'StrAux := '''';');
  SynEditDAO.Lines.Add(Ident + Ident + Ident +'{$REGION ' + QuotedStr('RTTI - Monta Clausula Where') + '}');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + 'CtxRtti  := TRttiContext.Create;');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + 'TpRtti   := CtxRtti.GetType(' + VarModel + '.ClassType);');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + 'for PropRtti in TpRtti.GetProperties do');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + 'begin');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'PropNameRtti := PropRtti.Name;');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'if '+ClassNameDAO+'.IsPrimaryKey(PropNameRtti, ' + VarModel + ') then ');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'begin');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'Qry.Sql.Add(StrAux + propRtti.Name+''= :''+  propRtti.Name);');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'StrAux := '' AND '';');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'end;');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + 'end;');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + '{$EndRegion}');
end;

procedure TFrmModel.GenerateSqlQueryDeleteRecord;
var
  I: integer;
begin
  SynEditDAO.Lines.Add(Ident + Ident + Ident + 'Qry.Sql.Add(' + QuotedStr('DELETE FROM ') + ' + '+ClassNameDAO+'.GetTableNameAttributes('+VarModel+'));');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + 'Qry.Sql.Add(' + QuotedStr('WHERE') +');');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + 'StrAux := '''';');
  SynEditDAO.Lines.Add(Ident + Ident + Ident +'{$REGION ' + QuotedStr('RTTI - Monta Clausula Where') + '}');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + 'CtxRtti  := TRttiContext.Create;');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + 'TpRtti   := CtxRtti.GetType(' + VarModel + '.ClassType);');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + 'for PropRtti in TpRtti.GetProperties do');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + 'begin');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'PropNameRtti := PropRtti.Name;');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'if '+ClassNameDAO+'.IsPrimaryKey(PropNameRtti, ' + VarModel + ') then ');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'begin');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'Qry.Sql.Add(StrAux + propRtti.Name+''= :''+  propRtti.Name);');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'StrAux := '' AND '';');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'end;');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + 'end;');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + '{$EndRegion}');
end;

procedure TFrmModel.GenerateSqlQueryListaRecords;
var
  I: integer;
begin
  SynEditDAO.Lines.Add(Ident + Ident + Ident + 'Qry.Sql.Add(' + QuotedStr('SELECT * FROM ') + ' + '+ClassNameDAO+'.GetTableNameAttributes('+VarModel+'));');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + 'Qry.Sql.Add(' + QuotedStr('WHERE') +');');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + 'StrAux := '''';');
  SynEditDAO.Lines.Add(Ident + Ident + Ident +'{$REGION ' + QuotedStr('RTTI - Monta Clausula Where') + '}');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + 'CtxRtti  := TRttiContext.Create;');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + 'TpRtti   := CtxRtti.GetType(' + VarModel + '.ClassType);');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + 'for PropRtti in TpRtti.GetProperties do');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + 'begin');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'PropNameRtti := PropRtti.Name;');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'if '+ClassNameDAO+'.IsPrimaryKey(PropNameRtti, ' + VarModel + ') then ');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'begin');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'Qry.Sql.Add(StrAux + propRtti.Name+''= :''+  propRtti.Name);');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'StrAux := '' AND '';');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'end;');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'break;');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + 'end;');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + '{$EndRegion}');
end;

procedure TFrmModel.GenerateSqlQueryInsert;
var
  I: integer;
begin
  SynEditDAO.Lines.Add(Ident + Ident + Ident + 'Qry.Sql.Add(' + QuotedStr('INSERT INTO ')+ '+' + ClassNameDAO+'.GetTableNameAttributes('+VarModel+') + ' + QuotedStr(' ( ') + ');');
  SynEditDAO.Lines.Add(Ident + Ident + Ident +'{$REGION ' + QuotedStr('RTTI - Gera comando Insert') + '}');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + 'CtxRtti  := TRttiContext.Create;');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + 'TpRtti   := CtxRtti.GetType(' + VarModel + '.ClassType);');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + 'StrAux := '''';');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + 'for PropRtti in TpRtti.GetProperties do');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + 'begin');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'PropNameRtti := PropRtti.Name;');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'if (not '+ClassNameDAO+'.isFieldReadOnly(PropNameRtti, ' + VarModel + ')) then');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'begin');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'Qry.Sql.Add(StrAux + propRtti.Name);');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'StrAux := '', '';');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'end;');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + 'end;');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + '{$EndRegion}');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + 'Qry.Sql.Add(' + QuotedStr(') VALUES (') +');');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + 'StrAux := '''';');
  SynEditDAO.Lines.Add(Ident + Ident + Ident +'{$REGION ' + QuotedStr('RTTI - Monta Clausula Values') + '}');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + 'for PropRtti in TpRtti.GetProperties do');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + 'begin');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'PropNameRtti := PropRtti.Name;');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'if (not '+ClassNameDAO+'.isFieldReadOnly(PropNameRtti, ' + VarModel + ')) then');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'begin');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'Qry.Sql.Add(StrAux + '':''+propRtti.Name);');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'StrAux := '', '';');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'end;');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + 'end;');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + 'Qry.Sql.Add(' + QuotedStr(')') +');');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + '{$EndRegion}');
end;


procedure TFrmModel.EscreveSqlSynEditDao(StrList: TStringList);
var
  j, comp: word;

  function Alinha(x: string): string;
  begin
    Result := copy(x, 1, comp) + StringOfChar(' ', comp - length(copy(x, 1, comp)));
  end;

begin
  comp := 0;
  for J := 0 to StrList.Count - 1 do
    if Length(StrList.Strings[j]) + 2 > comp then
      comp := Length(StrList.Strings[j]) + 2;
  for J := 0 to StrList.Count - 1 do
  begin
    if J = 0 then //Primeira linha
    begin
      if (StrList.Count > 1) then //Primeira linha de uma lista com vários registros...
        SynEditDAO.Lines.Add(StringOfChar(' ', 6) + 'Qry.Sql.Add(' +
          QuotedStr(Alinha(StrList.Strings[J])) + ');')
      else //Se tiver apenas um registro na lista, cai aqui....     }
        SynEditDAO.Lines.Add(StringOfChar(' ', 6) + 'Qry.Sql.Add(' +
          QuotedStr(Alinha(StrList.Strings[J])) + ');');
    end
    else
    begin
      if J = StrList.Count - 1 then //Ultima linha
        SynEditDAO.Lines.Add(StringOfChar(' ', 6) + 'Qry.Sql.Add(' +
          QuotedStr(Alinha(StrList.Strings[J])) + ');')
      else //Demais registros
        SynEditDAO.Lines.Add(StringOfChar(' ', 6) + 'Qry.Sql.Add(' +
          QuotedStr(Alinha(StrList.Strings[J])) + ');');
    end;
  end;
end;

procedure TFrmModel.GeneratorCodeProcInsert;
var
  SQL: TStringList;
  S: string;
  J, IdSpace, IdSpaceAux: integer;
  StrFunctionName: string;
begin
  if InfoCrud.ProcInsert.Enable then
  begin
    StrFunctionName := 'class function ' + ClassNameDAO + '.' +
      InfoCrud.ProcInsert.ProcName + '(';
    if StrFunctionName <> 'class function ' + ClassNameDAO + '.' +
      InfoCrud.ProcInsert.ProcName + '(' then
      StrFunctionName := StrFunctionName + ';' + InfoCrud.Connection
    else
      StrFunctionName := StrFunctionName + InfoCrud.Connection;

    if StrFunctionName <> 'class function ' + ClassNameDAO + '.' +
      InfoCrud.ProcInsert.ProcName + '(' then
      StrFunctionName := StrFunctionName + ';' + WithVar(VarModel) +
        ': ' + ClassNameModel
    else
      StrFunctionName := StrFunctionName + WithVar(VarModel) + ': ' + ClassNameModel;

    if (StrFunctionName <> 'class function ' + ClassNameDAO + '.' +
      InfoCrud.ProcInsert.ProcName + '(') and (InfoCrud.HasReturnException) then
      StrFunctionName := StrFunctionName + ';' + WithVar(InfoCrud.ReturnException)
    else
      StrFunctionName := StrFunctionName + WithVar(InfoCrud.ReturnException);

    SynEditDAO.Lines.Add(StrFunctionName + '):Boolean;');
    SynEditDAO.Lines.Add('var');
    SynEditDAO.Lines.Add(Ident + 'Qry: ' + InfoCrud.ClassSQL + ';');
    SynEditDAO.Lines.Add(Ident + 'StrAux: String;');
    {$REGION 'Variaveis RTTI'}
    SynEditDAO.Lines.Add(Ident + '{$Region ' + QuotedStr('Variaveis RTTI NewValue') + '}');
    SynEditDAO.Lines.Add(Ident + 'CtxRtti     : TRttiContext;');
    SynEditDAO.Lines.Add(Ident + 'TpRtti      : TRttiType;');
    SynEditDAO.Lines.Add(Ident + 'PropRtti    : TRttiProperty;');
    SynEditDAO.Lines.Add(Ident + 'PropNameRtti: String;');
    SynEditDAO.Lines.Add(Ident + '{$ENDREGION}');
    {$EndRegion}
    SynEditDAO.Lines.Add('begin');
    WriteCreateSQL;
    SynEditDAO.Lines.Add(Ident + Ident + 'try');

    SynEditDAO.Lines.Add(Ident + Ident + Ident + '{$REGION ''Comando SQL''}');
    GenerateSqlQueryInsert;
    SynEditDAO.Lines.Add(Ident + Ident + Ident + '{$ENDREGION}');

    SynEditDAO.Lines.Add(Ident + Ident + Ident + '{$Region ' + QuotedStr('RTTI - Atribui valores para os Paramentros caso necessario ') + '}');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + 'CtxRtti  := TRttiContext.Create;');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + 'TpRtti   := CtxRtti.GetType(' + VarModel + '.ClassType);');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + 'for PropRtti in TpRtti.GetProperties do');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + 'begin');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'PropNameRtti := PropRtti.Name;');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'if (not '+ClassNameDAO+'.isFieldReadOnly(PropNameRtti, ' + VarModel + ')) then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'begin');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'if (PropRtti.PropertyType.TypeKind in [tkUString, tkString, tkChar]) then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'begin');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + 'if ' + ClassNameDAO+'.IsPrimaryKey(PropNameRtti,'+VarModel+') then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'Qry.ParamByName(PropNameRtti).AsString := propRtti.GetValue(' + VarModel + ').ToString');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + 'else if (not '+ClassNameDAO+'.IsFieldReadOnly(PropNameRtti,'+VarModel+')) then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + 'begin');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'if (Trim(PropRtti.GetValue(' + VarModel + ').ToString) <> ' + QuotedStr('') + ') then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'Qry.ParamByName(PropNameRtti).AsString := propRtti.GetValue(' + VarModel + ').ToString');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'else');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'Qry.ParamByName(PropNameRtti).Clear;');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + 'end;');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'end');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'else if (propRtti.PropertyType.TypeKind in [tkInteger]) then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'begin');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + 'if '+ClassNameDAO+'.IsPrimaryKey(PropNameRtti,'+VarModel+') then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'Qry.ParamByName(PropNameRtti).Value := propRtti.GetValue(' + VarModel + ').AsVariant');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + 'else if (not '+ClassNameDAO+'.IsFieldReadOnly(PropNameRtti,'+VarModel+')) then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + 'begin');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'if (propRtti.GetValue(' + VarModel + ').ToString <> ''0'') and');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + '(propRtti.GetValue(' + VarModel + ').ToString <> '''') then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'Qry.ParamByName(PropNameRtti).Value := propRtti.GetValue(' + VarModel + ').AsVariant');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'else');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'Qry.ParamByName(PropNameRtti).Clear;');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + 'end;');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'end');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'else if (propRtti.PropertyType.TypeKind in [tkFloat]) then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'begin');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + 'if '+ClassNameDAO+'.IsPrimaryKey(PropNameRtti,'+VarModel+') then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + 'begin');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident +'if (CompareText(''TDateTime'', propRtti.PropertyType.Name) = 0 ) or');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident +'   (CompareText(''TDate'', propRtti.PropertyType.Name) = 0) or');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident +'   (CompareText(''TTime'', propRtti.PropertyType.Name) = 0) then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'Qry.ParamByName(PropNameRtti).AsDateTime := propRtti.GetValue(' + VarModel + ').AsExtended');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'else');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'Qry.ParamByName(PropNameRtti).AsFloat := propRtti.GetValue(' + VarModel + ').AsExtended');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + 'end');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + 'else if (not '+ClassNameDAO+'.IsFieldReadOnly(PropNameRtti,'+VarModel+')) then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + 'begin');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'if ((propRtti.GetValue(' + VarModel + ').ToString <> ''0'') and');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + '(propRtti.GetValue(' + VarModel + ').ToString <> ' + QuotedStr('') + ')) then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'begin');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'if (CompareText(''TDateTime'', propRtti.PropertyType.Name) = 0 ) or');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + '   (CompareText(''TDate'', propRtti.PropertyType.Name) = 0) or');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + '   (CompareText(''TTime'', propRtti.PropertyType.Name) = 0) then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'Qry.ParamByName(PropNameRtti).AsDateTime := propRtti.GetValue(' + VarModel + ').AsExtended');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'else');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'Qry.ParamByName(PropNameRtti).AsFloat := propRtti.GetValue(' + VarModel + ').AsExtended');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'end');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'else');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'Qry.ParamByName(PropNameRtti).Clear;');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + 'end;');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'end;');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'end;');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + 'end;');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + '{$EndRegion}');

    SynEditDAO.Lines.Add(Ident + Ident + Ident + 'Qry.' + InfoCrud.SQLCommand + ';');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + 'Result := True;');
    SynEditDAO.Lines.Add(Ident + Ident + 'except');
    for J := 0 to InfoCrud.ExceptionCode.Count - 1 do
    begin
      S := StringReplace(InfoCrud.ExceptionCode.Strings[J], '$UnitName',
        UnitNameDAO, [rfReplaceAll]);
      S := StringReplace(S, '$ProcName', InfoCrud.ProcInsert.ProcName, [rfReplaceAll]);
      SynEditDAO.Lines.Add(Ident + Ident + Ident + S);
    end;
    SynEditDAO.Lines.Add(Ident + Ident + 'end;');
    SynEditDAO.Lines.Add(Ident + 'finally');
    WriteDestroyQuery;
    SynEditDAO.Lines.Add(Ident + 'end;');
    SynEditDAO.Lines.Add('end;');
  end;
end;

procedure TFrmModel.GeneratorCodeProcUpdate;
var
  SQL: TStringList;
  S: string;
  J, IdSpace, IdSpaceAux: integer;
  StrFunctionName: string;
begin
  if InfoCrud.ProcUpdate.Enable then
  begin
    SynEditDAO.Lines.Add(ident + '');
    StrFunctionName := 'class function ' + ClassNameDAO + '.' +
      InfoCrud.ProcUpdate.ProcName + '(';

    if StrFunctionName <> 'class function ' + ClassNameDAO + '.' +
      InfoCrud.ProcUpdate.ProcName + '(' then
      StrFunctionName := StrFunctionName + ';' + InfoCrud.Connection
    else
      StrFunctionName := StrFunctionName + InfoCrud.Connection;

    if StrFunctionName <> 'class function ' + ClassNameDAO + '.' +
      InfoCrud.ProcUpdate.ProcName + '(' then
      StrFunctionName := StrFunctionName + ';' + WithVar(VarModel) +
        ': ' + ClassNameModel
    else
      StrFunctionName := StrFunctionName + WithVar(VarModel) + ': ' + ClassNameModel;

    if (StrFunctionName <> 'class function ' + ClassNameDAO + '.' +
      InfoCrud.ProcUpdate.ProcName + '(') and (InfoCrud.HasReturnException) then
      StrFunctionName := StrFunctionName + ';' + WithVar(InfoCrud.ReturnException)
    else
      StrFunctionName := StrFunctionName + WithVar(InfoCrud.ReturnException);

    SynEditDAO.Lines.Add(StrFunctionName + '):Boolean;');

    SynEditDAO.Lines.Add('var');
    SynEditDAO.Lines.Add(Ident + 'Qry: ' + InfoCrud.ClassSQL + ';');
    SynEditDAO.Lines.Add(Ident + 'StrAux: String;');

    {$REGION 'Variaveis RTTI'}
    SynEditDAO.Lines.Add(Ident + '{$Region ' + QuotedStr('Variaveis RTTI NewValue') + '}');
    SynEditDAO.Lines.Add(Ident + 'CtxRtti     : TRttiContext;');
    SynEditDAO.Lines.Add(Ident + 'TpRtti      : TRttiType;');
    SynEditDAO.Lines.Add(Ident + 'PropRtti    : TRttiProperty;');
    SynEditDAO.Lines.Add(Ident + 'PropNameRtti: String;');
    SynEditDAO.Lines.Add(Ident + '{$ENDREGION}');
    {$EndRegion}
    SynEditDAO.Lines.Add(Ident + 'function GetOldValue: String;');
    SynEditDAO.Lines.Add(Ident + 'var');
    SynEditDAO.Lines.Add(Ident + Ident + 'CtxRttiOld: TRttiContext;');
    SynEditDAO.Lines.Add(Ident + Ident + 'TpRttiOld: TRttiType;');
    SynEditDAO.Lines.Add(Ident + Ident + 'PropRttiOld: TRttiProperty;');
    SynEditDAO.Lines.Add(Ident + 'begin');
    SynEditDAO.Lines.Add(Ident + Ident + 'Result := ' + QuotedStr('') + ';');
    SynEditDAO.Lines.Add(Ident + Ident + 'CtxRttiOld  := TRttiContext.Create;');
    SynEditDAO.Lines.Add(Ident + Ident + 'TpRttiOld   := CtxRttiOld.GetType(' +
      VarModel + '.Original.ClassType);');
    SynEditDAO.Lines.Add(Ident + Ident +
      'PropRttiOld := TpRttiOld.GetProperty(PropNameRtti);');
    SynEditDAO.Lines.Add(Ident + Ident +
      'Result      := VarToStr(PropRttiOld.GetValue(' + VarModel + '.Original).AsVariant);');
    SynEditDAO.Lines.Add(Ident + 'end;');

    SynEditDAO.Lines.Add(Ident + 'function Separator : String; ');
    SynEditDAO.Lines.Add(Ident + 'begin                        ');
    SynEditDAO.Lines.Add(Ident + '  Result := ' + QuotedStr('') + ';              ');
    SynEditDAO.Lines.Add(Ident + '  if Qry.Sql.Count > 1 then   ');
    SynEditDAO.Lines.Add(Ident + '    Result := ' + QuotedStr(', ') + ';');
    SynEditDAO.Lines.Add(Ident + 'end;                         ');
    SynEditDAO.Lines.Add('begin');
    WriteCreateSQL;
    SynEditDAO.Lines.Add(Ident + Ident + 'try');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + 'if (' + VarModel + '.IsModify) then ');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + 'begin');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + '{$REGION ''Comando SQL''}');
    GenerateSqlQueryUpdate;
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + '{$ENDREGION}');
    SynEditDAO.Lines.Add('');

    //Pega a maior sequencia de caracteres existente nos parametros, para alinhar a codificacao
    IdSpace := 0;
    IdSpaceAux := 0;
    for J := 0 to InfoTable.AllFields.Count - 1 do
    begin
      IdSpaceAux := Length('Qry.ParamByName(' +
        QuotedStr(InfoTable.AllFields[J].FieldName) + ').' +
        TypeDBToTypePascalParams(InfoTable.AllFields[J]));
      IdSpace := IfThen(IdSpaceAux > IdSpace, IdSpaceAux, IdSpace);
    end;

    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + '{$Region ' + QuotedStr('RTTI - Atribui valores para os Paramentros caso necessario ') + '}');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'for PropRtti in TpRtti.GetProperties do');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'begin');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'PropNameRtti := PropRtti.Name;');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident +'if (not '+ClassNameDAO+'.isFieldReadOnly(PropNameRtti, ' + VarModel + ')) then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident +'begin');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + 'if (PropRtti.PropertyType.TypeKind in [tkUString, tkString, tkChar]) then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + 'begin');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'if '+ClassNameDAO+'.IsPrimaryKey(PropNameRtti,'+VarModel+') then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'Qry.ParamByName(PropNameRtti).AsString := propRtti.GetValue(' + VarModel + ').ToString');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'else');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'begin');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'if (PropRtti.GetValue(' + VarModel + ').ToString <> GetOldValue) and (not '+ClassNameDAO+'.IsFieldReadOnly(PropNameRtti,'+VarModel+')) then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'begin');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'if (Trim(PropRtti.GetValue(' + VarModel + ').ToString) <> ' + QuotedStr('') + ') then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'Qry.ParamByName(PropNameRtti).AsString := propRtti.GetValue(' + VarModel + ').ToString');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'else');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'Qry.ParamByName(PropNameRtti).Clear;');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'end;');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'end;');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + 'end');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + 'else if (propRtti.PropertyType.TypeKind in [tkInteger]) then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + 'begin');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'if '+ClassNameDAO+'.IsPrimaryKey(PropNameRtti,'+VarModel+') then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'Qry.ParamByName(PropNameRtti).Value := propRtti.GetValue(' + VarModel + ').AsVariant');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'else');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'begin');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'if (PropRtti.GetValue(' + VarModel + ').ToString <> GetOldValue) and (not '+ClassNameDAO+'.IsFieldReadOnly(PropNameRtti,'+VarModel+')) then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'begin');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'if ((propRtti.GetValue(' + VarModel + ').ToString <> ''0'') and');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + '(propRtti.GetValue(' + VarModel + ').ToString <> '''')) then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'Qry.ParamByName(PropNameRtti).Value := propRtti.GetValue(' + VarModel + ').AsVariant');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'else');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'Qry.ParamByName(PropNameRtti).Clear;');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'end;');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'end;');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + 'end');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + 'else if (propRtti.PropertyType.TypeKind in [tkFloat]) then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + 'begin');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'if '+ClassNameDAO+'.IsPrimaryKey(PropNameRtti,'+VarModel+') then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'begin');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'if (CompareText(''TDateTime'', propRtti.PropertyType.Name) = 0 ) or');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + '   (CompareText(''TDate'', propRtti.PropertyType.Name) = 0) or');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + '   (CompareText(''TTime'', propRtti.PropertyType.Name) = 0) then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'Qry.ParamByName(PropNameRtti).AsDateTime := propRtti.GetValue(' + VarModel + ').AsExtended');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'else');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'Qry.ParamByName(PropNameRtti).AsFloat := propRtti.GetValue(' + VarModel + ').AsExtended');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'end');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'else');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'begin');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'if (PropRtti.GetValue(' + VarModel + ').ToString <> GetOldValue) and (not '+ClassNameDAO+'.IsFieldReadOnly(PropNameRtti,'+VarModel+')) then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'begin');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'if ((propRtti.GetValue(' + VarModel + ').ToString <> ''0'') and');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + '(PropRtti.GetValue(' + VarModel + ').ToString <> ' + QuotedStr('') + '))  then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'begin');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'if (CompareText(''TDateTime'', propRtti.PropertyType.Name) = 0 ) or');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + '   (CompareText(''TDate'', propRtti.PropertyType.Name) = 0) or');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + '   (CompareText(''TTime'', propRtti.PropertyType.Name) = 0) then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'Qry.ParamByName(PropNameRtti).AsDateTime := propRtti.GetValue(' + VarModel + ').AsExtended');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'else');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'Qry.ParamByName(PropNameRtti).AsFloat := propRtti.GetValue(' + VarModel + ').AsExtended');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'end');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'else');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'Qry.ParamByName(PropNameRtti).Clear;');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'end;');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'end;');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + 'end;');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'end;');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'end;');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + '{$EndRegion}');

    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'Qry.' + InfoCrud.SQLCommand + ';');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + 'end;');

    SynEditDAO.Lines.Add(Ident + Ident + Ident + 'Result := True;');
    SynEditDAO.Lines.Add(Ident + Ident + 'except');
    for J := 0 to InfoCrud.ExceptionCode.Count - 1 do
    begin
      S := StringReplace(InfoCrud.ExceptionCode.Strings[J], '$UnitName',
        UnitNameDAO, [rfReplaceAll]);
      S := StringReplace(S, '$ProcName', InfoCrud.ProcUpdate.ProcName, [rfReplaceAll]);
      SynEditDAO.Lines.Add(Ident + Ident + Ident + S);
    end;
    SynEditDAO.Lines.Add(Ident + Ident + 'end;');
    SynEditDAO.Lines.Add(Ident + 'finally');
    WriteDestroyQuery;
    SynEditDAO.Lines.Add(Ident + 'end;');
    SynEditDAO.Lines.Add('end;');
  end;
end;

procedure TFrmModel.GeneratorCodeGetTableNameAttributes;
var
  StrFunctionName: string;
begin
  {$Region 'Get TableNameAtributtes'}
  StrFunctionName := 'class function ' + ClassNameDAO +
    '.GetTableNameAttributes('+VarModel+':' + ClassNameModel+'): String;';
  SynEditDAO.Lines.Add(StrFunctionName);
  SynEditDAO.Lines.Add('var');
  SynEditDAO.Lines.Add(Ident + 'ctx    : TRttiContext; ');
  SynEditDAO.Lines.Add(Ident + 'typ    : TRttiType;    ');
  SynEditDAO.Lines.Add(Ident + 'oAtt    : TCustomAttribute; ');
  SynEditDAO.Lines.Add('begin                       ');
  SynEditDAO.Lines.Add(Ident + 'Result := '''';               ');
  SynEditDAO.Lines.Add(Ident + 'ctx := TRttiContext.Create; ');
  SynEditDAO.Lines.Add(Ident + 'typ := ctx.GetType('+VarModel+'.ClassType); ');
  SynEditDAO.Lines.Add(Ident + 'for oAtt in typ.GetAttributes do ');
  SynEditDAO.Lines.Add(Ident + 'begin                            ');
  SynEditDAO.Lines.Add(Ident + Ident + 'if (oAtt is TTableName) then     ');
  SynEditDAO.Lines.Add(Ident + Ident + Ident + 'Result := TTableName(oAtt).TableName; ');
  SynEditDAO.Lines.Add(Ident + 'end;');
  SynEditDAO.Lines.Add('end;');
  SynEditDAO.Lines.Add('');
  {$ENDREGION}
end;

procedure TFrmModel.GeneratorCodeGetIsPrimaryKey;
var
  StrFunctionName: string;
begin
  {$Region 'Get TableNameAtributtes'}
  StrFunctionName := 'class function ' + ClassNameDAO +
    '.IsPrimaryKey(aPropName: String; '+VarModel+':' + ClassNameModel+'): Boolean;';
  SynEditDAO.Lines.Add(StrFunctionName);
  SynEditDAO.Lines.Add('var');
  SynEditDAO.Lines.Add('  ctx    : TRttiContext;');
  SynEditDAO.Lines.Add('  typ    : TRttiType;');
  SynEditDAO.Lines.Add('  pro    : TRttiProperty;');
  SynEditDAO.Lines.Add('  oAtt    : TCustomAttribute;');
  SynEditDAO.Lines.Add('begin');
  SynEditDAO.Lines.Add('  Result := False;');
  SynEditDAO.Lines.Add('  ctx := TRttiContext.Create;');
  SynEditDAO.Lines.Add('  typ := ctx.GetType('+VarModel+'.ClassType);');
  SynEditDAO.Lines.Add('  for pro in typ.GetProperties do');
  SynEditDAO.Lines.Add('  begin');
  SynEditDAO.Lines.Add('    if aPropName = Pro.Name then');
  SynEditDAO.Lines.Add('    begin');
  SynEditDAO.Lines.Add('      for oAtt in pro.GetAttributes do');
  SynEditDAO.Lines.Add('      begin');
  SynEditDAO.Lines.Add('        Result :=  oAtt is TPrimaryKey;');
  SynEditDAO.Lines.Add('        if Result then');
  SynEditDAO.Lines.Add('          Break;');
  SynEditDAO.Lines.Add('      end;');
  SynEditDAO.Lines.Add('    end;');
  SynEditDAO.Lines.Add('    if Result then');
  SynEditDAO.Lines.Add('      Break;');
  SynEditDAO.Lines.Add('  end;');
  SynEditDAO.Lines.Add('end;');
  SynEditDAO.Lines.Add('');
end;

procedure TFrmModel.GeneratorCodeGetIsFieldReadOnly;
var
  StrFunctionName: string;
begin
  {$Region 'Get TableNameAtributtes'}
  StrFunctionName := 'class function ' + ClassNameDAO +
    '.IsFieldReadOnly(aPropName: String; '+VarModel+':' + ClassNameModel+'): Boolean;';
  SynEditDAO.Lines.Add(StrFunctionName);
  SynEditDAO.Lines.Add('var');
  SynEditDAO.Lines.Add('  ctx    : TRttiContext;');
  SynEditDAO.Lines.Add('  typ    : TRttiType;');
  SynEditDAO.Lines.Add('  pro    : TRttiProperty;');
  SynEditDAO.Lines.Add('  oAtt    : TCustomAttribute;');
  SynEditDAO.Lines.Add('begin');
  SynEditDAO.Lines.Add('  Result := False;');
  SynEditDAO.Lines.Add('  ctx := TRttiContext.Create;');
  SynEditDAO.Lines.Add('  typ := ctx.GetType('+VarModel+'.ClassType);');
  SynEditDAO.Lines.Add('  for pro in typ.GetProperties do');
  SynEditDAO.Lines.Add('  begin');
  SynEditDAO.Lines.Add('    if aPropName = Pro.Name then');
  SynEditDAO.Lines.Add('    begin');
  SynEditDAO.Lines.Add('      for oAtt in pro.GetAttributes do');
  SynEditDAO.Lines.Add('      begin');
  SynEditDAO.Lines.Add('        Result :=  oAtt is TFieldReadOnly;');
  SynEditDAO.Lines.Add('        if Result then');
  SynEditDAO.Lines.Add('          Break;');
  SynEditDAO.Lines.Add('      end;');
  SynEditDAO.Lines.Add('    end;');
  SynEditDAO.Lines.Add('    if Result then');
  SynEditDAO.Lines.Add('      Break;');
  SynEditDAO.Lines.Add('  end;');
  SynEditDAO.Lines.Add('end;');
  SynEditDAO.Lines.Add('');
end;

procedure TFrmModel.GeneratorCodeProcDelete;
var
  SQL: TStringList;
  S: string;
  J, IdSpace, IdSpaceAux: integer;
  StrFunctionName: string;
begin
  if InfoCrud.ProcDelete.Enable then
  begin
    SynEditDAO.Lines.Add(ident + '');
    StrFunctionName := 'class function ' + ClassNameDAO + '.' +
      InfoCrud.ProcDelete.ProcName + '(';
    if StrFunctionName <> 'class function ' + ClassNameDAO + '.' +
      InfoCrud.ProcDelete.ProcName + '(' then
      StrFunctionName := StrFunctionName + ';' + InfoCrud.Connection
    else
      StrFunctionName := StrFunctionName + InfoCrud.Connection;

    if StrFunctionName <> 'class function ' + ClassNameDAO + '.' +
      InfoCrud.ProcDelete.ProcName + '(' then
      StrFunctionName := StrFunctionName + ';' + WithVar(VarModel) +
        ': ' + ClassNameModel
    else
      StrFunctionName := StrFunctionName + WithVar(VarModel) + ': ' + ClassNameModel;

    if (StrFunctionName <> 'class function ' + ClassNameDAO +
      '.' + InfoCrud.ProcDelete.ProcName + '(') and (InfoCrud.HasReturnException) then
      StrFunctionName := StrFunctionName + ';' + WithVar(InfoCrud.ReturnException)
    else
      StrFunctionName := StrFunctionName + WithVar(InfoCrud.ReturnException);

    SynEditDAO.Lines.Add(StrFunctionName + '):Boolean;');

    SynEditDAO.Lines.Add('var');
    SynEditDAO.Lines.Add(Ident + 'Qry: ' + InfoCrud.ClassSQL + ';');
    SynEditDAO.Lines.Add(Ident + 'StrAux: String;');
    {$REGION 'Variaveis RTTI'}
    SynEditDAO.Lines.Add(Ident + '{$Region ' + QuotedStr('Variaveis RTTI NewValue') + '}');
    SynEditDAO.Lines.Add(Ident + 'CtxRtti     : TRttiContext;');
    SynEditDAO.Lines.Add(Ident + 'TpRtti      : TRttiType;');
    SynEditDAO.Lines.Add(Ident + 'PropRtti    : TRttiProperty;');
    SynEditDAO.Lines.Add(Ident + 'PropNameRtti: String;');
    SynEditDAO.Lines.Add(Ident + '{$ENDREGION}');
    {$EndRegion}

    SynEditDAO.Lines.Add('begin');
    WriteCreateSQL;
    SynEditDAO.Lines.Add(Ident + Ident + 'try');

    SQL := GenerateSqlQuery(qtDelete);

    SynEditDAO.Lines.Add('');
    SynEditDAO.Lines.Add(StringOfChar(' ', 6) + '{$REGION ''Comando SQL''}');
    GenerateSqlQueryDeleteRecord;
    SynEditDAO.Lines.Add(StringOfChar(' ', 6) + '{$ENDREGION}');
    SynEditDAO.Lines.Add('');

    //Pega a maior sequencia de caracteres existente nos parametros, para alinhar a codificacao
    IdSpace := 0;
    IdSpaceAux := 0;

    SynEditDAO.Lines.Add(Ident + Ident + Ident +
      '{$Region ' + QuotedStr('RTTI - Atribui valores para os Paramentros caso necessario ') + '}');
    SynEditDAO.Lines.Add(Ident + Ident + Ident +
      'for PropRtti in TpRtti.GetProperties do');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + 'begin');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'PropNameRtti := PropRtti.Name;');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'if '+ClassNameDAO+'.IsPrimaryKey(PropNameRtti,'+VarModel+') then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'begin');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'if (PropRtti.PropertyType.TypeKind in [tkUString, tkString, tkChar, tkInteger]) then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'begin');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + 'Qry.ParamByName(PropNameRtti).Value := propRtti.GetValue(' + VarModel + ').AsVariant');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'end');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'else if (propRtti.PropertyType.TypeKind in [tkFloat]) then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'begin');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident +'if (CompareText(''TDateTime'', propRtti.PropertyType.Name) = 0 ) or');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident +'   (CompareText(''TDate'', propRtti.PropertyType.Name) = 0) or');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident +'   (CompareText(''TTime'', propRtti.PropertyType.Name) = 0) then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'Qry.ParamByName(PropNameRtti).AsDateTime := propRtti.GetValue(' + VarModel + ').AsExtended');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + 'else');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'Qry.ParamByName(PropNameRtti).AsFloat := propRtti.GetValue(' + VarModel + ').AsExtended');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'end;');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'end;');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + 'end;');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + '{$EndRegion}');

    SynEditDAO.Lines.Add(Ident + Ident + Ident + 'Qry.' + InfoCrud.SQLCommand + ';');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + 'Result := True;');
    SynEditDAO.Lines.Add(Ident + Ident + 'except');
    for J := 0 to InfoCrud.ExceptionCode.Count - 1 do
    begin
      S := StringReplace(InfoCrud.ExceptionCode.Strings[J], '$UnitName',
        UnitNameDAO, [rfReplaceAll]);
      S := StringReplace(S, '$ProcName', InfoCrud.ProcDelete.ProcName, [rfReplaceAll]);
      SynEditDAO.Lines.Add(Ident + Ident + Ident + S);
    end;
    SynEditDAO.Lines.Add(Ident + Ident + 'end;');
    SynEditDAO.Lines.Add(Ident + 'finally');
    WriteDestroyQuery;
    SynEditDAO.Lines.Add(Ident + 'end;');

    SynEditDAO.Lines.Add('end;');
  end;
end;

procedure TFrmModel.GeneratorCodeProcGetItem;
var
  SQL: TStringList;
  S: string;
  J, IdSpace, IdSpaceAux: integer;
  StrFunctionName: string;
begin
  if InfoCrud.ProcGetRecord.Enable then
  begin
    SynEditDAO.Lines.Add(ident + '');
    StrFunctionName := 'class function ' + ClassNameDAO + '.' +
      InfoCrud.ProcGetRecord.ProcName + '(';

    if StrFunctionName <> 'class function ' + ClassNameDAO + '.' +
      InfoCrud.ProcGetRecord.ProcName + '(' then
      StrFunctionName := StrFunctionName + ';' + InfoCrud.Connection
    else
      StrFunctionName := StrFunctionName + InfoCrud.Connection;

    if StrFunctionName <> 'class function ' + ClassNameDAO + '.' +
      InfoCrud.ProcGetRecord.ProcName + '(' then
      StrFunctionName := StrFunctionName + ';' + WithVar(VarModel) +
        ': ' + ClassNameModel
    else
      StrFunctionName := StrFunctionName + WithVar(VarModel) + ': ' + ClassNameModel;

    if (StrFunctionName <> 'class function ' + ClassNameDAO + '.' +
      InfoCrud.ProcGetRecord.ProcName + '(') and (InfoCrud.HasReturnException) then
      StrFunctionName := StrFunctionName + ';' + WithVar(InfoCrud.ReturnException)
    else
      StrFunctionName := StrFunctionName + WithVar(InfoCrud.ReturnException);

    SynEditDAO.Lines.Add(StrFunctionName + '):Boolean;');

    SynEditDAO.Lines.Add('var');
    SynEditDAO.Lines.Add(Ident + 'Qry: ' + InfoCrud.ClassQuery + ';');
    SynEditDAO.Lines.Add(Ident + 'StrAux: String;');
    {$REGION 'Variaveis RTTI'}
    SynEditDAO.Lines.Add(Ident + '{$Region ' + QuotedStr('Variaveis RTTI NewValue') + '}');
    SynEditDAO.Lines.Add(Ident + 'CtxRtti     : TRttiContext;');
    SynEditDAO.Lines.Add(Ident + 'TpRtti      : TRttiType;');
    SynEditDAO.Lines.Add(Ident + 'PropRtti    : TRttiProperty;');
    SynEditDAO.Lines.Add(Ident + 'PropNameRtti: String;');
    SynEditDAO.Lines.Add(Ident + '{$ENDREGION}');
    {$EndRegion}

    SynEditDAO.Lines.Add('begin');
    WriteCreateQuery;
    SynEditDAO.Lines.Add(Ident + Ident + 'try');

    SynEditDAO.Lines.Add(Ident + Ident + Ident + '{$REGION ''Comando SQL''}');
    GenerateSqlQueryGetRecord;
    SynEditDAO.Lines.Add(Ident + Ident + Ident + '{$ENDREGION}');


    SynEditDAO.Lines.Add(Ident + Ident + Ident + '{$Region ' + QuotedStr('RTTI - Atribui valores para os Paramentros caso necessario ') + '}');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + 'CtxRtti  := TRttiContext.Create;');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + 'TpRtti   := CtxRtti.GetType(' + VarModel + '.ClassType);');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + 'for PropRtti in TpRtti.GetProperties do');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + 'begin');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident +'PropNameRtti := PropRtti.Name;');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'if '+ClassNameDAO+'.IsPrimaryKey(PropNameRtti,'+VarModel+') then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'begin');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'if (PropRtti.PropertyType.TypeKind in [tkUString, tkString, tkChar, tkInteger]) then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'begin');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + 'Qry.ParamByName(PropNameRtti).Value := propRtti.GetValue(' + VarModel + ').AsVariant');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'end');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'else if (propRtti.PropertyType.TypeKind in [tkFloat]) then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'begin');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident +'if (CompareText(''TDateTime'', propRtti.PropertyType.Name) = 0 ) or');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident +'   (CompareText(''TDate'', propRtti.PropertyType.Name) = 0) or');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident +'   (CompareText(''TTime'', propRtti.PropertyType.Name) = 0) then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'Qry.ParamByName(PropNameRtti).AsDateTime := propRtti.GetValue(' + VarModel + ').AsExtended');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + 'else');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'Qry.ParamByName(PropNameRtti).AsFloat := propRtti.GetValue(' + VarModel + ').AsExtended');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'end;');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'end;');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + 'end;');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + '{$EndRegion}');

    SynEditDAO.Lines.Add(Ident + Ident + Ident + 'Qry.' + InfoCrud.QueryCommand + ';');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + 'if not Qry.isEmpty then ');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + 'begin');

    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'for PropRtti in TpRtti.GetProperties do');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'begin');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'PropNameRtti := PropRtti.Name;');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'if not IsFieldReadOnly(PropNameRtti, '+VarModel+') then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident +'if (CompareText(''TDateTime'', propRtti.PropertyType.Name) = 0 ) or');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident +'   (CompareText(''TDate'', propRtti.PropertyType.Name) = 0) or');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident +'   (CompareText(''TTime'', propRtti.PropertyType.Name) = 0) then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident +'PropRtti.SetValue('+VarModel+', TValue.From(Qry.FieldByName(PropNameRTTI).AsDateTime))');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'else');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + 'if (CompareText(''String'', propRtti.PropertyType.Name) = 0 ) then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'PropRtti.SetValue('+VarModel+', TValue.From(Qry.FieldByName(PropNameRTTI).AsString))');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + 'else if (CompareText(''Integer'', propRtti.PropertyType.Name) = 0 ) or ');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + '        (CompareText(''Smallint'', propRtti.PropertyType.Name) = 0 ) then ');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'PropRtti.SetValue('+VarModel+', TValue.From(Qry.FieldByName(PropNameRTTI).AsInteger))');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + 'else');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'PropRtti.SetValue('+VarModel+', TValue.From(Qry.FieldByName(PropNameRTTI).Value));');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'end;');

    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + VarModel + '.Original := ' +
      ClassNameModel + '.Create(' + VarModel + ');');

    SynEditDAO.Lines.Add(Ident + Ident + Ident + 'end;');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + 'Result := True;');
    SynEditDAO.Lines.Add(Ident + Ident + 'except');
    for J := 0 to InfoCrud.ExceptionCode.Count - 1 do
    begin
      S := StringReplace(InfoCrud.ExceptionCode.Strings[J], '$UnitName',
        UnitNameDAO, [rfReplaceAll]);
      S := StringReplace(S, '$ProcName', InfoCrud.ProcGetRecord.ProcName,
        [rfReplaceAll]);
      SynEditDAO.Lines.Add(Ident + Ident + Ident + S);
    end;
    SynEditDAO.Lines.Add(Ident + Ident + 'end;');
    SynEditDAO.Lines.Add(Ident + 'Finally');
    WriteDestroyQuery;
    SynEditDAO.Lines.Add(Ident + 'end;');

    SynEditDAO.Lines.Add('end;');
  end;
end;

procedure TFrmModel.GeneratorCodeProcList;
var
  SQL: TStringList;
  S: string;
  J, IdSpaceAux, IdSpace: integer;
  StrFunctionName: string;
  ConnectionStr, ReturnExceptionStr: string;
begin
  if InfoCrud.ProcListRecords.Enable then
  begin
    SynEditDAO.Lines.Add(ident + '');

    StrFunctionName := 'class function ' + ClassNameDAO + '.' +
      InfoCrud.ProcListRecords.ProcName + '(';
    if StrFunctionName <> 'class function ' + ClassNameDAO + '.' +
      InfoCrud.ProcListRecords.ProcName + '(' then
      StrFunctionName := StrFunctionName + ';' + InfoCrud.Connection
    else
      StrFunctionName := StrFunctionName + InfoCrud.Connection;

    if StrFunctionName <> 'class function ' + ClassNameDAO + '.' +
      InfoCrud.ProcListRecords.ProcName + '(' then
      StrFunctionName := StrFunctionName + '; out ObjLst: TObjectList; ' +
        'WhereSQL: String'
    else
      StrFunctionName := StrFunctionName + ' out ObjLst: TObjectList; ' +
        'WhereSQL: String';

    if (StrFunctionName <> 'class function ' + ClassNameDAO + '.' +
      InfoCrud.ProcListRecords.ProcName + '(') and (InfoCrud.HasReturnException) then
      StrFunctionName := StrFunctionName + ';' + WithVar(InfoCrud.ReturnException)
    else
      StrFunctionName := StrFunctionName + WithVar(InfoCrud.ReturnException);

    SynEditDAO.Lines.Add(StrFunctionName + '):Boolean;');

    SynEditDAO.Lines.Add('var');
    SynEditDAO.Lines.Add(Ident + 'Qry: ' + InfoCrud.ClassQuery + ';');
    SynEditDAO.Lines.Add(Ident + VarModel + ':' + ClassNameModel + ';');
    SynEditDAO.Lines.Add(Ident + 'StrAux: String;');
    {$REGION 'Variaveis RTTI'}
    SynEditDAO.Lines.Add(Ident + '{$Region ' + QuotedStr('Variaveis RTTI NewValue') + '}');
    SynEditDAO.Lines.Add(Ident + 'CtxRtti     : TRttiContext;');
    SynEditDAO.Lines.Add(Ident + 'TpRtti      : TRttiType;');
    SynEditDAO.Lines.Add(Ident + 'PropRtti    : TRttiProperty;');
    SynEditDAO.Lines.Add(Ident + 'PropNameRtti: String;');
    SynEditDAO.Lines.Add(Ident + '{$ENDREGION}');
    {$EndRegion}
    SynEditDAO.Lines.Add('begin');
    WriteCreateQuery;
    SynEditDAO.Lines.Add(Ident + Ident + 'try');
    ConnectionStr := Trim(StringReplace(InfoCrud.Connection, 'var', '', [rfReplaceAll]));
    ReturnExceptionStr := Trim(StringReplace(InfoCrud.ReturnException,
      'var', '', [rfReplaceAll]));
    if Trim(InfoCrud.ReturnException) <> '' then
    Begin
      SynEditDAO.Lines.Add(Ident + Ident + Ident + 'if not Assigned('+VarModel+') then ');
      SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + VarModel +':= ' + ClassNameModel + '.Create(' + Copy(ConnectionStr, 1, Pos(':', ConnectionStr) - 1) +
        ', ' + Copy(ReturnExceptionStr, 1, Pos(':', ReturnExceptionStr) - 1) + ');')
    end
    else
    begin
      SynEditDAO.Lines.Add(Ident + Ident + Ident + 'if not Assigned('+VarModel+') then ');
      SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + VarModel +':= ' + ClassNameModel + '.Create(' + Copy(ConnectionStr, 1, Pos(':', ConnectionStr) - 1) + ');');
    end;

    SynEditDAO.Lines.Add(Ident + Ident + Ident + '{$REGION ''Comando SQL''}');
    GenerateSqlQueryListaRecords;
    SynEditDAO.Lines.Add(Ident + Ident + Ident + '{$ENDREGION}');

    if (InfoCrud.SelectDefault1.Field <> '') or
      (InfoCrud.SelectDefault2.Field <> '') or
      (InfoCrud.SelectDefault3.Field <> '') then
    begin
      SynEditDAO.Lines.Add(Ident + Ident + Ident + '{$Region ' + QuotedStr('RTTI - Atribui valores para os Paramentros caso necessario ') + '}');
      SynEditDAO.Lines.Add(Ident + Ident + Ident + 'CtxRtti  := TRttiContext.Create;');
      SynEditDAO.Lines.Add(Ident + Ident + Ident + 'TpRtti   := CtxRtti.GetType(' + VarModel + '.ClassType);');
      SynEditDAO.Lines.Add(Ident + Ident + Ident + 'for PropRtti in TpRtti.GetProperties do');
      SynEditDAO.Lines.Add(Ident + Ident + Ident + 'begin');
      SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident +'PropNameRtti := PropRtti.Name;');
      if (InfoCrud.SelectDefault1.Field <> '') then
      begin
        SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'if '+ClassNameDAO+'.IsPrimaryKey(PropNameRtti,'+VarModel+') and ');
        SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + '   (PropNameRtti = '+QuotedStr(InfoCrud.SelectDefault1.Field) +') then');
        SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'begin');
        SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'if (PropRtti.PropertyType.TypeKind in [tkUString, tkString, tkChar, tkInteger]) then');
        SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'begin');
        SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + 'Qry.ParamByName(PropNameRtti).Value := ' + InfoCrud.SelectDefault1.Value +';');
        SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'end');
        SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'else if (propRtti.PropertyType.TypeKind in [tkFloat]) then');
        SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'begin');
        SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + 'Qry.ParamByName(PropNameRtti).AsFloat := '+ InfoCrud.SelectDefault1.Value +';');
        SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'end;');
        SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'end;');
      end;
      if (InfoCrud.SelectDefault2.Field <> '') then
      begin
        SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'if '+ClassNameDAO+'.IsPrimaryKey(PropNameRtti,'+VarModel+') and ');
        SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + '   (PropNameRtti = '+QuotedStr(InfoCrud.SelectDefault2.Field) +') then');
        SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'begin');
        SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'if (PropRtti.PropertyType.TypeKind in [tkUString, tkString, tkChar, tkInteger]) then');
        SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'begin');
        SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + 'Qry.ParamByName(PropNameRtti).Value := ' + InfoCrud.SelectDefault2.Value +';');
        SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'end');
        SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'else if (propRtti.PropertyType.TypeKind in [tkFloat]) then');
        SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'begin');
        SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + 'Qry.ParamByName(PropNameRtti).AsFloat := '+ InfoCrud.SelectDefault2.Value +';');
        SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'end;');
        SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'end;');
      end;
      if (InfoCrud.SelectDefault3.Field <> '') then
      begin
        SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'if '+ClassNameDAO+'.IsPrimaryKey(PropNameRtti,'+VarModel+') and ');
        SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + '   (PropNameRtti = '+QuotedStr(InfoCrud.SelectDefault3.Field) +') then');
        SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'begin');
        SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'if (PropRtti.PropertyType.TypeKind in [tkUString, tkString, tkChar, tkInteger]) then');
        SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'begin');
        SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + 'Qry.ParamByName(PropNameRtti).Value := ' + InfoCrud.SelectDefault3.Value +';');
        SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'end');
        SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'else if (propRtti.PropertyType.TypeKind in [tkFloat]) then');
        SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'begin');
        SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + 'Qry.ParamByName(PropNameRtti).AsFloat := '+ InfoCrud.SelectDefault3.Value +';');
        SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'end;');
        SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'end;');
      end;
      SynEditDAO.Lines.Add(Ident + Ident + Ident + 'end;');
      SynEditDAO.Lines.Add(Ident + Ident + Ident + '{$EndRegion}');
    end;
    SynEditDAO.Lines.Add('');

    SynEditDAO.Lines.Add(Ident + Ident + Ident + 'if Trim(WhereSQL) <> ' +
      QuotedStr('') + ' then ');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'Qry.Sql.Add(WhereSQL);');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + 'Qry.' + InfoCrud.QueryCommand + ';');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + 'Qry.First;');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + 'While not Qry.Eof do ');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + 'begin');

    ConnectionStr := Trim(StringReplace(InfoCrud.Connection, 'var', '', [rfReplaceAll]));
    ReturnExceptionStr := Trim(StringReplace(InfoCrud.ReturnException,
      'var', '', [rfReplaceAll]));

    if Trim(InfoCrud.ReturnException) <> '' then
    Begin
     SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + VarModel +':= ' + ClassNameModel + '.Create(' + Copy(ConnectionStr, 1, Pos(':', ConnectionStr) - 1) +
        ', ' + Copy(ReturnExceptionStr, 1, Pos(':', ReturnExceptionStr) - 1) + ');')
    end
    else
    begin
      SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + VarModel +':= ' + ClassNameModel + '.Create(' + Copy(ConnectionStr, 1, Pos(':', ConnectionStr) - 1) + ');');
    end;

    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'for PropRtti in TpRtti.GetProperties do');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'begin');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'PropNameRtti := PropRtti.Name;');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + 'if not IsFieldReadOnly(PropNameRtti, '+VarModel+') then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + 'if (CompareText(''TDateTime'', propRtti.PropertyType.Name) = 0 ) or');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + '   (CompareText(''TDate'', propRtti.PropertyType.Name) = 0) or');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + '   (CompareText(''TTime'', propRtti.PropertyType.Name) = 0) then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident +'PropRtti.SetValue('+VarModel+', TValue.From(Qry.FieldByName(PropNameRTTI).AsDateTime))');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + 'else');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'if (CompareText(''String'', propRtti.PropertyType.Name) = 0 ) then');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'PropRtti.SetValue('+VarModel+', TValue.From(Qry.FieldByName(PropNameRTTI).AsString))');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'else if (CompareText(''Integer'', propRtti.PropertyType.Name) = 0 ) or');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + '        (CompareText(''Smallint'', propRtti.PropertyType.Name) = 0 ) then ');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'PropRtti.SetValue('+VarModel+', TValue.From(Qry.FieldByName(PropNameRTTI).AsInteger))');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'else');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + Ident + Ident + Ident + Ident + 'PropRtti.SetValue('+VarModel+', TValue.From(Qry.FieldByName(PropNameRTTI).Value));');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'end;');

    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + VarModel + '.Original := ' +
      ClassNameModel + '.Create(' + VarModel + ');');

    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'ObjLst.Add(' +
      VarModel + ');');


    SynEditDAO.Lines.Add(Ident + Ident + Ident + Ident + 'Qry.Next;');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + 'end;');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + 'Result := True;');
    SynEditDAO.Lines.Add(Ident + Ident + 'except');
    for J := 0 to InfoCrud.ExceptionCode.Count - 1 do
    begin
      S := StringReplace(InfoCrud.ExceptionCode.Strings[J], '$UnitName',
        UnitNameDAO, [rfReplaceAll]);
      S := StringReplace(S, '$ProcName', InfoCrud.ProcListRecords.ProcName,
        [rfReplaceAll]);
      SynEditDAO.Lines.Add(Ident + Ident + Ident + S);
    end;
    SynEditDAO.Lines.Add(Ident + Ident + 'end;');
    SynEditDAO.Lines.Add(Ident + 'finally');
    WriteDestroyQuery;
    SynEditDAO.Lines.Add(Ident + 'end;');
    SynEditDAO.Lines.Add('end;');
  end;
end;

function TFrmModel.Limpa(S: string): string;
var
  A: string;
  P: integer;
begin
  A := StringReplace(UpperCase(S), 'VAR', '', [rfReplaceAll]);
  Result := Trim(A);
end;

function TFrmModel.FieldExist(FieldsKey: TStringList; Field: string): boolean;
var
  Idx: integer;
begin
  idx := FieldsKey.IndexOf(Field);
  Result := Idx > -1;
end;

procedure TFrmModel.GenerateLazy;
var
  IK: integer;
  J, K: integer;
  Aux, LazyAnt: string;
  MaxField, MaxType, MaxVar: integer;
  MaxVarAux, MaxVarFunction: integer;
  StrFunctionNameGet: string;
  InfoTableAux: TAsTableInfo;
  FieldsKeys, FieldsKeysAux: TStringList;
  ConnectionStr, ReturnExceptionStr: String;

  procedure LoadPrimaryKey(ConstraintName: string);
  var
    PK: integer;
    FF: string;
  begin
    if Assigned(FieldsKeys) then
      FreeAndNil(FieldsKeys);
    FieldsKeys := TStringList.Create;
    FieldsKeys.Clear;
    //for downto devido ao laz trazer os fields fora de ordem
    for PK := 0 to InfoTable.ImportedKeys.Count - 1 do
    begin
      if ConstraintName = InfoTable.ImportedKeys[PK].ConstraintName then
      begin
        FF := InfoTable.ImportedKeys[pk].ColumnName;
        if FieldsKeys.IndexOf(FF) = -1 then
          FieldsKeys.Add(FF);
      end;
    end;
  end;

  procedure LoadPrimaryKeyAux;
  var
    PK: integer;
  begin
    if Assigned(FieldsKeysAux) then
      FreeAndNil(FieldsKeysAux);
    FieldsKeysAux := TStringList.Create;
    FieldsKeysAux.Clear;
    for PK := 0 to InfoTableAux.PrimaryKeys.Count - 1 do
      FieldsKeysAux.Add(InfoTableAux.PrimaryKeys[pk].FieldName);
  end;

begin
  FieldsKeysAux := nil;
  FieldsKeys := nil;
  MmLazyCodeFunctions.Clear;
  if InfoTable.ImportedKeys.Count > 0 then
  begin
    MmLazyCodeFunctions.Add('//Metodos Get Lazy');
    for IK := 0 to InfoTable.ImportedKeys.Count - 1 do
    begin
      Application.ProcessMessages;
      if LazyAnt <> InfoTable.ImportedKeys[IK].ConstraintName then
      begin
        LoadPrimaryKey(InfoTable.ImportedKeys[IK].ConstraintName);
        InfoTableAux := TablesInfos.LoadTable(SchemaText,
          InfoTable.ImportedKeys[IK].ForeignTableName, False);
        try
          LoadPrimaryKeyAux;
          LazyAnt := InfoTable.ImportedKeys[IK].ConstraintName;
          Aux := Copy(LazyAnt, Length(LazyAnt), 1);
          try
            StrToInt(Aux); //Devido a poder ter mais de uma FK com a mesma tabela
          except
            Aux := '';
          end;
          Application.ProcessMessages;
          {$Region 'Metodos Get Lazy'}

          MaxVarFunction := 0;
          MaxVarAux := 0;
          for K := 0 to FieldsKeysAux.Count - 1 do
          begin
            Application.ProcessMessages;
            if MaxVarAux < (Length('(F' + Copy(InfoTableAux.Tablename,
              InfoCrud.CopyTableName, Length(InfoTableAux.Tablename)) + '.' +
              FieldsKeysAux[k]) + 1) then
              MaxVarAux := (Length('F''(F' + Copy(InfoTableAux.Tablename,
                InfoCrud.CopyTableName, Length(InfoTableAux.Tablename)) + '.' +
                FieldsKeysAux[k]) + 1);

            if MaxVar < (Length('Self.' + FieldsKeysAux[k]) + 1) then
              MaxVar := (Length('Self.' + FieldsKeysAux[k]) + 1);
          end;
          MmLazyCodeFunctions.Add('function ' + ClassNameModel + '.' +
            'Get' + Copy(InfoTableAux.Tablename, InfoCrud.CopyTableName,
            Length(InfoTableAux.Tablename)) + Aux + ': ' + 'T' + Copy(
            InfoTableAux.Tablename, InfoCrud.CopyTableName, Length(InfoTableAux.Tablename)) + ';');
          MmLazyCodeFunctions.Add('begin');
          MmLazyCodeFunctions.Add(Ident + 'if not Assigned(F' + Copy(
            InfoTableAux.Tablename, InfoCrud.CopyTableName, Length(InfoTableAux.Tablename)) +
            Aux + ') or ');
          MmLazyCodeFunctions.Add(Ident + Ident + '( ');
          for J := 0 to FieldsKeysAux.Count - 1 do
          begin
            Application.ProcessMessages;
            if FieldExist(FieldsKeys, FieldsKeysAux[J] + Aux) then
            begin
              Application.ProcessMessages;
              if (FieldsKeysAux.Count = 1) or (J = FieldsKeysAux.Count - 1) then
                MmLazyCodeFunctions.Add(Ident + Ident +
                  Ident + '(F' + Copy(InfoTableAux.Tablename, InfoCrud.CopyTableName,
                  Length(InfoTableAux.Tablename)) + Aux + '.' + FieldsKeysAux[J] +
                  ' <> ' + 'Self.' + FieldsKeys[J] + Aux + ') ')
              else
                MmLazyCodeFunctions.Add(Ident + Ident +
                  Ident + '(F' + Copy(InfoTableAux.Tablename, InfoCrud.CopyTableName,
                  Length(InfoTableAux.Tablename)) + Aux + '.' + FieldsKeysAux[J] +
                  ' <> ' + 'Self.' + FieldsKeys[J] + Aux + ') or ');
            end
            else
            begin
              Application.ProcessMessages;
              if (FieldsKeysAux.Count = 1) or (J = FieldsKeysAux.Count - 1) then
                MmLazyCodeFunctions.Add(Ident + Ident +
                  Ident + '(F' + Copy(InfoTableAux.Tablename, InfoCrud.CopyTableName,
                  Length(InfoTableAux.Tablename)) + Aux + '.' + FieldsKeysAux[J] +
                  ' <> ' + 'Self.' + FieldsKeys[J] + ') ')
              else
                MmLazyCodeFunctions.Add(Ident + Ident +
                  Ident + '(F' + Copy(InfoTableAux.Tablename, InfoCrud.CopyTableName,
                  Length(InfoTableAux.Tablename)) + Aux + '.' + FieldsKeysAux[J] +
                  ' <> ' + 'Self.' + FieldsKeys[J] + ') or ');
            end;
          end;
          Application.ProcessMessages;
          MmLazyCodeFunctions.Add(Ident + Ident + ') then ');
          MmLazyCodeFunctions.Add(Ident + Ident + 'begin');
          ConnectionStr := Trim(StringReplace(InfoCrud.Connection, 'var', '', [rfReplaceAll]));
          ReturnExceptionStr := Trim(StringReplace(InfoCrud.ReturnException,
            'var', '', [rfReplaceAll]));
          if Trim(InfoCrud.ReturnException) <> '' then
          Begin
            MmLazyCodeFunctions.Add(Ident + Ident + Ident + 'if not Assigned('+'F' + Copy(InfoTableAux.Tablename,InfoCrud.CopyTableName, Length(InfoTableAux.Tablename))+') then ');
            MmLazyCodeFunctions.Add(Ident + Ident + Ident + Ident + 'F' + Copy(InfoTableAux.Tablename,
                InfoCrud.CopyTableName, Length(InfoTableAux.Tablename)) +':= ' + 'T' + Copy(InfoTableAux.Tablename,
                InfoCrud.CopyTableName, Length(InfoTableAux.Tablename)) + '.Create(F' + Copy(ConnectionStr, 1, Pos(':', ConnectionStr) - 1) +
              ', ' + Copy(ReturnExceptionStr, 1, Pos(':', ReturnExceptionStr) - 1) + ');')
          end
          else
          begin
            MmLazyCodeFunctions.Add(Ident + Ident + Ident + 'if not Assigned('+'F' + Copy(InfoTableAux.Tablename,
                InfoCrud.CopyTableName, Length(InfoTableAux.Tablename))+') then ');
            MmLazyCodeFunctions.Add(Ident + Ident + Ident + Ident + 'F' + Copy(InfoTableAux.Tablename,
                InfoCrud.CopyTableName, Length(InfoTableAux.Tablename)) +':= ' + 'T' + Copy(InfoTableAux.Tablename,
                InfoCrud.CopyTableName, Length(InfoTableAux.Tablename)) + '.Create(F' + Copy(ConnectionStr, 1, Pos(':', ConnectionStr) - 1) + ');');
          end;

          for J := 0 to FieldsKeysAux.Count - 1 do
          begin
            Application.ProcessMessages;
            if FieldExist(FieldsKeys, FieldsKeysAux[J] + Aux) then
            begin
              StrFunctionNameGet :=
                Ident + Ident + Ident + LPad('F' + Copy(InfoTableAux.Tablename,
                InfoCrud.CopyTableName, Length(InfoTableAux.Tablename)) + AUX +
                '.' + FieldsKeysAux[J], ' ', MaxVarAux) + ' := ' +
                Trim('Self.' + FieldsKeys[J] + AUX) + ';';
              MmLazyCodeFunctions.Add(StrFunctionNameGet);
            end
            else
            begin
              StrFunctionNameGet :=
                Ident + Ident + Ident + LPad('F' + Copy(InfoTableAux.Tablename,
                InfoCrud.CopyTableName, Length(InfoTableAux.Tablename)) + AUX +
                '.' + FieldsKeysAux[J], ' ', MaxVarAux) + ' := ' +
                Trim('Self.' + FieldsKeys[J]) + ';';
              MmLazyCodeFunctions.Add(StrFunctionNameGet);
            end;
          end;
          Application.ProcessMessages;
          //Gera Chamada do Get da Classe
          StrFunctionNameGet := '';
          StrFunctionNameGet :=
            Ident + Ident + Ident + 'F' + Copy(InfoTableAux.Tablename, InfoCrud.CopyTableName,
            Length(InfoTableAux.Tablename)) + Aux + '.' +
            InfoCrud.ProcGetRecord.ProcName + '(';

          if (StrFunctionNameGet <> Ident + Ident + Ident +
            'F' + Copy(InfoTableAux.Tablename, InfoCrud.CopyTableName,
            Length(InfoTableAux.Tablename)) + Aux + '.' +
            InfoCrud.ProcGetRecord.ProcName + '(') and
            (Trim(Copy(InfoCrud.Connection, 1, Pos(':', InfoCrud.Connection) -
            1)) <> '') then
            StrFunctionNameGet :=
              StrFunctionNameGet + ', ' + 'F' + Limpa(Copy(InfoCrud.Connection,
              1, Pos(':', InfoCrud.Connection) - 1))
          else
            StrFunctionNameGet :=
              StrFunctionNameGet + 'F' + Limpa(Copy(InfoCrud.Connection,
              1, Pos(':', InfoCrud.Connection) - 1));

          if (StrFunctionNameGet <> Ident + Ident + Ident +
            'F' + Copy(InfoTableAux.Tablename, InfoCrud.CopyTableName,
            Length(InfoTableAux.Tablename)) + Aux + '.' +
            InfoCrud.ProcGetRecord.ProcName + '(') then
            StrFunctionNameGet :=
              StrFunctionNameGet + ', ' + 'F' + Copy(InfoTableAux.Tablename,
              InfoCrud.CopyTableName, Length(InfoTableAux.Tablename)) + Aux
          else
            StrFunctionNameGet :=
              StrFunctionNameGet + 'F' + Copy(InfoTableAux.Tablename, InfoCrud.CopyTableName,
              Length(InfoTableAux.Tablename)) + Aux;

          Application.ProcessMessages;
          if (StrFunctionNameGet <> (Ident + Ident + Ident +
            'F' + Copy(InfoTableAux.Tablename, InfoCrud.CopyTableName,
            Length(InfoTableAux.Tablename)) + Aux +
            '.' + InfoCrud.ProcGetRecord.ProcName + '(')) and
            (Trim(Copy(InfoCrud.ReturnException, 1,
            Pos(':', InfoCrud.ReturnException) - 1)) <> '') then
            StrFunctionNameGet :=
              StrFunctionNameGet + ', F' + Copy(InfoCrud.ReturnException, 1,
              Pos(':', InfoCrud.ReturnException) - 1)
          else
            StrFunctionNameGet :=
              StrFunctionNameGet + Copy(InfoCrud.ReturnException, 1,
              Pos(':', InfoCrud.ReturnException) - 1);
          Application.ProcessMessages;
          StrFunctionNameGet := StrFunctionNameGet + ');';
          MmLazyCodeFunctions.Add(StrFunctionNameGet);
          MmLazyCodeFunctions.Add(Ident + Ident + 'end;');
          MmLazyCodeFunctions.Add(Ident + Ident +
            'Result  := F' + Copy(InfoTableAux.Tablename, InfoCrud.CopyTableName,
            Length(InfoTableAux.Tablename)) + Aux);
          MmLazyCodeFunctions.Add('end;');
          MmLazyCodeFunctions.Add(Ident + Ident + '');
         {$EndRegion}
          Application.ProcessMessages;

        finally
          InfoTableAux.Destroy;
        end;
      end;
    end;
  end;
  Application.ProcessMessages;
end;

end.
