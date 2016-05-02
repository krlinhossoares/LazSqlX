unit UFrmModel;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, SynHighlighterPas, SynHighlighterAny,
  SynCompletion, SynHighlighterJava, SynHighlighterSQL, Forms, Controls,
  Graphics, Dialogs, math, ComCtrls, ZDataset, ZConnection, AsTableInfo,
  AsCrudInfo, AsSqlGenerator, StrUtils;

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
    UnitNameDAO, ClassNameDAO, VarDAO, UnitNameModel, ClassNameModel, VarModel: string;

    function GenerateSqlQuery(queryType: TQueryType): TStringList;
    procedure EscreveSqlSynEditDao(StrList: TStringList);
    procedure GeneratorCodeProcDelete;
    procedure GeneratorCodeProcGetItem;
    procedure GeneratorCodeProcInsert;
    procedure GeneratorCodeProcList;
    procedure GeneratorCodeProcUpdate;
    procedure GeneratorDAOClass;
    procedure GeneratorPascalClass;
    function IFNull(FieldInfo: TAsFieldInfo): string;
    function Limpa(S: String): String;
    function LPad(S: string; Ch: char; Len: integer): string;
    function RPad(S: string; Ch: char; Len: integer): string;
    function TypeDBToTypePascal(S: string): string;
    function TypeDBToTypePascalParams(Field: TAsFieldInfo): string;
    procedure WriteCreateQuery;
    function WithVar(s: string): string;
    function WithOut(s: string): string;
  public
    { public declarations }
    InfoTable: TAsTableInfo;
    InfoCrud: TCRUDInfo;
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
  GeneratorPascalClass;
  GeneratorDAOClass;
end;

procedure TFrmModel.ToolButton2Click(Sender: TObject);
begin
  SynEditDAO.Lines.SaveToFile(InfoCrud.DirDAO + UnitNameDAO + '.pas');
  SynEditModel.Lines.SaveToFile(InfoCrud.DirModel + UnitNameModel + '.pas');
end;

function TFrmModel.TypeDBToTypePascal(S: string): string;
begin
  if (UpperCase(S) = 'VARCHAR') or (UpperCase(S) = 'BLOB') then
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

function TFrmModel.TypeDBToTypePascalParams(Field: TAsFieldInfo): string;
begin
    Result := '';

    if LowerCase(TAsFieldInfo(Field).FieldType) = 'Unknow'        then Result := 'ERRO_FIELDTYPE_NAO_DEFINIDO';
    if LowerCase(TAsFieldInfo(Field).FieldType) = 'integer'       then Result := 'AsInteger';
    if LowerCase(TAsFieldInfo(Field).FieldType) = 'smallint'      then Result := 'AsInteger';
    if LowerCase(TAsFieldInfo(Field).FieldType) = 'word'          then Result := 'AsInteger';
    if LowerCase(TAsFieldInfo(Field).FieldType) = 'string'        then Result := 'AsString';
    if LowerCase(TAsFieldInfo(Field).FieldType) = 'varchar'       then Result := 'AsString';
    if LowerCase(TAsFieldInfo(Field).FieldType) = 'char'          then Result := 'AsString';
    if LowerCase(TAsFieldInfo(Field).FieldType) = 'float'         then Result := 'AsFloat';
    if LowerCase(TAsFieldInfo(Field).FieldType) = 'currency'      then Result := 'AsFloat';
    if LowerCase(TAsFieldInfo(Field).FieldType) = 'date'          then Result := 'AsDate';
    if LowerCase(TAsFieldInfo(Field).FieldType) = 'time'          then Result := 'AsTime';
    if LowerCase(TAsFieldInfo(Field).FieldType) = 'dateTime'      then Result := 'AsDateTime';
    if LowerCase(TAsFieldInfo(Field).FieldType) = 'blob'          then Result := 'AsString';
    if LowerCase(TAsFieldInfo(Field).FieldType) = 'memo'          then Result := 'AsString';
    if LowerCase(TAsFieldInfo(Field).FieldType) = 'widestring'    then Result := 'AsString';
    if LowerCase(TAsFieldInfo(Field).FieldType) = 'widememo'      then Result := 'AsString';
    if LowerCase(TAsFieldInfo(Field).FieldType) = 'fixedwidechar' then Result := 'AsString';
    if LowerCase(TAsFieldInfo(Field).FieldType) = 'boolean'       then Result := 'AsBoolean';
    if LowerCase(TAsFieldInfo(Field).FieldType) = 'timestamp'     then Result := 'AsDateTime';
    if LowerCase(TAsFieldInfo(Field).FieldType) = 'bytes'         then Result := 'AsInteger';
    if LowerCase(TAsFieldInfo(Field).FieldType) = 'bcd'           then Result := 'AsBCD';
    if LowerCase(TAsFieldInfo(Field).FieldType) = 'fixedchar'     then Result := 'AsString';

    if Result = '' then Result := 'ERRO_FIELDTYPE_NAO_DEFINIDO';


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
  I: integer;
  MaxField, MaxType, MaxVar: integer;
  StrFunctionNameInsert, StrFunctionNameUpdate, StrFunctionNameDelete, StrFunctionNameGet, StrFunctionNameList: String;
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
  SynEditModel.Lines.Add('Unit ' + UnitNameModel + ';');
  SynEditModel.Lines.Add('');
  SynEditModel.Lines.Add('interface');
  SynEditModel.Lines.Add('');
  SynEditModel.Lines.Add('uses ');
  SynEditModel.Lines.Add(Ident + InfoCrud.UsesDefault);
  SynEditModel.Lines.Add('');
  SynEditModel.Lines.Add('type');
  SynEditModel.Lines.Add(ident + ClassNameModel + '= class');
  SynEditModel.Lines.Add('');
  SynEditModel.Lines.Add(ident + 'private');
  //Cria Variaveis das Propriedades.
  for I := 0 to InfoTable.AllFields.Count - 1 do
  begin
    SynEditModel.Lines.Add(Ident + Ident +
      'F' + LPad(InfoTable.AllFields[I].FieldName, ' ', MaxVar) + ':' +
      LPad(TypeDBToTypePascal(InfoTable.AllFields[I].FieldType), ' ', MaxType) + ';');
  end;
  SynEditModel.Lines.Add(ident + 'public');
  //Cria Propriedades.
  SynEditModel.Lines.Add(Ident + Ident + '//Propertys Model');
  for I := 0 to InfoTable.AllFields.Count - 1 do
  begin
    SynEditModel.Lines.Add(Ident + Ident + 'Property ' +
      LPad(InfoTable.AllFields[I].FieldName, ' ', MaxField) + ':' +
      LPad(TypeDBToTypePascal(InfoTable.AllFields[I].FieldType), ' ', MaxType) +
      ' read F' + LPad(InfoTable.AllFields[I].FieldName, ' ', MaxVar) +
      ' write F' + LPad(InfoTable.AllFields[I].FieldName, ' ', MaxVar) + ';');
  end;
  //Cria Funcoes e Procedures CRUD;
  SynEditModel.Lines.Add(Ident + Ident + '//Functions and Procedures Model CRUD');

  if InfoCrud.ProcInsert.Enable then
  begin
    StrFunctionNameInsert := InfoCrud.ProcInsert.ProcName + '(';
      if StrFunctionNameInsert <> InfoCrud.ProcInsert.ProcName + '(' then
        StrFunctionNameInsert := StrFunctionNameInsert + ';' + InfoCrud.Connection
      else
        StrFunctionNameInsert := StrFunctionNameInsert + InfoCrud.Connection;

      if StrFunctionNameInsert <> InfoCrud.ProcInsert.ProcName + '(' then
        StrFunctionNameInsert := StrFunctionNameInsert + '; ' + WithVar(VarModel) + ': ' + ClassNameModel
      else
        StrFunctionNameInsert := StrFunctionNameInsert + WithVar(VarModel) + ': ' + ClassNameModel;

      if (StrFunctionNameInsert <> InfoCrud.ProcInsert.ProcName + '(') and (InfoCrud.HasReturnException)then
        StrFunctionNameInsert := StrFunctionNameInsert + ';' + InfoCrud.ReturnException
      else
        StrFunctionNameInsert := StrFunctionNameInsert + InfoCrud.ReturnException;

      SynEditModel.Lines.Add(Ident + Ident +'function ' +StrFunctionNameInsert+'):Boolean;');
      StrFunctionNameInsert := 'function ' + ClassNameModel + '.' + StrFunctionNameInsert + '):Boolean;';

  end;

  if InfoCrud.ProcUpdate.Enable then
  begin
    StrFunctionNameUpdate := InfoCrud.ProcUpdate.ProcName + '(';

    if StrFunctionNameUpdate <>
      InfoCrud.ProcUpdate.ProcName + '(' then
      StrFunctionNameUpdate := StrFunctionNameUpdate + ';' + InfoCrud.Connection
    else
      StrFunctionNameUpdate := StrFunctionNameUpdate + InfoCrud.Connection;

    if StrFunctionNameUpdate <>
      InfoCrud.ProcUpdate.ProcName + '(' then
      StrFunctionNameUpdate := StrFunctionNameUpdate + '; ' + WithVar(VarModel) + ': ' + ClassNameModel
    else
      StrFunctionNameUpdate := StrFunctionNameUpdate + WithVar(VarModel) + ': ' + ClassNameModel;

    if (StrFunctionNameUpdate <> InfoCrud.ProcUpdate.ProcName + '(') and (InfoCrud.HasReturnException) then
      StrFunctionNameUpdate := StrFunctionNameUpdate + ';' + InfoCrud.ReturnException
    else
      StrFunctionNameUpdate := StrFunctionNameUpdate + InfoCrud.ReturnException;

    SynEditModel.Lines.Add(Ident + Ident +'function ' + StrFunctionNameUpdate+ '):Boolean;');
    StrFunctionNameUpdate := 'function ' + ClassNameModel + '.' +StrFunctionNameUpdate + '):Boolean;';

   {SynEditDAO.Lines.Add(Ident + Ident + 'function ' + InfoCrud.ProcUpdate.ProcName + '(' +
      InfoCrud.Connection + '; ' + VarModel + ':' + ClassNameModel + '; ' +
      InfoCrud.ReturnException + '):Boolean;');}
  end;

  if InfoCrud.ProcDelete.Enable then
  begin
    StrFunctionNameDelete := InfoCrud.ProcDelete.ProcName + '(';
    if StrFunctionNameDelete <>
      InfoCrud.ProcDelete.ProcName + '(' then
      StrFunctionNameDelete := StrFunctionNameDelete + ';' + InfoCrud.Connection
    else
      StrFunctionNameDelete := StrFunctionNameDelete + InfoCrud.Connection;

    if StrFunctionNameDelete <>
      InfoCrud.ProcDelete.ProcName + '(' then
      StrFunctionNameDelete := StrFunctionNameDelete + '; ' + WithVar(VarModel) + ': ' + ClassNameModel
    else
      StrFunctionNameDelete := StrFunctionNameDelete + WithVar(VarModel) + ': ' + ClassNameModel;

    if (StrFunctionNameDelete <> InfoCrud.ProcDelete.ProcName + '(') and (InfoCrud.HasReturnException) then
      StrFunctionNameDelete := StrFunctionNameDelete + ';' + InfoCrud.ReturnException
    else
      StrFunctionNameDelete := StrFunctionNameDelete + InfoCrud.ReturnException;

    SynEditModel.Lines.Add(Ident + Ident +'function ' +  StrFunctionNameDelete+ '):Boolean;');
    StrFunctionNameDelete := 'function ' + ClassNameModel + '.' + StrFunctionNameDelete + '):Boolean;';

  end;

  if InfoCrud.ProcGetRecord.Enable then
  begin
    StrFunctionNameGet := InfoCrud.ProcGetRecord.ProcName + '(';

    if StrFunctionNameGet <>
      InfoCrud.ProcGetRecord.ProcName + '(' then
      StrFunctionNameGet := StrFunctionNameGet + ';' + InfoCrud.Connection
    else
      StrFunctionNameGet := StrFunctionNameGet + InfoCrud.Connection;

    if StrFunctionNameGet <>
      InfoCrud.ProcGetRecord.ProcName + '(' then
      StrFunctionNameGet := StrFunctionNameGet + '; ' + WithVar(VarModel) + ': ' + ClassNameModel
    else
      StrFunctionNameGet := StrFunctionNameGet + WithVar(VarModel) + ': ' + ClassNameModel;

    if (StrFunctionNameGet <> InfoCrud.ProcGetRecord.ProcName + '(') and (InfoCrud.HasReturnException) then
      StrFunctionNameGet := StrFunctionNameGet + ';' + InfoCrud.ReturnException
    else
      StrFunctionNameGet := StrFunctionNameGet + InfoCrud.ReturnException;

    SynEditModel.Lines.Add(Ident + Ident + 'function ' + StrFunctionNameGet+'):Boolean;');
    StrFunctionNameGet := 'function ' + ClassNameModel + '.' +StrFunctionNameGet + '):Boolean;';

  end;

  if InfoCrud.ProcListRecords.Enable then
  begin
    StrFunctionNameList :=  InfoCrud.ProcListRecords.ProcName + '(';
    if StrFunctionNameList <> InfoCrud.ProcListRecords.ProcName + '(' then
      StrFunctionNameList := StrFunctionNameList + ';' + InfoCrud.Connection
    else
      StrFunctionNameList := StrFunctionNameList + InfoCrud.Connection;

    if StrFunctionNameList <> InfoCrud.ProcListRecords.ProcName + '(' then
      StrFunctionNameList := StrFunctionNameList + '; out ObjLst: TObjectList; ' + 'WhereSQL: String'
    else
      StrFunctionNameList := StrFunctionNameList + ' out ObjLst: TObjectList; ' + 'WhereSQL: String';

    if (StrFunctionNameList <> InfoCrud.ProcListRecords.ProcName + '(') and (InfoCrud.HasReturnException)then
      StrFunctionNameList := StrFunctionNameList + ';' + InfoCrud.ReturnException
    else
      StrFunctionNameList := StrFunctionNameList + InfoCrud.ReturnException;

    SynEditModel.Lines.Add(Ident + Ident + 'function ' + StrFunctionNameList+ '):Boolean;');
    StrFunctionNameList := 'function ' + ClassNameModel + '.' +StrFunctionNameList + '):Boolean;';

  end;

  SynEditModel.Lines.Add(ident + 'end; ');
  SynEditModel.Lines.Add(ident + '');
  SynEditModel.Lines.Add('implementation');
  SynEditModel.Lines.Add(ident + '');
  SynEditModel.Lines.Add('uses ');
  SynEditModel.Lines.Add(Ident + UnitNameDAO + ';');
  SynEditModel.Lines.Add(ident + '');
  SynEditModel.Lines.Add('Var ');
  SynEditModel.Lines.Add(ident + VarDAO + ':' + ClassNameDAO + ';');

  //Gerando Functions Code
  if InfoCrud.ProcInsert.Enable then
  begin
    SynEditModel.Lines.Add(ident + '');
    SynEditModel.Lines.Add(StrFunctionNameInsert);
    SynEditModel.Lines.Add('begin');
    StrFunctionNameInsert := Ident + 'Result := ' + VarDAO + '.' + InfoCrud.ProcInsert.ProcName + '(';
    if (StrFunctionNameInsert <> Ident + 'Result := ' + VarDAO + '.' + InfoCrud.ProcInsert.ProcName + '(') and
      (Trim(Copy(InfoCrud.Connection, 1,Pos(':', InfoCrud.Connection) - 1)) <> '') then
      StrFunctionNameInsert:= StrFunctionNameInsert + ','+Limpa(Copy(InfoCrud.Connection, 1,
      Pos(':', InfoCrud.Connection) - 1))
    else
      StrFunctionNameInsert:= StrFunctionNameInsert + Limpa(Copy(InfoCrud.Connection, 1,
        Pos(':', InfoCrud.Connection) - 1));

    if (StrFunctionNameInsert <> Ident + 'Result := ' + VarDAO + '.' +
      InfoCrud.ProcUpdate.ProcName + '(') then
      StrFunctionNameInsert:= StrFunctionNameInsert + ', ' + VarModel
    else
      StrFunctionNameInsert:= StrFunctionNameInsert + VarModel;

    if (StrFunctionNameInsert <> Ident + 'Result := ' + VarDAO + '.' +
      InfoCrud.ProcInsert.ProcName + '(') and (Trim(Copy(InfoCrud.ReturnException, 1,Pos(':', InfoCrud.ReturnException) - 1)) <> '') then
      StrFunctionNameInsert:= StrFunctionNameInsert + ', '+ Copy(InfoCrud.ReturnException, 1, Pos(':', InfoCrud.ReturnException) - 1)
    else
      StrFunctionNameInsert:= StrFunctionNameInsert + Copy(InfoCrud.ReturnException, 1, Pos(':', InfoCrud.ReturnException) - 1);

    StrFunctionNameInsert:= StrFunctionNameInsert + ');';
    SynEditModel.Lines.Add(StrFunctionNameInsert);
    {SynEditModel.Lines.Add(Ident + 'Result := ' +
      VarDAO + '.' + InfoCrud.ProcInsert.ProcName + '(' + Copy(InfoCrud.Connection,
      1, Pos(':', InfoCrud.Connection) - 1) + ', ' + VarModel + ', ' +
      Copy(InfoCrud.ReturnException, 1, Pos(':', InfoCrud.ReturnException) - 1) + ');');}
    SynEditModel.Lines.Add('end;');
  end;
  if InfoCrud.ProcUpdate.Enable then
  begin
    SynEditModel.Lines.Add(ident + '');
    SynEditModel.Lines.Add(StrFunctionNameUpdate);
    SynEditModel.Lines.Add('begin');

    StrFunctionNameUpdate := Ident + 'Result := ' + VarDAO + '.' +
      InfoCrud.ProcUpdate.ProcName + '(';
    if (StrFunctionNameUpdate <> Ident + 'Result := ' + VarDAO + '.' +
      InfoCrud.ProcUpdate.ProcName + '(') and (Trim(Copy(InfoCrud.Connection, 1,
      Pos(':', InfoCrud.Connection) - 1)) <> '') then
      StrFunctionNameUpdate:= StrFunctionNameUpdate + ','+Limpa(Copy(InfoCrud.Connection, 1,
      Pos(':', InfoCrud.Connection) - 1))
    else
      StrFunctionNameUpdate:= StrFunctionNameUpdate + Limpa(Copy(InfoCrud.Connection, 1,
        Pos(':', InfoCrud.Connection) - 1));

    if (StrFunctionNameUpdate <> Ident + 'Result := ' + VarDAO + '.' +
      InfoCrud.ProcUpdate.ProcName + '(') then
      StrFunctionNameUpdate:= StrFunctionNameUpdate + ', ' + VarModel
    else
      StrFunctionNameUpdate:= StrFunctionNameUpdate + VarModel;

    if (StrFunctionNameUpdate <> Ident + 'Result := ' + VarDAO + '.' +
      InfoCrud.ProcUpdate.ProcName + '(') and (Trim(Copy(InfoCrud.ReturnException, 1,
        Pos(':', InfoCrud.ReturnException) - 1)) <> '') then
      StrFunctionNameUpdate:= StrFunctionNameUpdate + ', '+ Copy(InfoCrud.ReturnException, 1, Pos(':', InfoCrud.ReturnException) - 1)
    else
      StrFunctionNameUpdate:= StrFunctionNameUpdate + Copy(InfoCrud.ReturnException, 1, Pos(':', InfoCrud.ReturnException) - 1);

    StrFunctionNameUpdate:= StrFunctionNameUpdate + ');';
    SynEditModel.Lines.Add(StrFunctionNameUpdate);

{    SynEditModel.Lines.Add(Ident + 'Result := ' + VarDAO + '.' +
      InfoCrud.ProcUpdate.ProcName + '(' + Copy(InfoCrud.Connection, 1,
      Pos(':', InfoCrud.Connection) - 1) + ', ' + VarModel + ', ' +
      Copy(InfoCrud.ReturnException, 1, Pos(':', InfoCrud.ReturnException) - 1) + ');');}
    SynEditModel.Lines.Add('end;');
  end;
  if InfoCrud.ProcDelete.Enable then
  begin
    SynEditModel.Lines.Add(ident + '');
    SynEditModel.Lines.Add(StrFunctionNameDelete);
    SynEditModel.Lines.Add('begin');

    StrFunctionNameDelete := Ident + 'Result := ' + VarDAO + '.' +
      InfoCrud.ProcDelete.ProcName + '(';

    if (StrFunctionNameDelete <> (Ident + 'Result := ' + VarDAO + '.' +InfoCrud.ProcDelete.ProcName + '(')) and
      (Trim(Copy(InfoCrud.Connection, 1, Pos(':', InfoCrud.Connection) - 1)) <> '') then
      StrFunctionNameDelete := StrFunctionNameDelete + ', ' + Limpa(Copy(InfoCrud.Connection, 1,Pos(':', InfoCrud.Connection) - 1))
    else
      StrFunctionNameDelete := StrFunctionNameDelete + Limpa(Copy(InfoCrud.Connection, 1,Pos(':', InfoCrud.Connection) - 1));

    if (StrFunctionNameDelete <> Trim(Ident + 'Result := ' + VarDAO + '.' +InfoCrud.ProcDelete.ProcName + '(')) then
      StrFunctionNameDelete := StrFunctionNameDelete + ', ' + VarModel
    else
      StrFunctionNameDelete := StrFunctionNameDelete + VarModel;

    if (StrFunctionNameDelete <> Trim(Ident + 'Result := ' + VarDAO + '.' +InfoCrud.ProcDelete.ProcName + '(')) and
      (Trim(Copy(InfoCrud.ReturnException, 1, Pos(':', InfoCrud.ReturnException) - 1)) <> '') then
      StrFunctionNameDelete := StrFunctionNameDelete + ', ' + Copy(InfoCrud.ReturnException, 1, Pos(':', InfoCrud.ReturnException) - 1)
    else
      StrFunctionNameDelete := StrFunctionNameDelete + Copy(InfoCrud.ReturnException, 1, Pos(':', InfoCrud.ReturnException) - 1);

    StrFunctionNameDelete:=  StrFunctionNameDelete + ');';
    SynEditModel.Lines.Add(StrFunctionNameDelete);
    {SynEditModel.Lines.Add(Ident + 'Result := ' + VarDAO + '.' +
      InfoCrud.ProcDelete.ProcName + '(' + Copy(InfoCrud.Connection, 1,
      Pos(':', InfoCrud.Connection) - 1) + ', ' + VarModel + ', ' +
      Copy(InfoCrud.ReturnException, 1, Pos(':', InfoCrud.ReturnException) - 1) + ');');
    }
    SynEditModel.Lines.Add('end;');
  end;

  if InfoCrud.ProcGetRecord.Enable then
  begin
    SynEditModel.Lines.Add(ident + '');
    SynEditModel.Lines.Add(StrFunctionNameGet);
    SynEditModel.Lines.Add('begin');

    StrFunctionNameGet := Ident + 'Result := ' + VarDAO + '.' + InfoCrud.ProcGetRecord.ProcName + '(';

    if (StrFunctionNameGet <> Ident +'Result := ' + VarDAO + '.' + InfoCrud.ProcGetRecord.ProcName + '(') and
      (Trim(Copy(InfoCrud.Connection, 1,Pos(':', InfoCrud.Connection) - 1))<>'') then
      StrFunctionNameGet := StrFunctionNameGet  +', ' + Limpa(Copy(InfoCrud.Connection, 1,Pos(':', InfoCrud.Connection) - 1))
    else
      StrFunctionNameGet := StrFunctionNameGet  + Limpa(Copy(InfoCrud.Connection, 1,Pos(':', InfoCrud.Connection) - 1));

    if (StrFunctionNameGet <> Ident +'Result := ' + VarDAO + '.' + InfoCrud.ProcGetRecord.ProcName + '(') then
      StrFunctionNameGet := StrFunctionNameGet  +', ' + VarModel
    else
      StrFunctionNameGet := StrFunctionNameGet  + VarModel;


    if (StrFunctionNameGet <> (Ident + 'Result := ' + VarDAO + '.' +InfoCrud.ProcGetRecord.ProcName + '(')) and
       (Trim(Copy(InfoCrud.ReturnException, 1, Pos(':', InfoCrud.ReturnException) - 1)) <> '') then
      StrFunctionNameGet := StrFunctionNameGet + ', ' + Copy(InfoCrud.ReturnException, 1, Pos(':', InfoCrud.ReturnException) - 1)
    else
      StrFunctionNameGet := StrFunctionNameGet + Copy(InfoCrud.ReturnException, 1, Pos(':', InfoCrud.ReturnException) - 1);

    StrFunctionNameGet:=  StrFunctionNameGet + ');';
    SynEditModel.Lines.Add(StrFunctionNameGet);

    {SynEditModel.Lines.Add(Ident + 'Result := ' + VarDAO + '.' +
      InfoCrud.ProcGetRecord.ProcName + '(' + Copy(InfoCrud.Connection, 1,
      Pos(':', InfoCrud.Connection) - 1) + ', ' + VarModel + ', ' +
      Copy(InfoCrud.ReturnException, 1, Pos(':', InfoCrud.ReturnException) - 1) + ');');}

    SynEditModel.Lines.Add('end;');
  end;
  if InfoCrud.ProcListRecords.Enable then
  begin
    SynEditModel.Lines.Add(ident + '');
    SynEditModel.Lines.Add(StrFunctionNameList);
    SynEditModel.Lines.Add('begin');

    StrFunctionNameList :=Ident +  'Result := ' + VarDAO + '.' + InfoCrud.ProcListRecords.ProcName + '(';

    if (StrFunctionNameList <> Ident +'Result := ' + VarDAO + '.' + InfoCrud.ProcListRecords.ProcName + '(') and
      (Trim(Copy(InfoCrud.Connection, 1,Pos(':', InfoCrud.Connection) - 1))<>'') then
      StrFunctionNameList := StrFunctionNameList  +', ' + Limpa(Copy(InfoCrud.Connection, 1,Pos(':', InfoCrud.Connection) - 1))
    else
      StrFunctionNameList := StrFunctionNameList  + Limpa(Copy(InfoCrud.Connection, 1,Pos(':', InfoCrud.Connection) - 1));

    if (StrFunctionNameList <> Ident +'Result := ' + VarDAO + '.' + InfoCrud.ProcListRecords.ProcName + '(') then
      StrFunctionNameList := StrFunctionNameList  +', ObjLst, WhereSQL'
    else
      StrFunctionNameList := StrFunctionNameList  +  'ObjLst, WhereSQL';

    if (StrFunctionNameList <> Trim(Ident + 'Result := ' + VarDAO + '.' +InfoCrud.ProcListRecords.ProcName + '(')) and
       (Trim(Copy(InfoCrud.ReturnException, 1, Pos(':', InfoCrud.ReturnException) - 1)) <> '') then
      StrFunctionNameList := StrFunctionNameList + ', ' + Copy(InfoCrud.ReturnException, 1, Pos(':', InfoCrud.ReturnException) - 1)
    else
      StrFunctionNameList := StrFunctionNameList + Copy(InfoCrud.ReturnException, 1, Pos(':', InfoCrud.ReturnException) - 1);


    StrFunctionNameList:=  StrFunctionNameList + ');';
    SynEditModel.Lines.Add(StrFunctionNameList);


    {SynEditModel.Lines.Add(Ident + 'Result := ' +
      VarDAO + '.' + InfoCrud.ProcListRecords.ProcName + '(' +
      Limpa(Copy(InfoCrud.Connection, 1,Pos(':', InfoCrud.Connection) - 1)) + ', ' +
      'ObjLst, ' + 'WhereSQL, ' + Copy(InfoCrud.ReturnException, 1,
      Pos(':', InfoCrud.ReturnException) - 1) + ');');}
    SynEditModel.Lines.Add('End;');
  end;
  SynEditModel.Lines.Add(ident + '');
  SynEditModel.Lines.Add('end.');
end;

procedure TFrmModel.WriteCreateQuery;
begin
  SynEditDAO.Lines.Add(Ident + Ident + 'Qry := ' + InfoCrud.ClassQuery + '.Create(Master.Con);');

  {/SynEditDAO.Lines.Add(Ident + Ident + 'Qry.' + InfoCrud.QueryPropDatabase + ':= ' +
    InfoCrud.QueryConDatabase + ';');
  //SynEditDAO.Lines.Add(Ident + Ident + 'Qry.'+ InfoCrud.Connection. );
  if Trim(InfoCrud.QueryPropTransaction) <> '' then
    SynEditDAO.Lines.Add(Ident + Ident + 'Qry.' + InfoCrud.QueryPropTransaction + ':= ' +
      InfoCrud.QueryConTransaction + ';');                                               }

  SynEditDAO.Lines.Add(Ident + Ident + 'Qry.SQL.Clear;');
end;

function TFrmModel.WithVar(s: string): string;
begin
  result := 'var ' + Trim(StringReplace(S, 'var ', '', [rfIgnoreCase, rfReplaceAll]));
end;

function TFrmModel.WithOut(s: string): string;
begin
  result := 'out ' + Trim(StringReplace(S, 'out ', '', [rfIgnoreCase, rfReplaceAll]));
end;

procedure TFrmModel.GeneratorDAOClass;
var
  I, J: integer;
  MaxField, MaxType, MaxVar: integer;
  S: string;
  SQL: TStringList;
  StrFunctionName: String;
begin
  MaxField := 0;
  MaxType  := 0;
  MaxVar   := 0;

  for I := 0 to InfoTable.AllFields.Count - 1 do
  begin
    if MaxField < Length(InfoTable.AllFields[I].FieldName) then
      MaxField := Length(InfoTable.AllFields[I].FieldName);
    if MaxType < Length(TypeDBToTypePascal(InfoTable.AllFields[I].FieldType)) then
      MaxType := Length(TypeDBToTypePascal(InfoTable.AllFields[I].FieldType));
    if MaxVar < (Length(InfoTable.AllFields[I].FieldName) + 1) then
      MaxVar := (Length(InfoTable.AllFields[I].FieldName) + 1);
  end;

  UnitNameDAO  := 'U' + Copy(InfoTable.Tablename, InfoCrud.CopyTableName, Length(InfoTable.TableName)) + 'DAO';
  ClassNameDAO := 'T' + Trim(Copy(InfoTable.Tablename, InfoCrud.CopyTableName, Length(InfoTable.TableName))) + 'DAO';
  VarDAO       := Trim(Copy(InfoTable.Tablename, InfoCrud.CopyTableName, Length(InfoTable.TableName))) + 'DAO';

  UnitNameModel  := 'U' + Copy(InfoTable.Tablename, InfoCrud.CopyTableName, Length(InfoTable.TableName));
  ClassNameModel := 'T' + Trim(Copy(InfoTable.Tablename, InfoCrud.CopyTableName, Length(InfoTable.TableName)));
  VarModel       := Trim(Copy(InfoTable.Tablename, InfoCrud.CopyTableName, Length(InfoTable.TableName)));

  SynEditDAO.Lines.Clear;
  SynEditDAO.Lines.Add('Unit ' + UnitNameDAO + ';');
  SynEditDAO.Lines.Add('');
  SynEditDAO.Lines.Add('interface');
  SynEditDAO.Lines.Add('');
  SynEditDAO.Lines.Add('uses ');
  SynEditDAO.Lines.Add(Ident + UnitNameModel + ', ' + InfoCrud.UsesDefault);
  SynEditDAO.Lines.Add('');
  SynEditDAO.Lines.Add('type');
  SynEditDAO.Lines.Add(ident + ClassNameDAO + ' = class');
  SynEditDAO.Lines.Add('');
  SynEditDAO.Lines.Add(ident + 'private');

  SynEditDAO.Lines.Add(ident + 'public');
  //Cria Funcoes e Procedures CRUD;
  SynEditDAO.Lines.Add(Ident + Ident + '//Functions and Procedures Model CRUD');

  if InfoCrud.ProcInsert.Enable then
  begin
    StrFunctionName := 'function ' + InfoCrud.ProcInsert.ProcName + '(';

    if StrFunctionName <> 'function ' + ClassNameDAO + '.' + InfoCrud.ProcInsert.ProcName + '(' then
      StrFunctionName := StrFunctionName + InfoCrud.Connection;

    if StrFunctionName <> 'function ' + ClassNameDAO + '.' +
      InfoCrud.ProcInsert.ProcName + '(' then
      StrFunctionName := StrFunctionName + '; ' + WithVar(VarModel) + ': ' + ClassNameModel
    else
      StrFunctionName := StrFunctionName + WithVar(VarModel) + ': ' + ClassNameModel;

    if (StrFunctionName <> 'function ' + ClassNameDAO + '.' + InfoCrud.ProcInsert.ProcName + '(') and (InfoCrud.HasReturnException)then
      StrFunctionName := StrFunctionName + '; ' + InfoCrud.ReturnException
    else
      StrFunctionName := StrFunctionName + InfoCrud.ReturnException;

    StrFunctionName := StrFunctionName + '):Boolean;';
    SynEditDAO.Lines.Add(Ident + Ident +StrFunctionName);

  end;

  if InfoCrud.ProcUpdate.Enable then
  begin
    StrFunctionName := 'function ' + InfoCrud.ProcUpdate.ProcName + '(';

    if StrFunctionName <> 'function ' + ClassNameDAO + '.' + InfoCrud.ProcUpdate.ProcName + '(' then
      StrFunctionName := StrFunctionName + InfoCrud.Connection;

    if StrFunctionName <> 'function ' + ClassNameDAO + '.' + InfoCrud.ProcUpdate.ProcName + '(' then
      StrFunctionName := StrFunctionName + '; ' + WithVar(VarModel) + ': ' + ClassNameModel
    else
      StrFunctionName := StrFunctionName + WithVar(VarModel) + ': ' + ClassNameModel;

    if (StrFunctionName <> 'function ' + InfoCrud.ProcUpdate.ProcName + '(') and (InfoCrud.HasReturnException) then
      StrFunctionName := StrFunctionName + '; ' + InfoCrud.ReturnException
    else
      StrFunctionName := StrFunctionName + InfoCrud.ReturnException;

    StrFunctionName := StrFunctionName + '):Boolean;';
    SynEditDAO.Lines.Add(Ident + Ident +StrFunctionName);

  end;

  if InfoCrud.ProcDelete.Enable then
  begin
    StrFunctionName := 'function ' + InfoCrud.ProcDelete.ProcName + '(';

    if StrFunctionName <> 'function ' + ClassNameDAO + '.' + InfoCrud.ProcDelete.ProcName + '(' then
      StrFunctionName := StrFunctionName + InfoCrud.Connection;

    if StrFunctionName <> 'function ' + ClassNameDAO + '.' +
      InfoCrud.ProcDelete.ProcName + '(' then
      StrFunctionName := StrFunctionName + '; ' + WithVar(VarModel) + ': ' + ClassNameModel
    else
      StrFunctionName := StrFunctionName + WithVar(VarModel) + ': ' + ClassNameModel;

    if (StrFunctionName <> 'function ' + ClassNameDAO + '.' +InfoCrud.ProcDelete.ProcName + '(') and (InfoCrud.HasReturnException) then
      StrFunctionName := StrFunctionName + '; ' + InfoCrud.ReturnException
    else
      StrFunctionName := StrFunctionName + InfoCrud.ReturnException;

    StrFunctionname := StrFunctionName + '):Boolean;';
    SynEditDAO.Lines.Add(Ident + Ident +StrFunctionName);
  end;

  if InfoCrud.ProcGetRecord.Enable then
  begin

    StrFunctionName := 'function ' + InfoCrud.ProcGetRecord.ProcName + '(';

    if StrFunctionName <> 'function ' + ClassNameDAO + '.' + InfoCrud.ProcGetRecord.ProcName + '(' then
      StrFunctionName := StrFunctionName + InfoCrud.Connection;

    if StrFunctionName <> 'function ' + ClassNameDAO + '.' +
      InfoCrud.ProcGetRecord.ProcName + '(' then
      StrFunctionName := StrFunctionName + '; ' + WithVar(VarModel) + ': ' + ClassNameModel
    else
      StrFunctionName := StrFunctionName + WithVar(VarModel) + ': ' + ClassNameModel;

    if (StrFunctionName <> 'function ' + InfoCrud.ProcGetRecord.ProcName + '(') and (InfoCrud.HasReturnException) then
      StrFunctionName := StrFunctionName + '; ' + InfoCrud.ReturnException
    else
      StrFunctionName := StrFunctionName + InfoCrud.ReturnException;

    StrFunctionName := StrFunctionName + '):Boolean;';

    SynEditDAO.Lines.Add(Ident + Ident + StrFunctionName);

  end;

  if InfoCrud.ProcListRecords.Enable then
  begin

    StrFunctionName := 'function ' + InfoCrud.ProcListRecords.ProcName + '(';

    if StrFunctionName <> 'function ' + ClassNameDAO + '.' + InfoCrud.ProcListRecords.ProcName + '(' then
      StrFunctionName := StrFunctionName + InfoCrud.Connection;

    if StrFunctionName <> 'function ' + InfoCrud.ProcListRecords.ProcName + '(' then
      StrFunctionName := StrFunctionName + '; out ObjLst: TObjectList;' + ' WhereSQL: String'
    else
      StrFunctionName := StrFunctionName + ' out ObjLst: TObjectList;' + ' WhereSQL: String';

    if (StrFunctionName <> 'function ' + InfoCrud.ProcListRecords.ProcName + '(') and
      (Trim(InfoCrud.ReturnException) <> '')then
      StrFunctionName := StrFunctionName + '; ' + InfoCrud.ReturnException
    else
      StrFunctionName := StrFunctionName + InfoCrud.ReturnException;

    StrFunctionName := StrFunctionName + '):Boolean;';

    SynEditDAO.Lines.Add(Ident + Ident + StrFunctionName);

  end;


  SynEditDAO.Lines.Add(ident + 'end; ');
  SynEditDAO.Lines.Add(ident + '');
  SynEditDAO.Lines.Add('implementation');
  SynEditDAO.Lines.Add(ident + '');
  SynEditDAO.Lines.Add(ident + '');
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
  (*Allan R Machovsky: --> Em testes, foi identificado que o NullIF nao é suportado pelo firebird na atribuição de parametros*)

  {if FieldInfo.AllowNull then
  begin
    if (UpperCase(FieldInfo.FieldType) = 'VARCHAR') or
      (UpperCase(FieldInfo.FieldType) = 'CHAR') then
      Result := 'NULLIF(' + ':' + FieldInfo.FieldName + ','')'
    else if (UpperCase(FieldInfo.FieldType) = 'INTEGER') or
      (UpperCase(FieldInfo.FieldType) = 'SMALLINT') or
      (UpperCase(FieldInfo.FieldType) = 'NUMERIC') or
      (UpperCase(FieldInfo.FieldType) = 'TIMESTAMP') or
      (UpperCase(FieldInfo.FieldType) = 'TIME') or
      (UpperCase(FieldInfo.FieldType) = 'LONGINT') or
      (UpperCase(FieldInfo.FieldType) = 'DATE') then
      Result := 'NULLIF(' + ':' + FieldInfo.FieldName + ',0)'
    else
      Result := ':' + FieldInfo.FieldName;
  end
  else}
    Result := ':' + FieldInfo.FieldName;
end;

function TFrmModel.GenerateSqlQuery(queryType: TQueryType): TStringList;
var
  I: integer;
  vAux: wideString;
begin
  try
    Result := TStringList.Create;
    case queryType of

      qtSelect: //Seleciona Varios registros, porém apenas os campos chave da tabela [List]
      begin

        vAux := '';
        for I := 0 to InfoTable.PrimaryKeys.Count - 1 do
          vAux := vAux + ifThen(I = 0, '', ', ') + InfoTable.PrimaryKeys.Items[I].FieldName;

        Result.Add(' SELECT ' + vAux + ' FROM ' + InfoTable.Tablename + ' ');
      end;

      qtSelectItem: //Retorna um unico registro de acordo com sua chave (Retorna todos os campos)
      begin

        Result.Add(' SELECT * FROM ' + InfoTable.Tablename + ' ');

        for I := 0 to InfoTable.PrimaryKeys.Count - 1 do
          Result.Add(Ident + ifthen(I = 0, ' WHERE (', '   AND (') + InfoTable.PrimaryKeys.Items[I].FieldName +
                     ' = :' + InfoTable.PrimaryKeys.Items[I].FieldName + ')');
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
              Result.Add(Ident + InfoTable.AllFields[I].FieldName + ' = ' +
                IfNull(InfoTable.AllFields[I]) + '')
            else
              Result.Add(Ident + InfoTable.AllFields[I].FieldName + ' = ' +
                IfNull(InfoTable.AllFields[I]) + ', ');
          end;
        end;
        for I := 0 to InfoTable.PrimaryKeys.Count - 1 do
        begin
          Result.Add(ifthen(I = 0, ' WHERE (', Ident + ' AND (') + InfoTable.PrimaryKeys.Items[I].FieldName +
                                                      ' = :' + InfoTable.PrimaryKeys.Items[I].FieldName + ')');
        end;
      end;

      qtDelete:
      begin
        Result.Add(' DELETE FROM ' + InfoTable.Tablename);
        for I := 0 to InfoTable.PrimaryKeys.Count - 1 do
        begin
          Result.Add(ifthen(I = 0, ' WHERE (', Ident + ' AND (') + InfoTable.PrimaryKeys.Items[I].FieldName +
                                                      ' = :' + InfoTable.PrimaryKeys.Items[I].FieldName + ')');
        end;
      end;

    end;
  finally

  end;
end;

procedure TFrmModel.EscreveSqlSynEditDao(StrList: TStringList);
var j, comp : word;

  function Alinha(x:string):string;
  begin
    result := copy(x, 1, comp) + StringOfChar(' ', comp - length(copy(x, 1, comp)));
  end;

begin

  comp := 0;
  for J := 0 to StrList.Count - 1 do
    if Length(StrList.Strings[j]) + 2 > Comp then
       comp := Length(StrList.Strings[j]) + 2;

  for J := 0 to StrList.Count - 1 do
  begin
    if J = 0 then //Primeira linha
    begin
       if (StrList.Count > 1) then
         SynEditDAO.Lines.Add(StringOfChar(' ', 4) + 'Qry.Sql.Add(' + QuotedStr(Alinha(StrList.Strings[J])) + '#13+')
       else
         SynEditDAO.Lines.Add(StringOfChar(' ', 4) + 'Qry.Sql.Add(' + QuotedStr(Alinha(StrList.Strings[J])) + ');');
    end
    else
    begin
      if J = StrList.Count - 1 then //Ultima linha
        SynEditDAO.Lines.Add(StringOfChar(' ', 16) + QuotedStr(Alinha(StrList.Strings[J])) + ');')
      else //Demais registros
        SynEditDAO.Lines.Add(StringOfChar(' ', 16) + QuotedStr(Alinha(StrList.Strings[J])) + '#13+');
    end;
  end;
  SynEditDAO.Lines.Add('');
end;

procedure TFrmModel.GeneratorCodeProcInsert;
var
  SQL: TStringList;
  S: string;
  J, IdSpace, IdSpaceAux : integer;
  StrFunctionName: string;
begin
  if InfoCrud.ProcInsert.Enable then
  begin
    StrFunctionName := 'function ' + ClassNameDAO + '.' + InfoCrud.ProcInsert.ProcName + '(';
    if StrFunctionName <> 'function ' + ClassNameDAO + '.' +
      InfoCrud.ProcInsert.ProcName + '(' then
      StrFunctionName := StrFunctionName + ';' + InfoCrud.Connection
    else
      StrFunctionName := StrFunctionName + InfoCrud.Connection;

    if StrFunctionName <> 'function ' + ClassNameDAO + '.' +
      InfoCrud.ProcInsert.ProcName + '(' then
      StrFunctionName := StrFunctionName + '; ' + WithVar(VarModel) + ': ' + ClassNameModel
    else
      StrFunctionName := StrFunctionName + WithVar(VarModel) + ': ' + ClassNameModel;

    if (StrFunctionName <> 'function ' + ClassNameDAO + '.' + InfoCrud.ProcInsert.ProcName + '(') and (InfoCrud.HasReturnException)then
      StrFunctionName := StrFunctionName + '; ' + InfoCrud.ReturnException
    else
      StrFunctionName := StrFunctionName + InfoCrud.ReturnException;

    SynEditDAO.Lines.Add(StrFunctionName + '):Boolean;');
    SynEditDAO.Lines.Add('Var');
    SynEditDAO.Lines.Add(Ident + 'Qry:' + InfoCrud.ClassQuery + ';');
    SynEditDAO.Lines.Add('begin');
    SynEditDAO.Lines.Add(Ident + 'try');
    WriteCreateQuery;
    SQL := GenerateSqlQuery(qtInsert);

    EscreveSqlSynEditDao(SQL);

    //Pega a maior sequencia de caracteres existente nos parametros, para alinhar a codificacao
    IdSpace := 0;
    IdSpaceAux:=0;
    for J := 0 to InfoTable.AllFields.Count - 1 do
    begin
      IdSpaceAux := Length('Qry.ParamByName(' + QuotedStr(InfoTable.AllFields[J].FieldName) + ').' + TypeDBToTypePascalParams(InfoTable.AllFields[J]));
      IdSpace := IfThen(IdSpaceAux > IdSpace, IdSpaceAux, IdSpace);
    end;

    for J := 0 to InfoTable.AllFields.Count - 1 do
    begin
      SynEditDAO.Lines.Add(Ident + Ident +  LPad('Qry.ParamByName(' + QuotedStr(InfoTable.AllFields[J].FieldName) + ').' + TypeDBToTypePascalParams(InfoTable.AllFields[J]),' ', IdSpace)  + ' := ' + VarModel + '.' + InfoTable.AllFields[J].FieldName + ';');
    end;

    SynEditDAO.Lines.Add(Ident + Ident + 'Qry.ExecSQL;');
    SynEditDAO.Lines.Add(Ident + Ident + 'Result := True;');
    SynEditDAO.Lines.Add(Ident + 'except');
    for J := 0 to InfoCrud.ExceptionCode.Count - 1 do
    begin
      S := StringReplace(InfoCrud.ExceptionCode.Strings[J], '$UnitName',
        UnitNameDAO, [rfReplaceAll]);
      S := StringReplace(S, '$ProcName', InfoCrud.ProcInsert.ProcName, [rfReplaceAll]);
      SynEditDAO.Lines.Add(Ident + Ident + S);
    end;
    SynEditDAO.Lines.Add(Ident + 'end;');
    SynEditDAO.Lines.Add('End;');
  end;
end;

procedure TFrmModel.GeneratorCodeProcUpdate;
var
  SQL: TStringList;
  S: string;
  J, IdSpace, IdSpaceAux: integer;
  StrFunctionName: String;
begin
  if InfoCrud.ProcUpdate.Enable then
  begin
    SynEditDAO.Lines.Add(ident + '');
    StrFunctionName := 'function ' + ClassNameDAO + '.' + InfoCrud.ProcUpdate.ProcName + '(';

    if StrFunctionName <> 'function ' + ClassNameDAO + '.' +
      InfoCrud.ProcUpdate.ProcName + '(' then
      StrFunctionName := StrFunctionName + ';' + InfoCrud.Connection
    else
      StrFunctionName := StrFunctionName + InfoCrud.Connection;

    if StrFunctionName <> 'function ' + ClassNameDAO + '.' +
      InfoCrud.ProcUpdate.ProcName + '(' then
      StrFunctionName := StrFunctionName + '; ' + WithVar(VarModel) + ': ' + ClassNameModel
    else
      StrFunctionName := StrFunctionName + WithVar(VarModel) + ': ' + ClassNameModel;

    if (StrFunctionName <> 'function ' + ClassNameDAO + '.' + InfoCrud.ProcUpdate.ProcName + '(') and (InfoCrud.HasReturnException) then
      StrFunctionName := StrFunctionName + ';' + InfoCrud.ReturnException
    else
      StrFunctionName := StrFunctionName + InfoCrud.ReturnException;

    SynEditDAO.Lines.Add(StrFunctionName + '):Boolean;');

    SynEditDAO.Lines.Add('Var');
    SynEditDAO.Lines.Add(Ident + 'Qry:' + InfoCrud.ClassQuery + ';');

    SynEditDAO.Lines.Add('begin');
    SynEditDAO.Lines.Add(Ident + 'try');
    WriteCreateQuery;
    SQL := GenerateSqlQuery(qtUpdate);
    EscreveSqlSynEditDao(SQL);

    //Pega a maior sequencia de caracteres existente nos parametros, para alinhar a codificacao
    IdSpace := 0;
    IdSpaceAux:=0;
    for J := 0 to InfoTable.AllFields.Count - 1 do
    begin
      IdSpaceAux := Length('Qry.ParamByName(' + QuotedStr(InfoTable.AllFields[J].FieldName) + ').' + TypeDBToTypePascalParams(InfoTable.AllFields[J]));
      IdSpace := IfThen(IdSpaceAux > IdSpace, IdSpaceAux, IdSpace);
    end;

    for J := 0 to InfoTable.AllFields.Count - 1 do
    begin
      SynEditDAO.Lines.Add(Ident + Ident +  LPad('Qry.ParamByName(' + QuotedStr(InfoTable.AllFields[J].FieldName) + ').' + TypeDBToTypePascalParams(InfoTable.AllFields[J]),' ', IdSpace)  + ' := ' + VarModel + '.' + InfoTable.AllFields[J].FieldName + ';');
    end;

    SynEditDAO.Lines.Add(Ident + Ident + 'Qry.ExecSQL;');
    SynEditDAO.Lines.Add(Ident + Ident + 'Result := True;');
    SynEditDAO.Lines.Add(Ident + 'except');
    for J := 0 to InfoCrud.ExceptionCode.Count - 1 do
    begin
      S := StringReplace(InfoCrud.ExceptionCode.Strings[J], '$UnitName',
        UnitNameDAO, [rfReplaceAll]);
      S := StringReplace(S, '$ProcName', InfoCrud.ProcUpdate.ProcName, [rfReplaceAll]);
      SynEditDAO.Lines.Add(Ident + Ident + S);
    end;
    SynEditDAO.Lines.Add(Ident + 'end;');
    SynEditDAO.Lines.Add('End;');
  end;
end;

procedure TFrmModel.GeneratorCodeProcDelete;
var
  SQL: TStringList;
  S: string;
  J, IdSpace, IdSpaceAux : integer;
  StrFunctionName: string;
begin
  if InfoCrud.ProcDelete.Enable then
  begin
    SynEditDAO.Lines.Add(ident + '');
    StrFunctionName := 'function ' + ClassNameDAO + '.' + InfoCrud.ProcDelete.ProcName + '(';
    if StrFunctionName <> 'function ' + ClassNameDAO + '.' +
      InfoCrud.ProcDelete.ProcName + '(' then
      StrFunctionName := StrFunctionName + ';' + InfoCrud.Connection
    else
      StrFunctionName := StrFunctionName + InfoCrud.Connection;

    if StrFunctionName <> 'function ' + ClassNameDAO + '.' +
      InfoCrud.ProcDelete.ProcName + '(' then
      StrFunctionName := StrFunctionName + ';' + WithVar(VarModel) + ': ' + ClassNameModel
    else
      StrFunctionName := StrFunctionName + WithVar(VarModel) + ': ' + ClassNameModel;

    if (StrFunctionName <> 'function ' + ClassNameDAO + '.' +InfoCrud.ProcDelete.ProcName + '(') and (InfoCrud.HasReturnException) then
      StrFunctionName := StrFunctionName + '; ' + InfoCrud.ReturnException
    else
      StrFunctionName := StrFunctionName + InfoCrud.ReturnException;

    SynEditDAO.Lines.Add(StrFunctionName + '):Boolean;');

    SynEditDAO.Lines.Add('var');
    SynEditDAO.Lines.Add(Ident + 'Qry:' + InfoCrud.ClassQuery + ';');
    SynEditDAO.Lines.Add('begin');
    SynEditDAO.Lines.Add(Ident + 'try');
    WriteCreateQuery;
    SQL := GenerateSqlQuery(qtDelete);

    EscreveSqlSynEditDao(SQL);

    //Pega a maior sequencia de caracteres existente nos parametros, para alinhar a codificacao
    IdSpace:= 0;
    IdSpaceAux:=0;
    for J := 0 to InfoTable.PrimaryKeys.Count - 1 do
    begin
      IdSpaceAux := Length('Qry.ParamByName(' + QuotedStr(InfoTable.PrimaryKeys[J].FieldName) + ').' + TypeDBToTypePascalParams(InfoTable.PrimaryKeys[J]));
      IdSpace := IfThen(IdSpaceAux > IdSpace, IdSpaceAux, IdSpace);
    end;

    for J := 0 to InfoTable.PrimaryKeys.Count - 1 do
    begin
      SynEditDAO.Lines.Add(Ident + Ident +  LPad('Qry.ParamByName(' + QuotedStr(InfoTable.PrimaryKeys[J].FieldName) + ').' + TypeDBToTypePascalParams(InfoTable.PrimaryKeys[J]),' ', IdSpace)  + ' := ' + VarModel + '.' + InfoTable.PrimaryKeys[J].FieldName + ';');
    end;

    SynEditDAO.Lines.Add(Ident + Ident + 'Qry.ExecSQL;');
    SynEditDAO.Lines.Add(Ident + Ident + 'Result := True;');
    SynEditDAO.Lines.Add(Ident + 'except');
    for J := 0 to InfoCrud.ExceptionCode.Count - 1 do
    begin
      S := StringReplace(InfoCrud.ExceptionCode.Strings[J], '$UnitName', UnitNameDAO, [rfReplaceAll]);
      S := StringReplace(S, '$ProcName', InfoCrud.ProcDelete.ProcName, [rfReplaceAll]);
      SynEditDAO.Lines.Add(Ident + Ident + S);
    end;
    SynEditDAO.Lines.Add(Ident + 'end;');
    SynEditDAO.Lines.Add('End;');
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
    StrFunctionName := 'function ' + ClassNameDAO + '.' + InfoCrud.ProcGetRecord.ProcName + '(';

    if StrFunctionName <> 'function ' + ClassNameDAO + '.' +
      InfoCrud.ProcGetRecord.ProcName + '(' then
      StrFunctionName := StrFunctionName + ';' + InfoCrud.Connection
    else
      StrFunctionName := StrFunctionName + InfoCrud.Connection;

    if StrFunctionName <> 'function ' + ClassNameDAO + '.' +
      InfoCrud.ProcGetRecord.ProcName + '(' then
      StrFunctionName := StrFunctionName + ';' + WithVar(VarModel) + ': ' + ClassNameModel
    else
      StrFunctionName := StrFunctionName + WithVar(VarModel) + ': ' + ClassNameModel;

    if (StrFunctionName <> 'function ' + ClassNameDAO + '.' + InfoCrud.ProcGetRecord.ProcName + '(') and (InfoCrud.HasReturnException) then
      StrFunctionName := StrFunctionName + ';' + InfoCrud.ReturnException
    else
      StrFunctionName := StrFunctionName + InfoCrud.ReturnException;

    SynEditDAO.Lines.Add(StrFunctionName + '):Boolean;');

    SynEditDAO.Lines.Add('var');
    SynEditDAO.Lines.Add(Ident + 'Qry:' + InfoCrud.ClassQuery + ';');
    SynEditDAO.Lines.Add('begin');
    SynEditDAO.Lines.Add(Ident + 'try');
    WriteCreateQuery;
    SQL := GenerateSqlQuery(qtSelectItem);

    EscreveSqlSynEditDao(SQL);

    //Pega a maior sequencia de caracteres existente nos parametros, para alinhar a codificacao
    IdSpace:= 0;
    IdSpaceAux:=0;
    for J := 0 to InfoTable.PrimaryKeys.Count - 1 do
    begin
      IdSpaceAux := Length('Qry.ParamByName(' + QuotedStr(InfoTable.PrimaryKeys[J].FieldName) + ').' + TypeDBToTypePascalParams(InfoTable.PrimaryKeys[J]));
      IdSpace := IfThen(IdSpaceAux > IdSpace, IdSpaceAux, IdSpace);
    end;

    for J := 0 to InfoTable.PrimaryKeys.Count - 1 do
    begin
      SynEditDAO.Lines.Add(Ident + Ident +  LPad('Qry.ParamByName(' + QuotedStr(InfoTable.PrimaryKeys[J].FieldName) + ').' + TypeDBToTypePascalParams(InfoTable.PrimaryKeys[J]),' ', IdSpace)  + ' := ' + VarModel + '.' + InfoTable.PrimaryKeys[J].FieldName + ';');
    end;

    SynEditDAO.Lines.Add(Ident + Ident + 'Qry.Open;');
    SynEditDAO.Lines.Add(Ident + Ident + 'if not Qry.isEmpty then ');
    SynEditDAO.Lines.Add(Ident + Ident + 'begin');
    for J := 0 to InfoTable.AllFields.Count - 1 do
    begin
      SynEditDAO.Lines.Add(Ident + Ident + Ident +
        VarModel + '.' + InfoTable.AllFields[J].FieldName + ' := ' + 'Qry.FieldByName(' +
        QuotedStr(InfoTable.AllFields[J].FieldName) + ').Value;');
    end;
    SynEditDAO.Lines.Add(Ident + Ident + 'end;');
    SynEditDAO.Lines.Add(Ident + Ident + 'Result := True;');
    SynEditDAO.Lines.Add(Ident + 'except');
    for J := 0 to InfoCrud.ExceptionCode.Count - 1 do
    begin
      S := StringReplace(InfoCrud.ExceptionCode.Strings[J], '$UnitName',
        UnitNameDAO, [rfReplaceAll]);
      S := StringReplace(S, '$ProcName', InfoCrud.ProcGetRecord.ProcName, [rfReplaceAll]);
      SynEditDAO.Lines.Add(Ident + Ident + S);
    end;
    SynEditDAO.Lines.Add(Ident + 'end;');
    SynEditDAO.Lines.Add('End;');
  end;
end;

procedure TFrmModel.GeneratorCodeProcList;
var
  SQL: TStringList;
  S: string;
  J: integer;
  StrFunctionName: String;
begin
  if InfoCrud.ProcListRecords.Enable then
  begin
    SynEditDAO.Lines.Add(ident + '');

    StrFunctionName := 'function ' + ClassNameDAO + '.' + InfoCrud.ProcListRecords.ProcName + '(';
    if StrFunctionName <> 'function ' + ClassNameDAO + '.' + InfoCrud.ProcListRecords.ProcName + '(' then
      StrFunctionName := StrFunctionName + ';' + InfoCrud.Connection
    else
      StrFunctionName := StrFunctionName + InfoCrud.Connection;

    if StrFunctionName <> 'function ' + ClassNameDAO + '.' + InfoCrud.ProcListRecords.ProcName + '(' then
      StrFunctionName := StrFunctionName + '; out ObjLst: TObjectList; ' + 'WhereSQL: String'
    else
      StrFunctionName := StrFunctionName + ' out ObjLst: TObjectList; ' + 'WhereSQL: String';

    if (StrFunctionName <> 'function ' + ClassNameDAO + '.' + InfoCrud.ProcListRecords.ProcName + '(') and (InfoCrud.HasReturnException) then
      StrFunctionName := StrFunctionName + ';' + InfoCrud.ReturnException
    else
      StrFunctionName := StrFunctionName + InfoCrud.ReturnException;

    SynEditDAO.Lines.Add(StrFunctionName + '):Boolean;');

    SynEditDAO.Lines.Add('Var');
    SynEditDAO.Lines.Add(Ident + 'Qry:' + InfoCrud.ClassQuery + ';');
    SynEditDAO.Lines.Add(Ident + VarModel + ':' + ClassNameModel + ';');
    SynEditDAO.Lines.Add('begin');
    SynEditDAO.Lines.Add(Ident + 'try');
    WriteCreateQuery;
    SQL := GenerateSqlQuery(qtSelect);
    EscreveSqlSynEditDao(SQL);

    SynEditDAO.Lines.Add(Ident + Ident + 'if Trim(WhereSQL) <> ' + QuotedStr('') + ' then ');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + 'Qry.Sql.Add(WhereSQL);');
    SynEditDAO.Lines.Add(Ident + Ident + 'Qry.Open;');
    SynEditDAO.Lines.Add(Ident + Ident + 'Qry.First;');
    SynEditDAO.Lines.Add(Ident + Ident + 'While not Qry.Eof do ');
    SynEditDAO.Lines.Add(Ident + Ident + 'begin');
    SynEditDAO.Lines.Add(Ident + Ident + Ident + VarModel + ':= ' + ClassNameModel + '.Create;');
    for J := 0 to InfoTable.AllFields.Count - 1 do
    begin
      SynEditDAO.Lines.Add(Ident + Ident + Ident +
        VarModel + '.' + InfoTable.AllFields[J].FieldName + ' := ' + 'Qry.FieldByName(' +
        QuotedStr(InfoTable.AllFields[J].FieldName) + ').Value;');
    end;
    SynEditDAO.Lines.Add(Ident + Ident + Ident + 'ObjLst.Add(' + VarModel + ');');

    SynEditDAO.Lines.Add(Ident + Ident + Ident + 'Qry.Next;');
    SynEditDAO.Lines.Add(Ident + Ident + 'end;');
    SynEditDAO.Lines.Add(Ident + Ident + 'Result := True;');
    SynEditDAO.Lines.Add(Ident + 'except');
    for J := 0 to InfoCrud.ExceptionCode.Count - 1 do
    begin
      S := StringReplace(InfoCrud.ExceptionCode.Strings[J], '$UnitName',
        UnitNameDAO, [rfReplaceAll]);
      S := StringReplace(S, '$ProcName', InfoCrud.ProcListRecords.ProcName,
        [rfReplaceAll]);
      SynEditDAO.Lines.Add(Ident + Ident + S);
    end;
    SynEditDAO.Lines.Add(Ident + 'end;');
    SynEditDAO.Lines.Add('End;');
  end;
end;

function TFrmModel.Limpa(S: String): String;
Var
 A: String;
 P: Integer;
begin
  A := StringReplace(UpperCase(S), 'VAR','',[rfReplaceAll]);
  Result := Trim(A);
end;


end.
