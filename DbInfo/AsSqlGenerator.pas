{*******************************************************************
AUTHOR : Flakron Shkodra
*******************************************************************
Date Modified:  18/06/2013 (added qtAll queryType)
*******************************************************************
Date Modified : 18/05/2010 14:10:31
*******************************************************************
}


unit AsSqlGenerator;

{$mode objfpc}{$H+}
interface

uses SysUtils, Classes, Dialogs, StdCtrls, ComCtrls, ExtCtrls, DB,
  Forms, StrUtils, AsTableInfo, AsDbType, LazSqlXResources;


type
  TPCreateScript = (csTable, csPrimaryKey, csForeingKey);

  TQueryType =
    (
    qtSelect = 0,
    qtSelectItem = 1,
    qtInsert = 2,
    qtUpdate = 3,
    qtDelete = 4,
    qtAll = 5
    );

  TQueryTypes = set of TQueryType;

  { TAsSqlGenerator }
TAsProcedureNames = object
 public
   PnSelect:string;
   PnSelectItem:string;
   PnInsert:string;
   PnUpdate:string;
   PnDelete:string;
   Prefix:string;
   TablenameAfter:Boolean;
 end;

  TAsSqlGenerator = class
  strict private
    FprocNames: TAsProcedureNames;
    FSchema: string;
    FlstExistingProcedures: TStringList;
    FspPrefix: string;
    FDBConInfo:TAsDbConnectionInfo;
    FAsQuery:TAsQuery;
    procedure CheckProcedureName(Tablename: string);
    procedure DropProcedure(spName: string);
    {Used in GetCreateSql}
    function GetDataType(FieldInfo: TAsFieldInfo; AsDbType: TAsDatabaseType): string;
    function GetPrimaryKeyName(Table: String): String;

    procedure WriteLog(Msg: string);
    procedure _cmdBeforeOpen(DataSet: TDataSet);
    procedure _DataSetGetText(Sender: TField; var aText: string;
      DisplayText: boolean);

    function GetDbParamPrefix: string;

    function SafeWrap(TableOrField:string):string;

    function GetSql(Ident: integer; AsTableInfo: TAsTableInfo;
      QueryType: TQueryType): TStringList;
  public
    constructor Create(DbConInfo:TAsDbConnectionInfo);overload;
    constructor Create(DbConInfo:TAsDbConnectionInfo;ProcedureNames: TAsProcedureNames); overload;
    destructor Destroy;override;
    procedure Generate(Tables: TAsTableInfos; QueryTypes: TQueryTypes;
      Prefix: string = 'usp'); overload;
    procedure Generate(AsTableInfo: TAsTableInfo; QueryTypes: TQueryTypes;
      Prefix: string = 'usp'); overload;
    function GenerateStoredProcedure(AsTableInfo: TAsTableInfo;
     QueryType: TQueryType): TStringList;
    {Used in Generate procedures and functions}
    function GetCreateSql(AsTableInfo: TAsTableInfo; QueryType: TQueryType;
      SqlSpKeyword: string = 'CREATE '): TStringList;

    function GenerateQuery(Ident: integer; AsTableInfo: TAsTableInfo;
      QueryType: TQueryType): TStringList;

    function GetCreateScript(DBInfo: TAsDbConnectionInfo; Info: TAsTableInfo; TypeCreate: TPCreateScript): TStringList;

  end;

implementation

uses AsStringUtils;
const
  LoopSeperator: array [0 .. 1] of char = (' ', ',');
{ TAsSqlGenerator }

{$REGION 'Constructor/Destructor'}

constructor TAsSqlGenerator.Create(DbConInfo: TAsDbConnectionInfo;
 ProcedureNames: TAsProcedureNames);
var
  s: string;
  i: integer;
begin

  FprocNames := ProcedureNames;
  FDBConInfo := DbConInfo;
  if FDBConInfo.DbType = dtOracle then
  begin
    FspPrefix := UpperCase(FspPrefix);
    FprocNames.PnSelect := UpperCase(FprocNames.PnSelect);
    FprocNames.PnSelectItem := UpperCase(FprocNames.PnSelectItem);
    FprocNames.PnInsert := UpperCase(FprocNames.PnInsert);
    FprocNames.PnUpdate := UpperCase(FprocNames.PnUpdate);
    FprocNames.PnDelete := UpperCase(FprocNames.PnDelete);
    FprocNames.Prefix := UpperCase(FprocNames.Prefix);
  end;
  FAsQuery := TAsQuery.Create(DbConInfo);
  FlstExistingProcedures := TAsDbUtils.GetProcedureNames(FDBConInfo);

end;

destructor TAsSqlGenerator.Destroy;
begin
  FAsQuery.Free;
  FlstExistingProcedures.Free;

end;

procedure TAsSqlGenerator.DropProcedure(spName: string);
begin
  try
    case FDBConInfo.DbType of
      dtMsSql: FAsQuery.SQL.Text := ' drop procedure ' + spName;
      dtMySql: FAsQuery.SQL.Text := ' drop procedure ' + spName;
      dtOracle: FAsQuery.SQL.Text := ' drop procedure ' + spName;
    end;
    FAsQuery.ExecSQL;
  except
  end;

end;

{$ENDREGION}

{$REGION 'Public Methods'}


procedure TAsSqlGenerator.Generate(AsTableInfo: TAsTableInfo; QueryTypes: TQueryTypes;
  Prefix: string);
var
  tmpLst: TStringList;
  lstStoredProcs: TStringList;
begin


  FspPrefix := UpperCase(Prefix);

  lstStoredProcs := TAsDbUtils.GetProcedureNames(FDBConInfo);


  WriteLog('===============STORED PROCEDURE GENERATION BEGIN===============');



  FSchema := AsTableInfo.Schema;

  WriteLog('*************Processing [' + AsTableInfo.Tablename + ']*************');

  //checks if sp Names are identical with those to be generated
  //if so, existing procedures will be dropped
  CheckProcedureName(AsTableInfo.Tablename);

  if qtSelect in QueryTypes then
  begin
    try
      tmpLst := GetCreateSql(AsTableInfo, qtSelect);

      FAsQuery.SQL.Text := tmpLst.Text;
      FAsQuery.ExecSQL;
    except
      on e: Exception do
      begin
        WriteLog('Select for [' + AsTableInfo.Tablename + '] : ' + e.Message);
      end;
    end;
    tmpLst.Free;
  end;

  if qtSelectItem in QueryTypes then
  begin
    try
      tmpLst := GetCreateSql(AsTableInfo, qtSelectItem);
      FAsQuery.SQL.Text := tmpLst.Text;
      FAsQuery.ExecSQL;
    except
      on e: Exception do
      begin
        WriteLog('SelectItem for [' + AsTableInfo.Tablename + '] : ' + e.Message);
      end;
    end;
    tmpLst.Free;
  end;

  if qtInsert in QueryTypes then
  begin
    try
      tmpLst := GetCreateSql(AsTableInfo, qtInsert);
      FAsQuery.SQL.Text := tmpLst.Text;
      FAsQuery.ExecSQL;
    except
      on e: Exception do
      begin
        WriteLog('Insert for [' + AsTableInfo.Tablename + '] : ' + e.Message);
      end;
    end;
    tmpLst.Free;
  end;

  if qtUpdate in QueryTypes then
  begin
    try
      tmpLst := GetCreateSql(AsTableInfo, qtUpdate);
      FAsQuery.SQL.Text := tmpLst.Text;
      FAsQuery.ExecSQL;
    except
      on e: Exception do
      begin
        WriteLog('Update for [' + AsTableInfo.Tablename + '] : ' + e.Message);
      end;
    end;
    tmpLst.Free;
  end;

  if qtDelete in QueryTypes then
  begin
    try
      tmpLst := GetCreateSql(AsTableInfo, qtDelete);
      FAsQuery.SQL.Text := tmpLst.Text;
      FAsQuery.ExecSQL;
    except
      on e: Exception do
      begin
        WriteLog('Delete for [' + AsTableInfo.Tablename + '] : ' + e.Message);
      end;
    end;
    tmpLst.Free;
  end;

  lstStoredProcs.Free;
  WriteLog('===========STORED PROCEDURE GENERATION END===========');
end;

function TAsSqlGenerator.GenerateStoredProcedure(AsTableInfo: TAsTableInfo;
  QueryType: TQueryType): TStringList;
var
  lstAll: TStringList;
  lst: TStringList;
  spCreateWord:string;
begin
  lstAll := TStringList.Create;
    case FDBConInfo.DbType of
     dtMsSql,dtMySql,dtFirebirdd: spCreateWord:=' CREATE ';
     dtOracle,dtPostgreSql:spCreateWord := ' CREATE OR REPLACE ';
    end;

    if QueryType = qtAll then
    begin
      lst := GetCreateSql(AsTableInfo, qtSelect,spCreateWord);
      lstAll.AddStrings(lst);
      lst.Free;

      lst := GetCreateSql(AsTableInfo, qtSelectItem,spCreateWord);
      lstAll.AddStrings(lst);
      lst.Free;

      lst := GetCreateSql(AsTableInfo, qtInsert,spCreateWord);
      lstAll.AddStrings(lst);
      lst.Free;

      lst := GetCreateSql(AsTableInfo, qtUpdate,spCreateWord);
      lstAll.AddStrings(lst);
      lst.Free;

      lst := GetCreateSql(AsTableInfo, qtDelete,spCreateWord);
      lstAll.AddStrings(lst);
      lst.Free;
    end
    else
    begin
      lst := GetCreateSql(AsTableInfo, QueryType,spCreateWord);
      lstAll.AddStrings(lst);
      lst.Free;
    end;


    Result := lstAll;

end;

function TAsSqlGenerator.GetSql(Ident: integer; AsTableInfo: TAsTableInfo;
  QueryType: TQueryType): TStringList;
var
  seperator, tmpFTablename, tmpTablename: string;
  SqlParamChar, SqlTable,SqlFromDot,SqlDot: string;
  I, oIndex: integer;
  tmpSelect, tmpSelectInsert, tmpInsert, tmpUpdate, tmpUpdateAll,
  tmpSelectJoins: TStringList;
  r: TStringList;
  field: TField;
  selectTablename, selectFieldname:string;
  strTest, strIdent: string;
  F: Integer;
  fieldName: String;
  localColumn: String;
  foreignColumn: String;
begin

  FSchema := AsTableInfo.Schema;

  if FDBConInfo.DbType=dtFirebirdd then
  begin
    FSchema:='';
  end;

  for I := 0 to Ident - 1 do
  begin
    strIdent := strIdent + #9;
  end;

  SqlFromDot := '.';
  SqlTable := AsTableInfo.Tablename;
  SqlDot := '.';
  SqlParamChar := ':';

  if FDBConInfo.DbType= dtFirebirdd then
  begin
    FSchema:='';
  end;

  if Trim(AsTableInfo.TableAlias)=EmptyStr then
    AsTableInfo.TableAlias:=AsTableInfo.Tablename[1];


  if (AsTableInfo.PrimaryKeys.Count = 0) and not (QueryType in [qtSelect, qtInsert]) then
    raise Exception.Create('No primary keys found!');

  r := TStringList.Create;


  tmpSelect := TStringList.Create;
  tmpInsert := TStringList.Create;
  tmpUpdate := TStringList.Create;
  tmpUpdateAll := TStringList.Create;
  tmpSelectJoins := TStringList.Create;
  tmpSelectInsert := TStringList.Create;

  for I := 0 to AsTableInfo.AllFields.Count - 1 do
  begin
    fieldName := SafeWrap(AsTableInfo.AllFields[I].FieldName);

    if I < (AsTableInfo.AllFields.Count - 1) then
      seperator := ','
    else
      seperator := '';

    if (I + 1) = AsTableInfo.AllFields.Count - 1 then
      if (QueryType in [qtInsert]) then
        if AsTableInfo.AllFields[I + 1].IsIdentity then
          seperator := '';

    if AsTableInfo.AllFields[I].IsReference then
    begin
      oIndex := AsTableInfo.ImportedKeys.GetIndex(fieldName);

      if Pos(SqlDot+fieldName,tmpSelect.Text) = 0 then
        tmpSelect.Add(strIdent + '    ' + AsTableInfo.Tablename + SqlDot + fieldName+ ',');

      if AsTableInfo.ImportedKeys[oIndex]<>nil then
      if AsTableInfo.ImportedKeys[oIndex].TableName<>'' then
      for F := 0 to AsTableInfo.ImportedKeys[oIndex].SelectFields.Count-1 do
      begin
        if Pos(SqlDot+AsTableInfo.ImportedKeys[oIndex].SelectFields[F],tmpSelect.Text) = 0 then
          tmpSelect.Add(strIdent + '    ' + AsTableInfo.ImportedKeys[oIndex].ForeignTableName +
            SqlDot + SafeWrap(AsTableInfo.ImportedKeys[oIndex].SelectFields[F]) +
            seperator);
      end;
    end
    else
    begin
      if Pos(fieldName, tmpSelect.Text) = 0 then
        tmpSelect.Add(strIdent + '    ' + AsTableInfo.Tablename +
          SqlDot + fieldName + seperator);
    end;

    if (not AsTableInfo.AllFields[I].IsIdentity) then
    begin
      tmpInsert.Add(strIdent + ' ' + SqlParamChar +
        AsTableInfo.AllFields[I].CSharpName + seperator);
      tmpSelectInsert.Add(strIdent + ' ' + fieldName + seperator);

      //this check will prevent some unwanted stuff like : (..set Status=@Status, where.. )
      if (I + 1) = AsTableInfo.AllFields.Count - 1 then
        if (AsTableInfo.AllFields[I + 1].IsPrimaryKey) and
          (AsTableInfo.PrimaryKeys.Count <> AsTableInfo.AllFields.Count) then
          seperator := '';

      if not AsTableInfo.AllFields[I].IsPrimaryKey then
        tmpUpdate.Add(strIdent + ' ' + fieldName+ '=' + SqlParamChar + AsTableInfo.AllFields[I].CSharpName +
          seperator);

      tmpUpdateAll.Add(strIdent + '    ' +  fieldName + '=' +
        SqlParamChar + AsTableInfo.AllFields[I].CSharpName + seperator);

    end;
  end;

  //make joins for SELECTs
  for I := 0 to AsTableInfo.ImportedKeys.Count - 1 do
  begin

    if tmpFTablename <> AsTableInfo.ImportedKeys[I].ForeignTableName then
    begin
      tmpFTablename := AsTableInfo.ImportedKeys[I].ForeignTableName;
      tmpTablename := AsTableInfo.ImportedKeys[i].Tablename;
      if trim(tmpTablename)=EmptyStr then
      tmpTablename:=AsTableInfo.ImportedKeys[i].Tablename[1];
      localColumn := SafeWrap(AsTableInfo.ImportedKeys[I].ColumnName);
      foreignColumn := SafeWrap(AsTableInfo.ImportedKeys[I].ForeignColumnName);

      //if pos('.'+localColumn,tmpSelectJoins.text) = 0 then
      tmpSelectJoins.Add
        (
          strIdent + ' INNER JOIN  ' + tmpFTablename +  ' ON ' + tmpTablename + '.' +localColumn + ' = ' +
          tmpFTableName+ '.' + foreignColumn
          );
    end
    else
    begin
      localColumn := SafeWrap(AsTableInfo.ImportedKeys[I].ColumnName);
      foreignColumn := SafeWrap(AsTableInfo.ImportedKeys[I].ForeignColumnName);

      if pos('.'+localColumn, tmpSelectJoins.text) = 0 then
        tmpSelectJoins.Add
        (
          strIdent + ' AND ' + tmpTablename + '.' +localColumn + ' = ' +
          tmpFTableName+ '.' + foreignColumn
          );
    end;

  end;


  tmpTablename:=SafeWrap(AsTableInfo.Tablename);
  case QueryType of
    qtSelect:
    begin
      r.Add(strIdent + 'SELECT ');
      r.Add(tmpSelect.Text);
      r.Add(strIdent + 'FROM ' + tmpTablename);
      r.Add(tmpSelectJoins.Text);
    end;
    qtSelectItem:
    begin
      r.Add(strIdent + 'SELECT ');
      r.Add(tmpSelect.Text);
      r.Add(strIdent + 'FROM ' + tmpTablename);
      r.Add(tmpSelectJoins.Text);
      if AsTableInfo.PrimaryKeys.Count > 0 then
      begin
        r.Add(strIdent + 'WHERE ' + AsTableInfo.TableAlias+ '.' +
        SafeWrap(AsTableInfo.PrimaryKeys[0].FieldName) + '='+
         SqlParamChar + AsTableInfo.PrimaryKeys[0].CSharpName);
        if (AsTableInfo.PrimaryKeys.Count > 1) then
        begin
          for I := 1 to AsTableInfo.PrimaryKeys.Count - 1 do
            r.Add(strIdent + ' AND ' + SafeWrap(AsTableInfo.Tablename)+
            '.' + SafeWrap(AsTableInfo.PrimaryKeys[I].FieldName) + '=' +
            SqlParamChar + AsTableInfo.PrimaryKeys[I].CSharpName);
        end;
      end;

    end;
    qtInsert:
    begin
      r.Add(strIdent + 'INSERT INTO ' + SafeWrap(AsTableInfo.TableName));
      r.Add(strIdent + '(');
      r.Add(tmpSelectInsert.Text);
      r.Add(strIdent + ')');
      r.Add(strIdent + 'VALUES ');
      r.Add(strIdent + '(');
      r.Add(tmpInsert.Text);
      r.Add(strIdent + ')');
    end;
    qtUpdate:
    begin
      r.Add(strIdent + 'UPDATE ' + SafeWrap(AsTableInfo.TableName));
      r.Add(strIdent + 'SET ');

      //if tmpUpdate.Count > 0 then
      //  r.Add(tmpUpdate.Text)
      //else
        r.Add(tmpUpdateAll.Text);

      if AsTableInfo.PrimaryKeys.Count > 0 then
      begin
        r.Add(strIdent + 'WHERE ' + SafeWrap(SqlTable) + SqlDot +
          SafeWrap(AsTableInfo.PrimaryKeys[0].FieldName) + '=' + SqlParamChar + 'p1');
        if (AsTableInfo.PrimaryKeys.Count > 1) then
        begin
          for I := 1 to AsTableInfo.PrimaryKeys.Count - 1 do
            r.Add(strIdent + ' AND ' + SafeWrap(SqlTable)+SqlDot+
             SafeWrap(AsTableInfo.PrimaryKeys[I].FieldName)+
              '=' + SqlParamChar + 'p'+IntToStr(I+1));
        end;
      end;
    end;
    qtDelete:
    begin
      r.Add(strIdent + 'DELETE FROM ' + SafeWrap(SqlTable));
      if AsTableInfo.PrimaryKeys.Count > 0 then
      begin
        r.Add(strIdent + 'WHERE ' + SafeWrap(SqlTable)+
          SqlDot + SafeWrap(AsTableInfo.PrimaryKeys[0].FieldName)+
          '=' + SqlParamChar + 'p1');
        if (AsTableInfo.PrimaryKeys.Count > 1) then
        begin
          for I := 1 to AsTableInfo.PrimaryKeys.Count - 1 do
            r.Add(strIdent + ' AND ' + SafeWrap(SqlTable)+
              SqlDot + SafeWrap(AsTableInfo.PrimaryKeys[I].FieldName)+
              '=' + SqlParamChar + 'p'+IntToStr(I+1));
        end;
      end;
    end;

  end;

  //r[r.Count-1] := r[r.Count-1]+';';
  tmpSelectJoins.Free;
  tmpSelect.Free;
  tmpInsert.Free;
  tmpUpdate.Free;
  tmpUpdateAll.Free;
  tmpSelectInsert.Free;
  Result := r;
  strTest := StringReplace(Result.Text,'[]','',[rfReplaceAll]);
end;

constructor TAsSqlGenerator.Create(DbConInfo: TAsDbConnectionInfo);
begin
  FDBConInfo := DbConInfo;
  FAsQuery := TAsQuery.Create(DbConInfo);
  FlstExistingProcedures := TAsDbUtils.GetProcedureNames(FDBConInfo);
end;

procedure TAsSqlGenerator.Generate(Tables: TAsTableInfos; QueryTypes: TQueryTypes;
  Prefix: string = 'usp');
var
  I: integer;
  tmpLst, tmp2: TStringList;
  lstStoredProcs: TStringList;
begin


  FspPrefix := Prefix;
  lstStoredProcs := TAsDbUtils.GetProcedureNames(FDBConInfo);

  WriteLog('===============STORED PROCEDURE GENERATION BEGIN===============');


  FSchema := Tables[0].Schema;
  for I := 0 to Tables.Count - 1 do
  begin
    WriteLog('*************Processing [' + Tables[i].Tablename + ']*************');

    //checks if sp Names are identical with those to be generated
    //if so, existing procedures will be dropped
    CheckProcedureName(Tables[i].Tablename);

    if qtSelect in QueryTypes then
    begin
      try
        tmpLst := GetCreateSql(Tables[i], qtSelect);
        FAsQuery.SQL.Clear;
        FAsQuery.SQL.AddStrings(tmpLst);
        FAsQuery.ExecSQL;
      except
        on e: Exception do
        begin
          WriteLog('Select for [' + Tables[i].Tablename + '] : ' + e.Message);
        end;
      end;
      tmpLst.Free;
    end;

    if qtSelectItem in QueryTypes then
    begin
      try
        tmpLst := GetCreateSql(Tables[i], qtSelectItem);
        FAsQuery.SQL.Clear;
        FAsQuery.SQL.AddStrings(tmpLst);
        FAsQuery.ExecSQL;
      except
        on e: Exception do
        begin
          WriteLog('SelectItem for [' + Tables[i].Tablename + '] : ' + e.Message);
        end;
      end;
      tmpLst.Free;
    end;

    if qtInsert in QueryTypes then
    begin
      try
        tmpLst := GetCreateSql(Tables[i], qtInsert);
        FAsQuery.SQL.Text := tmpLst.Text;
        FAsQuery.ExecSQL;
      except
        on e: Exception do
        begin
          WriteLog('Insert for [' + Tables[i].Tablename + '] : ' + e.Message);
        end;
      end;
      tmpLst.Free;
    end;

    if qtUpdate in QueryTypes then
    begin
      try
        tmpLst := GetCreateSql(Tables[i], qtUpdate);
        FAsQuery.SQL.Text := tmpLst.Text;
        FAsQuery.ExecSQL;
      except
        on e: Exception do
        begin
          WriteLog('Update for [' + Tables[i].Tablename + '] : ' + e.Message);
        end;
      end;
      tmpLst.Free;
    end;

    if qtDelete in QueryTypes then
    begin
      try
        tmpLst := GetCreateSql(Tables[i], qtDelete);
        FAsQuery.SQL.Text := tmpLst.Text;
        FAsQuery.ExecSQL;
      except
        on e: Exception do
        begin
          WriteLog('Delete for [' + Tables[i].Tablename + '] : ' + e.Message);
        end;
      end;
      tmpLst.Free;
    end;

  end;

  lstStoredProcs.Free;
  WriteLog('===============STORED PROCEDURE GENERATION END===============');
end;

function TAsSqlGenerator.GenerateQuery(Ident: integer; AsTableInfo: TAsTableInfo;
  QueryType: TQueryType): TStringList;
var
  lst: TStringList;
begin

  Result := TStringList.Create;

    if QueryType = qtAll then
    begin

      lst := GetSql(0, AsTableInfo, qtSelect);
      Result.AddStrings(lst);
      lst.Free;

      lst := GetSql(0, AsTableInfo, qtSelectItem);
      Result.AddStrings(lst);
      lst.Free;

      lst := GetSql(0, AsTableInfo, qtInsert);
      Result.AddStrings(lst);
      lst.Free;

      lst := GetSql(0, AsTableInfo, qtUpdate);
      Result.AddStrings(lst);
      lst.Free;

      lst := GetSql(0, AsTableInfo, qtDelete);
      Result.AddStrings(lst);
      lst.Free;
    end
    else
    begin
      lst := GetSql(0, AsTableInfo, QueryType);
      Result.AddStrings(lst);
      lst.Free;
    end;

end;

function TAsSqlGenerator.GetCreateScript(DBInfo: TAsDbConnectionInfo; Info: TAsTableInfo;
  TypeCreate: TPCreateScript): TStringList;
var
  bsql, asql, sql: string;
  I: integer;
  len, precision, scale:Integer;
  strDefaulType,strNewType,strReferences,strField, strfieldFK:string;
begin
  scale := 0;
  Result := TStringList.Create;
  Result.Clear;
  if TypeCreate = csTable then
  begin
    sql := 'CREATE TABLE ' + info.Tablename + ' ('#13;
    for I := 0 to info.AllFields.Count - 1 do
    begin
      sql := sql + '    ';

      len := info.AllFields[I].Length;
      {if not OverrideDefaultTypes then
      begin  }
       if (UpperCase(info.AllFields[I].FieldType) = 'VARCHAR') or (UpperCase(info.AllFields[I].FieldType) = UpperCase('nvarchar')) or (UpperCase(info.AllFields[I].FieldType) = UpperCase('varchar2')) or
            (UpperCase(info.AllFields[I].FieldType) = UpperCase('nvarchar2')) or (UpperCase(info.AllFields[I].FieldType) = UpperCase('character varying')) then
         sql := sql + info.AllFields[I].FieldName + ' ' + info.AllFields[I].FieldType
       else
         if Pos('NUMERIC', UpperCase(info.AllFields[I].FieldType)) > 0 THEN
         begin
           sql := sql + info.AllFields[I].FieldName + ' ' + info.AllFields[I].FieldType
         end
         ELSE If ((UpperCase(info.AllFields[I].FieldType) = 'INTEGER')  OR (UpperCase(info.AllFields[I].FieldType) = 'SMALLINT'))
              OR (UpperCase(info.AllFields[I].FieldType) = 'TIMESTAMP') OR (UpperCase(info.AllFields[I].FieldType) = 'DATE')
              OR (UpperCase(info.AllFields[I].FieldType) = 'TIME') THEN
           sql := sql + info.AllFields[I].FieldName + ' ' + info.AllFields[I].FieldType
         ELSE If ((UpperCase(info.AllFields[I].FieldType) = 'DOUBLE')) THEN
           sql := sql + info.AllFields[I].FieldName + ' ' + 'DOUBLE PRECISION'
         ELSE If ((UpperCase(info.AllFields[I].FieldType) = 'FLOAT')) THEN
           sql := sql + info.AllFields[I].FieldName + ' ' + 'NUMERIC'
         ELSE
           sql := sql + info.AllFields[I].FieldName + ' ' + info.AllFields[I].FieldType + '('+IntToStr(Len)+')';
      {end
      else
        sql := sql + info.AllFields[I].GetCompatibleFieldName(FDbInfo.DbType)+ ' ' +  GetFieldTypeAs(info.AllFields[I].DataType);
       }
      len := info.AllFields[I].Length;

      if len >2000 then
      len :=2000;

      strDefaulType:= info.AllFields[I].FieldType;
      {if OverrideDefaultTypes then
        strNewType:= lowercase(GetFieldTypeAs(info.AllFields[I].DataType))
      else}
        strNewType:=strDefaulType;

        if (UpperCase(strNewType) = 'VARCHAR') or (UpperCase(strNewType) = UpperCase('nvarchar')) or (UpperCase(strNewType) = UpperCase('varchar2')) or
         (UpperCase(strNewType) = UpperCase('nvarchar2')) or (UpperCase(strNewType)=UpperCase('character varying')) then
        begin
          if len>0 then
            sql := sql + '(' + IntToStr(len) + ')'
          else
            sql := sql + '(50)';
        end;

        if (uppercase(strNewType) = uppercase('decimal')) or (uppercase(strNewType) = uppercase('float')) then
        begin
          if info.AllFields[I].Precision=0 then
          info.AllFields[I].Precision := 2;

          if len=0 then len := 12;

          if len< info.AllFields[I].Precision then
          begin
            len := 12;
            info.AllFields[I].Precision := 2;
          end;

          sql := sql + '( ' + IntToStr(len) + ',' +
          IntToStr(info.AllFields[I].Precision) + ')';
        end;

      if not info.AllFields[I].AllowNull then
      begin
        sql := sql + ' NOT NULL';
      end;

      sql := sql + LoopSeperator[integer(I < info.AllFields.Count - 1)] + #13;

    end;
  end;

  if (TypeCreate = csPrimaryKey) and info.HasPrimaryKeys then
  begin

    {if DbInfo.DbType in [dtSQLite, dtOracle, dtMySql,dtFirebirdd] then
    begin
      sql := sql + ',';
    end;

    if DbInfo.DbType in [dtOracle, dtMySql] then
      sql := sql + '    CONSTRAINT ' + info.Tablename + '_PK ';

    if DbInfo.DbType<>dtPostgreSql then
    begin
      sql := sql + ' PRIMARY KEY (';

      for I := 0 to info.PrimaryKeys.Count - 1 do
      begin
        sql := sql + info.PrimaryKeys[I].GetCompatibleFieldName(DbInfo.DbType) +
          LoopSeperator[integer(I < info.PrimaryKeys.Count - 1)];
        //if FDbInfo.DbType=dtSQLite then
        //begin
        //  sql[Length(sql)]:=' ';
        //  Break;
        //end;
      end;
    end;
    sql := sql + ' )' + #13 ;

    if DbInfo.DbType=dtPostgreSql then
    begin
      sql := sql +';' + LineEnding;
      for I:= 0 to info.PrimaryKeys.Count-1 do
      begin
        sql := sql + ' ALTER TABLE ONLY '+Info.Tablename+' ADD CONSTRAINT '+ info.Tablename+'_'+info.PrimaryKeys[I].FieldName+' PRIMARY KEY ('+Info.PrimaryKeys[I].FieldName+');'+LineEnding + #13;
        break;//only one primary key
      end;
    end;
     }
    if DbInfo.DbType=dtFirebirdd then
    begin
      sql := '';
      for I:= 0 to info.PrimaryKeys.Count-1 do
      begin
        if Sql = '' then
          sql := sql + Info.PrimaryKeys[I].FieldName
        else
          sql := sql + ','+ Info.PrimaryKeys[I].FieldName;
      end;
      Sql := ' ALTER TABLE '+Info.Tablename+' ADD CONSTRAINT '+ GetPrimaryKeyName(Info.TableName)+' PRIMARY KEY (' + SQL +')';
    end;
  end;

  if TypeCreate = csForeingKey then
  begin
    for I := 0 to info.ImportedKeys.Count - 1 do
    begin
      {if DbInfo.DbType in [dtOracle, dtMySql,dtFirebirdd,dtSQLite] then
      begin
        sql := sql + ',' + #13;
      end;}
      case DbInfo.DbType of
        dtMsSql,dtOracle,dtMySql:
          begin
          Sql := Sql + '    CONSTRAINT ' + TAsDbUtils.SafeWrap(DbInfo.DbType,'fk_'+ info.ImportedKeys[I].ForeignTableName + info.ImportedKeys[I].ForeignColumnName) +
            ' FOREIGN KEY (' + info.ImportedKeys[I].GetCompatibleColumnName(DbInfo.DbType) + ') ' +
            ' REFERENCES ' + info.ImportedKeys[I].ForeignTableName +
            '(' + info.ImportedKeys[I].GetCompatibleForeignColumnName(DbInfo.DbType) + ') ';

          end;
        dtSQLite:
          begin
             Sql := Sql + ' FOREIGN KEY('+info.ImportedKeys[I].GetCompatibleColumnName(DbInfo.DbType)+') REFERENCES '+
            info.ImportedKeys[I].ForeignTableName+'('+info.ImportedKeys[I].ForeignColumnName+')';
          end;
        dtFirebirdd:
          begin
            strReferences := info.ImportedKeys[I].ForeignTableName;
            if (aSql = '') and (strField <> TAsDbUtils.SafeWrap(DbInfo.DbType, info.ImportedKeys[I].ColumnName)) then
            begin
              asql := asql + TAsDbUtils.SafeWrap(DbInfo.DbType, info.ImportedKeys[I].ColumnName);
              strField := TAsDbUtils.SafeWrap(DbInfo.DbType, info.ImportedKeys[I].ColumnName);
            end
            else if strField <> TAsDbUtils.SafeWrap(DbInfo.DbType, info.ImportedKeys[I].ColumnName) then
            begin
              asql := asql + ','+ TAsDbUtils.SafeWrap(DbInfo.DbType, info.ImportedKeys[I].ColumnName);
              strField := TAsDbUtils.SafeWrap(DbInfo.DbType, info.ImportedKeys[I].ColumnName);
            end;
            if (bSql = '') and (strfieldFK <> TAsDbUtils.SafeWrap(DbInfo.DbType, info.ImportedKeys[I].ForeignColumnName)) then
            begin
              if Pos(info.ImportedKeys[I].ForeignColumnName, bsql) = 0 then
                bsql := bsql + TAsDbUtils.SafeWrap(DbInfo.DbType, info.ImportedKeys[I].ForeignColumnName);
              strfieldFK := TAsDbUtils.SafeWrap(DbInfo.DbType, info.ImportedKeys[I].ForeignColumnName);
            end
            else if strfieldFK <> TAsDbUtils.SafeWrap(DbInfo.DbType, info.ImportedKeys[I].ForeignColumnName) then
            begin
              if Pos(info.ImportedKeys[I].ForeignColumnName, bsql) = 0 then
                bsql := bsql + ','+  TAsDbUtils.SafeWrap(DbInfo.DbType, info.ImportedKeys[I].ForeignColumnName);
              strfieldFK := TAsDbUtils.SafeWrap(DbInfo.DbType, info.ImportedKeys[I].ForeignColumnName);
            end;

            if ((info.ImportedKeys.Count-1) <I+1) or (strReferences <> info.ImportedKeys[I+1].ForeignTableName) then
            begin
              sql := 'ALTER TABLE ' +Info.Tablename + ' ADD CONSTRAINT '+ info.ImportedKeys[I].ConstraintName +' FOREIGN KEY ('+ asql +')  REFERENCES '+strReferences+'('+bSql+');' + #13;
              aSql := '';
              bSql := '';
            end;
         end;
      end;
    end;
  end;
  {
  if DbInfo.DbType <> dtPostgreSql then
    sql := sql + ')';

  if DbInfo.DbType = dtMySql then
  begin
    sql := sql + ';'
  end;
  }
    if Trim(Sql) <> '' then
      if TypeCreate <> csForeingKey then
      begin
        if TypeCreate = csTable then
          Result.Text := Trim(UpperCase(Sql))+');'
        else
          Result.Text := Trim(UpperCase(Sql))+';'
      end
      else
        Result.Text := Trim(UpperCase(Sql));
end;
{$ENDREGION}

function TAsSqlGenerator.GetPrimaryKeyName(Table:String): String;
begin
  FAsQuery.Close;
  FAsQuery.SQL.Clear;
  FAsQuery.SQL.Add('SELECT RDB$CONSTRAINT_NAME FROM RDB$RELATION_CONSTRAINTS ');
  FAsQuery.SQL.Add('WHERE (RDB$RELATION_NAME ='+QuotedStr(Table)+')');
  FAsQuery.SQL.Add('AND (RDB$CONSTRAINT_TYPE=''PRIMARY KEY'')');
  FAsQuery.Open;
  Result := FAsQuery.Fields[0].AsString;
end;

{$REGION 'Private Methods'}

procedure TAsSqlGenerator._cmdBeforeOpen(DataSet: TDataSet);
var
  I: integer;
begin
  for I := 0 to DataSet.Fields.Count - 1 do
  begin
    DataSet.Fields[I].OnGetText := @_DataSetGetText;
  end;
end;

procedure TAsSqlGenerator._DataSetGetText(Sender: TField; var aText: string;
  DisplayText: boolean);
begin
  aText := Utf8ToAnsi(Sender.AsWideString);
  DisplayText := True;
end;


function TAsSqlGenerator.GetDbParamPrefix: string;
begin
  case FDBConInfo.DbType of
    dtMsSql: Result := '@';
    dtOracle: Result := '_';
    dtMySql: Result := '_';
  end;
end;

function TAsSqlGenerator.SafeWrap(TableOrField: string): string;
begin
  Result := TAsDbUtils.SafeWrap(FDBConInfo.DbType,TableOrField);
end;

procedure TAsSqlGenerator.CheckProcedureName(Tablename: string);
var
  spInsertName, spSelectName, spSelectItemName, spUpdateName, spDeleteName, uid: string;
begin
  uid := ';1';
  spSelectName := FspPrefix + '' + Tablename + '' + FprocNames.pnSelect;
  spSelectItemName := FspPrefix + '' + Tablename + '' + FprocNames.pnSelectItem;
  spInsertName := FspPrefix + '' + Tablename + '' + FprocNames.pnInsert;
  spDeleteName := FspPrefix + '' + Tablename + '' + FprocNames.pnUpdate;
  spUpdateName := FspPrefix + '' + Tablename + '' + FprocNames.pnDelete;

  if FlstExistingProcedures.IndexOf(spSelectName + uid) > -1 then
  begin
    WriteLog('Existing storedProc [' + spSelectName + '], executing cleanup...');
    DropProcedure(spSelectName);
  end;

  if FlstExistingProcedures.IndexOf(spSelectItemName + uid) > -1 then
  begin
    WriteLog('Existing storedProc found [' + spSelectItemName +
      '], executing cleanup...');
    DropProcedure(spSelectItemName);
  end;

  if FlstExistingProcedures.IndexOf(spInsertName + uid) > -1 then
  begin
    WriteLog('Existing storedProc found [' + spInsertName + '], executing cleanup...');
    DropProcedure(spInsertName);
  end;

  if FlstExistingProcedures.IndexOf(spUpdateName + uid) > -1 then
  begin
    WriteLog('Existing storedProc found [' + spUpdateName + '], executing cleanup...');
    DropProcedure(spUpdateName);
  end;

  if FlstExistingProcedures.IndexOf(spDeleteName + uid) > -1 then
  begin
    WriteLog('Existing storedProc found [' + spDeleteName + '], executing cleanup...');
    DropProcedure(spDeleteName);
  end;
end;

{Used in GetCreateSql}
function TAsSqlGenerator.GetDataType(FieldInfo: TAsFieldInfo; AsDbType: TAsDatabaseType): string;
var
  dtype: string;
begin
  case FieldInfo.DataType of
    ftFloat, ftCurrency, ftFMTBcd, ftBCD:
    begin
      if AsDbType <> dtOracle then
      begin

        if (FieldInfo.FieldType = 'real') or (FieldInfo.FieldType =
          'float') then
          dtype := FieldInfo.FieldType
        else
          dtype := 'decimal(' + IntToStr(FieldInfo.Length) + ',' +
            IntToStr(FieldInfo.Precision) + ')';

      end
      else
      begin
        //ORACLE
        dtype := 'number(' + IntToStr(FieldInfo.Length) + ',' +
          IntToStr(FieldInfo.Precision) + ')';
      end;
    end;
    ftInteger, ftSmallint, ftWord, ftLargeint:
    begin
      if AsDbType <> dtOracle then
        dtype := 'int'
      else
        dtype := 'number';
    end;
    ftBoolean:
    begin
      case AsDbType of
        dtMsSql: dtype := 'bit';
        dtMySql: dtype := 'boolean';
        dtOracle: dtype := 'number(1)';//>9i supports boolean
      end;
    end;
    ftBlob: dtype := 'binary';
    ftDateTime, ftDate: dtype := 'datetime';
    ftGuid:
    begin
      case AsDbType of
        dtMsSql: dtype := 'uniqueidentifier';
        //dtMySql: dtype:='uniqueidentifier'; not supported
        dtOracle: dtype := 'uuid';
      end;
    end;
    ftMemo, ftWideMemo: dtype := 'text';
    else
    begin
      dtype := FieldInfo.FieldType;
      if FieldInfo.Length > 0 then
        dtype := dtype + '(' + IntToStr(FieldInfo.Length) + ')';
    end;
  end;

  //Zeos returns unique identifier as Binary
  if FieldInfo.FieldType = 'uniqueidentifier' then
    dtype := 'uniqueidentifier';

  if (FieldInfo.FieldType = 'ntext') or (FieldInfo.FieldType = 'xml') then
    dtype := 'text';
  if (FieldInfo.FieldType = 'nvarchar') then
    dtype := 'nvarchar(' + IntToStr(FieldInfo.Length) + ')';

  //no need for any param length when oracle ;(
  if AsDbType = dtOracle then
  begin
    dtype := FieldInfo.FieldType;
  end;

  Result := dtype;
end;

{Used in Generate procedures and functions}
function TAsSqlGenerator.GetCreateSql(AsTableInfo: TAsTableInfo; QueryType: TQueryType;
  SqlSpKeyword: string = 'CREATE '): TStringList;
var
  dtype, seperator, tmpFTablename, tmpTablename: string;

  SqlOpenBr, SqlCloseBr, SqlBeginProc, SqlEndProc, SqlBegin, SqlEnd,
  SqlAsProc, SqlParamChar, SqlPreParam, SqlPostParam, SqlTablename,
  SqlDot, SqlSpSep: string;

  I, oIndex: integer;

  tmpSelect, tmpSelectInsert, tmpInsert, tmpUpdate,
  tmpUpdateAll,//this includes all fields, including PrimaryKeys-s
  tmpParamDeclare, tmpDelParamDeclare, tmpSelectItemParam, tmpSelectJoins: TStringList;

  r: TStringList;
  field: TField;
  tmpInsertParamDeclare: TStringList;
  strTest: string;
  EC: char;
  TC: char;
begin

  EC := ' ';
  TC := #9;

  FSchema := AsTableInfo.Schema;

  case FDBConInfo.DbType of
    dtOracle:
    begin
      FspPrefix := UpperCase(FspPrefix);
      SqlOpenBr := '"';
      SqlCloseBr := '"';
      SqlBeginProc := SqlSpKeyword + 'PROCEDURE ';
      SqlAsProc := ' AS ';
      SqlParamChar := 'P';//to differentiate from original column name
      SqlPreParam := '';
      SqlPostParam := ' IN ';
      SqlTablename := AsTableInfo.Tablename;
      SqlDot := '.';
      SqlBegin := 'BEGIN';
      SqlEnd := 'END;';
    end;
    dtMsSql:
    begin
      SqlOpenBr := '[';
      SqlCloseBr := ']';
      SqlBeginProc := SqlSpKeyword + 'PROCEDURE ';
      SqlAsProc := ' AS ';
      SqlParamChar := '@';
      SqlPreParam := '';
      SqlPostParam := '';
      SqlTablename := AsTableInfo.Tablename;
      SqlDot := '.';
      SqlBegin := 'BEGIN';
      SqlEnd := 'END';
    end;
    dtMySql:
    begin
      SqlOpenBr := '';
      SqlCloseBr := '';
      SqlBeginProc := SqlSpKeyword + 'PROCEDURE ';
      SqlAsProc := ' ';
      SqlParamChar := '_';//to differentiate from original column name
      SqlPreParam := ' ';
      SqlPostParam := '';
      SqlTablename := '';
      SqlDot := '';
      SqlBegin := '';
      if QueryType = qtSelect then
        SqlBegin := '()'
      else
        SqlBegin := 'BEGIN';
      SqlEnd := 'END;';
    end;
    dtFirebirdd:
    begin
       SqlOpenBr := '"';
      SqlCloseBr := '"';
      SqlBeginProc := SqlSpKeyword + 'PROCEDURE ';
      SqlAsProc := ' AS ';
      SqlParamChar := 'P';
      SqlPreParam := '';
      SqlPostParam := '';
      SqlTablename := AsTableInfo.Tablename;
      SqlDot := '.';
      SqlBegin := 'BEGIN';
      SqlEnd := 'END';

    end;
    dtPostgreSql:
    begin
      SqlOpenBr := '"';
      SqlCloseBr := '"';
      SqlBeginProc := SqlSpKeyword + 'FUNCTION ';
      if QueryType in [qtInsert,qtUpdate,qtDelete] then
      begin
        SqlAsProc := 'RETURNS void AS ';
        SqlBegin := '$BODY$'+LineEnding+'declare '+LineEnding+'BEGIN';
      end
      else
      begin
        SqlAsProc := 'RETURNS refcursor AS ';
        SqlBegin := '$BODY$'+LineEnding+'declare ref refcursor;'+LineEnding+'BEGIN';
      end;

      SqlParamChar := 'P';
      SqlPreParam := '';
      SqlPostParam := '';
      SqlTablename := AsTableInfo.Tablename;
      SqlDot := '.';

      SqlEnd := 'END'+LineEnding+'$BODY$'+LineEnding+'LANGUAGE plpgsql VOLATILE';
    end;
  end;

  if (AsTableInfo.PrimaryKeys.Count = 0) and not (QueryType in [qtSelect, qtInsert]) then
    raise Exception.Create('No primary keys found!');
 r := TStringList.Create;

  tmpSelect := TStringList.Create;
  tmpInsert := TStringList.Create;
  tmpUpdate := TStringList.Create;
  tmpUpdateAll := TStringList.Create;
  tmpInsertParamDeclare := TStringList.Create;
  tmpParamDeclare := TStringList.Create;
  tmpDelParamDeclare := TStringList.Create;
  tmpSelectItemParam := TStringList.Create;
  tmpSelectJoins := TStringList.Create;
  tmpSelectInsert := TStringList.Create;

  for I := 0 to AsTableInfo.AllFields.Count - 1 do
  begin
    if I < (AsTableInfo.AllFields.Count - 1) then
      seperator := ','
    else
      seperator := '';

    if (I + 1) = AsTableInfo.AllFields.Count - 1 then
      if (QueryType in [qtInsert]) then
        if AsTableInfo.AllFields[I + 1].IsIdentity then
          seperator := '';

    dtype := GetDataType(AsTableInfo.AllFields[I], FDBConInfo.DbType);

    tmpParamDeclare.Add(EC + EC + SqlParamChar + AsTableInfo.AllFields[I].CSharpName +
      SqlPostParam + EC + dtype + seperator);

    if AsTableInfo.AllFields[I].IsReference then
    begin
      oIndex := AsTableInfo.ImportedKeys.GetIndex(AsTableInfo.AllFields[I].FieldName);
      tmpSelect.Add(TC + TC + SqlOpenBr + SqlTablename + SqlCloseBr +
        SqlDot + SqlOpenBr + AsTableInfo.AllFields[I].FieldName + SqlCloseBr + ',');
      tmpSelect.Add(TC + TC + 't' + IntToStr(oIndex + 1) + '.' +
        SqlOpenBr + AsTableInfo.ImportedKeys[oIndex].ForeignFirstTextField +
        SqlCloseBr + seperator);
    end
    else
    begin
      tmpSelect.Add(TC + TC + SqlOpenBr + SqlTablename + SqlCloseBr +
        SqlDot + SqlOpenBr + AsTableInfo.AllFields[I].FieldName + SqlCloseBr + seperator);
    end;

    if (not AsTableInfo.AllFields[I].IsIdentity) then
    begin

      tmpInsertParamDeclare.Add(EC + SqlPreParam + SqlParamChar +
        AsTableInfo.AllFields[I].CSharpName + SqlPostParam + EC + dtype + seperator);

      tmpInsert.Add(TC + TC + SqlParamChar + AsTableInfo.AllFields[I].CSharpName +
        seperator);
      tmpSelectInsert.Add('    ' + SqlOpenBr + AsTableInfo.AllFields[I].FieldName +
        SqlCloseBr + seperator);

      //this check will prevent some unwanted stuff like : (..set Status=@Status, where.. )
      if (I + 1) = AsTableInfo.AllFields.Count - 1 then
        if (AsTableInfo.AllFields[I + 1].IsPrimaryKey) and
          (AsTableInfo.PrimaryKeys.Count <> AsTableInfo.AllFields.Count) then
          seperator := '';

      if not AsTableInfo.AllFields[I].IsPrimaryKey then
        tmpUpdate.Add(TC + TC + TC + SqlOpenBr + AsTableInfo.AllFields[I].FieldName +
          SqlCloseBr + '=' + SqlParamChar + AsTableInfo.AllFields[I].CSharpName +
          seperator);

      tmpUpdateAll.Add(TC + TC + SqlOpenBr + AsTableInfo.AllFields[I].FieldName +
        SqlCloseBr + '=' + SqlParamChar + AsTableInfo.AllFields[I].CSharpName + seperator);

    end;

  end;

  //declare params for delete (only ids)
  for I := 0 to AsTableInfo.PrimaryKeys.Count - 1 do
  begin
    dtype := GetDataType(AsTableInfo.PrimaryKeys[I], FDBConInfo.DbType);
    if I < AsTableInfo.PrimaryKeys.Count - 1 then
      seperator := ','
    else
      seperator := '';

    tmpDelParamDeclare.Add(TC + TC + SqlPreParam + SqlParamChar +
      AsTableInfo.PrimaryKeys[I].CSharpName + SqlPostParam + ' ' + dtype + seperator);
    tmpSelectItemParam.Add(TC + TC + SqlPreParam + SqlParamChar +
      AsTableInfo.PrimaryKeys[I].CSharpName + SqlPostParam + ' ' + dtype + seperator);
  end;

  //make joins for SELECTs
  for I := 0 to AsTableInfo.ImportedKeys.Count - 1 do
  begin
    tmpFTablename := SqlOpenBr + AsTableInfo.ImportedKeys[I].ForeignSchema +
      SqlCloseBr + '.' + SqlOpenBr + AsTableInfo.ImportedKeys[I].ForeignTableName +
      SqlCloseBr;
    tmpTablename := SqlOpenBr + AsTableInfo.Schema + SqlCloseBr + '.' +
      SqlOpenBr + AsTableInfo.ImportedKeys[i].TableName + SqlCloseBr;
    tmpSelectJoins.Add
    (
      EC + 'INNER' + EC + 'JOIN' + EC + tmpFTablename + EC + 't' +
      IntToStr(I + 1) + EC + 'ON' + EC + tmpTablename + '.' + SqlOpenBr +
      AsTableInfo.ImportedKeys[I].ColumnName + SqlCloseBr + ' = ' +
      't' + IntToStr(I + 1) + '.' + SqlOpenBr +
      AsTableInfo.ImportedKeys[I].ForeignColumnName + SqlCloseBr
      );
  end;

  case QueryType of
    qtSelect:
    begin
      r.Add(SqlBeginProc + AsTableInfo.Schema + '.' + FspPrefix + '' +
        AsTableInfo.TableName + '' + FprocNames.pnSelect);

      case FDBConInfo.DbType of
        dtOracle :r[r.Count - 1] :=r[r.Count - 1] + ' (' + EC + 'RESULT' + EC + 'OUT' + EC +'SYS_REFCURSOR' + EC + ')';
        dtPostgreSql: r.Add('()');
      end;

      r.Add(SqlAsProc + EC + SqlBegin);

      case FDBConInfo.DbType of
        dtOracle: r.Add('OPEN' + EC + 'RESULT' + EC + 'FOR');
        dtPostgreSql: r.Add( 'OPEN ref FOR ');
      end;

      r.Add('SELECT' + EC);
      r.Add(tmpSelect.Text);
      r.Add('FROM' + EC + SqlOpenBr + AsTableInfo.Schema + SqlCloseBr +
        '.' + SqlOpenBr + AsTableInfo.Tablename + SqlCloseBr);
      if Trim(tmpSelectJoins.Text) <> EmptyStr then
        r.Add(tmpSelectJoins.Text);
    end;
    qtSelectItem:
    begin
      r.Add(SqlBeginProc + AsTableInfo.schema + '.' + FspPrefix + '' +
        AsTableInfo.TableName + '' + FprocNames.pnSelectItem);
      r.Add('(');
      r.Add('' + tmpSelectItemParam.Text);
      if FDBConInfo.DbType = dtOracle then
      begin
        r[r.Count - 1] :=
          r[r.Count - 1] + ',' + EC + 'RESULT' + EC + 'OUT' + EC + 'SYS_REFCURSOR';
      end;

      r.Add(') ' + SqlAsProc + ' ' + SqlBegin);

      case FDBConInfo.DbType of
        dtOracle: r.Add('OPEN' + EC + 'RESULT' + EC + 'FOR');
        dtPostgreSql: r.Add( 'OPEN ref FOR ');
      end;

      r.Add('SELECT' + EC);
      r.Add(tmpSelect.Text);
      r.Add('FROM' + EC + SqlOpenBr + AsTableInfo.schema + SqlCloseBr +
        '.' + SqlOpenBr + AsTableInfo.TableName + SqlCloseBr);

      if Trim(tmpSelectJoins.Text) <> EmptyStr then
        r.Add(tmpSelectJoins.Text);

      if AsTableInfo.PrimaryKeys.Count > 0 then
      begin
        r.Add('WHERE' + EC + SqlOpenBr + SqlTablename + SqlCloseBr +
          SqlDot + SqlOpenBr + AsTableInfo.PrimaryKeys[0].FieldName +
          SqlCloseBr + '=' + SqlParamChar + AsTableInfo.PrimaryKeys[0].CSharpName);
        if (AsTableInfo.PrimaryKeys.Count > 1) then
        begin
          for I := 1 to AsTableInfo.PrimaryKeys.Count - 1 do
            r.Add(EC + 'AND' + EC + SqlOpenBr + AsTableInfo.Tablename +
              SqlCloseBr + '.' + SqlOpenBr + AsTableInfo.PrimaryKeys[I].FieldName +
              SqlCloseBr + '=' + SqlParamChar + AsTableInfo.PrimaryKeys[I].CSharpName);
        end;
      end;
    end;
    qtInsert:
    begin
      r.Add(SqlBeginProc + AsTableInfo.schema + '.' + FspPrefix + '' +
        AsTableInfo.TableName + '' + FprocNames.pnInsert);
      r.Add('(');
      r.Add(tmpInsertParamDeclare.Text);
      r.Add(')' + EC + SqlAsProc + EC + SqlBegin);
      r.Add('INSERT INTO ' + SqlOpenBr + AsTableInfo.schema + SqlCloseBr +
        '.' + SqlOpenBr + AsTableInfo.TableName + SqlCloseBr);
      r.Add('(');
      r.Add(tmpSelectInsert.Text);
      r.Add(')');
      r.Add('VALUES' + EC);
      r.Add('(');
      r.Add(tmpInsert.Text);
      r.Add(')');
    end;
    qtUpdate:
    begin
      r.Add(SqlBeginProc + AsTableInfo.schema + '.' + FspPrefix + '' +
        AsTableInfo.TableName + '' + FprocNames.pnUpdate);
      r.Add('(');
      r.Add('' + tmpParamDeclare.Text);
      r.Add(') ' + SqlAsProc + ' ' + SqlBegin);
      r.Add('UPDATE' + EC + SqlOpenBr + AsTableInfo.schema + SqlCloseBr +
        '.' + SqlOpenBr + AsTableInfo.TableName + SqlCloseBr);
      r.Add('SET' + EC);

      if tmpUpdate.Count > 0 then
        r.Add(tmpUpdate.Text)
      else
        r.Add(tmpUpdateAll.Text);

      if AsTableInfo.PrimaryKeys.Count > 0 then
      begin
        r.Add('WHERE' + EC + SqlOpenBr + AsTableInfo.Tablename +
          SqlCloseBr + '.' + SqlOpenBr + AsTableInfo.PrimaryKeys[0].FieldName +
          SqlCloseBr + '=' + SqlParamChar + AsTableInfo.PrimaryKeys[0].CSharpName);
        if (AsTableInfo.PrimaryKeys.Count > 1) then
        begin
          for I := 1 to AsTableInfo.PrimaryKeys.Count - 1 do
            r.Add(EC + 'AND' + EC + SqlOpenBr + AsTableInfo.Tablename +
              SqlCloseBr + '.' + SqlOpenBr + AsTableInfo.PrimaryKeys[I].FieldName +
              SqlCloseBr + '=' + SqlParamChar + AsTableInfo.PrimaryKeys[I].CSharpName);
        end;
      end;
    end;
    qtDelete:
    begin
      r.Add(SqlBeginProc + AsTableInfo.schema + '.' + FspPrefix + '' +
        AsTableInfo.TableName + FprocNames.pnDelete);
      r.Add('(');
      r.Add('' + tmpDelParamDeclare.Text);
      r.Add(')' + EC + SqlAsProc + EC + SqlBegin);
      r.Add('DELETE' + EC + 'FROM' + EC + SqlOpenBr + AsTableInfo.schema +
        SqlCloseBr + '.' + SqlOpenBr + AsTableInfo.TableName + SqlCloseBr);
      if AsTableInfo.PrimaryKeys.Count > 0 then
      begin
        r.Add('WHERE' + EC + SqlOpenBr + AsTableInfo.Tablename +
          SqlCloseBr + '.' + SqlOpenBr + AsTableInfo.PrimaryKeys[0].FieldName +
          SqlCloseBr + '=' + SqlParamChar + AsTableInfo.PrimaryKeys[0].CSharpName);
        if (AsTableInfo.PrimaryKeys.Count > 1) then
        begin
          for I := 1 to AsTableInfo.PrimaryKeys.Count - 1 do
            r.Add(EC + 'AND' + EC + SqlOpenBr + AsTableInfo.Tablename +
              SqlCloseBr + '.' + SqlOpenBr + AsTableInfo.PrimaryKeys[I].FieldName +
              SqlCloseBr + '=' + SqlParamChar + AsTableInfo.PrimaryKeys[I].CSharpName);
        end;
      end;
    end;
  end;

  case FDBConInfo.DbType of
    dtMySql: if (QueryType <> qtSelect) then
        r[r.Count - 1] := r[r.Count - 1] + ';';
    dtOracle: r[r.Count - 1] := r[r.Count - 1] + ';';
    dtPostgreSql: r[r.Count - 1] := r[r.Count - 1] + ';'+LineEnding+'RETURN ref;';
  end;


  r.Add(SqlEnd);

  if FDBConInfo.DbType = dtOracle then
    r.Add('/');

  tmpDelParamDeclare.Free;
  tmpSelectItemParam.Free;
  tmpParamDeclare.Free;
  tmpSelectJoins.Free;
  tmpSelect.Free;
  tmpInsert.Free;
  tmpUpdate.Free;
  tmpUpdateAll.Free;
  tmpSelectInsert.Free;
  tmpInsertParamDeclare.Free;
  Result := r;
  strTest := Result.Text;
end;


procedure TAsSqlGenerator.WriteLog(Msg: string);
begin

end;

{$ENDREGION}

end.


