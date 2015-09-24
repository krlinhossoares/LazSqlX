unit UFrmModel;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, SynHighlighterPas, SynHighlighterAny,
  Forms, Controls, Graphics, Dialogs, ComCtrls, AsTableInfo, AsCrudInfo;

type

  { TFrmModel }

  TFrmModel = class(TForm)
    ApplicationImages: TImageList;
    PageControl1: TPageControl;
    PascalSyntax: TSynPasSyn;
    SynEditModel: TSynEdit;
    SynEditDAO: TSynEdit;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
    procedure GeneratorPascalClass;
    function LPad(S: string; Ch: Char; Len: Integer): string;
    function RPad(S: string; Ch: Char; Len: Integer): string;
    function TypeDBToTypePascal(S: String): String;
  public
    { public declarations }
    InfoTable: TAsTableInfo;
    InfoCrud: TCRUDInfo;
  end;

var
  FrmModel: TFrmModel;

implementation

Const
  Ident = '  ';

{$R *.lfm}

{ TFrmModel }

procedure TFrmModel.FormShow(Sender: TObject);
begin
  GeneratorPascalClass;
end;

function TFrmModel.TypeDBToTypePascal(S:String):String;
begin
  if UpperCase(S) = 'VARCHAR' then
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
  UnitNameCrud, ClassNameCrud, VarCrud: String;
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
  UnitNameCrud:= 'U'+Copy(InfoTable.Tablename,InfoCrud.CopyTableName, Length(InfoTable.TableName));
  ClassNameCrud := 'T'+Trim(Copy(InfoTable.Tablename,InfoCrud.CopyTableName, Length(InfoTable.TableName)));
  VarCrud := Trim(Copy(InfoTable.Tablename,InfoCrud.CopyTableName, Length(InfoTable.TableName)));
  SynEditModel.Lines.Clear;
  SynEditModel.Lines.Add('Unit ' + UnitNameCrud + ';');
  SynEditModel.Lines.Add('');
  SynEditModel.Lines.Add('uses ');
  SynEditModel.Lines.Add(InfoCrud.UsesDefault);
  SynEditModel.Lines.Add('');
  SynEditModel.Lines.Add('interface;');
  SynEditModel.Lines.Add('');
  SynEditModel.Lines.Add('type');
  SynEditModel.Lines.Add(ident + ClassNameCrud +'= class');
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
    VarCrud + ':' + ClassNameCrud +'; ' +
    InfoCrud.ReturnException+ '):Boolean;');

  if InfoCrud.ProcUpdate.Enable then
    SynEditModel.Lines.Add(Ident + Ident + 'function '+InfoCrud.ProcUpdate.ProcName+'('+ InfoCrud.Connection + '; '+
    VarCrud + ':' + ClassNameCrud+'; ' +
    InfoCrud.ReturnException+ '):Boolean;');

  if InfoCrud.ProcDelete.Enable then
    SynEditModel.Lines.Add(Ident + Ident + 'function '+InfoCrud.ProcDelete.ProcName+'('+ InfoCrud.Connection + '; '+
    VarCrud + ':' + ClassNameCrud +'; ' +
    InfoCrud.ReturnException+ '):Boolean;');

  if InfoCrud.ProcGetRecord.Enable then
    SynEditModel.Lines.Add(Ident + Ident + 'function '+InfoCrud.ProcGetRecord.ProcName+'('+ InfoCrud.Connection + '; '+
    Trim(Copy(InfoTable.Tablename,InfoCrud.CopyTableName, Length(InfoTable.TableName))) + ':' +
    'T'+Trim(Copy(InfoTable.Tablename,InfoCrud.CopyTableName, Length(InfoTable.TableName))) +'; ' +
    InfoCrud.ReturnException+ '):Boolean;');

  if InfoCrud.ProcListRecords.Enable then
    SynEditModel.Lines.Add(Ident + Ident + 'function '+InfoCrud.ProcListRecords.ProcName+'('+ InfoCrud.Connection + '; ' +
    'ObjLst: TObjectList; ' +
    VarCrud + ':' + ClassNameCrud +'; ' +
    'WhereSQL: String; '+
    InfoCrud.ReturnException+ '):Boolean;');
  SynEditModel.Lines.Add(ident+ 'end; ');
  SynEditModel.Lines.Add(ident+ '');
  SynEditModel.Lines.Add('implementation');
  SynEditModel.Lines.Add(ident+ '');
  SynEditModel.Lines.Add(ident+ '');
  //Gerando Functions Code
  if InfoCrud.ProcInsert.Enable then
  begin
    SynEditModel.Lines.Add( 'function '+ClassNameCrud+'.'+InfoCrud.ProcInsert.ProcName+'('+ InfoCrud.Connection + '; '+
    VarCrud + ':' + ClassNameCrud +'; ' +
    InfoCrud.ReturnException+ '):Boolean;');
    SynEditModel.Lines.Add('begin');
    SynEditModel.Lines.Add(Ident + 'Result := True;');
    SynEditModel.Lines.Add('End');
  end;
  if InfoCrud.ProcUpdate.Enable then
  begin
    SynEditModel.Lines.Add(ident+ '');
    SynEditModel.Lines.Add(Ident + Ident + 'function '+ClassNameCrud+'.'+InfoCrud.ProcUpdate.ProcName+'('+ InfoCrud.Connection + '; '+
    VarCrud + ':' + ClassNameCrud+'; ' +
    InfoCrud.ReturnException+ '):Boolean;');
    SynEditModel.Lines.Add('begin');
    SynEditModel.Lines.Add(Ident + 'Result := True;');
    SynEditModel.Lines.Add('End');
  end;
  if InfoCrud.ProcDelete.Enable then
  begin
    SynEditModel.Lines.Add(ident+ '');
    SynEditModel.Lines.Add(Ident + Ident + 'function '+ClassNameCrud+'.'+InfoCrud.ProcDelete.ProcName+'('+ InfoCrud.Connection + '; '+
    VarCrud + ':' + ClassNameCrud +'; ' +
    InfoCrud.ReturnException+ '):Boolean;');
    SynEditModel.Lines.Add('begin');
    SynEditModel.Lines.Add(Ident + 'Result := True;');
    SynEditModel.Lines.Add('End');
  end;

  if InfoCrud.ProcGetRecord.Enable then
  begin
    SynEditModel.Lines.Add(ident+ '');
    SynEditModel.Lines.Add(Ident + Ident + 'function '+ClassNameCrud+'.'+InfoCrud.ProcGetRecord.ProcName+'('+ InfoCrud.Connection + '; '+
    Trim(Copy(InfoTable.Tablename,InfoCrud.CopyTableName, Length(InfoTable.TableName))) + ':' +
    'T'+Trim(Copy(InfoTable.Tablename,InfoCrud.CopyTableName, Length(InfoTable.TableName))) +'; ' +
    InfoCrud.ReturnException+ '):Boolean;');
    SynEditModel.Lines.Add('begin');
    SynEditModel.Lines.Add(Ident + 'Result := True;');
    SynEditModel.Lines.Add('End');
  end;

  if InfoCrud.ProcListRecords.Enable then
  begin
    SynEditModel.Lines.Add(ident+ '');
    SynEditModel.Lines.Add(Ident + Ident + 'function '+ClassNameCrud+'.'+InfoCrud.ProcListRecords.ProcName+'('+ InfoCrud.Connection + '; ' +
    'ObjLst: TObjectList; ' +
    VarCrud + ':' + ClassNameCrud +'; ' +
    'WhereSQL: String; '+
    InfoCrud.ReturnException+ '):Boolean;');
    SynEditModel.Lines.Add('begin');
    SynEditModel.Lines.Add(Ident + 'Result := True;');
    SynEditModel.Lines.Add('End');
  end;
end;

end.

