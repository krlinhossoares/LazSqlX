unit UFrmModel;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, SynHighlighterPas, SynHighlighterAny,
  SynCompletion, SynHighlighterJava, Forms, Controls, Graphics, Dialogs,
  ComCtrls, ZDataset, ZConnection, AsTableInfo, AsCrudInfo, AsSqlGenerator;

type

  { TFrmModel }

  TFrmModel = class(TForm)
    ApplicationImages: TImageList;
    PageControl1: TPageControl;
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
    UnitNameDAO, ClassNameDAO, VarDAO,UnitNameModel, ClassNameModel, VarModel: String;

    function GenerateSqlQuery(queryType: TQueryType):TStringList;
    procedure GeneratorCodeProcDelete;
    procedure GeneratorCodeProcGetItem;
    procedure GeneratorCodeProcInsert;
    procedure GeneratorCodeProcList;
    procedure GeneratorCodeProcUpdate;
    procedure GeneratorDAOClass;
    procedure GeneratorPascalClass;
    function IFNull(FieldInfo: TAsFieldInfo): String;
    function LPad(S: string; Ch: Char; Len: Integer): string;
    function RPad(S: string; Ch: Char; Len: Integer): string;
    function TypeDBToTypePascal(S: String): String;
    procedure WriteCreateQuery;
  public
    { public declarations }
    InfoTable: TAsTableInfo;
    InfoCrud: TCRUDInfo;
  end;

var
  FrmModel: TFrmModel;

implementation

uses MainFormU;

Const
  Ident = '  ';

{$R *.lfm}

{ TFrmModel }

procedure TFrmModel.FormShow(Sender: TObject);
begin
  GeneratorPascalClass;
  GeneratorDAOClass;
end;

procedure TFrmModel.ToolButton2Click(Sender: TObject);
begin
  SynEditDAO.Lines.SaveToFile(InfoCrud.DirDAO + UnitNameDAO + '.pas');
  SynEditModel.Lines.SaveToFile(InfoCrud.DirModel + UnitNameModel + '.pas');
end;

function TFrmModel.TypeDBToTypePascal(S:String):String;
begin
  if (UpperCase(S) = 'VARCHAR') OR (UpperCase(S) = 'BLOB') then
    Result := 'String'
  else if Pos('NUMERIC', UpperCase(S)) > 0 then
    Result := 'Double'
  else if Pos('TIMESTAMP', UpperCase(S)) > 0 then
    Result := 'TDateTime'
  else if Pos('DATE', UpperCase(S)) > 0 then
    Result := 'TDate'
  else
    Result := S;
end;

function TFrmModel.LPad(S: string; Ch: Char; Len: Integer): string;
var   RestLen: Integer;
begin   Result  := S;
  RestLen := Len - Length(s);
  if RestLen < 1 then Exit;
  Result := S + StringOfChar(Ch, RestLen);
end;

function TFrmModel.RPad(S: string; Ch: Char; Len: Integer): string;
var   RestLen: Integer;
begin   Result  := S;
  RestLen := Len - Length(s);
  if RestLen < 1 then Exit;
  Result := StringOfChar(Ch, RestLen) + S;
end;

procedure TFrmModel.GeneratorPascalClass;
Var
  I: Integer;
  MaxField, MaxType, MaxVar: Integer;
begin
  MaxField := 0;
  MaxType  := 0;
  MaxVar   :=0;

  For I:= 0 to InfoTable.AllFields.Count -1 do
  begin
    if MaxField < Length(InfoTable.AllFields[I].FieldName) then
      MaxField:= Length(InfoTable.AllFields[I].FieldName);
    if MaxType < Length(TypeDBToTypePascal(InfoTable.AllFields[I].FieldType)) then
      MaxType:= Length(TypeDBToTypePascal(InfoTable.AllFields[I].FieldType));
    if MaxVar < (Length(InfoTable.AllFields[I].FieldName) + 1) then
      MaxVar:= (Length(InfoTable.AllFields[I].FieldName) + 1);
  end;
  UnitNameModel:= 'U'+Copy(InfoTable.Tablename,InfoCrud.CopyTableName, Length(InfoTable.TableName));
  ClassNameModel := 'T'+Trim(Copy(InfoTable.Tablename,InfoCrud.CopyTableName, Length(InfoTable.TableName)));
  VarModel := Trim(Copy(InfoTable.Tablename,InfoCrud.CopyTableName, Length(InfoTable.TableName)));
  UnitNameDAO:= 'U'+Copy(InfoTable.Tablename,InfoCrud.CopyTableName, Length(InfoTable.TableName))+'DAO';
  ClassNameDAO := 'T'+Trim(Copy(InfoTable.Tablename,InfoCrud.CopyTableName, Length(InfoTable.TableName)))+'DAO';
  VarDAO := Trim(Copy(InfoTable.Tablename,InfoCrud.CopyTableName, Length(InfoTable.TableName)))+'DAO';
  SynEditModel.Lines.Clear;
  SynEditModel.Lines.Add('Unit ' + UnitNameModel + ';');
  SynEditModel.Lines.Add('');
  SynEditModel.Lines.Add('interface');
  SynEditModel.Lines.Add('');
  SynEditModel.Lines.Add('uses ');
  SynEditModel.Lines.Add(Ident + InfoCrud.UsesDefault);
  SynEditModel.Lines.Add('');
  SynEditModel.Lines.Add('type');
  SynEditModel.Lines.Add(ident + ClassNameModel +'= class');
  SynEditModel.Lines.Add('');
  SynEditModel.Lines.Add(ident+'private');
  //Cria Variaveis das Propriedades.
  For I:= 0 to InfoTable.AllFields.Count -1 do
  begin
    SynEditModel.Lines.Add(Ident + Ident + 'F'+LPad(InfoTable.AllFields[I].FieldName,' ',MaxVar) + ':' +
      LPad(TypeDBToTypePascal(InfoTable.AllFields[I].FieldType), ' ', MaxType) +';');
  end;
  SynEditModel.Lines.Add(ident+'public');
  //Cria Propriedades.
  SynEditModel.Lines.Add(Ident + Ident + '//Propertys Model');
  For I:= 0 to InfoTable.AllFields.Count -1 do
  begin
    SynEditModel.Lines.Add(Ident + Ident + 'Property ' + LPad(InfoTable.AllFields[I].FieldName,' ', MaxField) + ':' +
      LPad(TypeDBToTypePascal(InfoTable.AllFields[I].FieldType), ' ', MaxType) + ' read F' +
      LPad(InfoTable.AllFields[I].FieldName,' ',MaxVar) + ' write F'+LPad(InfoTable.AllFields[I].FieldName,' ',MaxVar)+';');
  end;
  //Cria Funcoes e Procedures CRUD;
  SynEditModel.Lines.Add(Ident + Ident + '//Functions and Procedures Model CRUD');

  if InfoCrud.ProcInsert.Enable then
    SynEditModel.Lines.Add(Ident + Ident + 'function '+InfoCrud.ProcInsert.ProcName+'('+ InfoCrud.Connection + '; '+
    VarModel + ':' + ClassNameModel +'; ' +
    InfoCrud.ReturnException+ '):Boolean;');

  if InfoCrud.ProcUpdate.Enable then
    SynEditModel.Lines.Add(Ident + Ident + 'function '+InfoCrud.ProcUpdate.ProcName+'('+ InfoCrud.Connection + '; '+
    VarModel + ':' + ClassNameModel+'; ' +
    InfoCrud.ReturnException+ '):Boolean;');

  if InfoCrud.ProcDelete.Enable then
    SynEditModel.Lines.Add(Ident + Ident + 'function '+InfoCrud.ProcDelete.ProcName+'('+ InfoCrud.Connection + '; '+
    VarModel + ':' + ClassNameModel +'; ' +
    InfoCrud.ReturnException+ '):Boolean;');

  if InfoCrud.ProcGetRecord.Enable then
    SynEditModel.Lines.Add(Ident + Ident + 'function '+InfoCrud.ProcGetRecord.ProcName+'('+ InfoCrud.Connection + '; '+
    Trim(Copy(InfoTable.Tablename,InfoCrud.CopyTableName, Length(InfoTable.TableName))) + ':' +
    'T'+Trim(Copy(InfoTable.Tablename,InfoCrud.CopyTableName, Length(InfoTable.TableName))) +'; ' +
    InfoCrud.ReturnException+ '):Boolean;');

  if InfoCrud.ProcListRecords.Enable then
    SynEditModel.Lines.Add(Ident + Ident + 'function '+InfoCrud.ProcListRecords.ProcName+'('+ InfoCrud.Connection + '; ' +
    'ObjLst: TObjectList; ' +
    'WhereSQL: String; '+
    InfoCrud.ReturnException+ '):Boolean;');
  SynEditModel.Lines.Add(ident+ 'end; ');
  SynEditModel.Lines.Add(ident+ '');
  SynEditModel.Lines.Add('implementation');
  SynEditModel.Lines.Add(ident+ '');
  SynEditModel.Lines.Add('uses ');
  SynEditModel.Lines.Add(Ident + UnitNameDAO+';');
  SynEditModel.Lines.Add(ident+ '');
  SynEditModel.Lines.Add('Var ');
  SynEditModel.Lines.Add(ident+ VarDAO+':' + ClassNameDAO +';');

  //Gerando Functions Code
  if InfoCrud.ProcInsert.Enable then
  begin
    SynEditModel.Lines.Add(ident+ '');
    SynEditModel.Lines.Add('function '+ClassNameModel+'.'+InfoCrud.ProcInsert.ProcName+'('+ InfoCrud.Connection + '; '+
    VarModel + ':' + ClassNameModel +'; ' +
    InfoCrud.ReturnException+ '):Boolean;');
    SynEditModel.Lines.Add('begin');
    SynEditModel.Lines.Add(Ident + 'Result := '+ VarDAO+'.'+InfoCrud.ProcInsert.ProcName+'('+ Copy(InfoCrud.Connection, 1, Pos(':',InfoCrud.Connection) -1) + ', '+
    VarModel  + ', '+
    Copy(InfoCrud.ReturnException, 1, Pos(':',InfoCrud.ReturnException) -1)+ ');');
    SynEditModel.Lines.Add('end;');
  end;
  if InfoCrud.ProcUpdate.Enable then
  begin
    SynEditModel.Lines.Add(ident+ '');
    SynEditModel.Lines.Add('function '+ClassNameModel+'.'+InfoCrud.ProcUpdate.ProcName+'('+ InfoCrud.Connection + '; '+
    VarModel + ':' + ClassNameModel+'; ' +
    InfoCrud.ReturnException+ '):Boolean;');
    SynEditModel.Lines.Add('begin');
    SynEditModel.Lines.Add(Ident + 'Result := ' +VarDAO+'.'+InfoCrud.ProcUpdate.ProcName+'('+ Copy(InfoCrud.Connection, 1, Pos(':',InfoCrud.Connection) -1) + ', '+
        VarModel +', ' + Copy(InfoCrud.ReturnException, 1, Pos(':',InfoCrud.ReturnException) -1)+ ');');
    SynEditModel.Lines.Add('end;');
  end;
  if InfoCrud.ProcDelete.Enable then
  begin
    SynEditModel.Lines.Add(ident+ '');
    SynEditModel.Lines.Add('function '+ClassNameModel+'.'+InfoCrud.ProcDelete.ProcName+'('+ InfoCrud.Connection + '; '+
    VarModel + ':' + ClassNameModel +'; ' +
    InfoCrud.ReturnException+ '):Boolean;');
    SynEditModel.Lines.Add('begin');
    SynEditModel.Lines.Add(Ident + 'Result := ' +VarDAO+'.'+InfoCrud.ProcDelete.ProcName+'('+ Copy(InfoCrud.Connection, 1, Pos(':',InfoCrud.Connection) -1) + ', '+
       VarModel +', ' + Copy(InfoCrud.ReturnException, 1, Pos(':',InfoCrud.ReturnException) -1)+ ');');
    SynEditModel.Lines.Add('end;');
  end;

  if InfoCrud.ProcGetRecord.Enable then
  begin
    SynEditModel.Lines.Add(ident+ '');
    SynEditModel.Lines.Add('function '+ClassNameModel+'.'+InfoCrud.ProcGetRecord.ProcName+'('+ InfoCrud.Connection + '; '+
    Trim(Copy(InfoTable.Tablename,InfoCrud.CopyTableName, Length(InfoTable.TableName))) + ':' +
    'T'+Trim(Copy(InfoTable.Tablename,InfoCrud.CopyTableName, Length(InfoTable.TableName))) +'; ' +
    InfoCrud.ReturnException+ '):Boolean;');
    SynEditModel.Lines.Add('begin');
    SynEditModel.Lines.Add(Ident + 'Result := ' +VarDAO+'.'+InfoCrud.ProcGetRecord.ProcName+'('+ Copy(InfoCrud.Connection, 1, Pos(':',InfoCrud.Connection) -1) + ', '+
      VarModel +', ' + Copy(InfoCrud.ReturnException, 1, Pos(':',InfoCrud.ReturnException) -1)+ ');');
    SynEditModel.Lines.Add('end;');
  end;
  if InfoCrud.ProcListRecords.Enable then
  begin
    SynEditModel.Lines.Add(ident+ '');
    SynEditModel.Lines.Add('function '+ClassNameModel+'.'+InfoCrud.ProcListRecords.ProcName+'('+ InfoCrud.Connection + '; ' +
    'ObjLst: TObjectList; ' +
    'WhereSQL: String; '+
    InfoCrud.ReturnException+ '):Boolean;');
    SynEditModel.Lines.Add('begin');
    SynEditModel.Lines.Add(Ident + 'Result := '+ VarDAO+'.'+InfoCrud.ProcListRecords.ProcName+'('+ Copy(InfoCrud.Connection, 1, Pos(':',InfoCrud.Connection) -1) + ', '+
    'ObjLst, ' +
    'WhereSQL, ' + Copy(InfoCrud.ReturnException, 1, Pos(':',InfoCrud.ReturnException) -1)+ ');');
    SynEditModel.Lines.Add('End;');
  end;
  SynEditModel.Lines.Add(ident+ '');
  SynEditModel.Lines.Add('end.');
end;

procedure TFrmModel.WriteCreateQuery;
begin
  SynEditDAO.Lines.Add(Ident + Ident + 'Qry := ' + InfoCrud.ClassQuery +'.Create(Nil);');
  SynEditDAO.Lines.Add(Ident + Ident + 'Qry.'+InfoCrud.QueryPropDatabase+':= ' + InfoCrud.QueryConDatabase +';');
  if Trim(InfoCrud.QueryPropTransaction) <> '' then
  SynEditDAO.Lines.Add(Ident + Ident + 'Qry.'+InfoCrud.QueryPropTransaction+':= ' + InfoCrud.QueryConTransaction +';');
  SynEditDAO.Lines.Add(Ident + Ident + 'Qry.SQL.Clear;');
end;

procedure TFrmModel.GeneratorDAOClass;
Var
  I, J: Integer;
  MaxField, MaxType, MaxVar: Integer;
  S: String;
  SQL: TStringList;
begin
  MaxField := 0;
  MaxType  := 0;
  MaxVar   :=0;

  For I:= 0 to InfoTable.AllFields.Count -1 do
  begin
    if MaxField < Length(InfoTable.AllFields[I].FieldName) then
      MaxField:= Length(InfoTable.AllFields[I].FieldName);
    if MaxType < Length(TypeDBToTypePascal(InfoTable.AllFields[I].FieldType)) then
      MaxType:= Length(TypeDBToTypePascal(InfoTable.AllFields[I].FieldType));
    if MaxVar < (Length(InfoTable.AllFields[I].FieldName) + 1) then
      MaxVar:= (Length(InfoTable.AllFields[I].FieldName) + 1);
  end;
  UnitNameDAO:= 'U'+Copy(InfoTable.Tablename,InfoCrud.CopyTableName, Length(InfoTable.TableName)) +'DAO';
  ClassNameDAO := 'T'+Trim(Copy(InfoTable.Tablename,InfoCrud.CopyTableName, Length(InfoTable.TableName)))+'DAO';
  VarDAO := Trim(Copy(InfoTable.Tablename,InfoCrud.CopyTableName, Length(InfoTable.TableName)))+'DAO';

  UnitNameModel:= 'U'+Copy(InfoTable.Tablename,InfoCrud.CopyTableName, Length(InfoTable.TableName));
  ClassNameModel := 'T'+Trim(Copy(InfoTable.Tablename,InfoCrud.CopyTableName, Length(InfoTable.TableName)));
  VarModel := Trim(Copy(InfoTable.Tablename,InfoCrud.CopyTableName, Length(InfoTable.TableName)));

  SynEditDAO.Lines.Clear;
  SynEditDAO.Lines.Add('Unit ' + UnitNameDAO + ';');
  SynEditDAO.Lines.Add('');
  SynEditDAO.Lines.Add('interface');
  SynEditDAO.Lines.Add('');
  SynEditDAO.Lines.Add('uses ');
  SynEditDAO.Lines.Add(Ident + UnitNameModel+','+InfoCrud.UsesDefault);
  SynEditDAO.Lines.Add('');
  SynEditDAO.Lines.Add('type');
  SynEditDAO.Lines.Add(ident + ClassNameDAO +'= class');
  SynEditDAO.Lines.Add('');
  SynEditDAO.Lines.Add(ident+'private');

  SynEditDAO.Lines.Add(ident+'public');
  //Cria Funcoes e Procedures CRUD;
  SynEditDAO.Lines.Add(Ident + Ident + '//Functions and Procedures Model CRUD');

  if InfoCrud.ProcInsert.Enable then
    SynEditDAO.Lines.Add(Ident + Ident + 'function '+InfoCrud.ProcInsert.ProcName+'('+ InfoCrud.Connection + '; '+
    VarModel + ':' + ClassNameModel +'; ' +
    InfoCrud.ReturnException+ '):Boolean;');

  if InfoCrud.ProcUpdate.Enable then
    SynEditDAO.Lines.Add(Ident + Ident + 'function '+InfoCrud.ProcUpdate.ProcName+'('+ InfoCrud.Connection + '; '+
    VarModel + ':' + ClassNameModel+'; ' +
    InfoCrud.ReturnException+ '):Boolean;');

  if InfoCrud.ProcDelete.Enable then
    SynEditDAO.Lines.Add(Ident + Ident + 'function '+InfoCrud.ProcDelete.ProcName+'('+ InfoCrud.Connection + '; '+
    VarModel + ':' + ClassNameModel +'; ' +
    InfoCrud.ReturnException+ '):Boolean;');

  if InfoCrud.ProcGetRecord.Enable then
    SynEditDAO.Lines.Add(Ident + Ident + 'function '+InfoCrud.ProcGetRecord.ProcName+'('+ InfoCrud.Connection + '; '+
    Trim(Copy(InfoTable.Tablename,InfoCrud.CopyTableName, Length(InfoTable.TableName))) + ':' +
    'T'+Trim(Copy(InfoTable.Tablename,InfoCrud.CopyTableName, Length(InfoTable.TableName))) +'; ' +
    InfoCrud.ReturnException+ '):Boolean;');

  if InfoCrud.ProcListRecords.Enable then
    SynEditDAO.Lines.Add(Ident + Ident + 'function '+InfoCrud.ProcListRecords.ProcName+'('+ InfoCrud.Connection + '; ' +
    'ObjLst: TObjectList; ' +
    'WhereSQL: String; '+
    InfoCrud.ReturnException+ '):Boolean;');
  SynEditDAO.Lines.Add(ident+ 'end; ');
  SynEditDAO.Lines.Add(ident+ '');
  SynEditDAO.Lines.Add('implementation');
  SynEditDAO.Lines.Add(ident+ '');
  SynEditDAO.Lines.Add(ident+ '');
  //Gerando Functions Code
  GeneratorCodeProcInsert;
  GeneratorCodeProcUpdate;
  GeneratorCodeProcDelete;
  GeneratorCodeProcGetItem;
  GeneratorCodeProcList;
  SynEditDAO.Lines.Add(ident+ '');
  SynEditDAO.Lines.Add('end.');
end;

function TFrmModel.IFNull(FieldInfo: TAsFieldInfo): String;
begin
  IF FieldInfo.AllowNull THEN
  BEGIN
  if UpperCase(FieldInfo.FieldType) = 'VARCHAR' then
    Result := 'IFNull('+':'+FieldInfo.FieldName+','')'
  else   if (UpperCase(FieldInfo.FieldType) = 'INTEGER') OR
    (UpperCase(FieldInfo.FieldType) = 'NUMERIC') or
    (UpperCase(FieldInfo.FieldType) = 'TIMESTAMP') OR
    (UpperCase(FieldInfo.FieldType) = 'TIME') OR
    (UpperCase(FieldInfo.FieldType) = 'LONGINT') OR
    (UpperCase(FieldInfo.FieldType) = 'DATE')THEN
    Result := 'IFNull('+':'+FieldInfo.FieldName+',0)';
  end
  ELSE
    Result := ':' + FieldInfo.FieldName;
end;

function TFrmModel.GenerateSqlQuery(queryType: TQueryType): TStringList;
Var
  I: Integer;
begin
  try
    Result := TStringList.Create;
    Case queryType of
      qtSelect: Begin
        Result.Add('SELECT * FROM ' + InfoTable.Tablename+' ');
      end;
      qtSelectItem: begin
        Result.Add('SELECT * FROM ' + InfoTable.Tablename);
        For I:=0 to InfoTable.PrimaryKeys.Count-1 do
        begin
          if I = 0 then
            Result.Add(#9+'WHERE (' + InfoTable.PrimaryKeys.Items[I].FieldName + ' = :' +InfoTable.PrimaryKeys.Items[I].FieldName + ')')
          else
            Result.Add(#9+'AND (' + InfoTable.PrimaryKeys.Items[I].FieldName + ' = :' +InfoTable.PrimaryKeys.Items[I].FieldName + ')');
        end;
      end;
      qtInsert: begin
        Result.Add('INSERT INTO ' + InfoTable.Tablename + '(');
        For I:=0 to InfoTable.AllFields.Count-1 do
        begin
          if I = InfoTable.AllFields.Count-1 then
            Result.Add(#9+InfoTable.AllFields[I].FieldName+')')
          else
            Result.Add(#9+InfoTable.AllFields[I].FieldName+', ')
        end;
        Result.Add(' VALUES (');
        For I:=0 to InfoTable.AllFields.Count-1 do
        begin
          if I = InfoTable.AllFields.Count-1 then
            Result.Add(#9+IfNull(InfoTable.AllFields[I])+')')
          else
            Result.Add(#9+IfNull(InfoTable.AllFields[I])+', ')
        end;
      end;
      qtUpdate: begin
        Result.Add('UPDATE ' + InfoTable.Tablename + ' SET ' );
        For I:=0 to InfoTable.AllFields.Count-1 do
        begin
          if InfoTable.PrimaryKeys.GetIndex(InfoTable.AllFields[I].FieldName) = -1 then
          begin
            if I = InfoTable.AllFields.Count-1 then
              Result.Add(#9+InfoTable.AllFields[I].FieldName+' = ' + IfNull(InfoTable.AllFields[I])+'')
            else
              Result.Add(#9+InfoTable.AllFields[I].FieldName+' = ' + IfNull(InfoTable.AllFields[I])+', ')
          end;
        end;
        For I:=0 to InfoTable.PrimaryKeys.Count-1 do
        begin
          if I = 0 then
            Result.Add(#9+' WHERE (' + InfoTable.PrimaryKeys.Items[I].FieldName + ' = :' +InfoTable.PrimaryKeys.Items[I].FieldName + ')')
          else
            Result.Add(#9+'AND (' + InfoTable.PrimaryKeys.Items[I].FieldName + ' = :' +InfoTable.PrimaryKeys.Items[I].FieldName + ')');
        end;
      end;
      qtDelete: begin
        Result.Add('DELETE FROM ' + InfoTable.Tablename);
        For I:=0 to InfoTable.PrimaryKeys.Count-1 do
        begin
          if I = 0 then
             Result.Add(#9+'WHERE (' + InfoTable.PrimaryKeys.Items[I].FieldName + ' = :' +InfoTable.PrimaryKeys.Items[I].FieldName + ')')
          else
             Result.Add(#9+'AND (' + InfoTable.PrimaryKeys.Items[I].FieldName + ' = :' +InfoTable.PrimaryKeys.Items[I].FieldName + ')');
        end;
      end;
    end;
  finally

  end;
end;

procedure TFrmModel.GeneratorCodeProcInsert;
Var
  SQL: TStringList;
  S:String;
  J:Integer;
begin
  if InfoCrud.ProcInsert.Enable then
  begin
    SynEditDAO.Lines.Add( 'function '+ClassNameDAO+'.'+InfoCrud.ProcInsert.ProcName+'('+ InfoCrud.Connection + '; '+
    VarModel + ':' + ClassNameModel +'; ' +
    InfoCrud.ReturnException+ '):Boolean;');
    SynEditDAO.Lines.Add('Var');
    SynEditDAO.Lines.Add(Ident + 'Qry:' + InfoCrud.ClassQuery+';');
    SynEditDAO.Lines.Add('begin');
    SynEditDAO.Lines.Add(Ident + 'try');
    WriteCreateQuery;
    SQL := GenerateSqlQuery(qtInsert);
    For J:= 0 to SQL.Count - 1 do
    begin
      SynEditDAO.Lines.Add(Ident + Ident +'Qry.Sql.Add('+ QuotedStr(SQL.Strings[J])+');');
    end;
    //Set Values Params.
    For J:= 0 to InfoTable.AllFields.Count - 1 do
    begin
      SynEditDAO.Lines.Add(Ident + Ident +'Qry.ParamByName('+ QuotedStr(InfoTable.AllFields[J].FieldName)+').Value := '+VarModel+'.'+InfoTable.AllFields[J].FieldName+';');
    end;



    SynEditDAO.Lines.Add(Ident + Ident + 'Qry.ExecSQL;');
    SynEditDAO.Lines.Add(Ident + Ident + 'Result := True;');
    SynEditDAO.Lines.Add(Ident + 'except');
    For J:= 0 to InfoCrud.ExceptionCode.Count - 1 do
    begin
      S := StringReplace(InfoCrud.ExceptionCode.Strings[J],'$UnitName', UnitNameDAO, [rfReplaceAll]);
      S := StringReplace(S,'$ProcName', InfoCrud.ProcInsert.ProcName,[rfReplaceAll]);
      SynEditDAO.Lines.Add(Ident +Ident +S);
    end;
    SynEditDAO.Lines.Add(Ident + 'end;');
    SynEditDAO.Lines.Add('End;');
  end;
end;

procedure TFrmModel.GeneratorCodeProcUpdate;
Var
  SQL: TStringList;
  S: String;
  J:Integer;
begin
  if InfoCrud.ProcUpdate.Enable then
  begin
    SynEditDAO.Lines.Add(ident+ '');
    SynEditDAO.Lines.Add('function '+ClassNameDAO+'.'+InfoCrud.ProcUpdate.ProcName+'('+ InfoCrud.Connection + '; '+
    VarModel + ':' + ClassNameModel+'; ' +
    InfoCrud.ReturnException+ '):Boolean;');
    SynEditDAO.Lines.Add('Var');
    SynEditDAO.Lines.Add(Ident + 'Qry:' + InfoCrud.ClassQuery+';');

    SynEditDAO.Lines.Add('begin');
    SynEditDAO.Lines.Add(Ident + 'try');
    WriteCreateQuery;
    SQL := GenerateSqlQuery(qtUpdate);
    For J:= 0 to SQL.Count - 1 do
    begin
      SynEditDAO.Lines.Add(Ident + Ident +'Qry.Sql.Add('+ QuotedStr(SQL.Strings[J])+');');
    end;
    //Set Values Params Fields and Primary Key.
    For J:= 0 to InfoTable.AllFields.Count - 1 do
    begin
      SynEditDAO.Lines.Add(Ident + Ident +'Qry.ParamByName('+ QuotedStr(InfoTable.AllFields[J].FieldName)+').Value := '+VarModel+'.'+InfoTable.AllFields[J].FieldName+';');
    end;
    SynEditDAO.Lines.Add(Ident + Ident + 'Qry.ExecSQL;');
    SynEditDAO.Lines.Add(Ident + Ident + 'Result := True;');
    SynEditDAO.Lines.Add(Ident + 'except');
    For J:= 0 to InfoCrud.ExceptionCode.Count - 1 do
    begin
      S := StringReplace(InfoCrud.ExceptionCode.Strings[J],'$UnitName', UnitNameDAO,[rfReplaceAll]);
      S := StringReplace(S,'$ProcName', InfoCrud.ProcUpdate.ProcName,[rfReplaceAll]);
      SynEditDAO.Lines.Add(Ident +Ident +S);
    end;
    SynEditDAO.Lines.Add(Ident + 'end;');
    SynEditDAO.Lines.Add('End;');
  end;
end;

procedure TFrmModel.GeneratorCodeProcDelete;
Var
  SQL: TStringList;
  S: String;
  J:Integer;
begin
  if InfoCrud.ProcDelete.Enable then
  begin
    SynEditDAO.Lines.Add(ident+ '');
    SynEditDAO.Lines.Add('function '+ClassNameDAO+'.'+InfoCrud.ProcDelete.ProcName+'('+ InfoCrud.Connection + '; '+
    VarModel + ':' + ClassNameModel +'; ' +
    InfoCrud.ReturnException+ '):Boolean;');
    SynEditDAO.Lines.Add('Var');
    SynEditDAO.Lines.Add(Ident + 'Qry:' + InfoCrud.ClassQuery+';');
    SynEditDAO.Lines.Add('begin');
    SynEditDAO.Lines.Add(Ident + 'try');
    WriteCreateQuery;
    SQL := GenerateSqlQuery(qtDelete);
    For J:= 0 to SQL.Count - 1 do
    begin
      SynEditDAO.Lines.Add(Ident + Ident +'Qry.Sql.Add('+ QuotedStr(SQL.Strings[J])+');');
    end;
    //Set Values Params Primary Key.
    For J:= 0 to InfoTable.PrimaryKeys.Count - 1 do
    begin
      SynEditDAO.Lines.Add(Ident + Ident +'Qry.ParamByName('+ QuotedStr(InfoTable.PrimaryKeys[J].FieldName)+').Value := '+VarModel+'.'+InfoTable.PrimaryKeys[J].FieldName+';');
    end;
    SynEditDAO.Lines.Add(Ident + Ident + 'Qry.ExecSQL;');
    SynEditDAO.Lines.Add(Ident + Ident + 'Result := True;');
    SynEditDAO.Lines.Add(Ident + 'except');
    For J:= 0 to InfoCrud.ExceptionCode.Count - 1 do
    begin
      S := StringReplace(InfoCrud.ExceptionCode.Strings[J],'$UnitName', UnitNameDAO,[rfReplaceAll]) ;
      S := StringReplace(S,'$ProcName', InfoCrud.ProcDelete.ProcName,[rfReplaceAll]);
      SynEditDAO.Lines.Add(Ident +Ident +S);
    end;
    SynEditDAO.Lines.Add(Ident + 'end;');
    SynEditDAO.Lines.Add('End;');
  end;
end;

procedure TFrmModel.GeneratorCodeProcGetItem;
Var
  SQL: TStringList;
  S: String;
  J:Integer;
begin
  if InfoCrud.ProcGetRecord.Enable then
  begin
    SynEditDAO.Lines.Add(ident+ '');
    SynEditDAO.Lines.Add('function '+ClassNameDAO+'.'+InfoCrud.ProcGetRecord.ProcName+'('+ InfoCrud.Connection + '; '+
    Trim(Copy(InfoTable.Tablename,InfoCrud.CopyTableName, Length(InfoTable.TableName))) + ':' +
    'T'+Trim(Copy(InfoTable.Tablename,InfoCrud.CopyTableName, Length(InfoTable.TableName))) +'; ' +
    InfoCrud.ReturnException+ '):Boolean;');
    SynEditDAO.Lines.Add('Var');
    SynEditDAO.Lines.Add(Ident + 'Qry:' + InfoCrud.ClassQuery+';');
    SynEditDAO.Lines.Add('begin');
    SynEditDAO.Lines.Add(Ident + 'try');
    WriteCreateQuery;
    SQL := GenerateSqlQuery(qtSelectItem);
    For J:= 0 to SQL.Count - 1 do
    begin
      SynEditDAO.Lines.Add(Ident + Ident +'Qry.Sql.Add('+ QuotedStr(SQL.Strings[J])+');');
    end;
    For J:= 0 to InfoTable.PrimaryKeys.Count - 1 do
    begin
      SynEditDAO.Lines.Add(Ident + Ident +'Qry.ParamByName('+ QuotedStr(InfoTable.PrimaryKeys[J].FieldName)+').Value := '+VarModel+'.'+InfoTable.PrimaryKeys[J].FieldName+';');
    end;
    SynEditDAO.Lines.Add(Ident + Ident + 'Qry.Open;');
    SynEditDAO.Lines.Add(Ident + Ident + 'if not Qry.isEmpty then ');
    SynEditDAO.Lines.Add(Ident + Ident + 'begin');
    For J:= 0 to InfoTable.AllFields.Count - 1 do
    begin
      SynEditDAO.Lines.Add(Ident + Ident + Ident + VarModel+'.'+InfoTable.AllFields[J].FieldName+' := '+'Qry.FieldByName('+QuotedStr(InfoTable.AllFields[J].FieldName)+').Value;');
    end;
    SynEditDAO.Lines.Add(Ident + Ident + 'end;');
    SynEditDAO.Lines.Add(Ident + Ident + 'Result := True;');
    SynEditDAO.Lines.Add(Ident + 'except');
    For J:= 0 to InfoCrud.ExceptionCode.Count - 1 do
    begin
      S := StringReplace(InfoCrud.ExceptionCode.Strings[J],'$UnitName', UnitNameDAO,[rfReplaceAll]);
      S := StringReplace(S,'$ProcName', InfoCrud.ProcGetRecord.ProcName,[rfReplaceAll]);
      SynEditDAO.Lines.Add(Ident +Ident +S);
    end;
    SynEditDAO.Lines.Add(Ident + 'end;');
    SynEditDAO.Lines.Add('End;');
  end;
end;

procedure TFrmModel.GeneratorCodeProcList;
Var
  SQL: TStringList;
  S: String;
  J:Integer;
begin
  if InfoCrud.ProcListRecords.Enable then
  begin
    SynEditDAO.Lines.Add(ident+ '');
    SynEditDAO.Lines.Add('function '+ClassNameDAO+'.'+InfoCrud.ProcListRecords.ProcName+'('+ InfoCrud.Connection + '; ' +
    'ObjLst: TObjectList; ' +
    'WhereSQL: String; '+
    InfoCrud.ReturnException+ '):Boolean;');
    SynEditDAO.Lines.Add('Var');
    SynEditDAO.Lines.Add(Ident + 'Qry:' + InfoCrud.ClassQuery+';');
    SynEditDAO.Lines.Add(Ident + VarModel + ':'+ClassNameModel+';');
    SynEditDAO.Lines.Add('begin');
    SynEditDAO.Lines.Add(Ident + 'try');
    WriteCreateQuery;
    SQL := GenerateSqlQuery(qtSelect);
    For J:= 0 to SQL.Count - 1 do
    begin
      SynEditDAO.Lines.Add(Ident + Ident +'Qry.Sql.Add('+ QuotedStr(SQL.Strings[J])+');');
    end;
    SynEditDAO.Lines.Add(Ident + Ident + 'if Trim(WhereSQL) <> '+QuotedStr('')+' then ');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + 'Qry.Sql.Add(WhereSQL);');
    SynEditDAO.Lines.Add(Ident + Ident + 'Qry.Open;');
    SynEditDAO.Lines.Add(Ident + Ident + 'Qry.First;');
    SynEditDAO.Lines.Add(Ident + Ident + 'While not Qry.Eof do ');
    SynEditDAO.Lines.Add(Ident + Ident + 'begin');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + VarModel+ ':= '+ClassNameModel+'.Create;');
    For J:= 0 to InfoTable.AllFields.Count - 1 do
    begin
      SynEditDAO.Lines.Add(Ident + Ident + Ident + VarModel+'.'+InfoTable.AllFields[J].FieldName+' := '+'Qry.FieldByName('+QuotedStr(InfoTable.AllFields[J].FieldName)+').Value;');
    end;
    SynEditDAO.Lines.Add(Ident + Ident + Ident + 'ObjLst.Add('+VarModel+');');

    SynEditDAO.Lines.Add(Ident + Ident + Ident + 'Qry.Next;');
    SynEditDAO.Lines.Add(Ident + Ident + 'end;');
    SynEditDAO.Lines.Add(Ident + Ident + 'Result := True;');
    SynEditDAO.Lines.Add(Ident + 'except');
    For J:= 0 to InfoCrud.ExceptionCode.Count - 1 do
    begin
      S := StringReplace(InfoCrud.ExceptionCode.Strings[J],'$UnitName', UnitNameDAO,[rfReplaceAll]);
      S := StringReplace(S,'$ProcName', InfoCrud.ProcListRecords.ProcName,[rfReplaceAll]);
      SynEditDAO.Lines.Add(Ident +Ident +S);
    end;
    SynEditDAO.Lines.Add(Ident + 'end;');
    SynEditDAO.Lines.Add('End;');
  end;
end;



end.

