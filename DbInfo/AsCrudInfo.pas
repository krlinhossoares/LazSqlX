unit AsCrudInfo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IniFiles;

type
  { TCRUDProc }
  TCRUDProc = class
  private
    FEnable: boolean;
    FProcName: string;
  public
    property Enable: boolean read FEnable write FEnable;
    property ProcName: string read FProcName write FProcName;
  end;

  { TCRUDInfo }
  TCRUDInfo = class
  private
    FClassQuery: String;
    FConnection: string;
    FCopyTableName: integer;
    FDirDAO: String;
    FDirModel: String;
    FExceptionCode: TStringList;
    FHasReturnException: boolean;
    FProcDelete: TCRUDProc;
    FProcGetRecord: TCRUDProc;
    FProcInsert: TCRUDProc;
    FProcListRecords: TCRUDProc;
    FProcUpdate: TCRUDProc;
    FQueryConDatabase: String;
    FQueryConTransaction: String;
    FQueryPropDatabase: String;
    FQueryPropTransaction: String;
    FReturnException: string;
    FUsesDefault: string;
    function GetHasReturnException: boolean;
  public
    constructor Create;
    procedure SaveToFile(FileName: String);
    procedure LoadFromFile(FileName: String);

    property CopyTableName: integer read FCopyTableName write FCopyTableName;
    property UsesDefault: string read FUsesDefault write FUsesDefault;
    property Connection: string read FConnection write FConnection;
    property ReturnException: string read FReturnException write FReturnException;
    property ExceptionCode: TStringList read FExceptionCode write FExceptionCode;
    property DirModel: String read FDirModel write FDirModel;
    property DirDAO: String read FDirDAO write FDirDAO;
    property ClassQuery: String read FClassQuery write FClassQuery;
    property QueryPropDatabase: String read FQueryPropDatabase write FQueryPropDatabase;
    property QueryConDatabase: String read FQueryConDatabase write FQueryConDatabase;
    property QueryPropTransaction: String read FQueryPropTransaction write FQueryPropTransaction;
    property QueryConTransaction: String read FQueryConTransaction write FQueryConTransaction;
    property HasReturnException: boolean read GetHasReturnException;

    property ProcInsert: TCRUDProc read FProcInsert write FProcInsert;
    property ProcUpdate: TCRUDProc read FProcUpdate write FProcUpdate;
    property ProcDelete: TCRUDProc read FProcDelete write FProcDelete;
    property ProcGetRecord: TCRUDProc read FProcGetRecord write FProcGetRecord;
    property ProcListRecords: TCRUDProc read FProcListRecords write FProcListRecords;

  end;


implementation

{ TCRUDInfo }

function TCRUDInfo.GetHasReturnException: boolean;
begin
  Result := Length(Trim(Self.ReturnException)) > 0;
end;

constructor TCRUDInfo.Create;
begin
  ProcInsert := TCRUDProc.Create;
  ProcUpdate := TCRUDProc.Create;
  ProcDelete := TCRUDProc.Create;
  ProcGetRecord := TCRUDProc.Create;
  ProcListRecords := TCRUDProc.Create;
  ExceptionCode := TStringList.Create;
end;

procedure TCRUDInfo.SaveToFile(FileName: String);
Var
  CrudFile: TIniFile;
begin
  CrudFile := TIniFile.Create(FileName);
  try
  CrudFile.WriteInteger('CRUD','COPYTABLE', CopyTableName);
  CrudFile.WriteString('CRUD','USES', UsesDefault);
  CrudFile.WriteString('CRUD','CLASSCONNECTION', Connection);
  CrudFile.WriteString('CRUD','RETURNEXCEPTION', ReturnException);
  CrudFile.WriteBool('CRUD','CREATEINSERT',ProcInsert.Enable);
  CrudFile.WriteString('CRUD','PROCNAMEINSERT', ProcInsert.ProcName);
  CrudFile.WriteBool('CRUD','CREATEUPDATE',ProcUpdate.Enable);
  CrudFile.WriteString('CRUD','PROCNAMEUPDATE', ProcUpdate.ProcName);
  CrudFile.WriteBool('CRUD','CREATEDELETE',ProcDelete.Enable);
  CrudFile.WriteString('CRUD','PROCNAMEDELETE', ProcDelete.ProcName);
  CrudFile.WriteBool('CRUD','CREATEGETRECORD',ProcGetRecord.Enable);
  CrudFile.WriteString('CRUD','PROCNAMEGETRECORD', ProcGetRecord.ProcName);
  CrudFile.WriteBool('CRUD','CREATELISTRECORDS',ProcListRecords.Enable);
  CrudFile.WriteString('CRUD','PROCNAMELISTRECORDS', ProcListRecords.ProcName);
  ExceptionCode.SaveToFile(GetCurrentDir+ PathDelim+'CodeException.ini');
  CrudFile.WriteString('CRUD','EXCEPTIONCODE', GetCurrentDir+ PathDelim+'CodeException.ini');
  CrudFile.WriteString('CRUD','DIRMODEL',DirModel);
  CrudFile.WriteString('CRUD','DIRDAO',DirDAO);
  CrudFile.WriteString('CRUD','CLASSQUERY', ClassQuery);
  CrudFile.WriteString('CRUD','QUERYCONDATABASE', QueryConDatabase);
  CrudFile.WriteString('CRUD','QUERYPROPDATABASE', QueryPropDatabase);
  CrudFile.WriteString('CRUD','QUERYCONTRANSACTION', QueryConTransaction);
  CrudFile.WriteString('CRUD','QUERYPROPTRANSACTION', QueryPropTransaction);


  CrudFile.UpdateFile;
  finally
    FreeAndNil(CrudFile);
  end;
end;

procedure TCRUDInfo.LoadFromFile(FileName: String);
Var
  CrudFile: TIniFile;
begin
  CrudFile := TIniFile.Create(FileName);
  try
  CopyTableName:= CrudFile.ReadInteger('CRUD','COPYTABLE',1);
  UsesDefault  := CrudFile.ReadString('CRUD','USES', 'Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ZConnection, ZDataset, ContNrs;');
  Connection  := CrudFile.ReadString('CRUD','CLASSCONNECTION', 'Con:TZConnection');
  ReturnException := CrudFile.ReadString('CRUD','RETURNEXCEPTION','Erro: String' );
  DirModel:= CrudFile.ReadString('CRUD','DIRMODEL',GetCurrentDir+ PathDelim);
  DirDAO:= CrudFile.ReadString('CRUD','DIRDAO',GetCurrentDir+ PathDelim);

  ProcInsert.Enable  := CrudFile.ReadBool('CRUD','CREATEINSERT',True);
  ProcInsert.ProcName:= CrudFile.ReadString('CRUD','PROCNAMEINSERT', 'Insert');

  ProcUpdate.Enable   := CrudFile.ReadBool('CRUD','CREATEUPDATE',True);
  ProcUpdate.ProcName := CrudFile.ReadString('CRUD','PROCNAMEUPDATE', 'Update');

  ProcDelete.Enable   := CrudFile.ReadBool('CRUD','CREATEDELETE',True);
  ProcDelete.ProcName := CrudFile.ReadString('CRUD','PROCNAMEDELETE', 'Delete');

  ProcGetRecord.Enable   := CrudFile.ReadBool('CRUD','CREATEGETRECORD',True);
  ProcGetRecord.ProcName := CrudFile.ReadString('CRUD','PROCNAMEGETRECORD', 'GetRecord');

  ProcListRecords.Enable := CrudFile.ReadBool('CRUD','CREATELISTRECORDS',True);
  ProcListRecords.ProcName := CrudFile.ReadString('CRUD','PROCNAMELISTRECORDS', 'ListRecords');
  ClassQuery := CrudFile.ReadString('CRUD','CLASSQUERY', 'TzQuery');
  QueryConDatabase:= CrudFile.ReadString('CRUD','QUERYCONDATABASE', Connection);
  QueryPropDatabase:= CrudFile.ReadString('CRUD','QUERYPROPDATABASE', Connection);
  QueryConTransaction:= CrudFile.ReadString('CRUD','QUERYCONTRANSACTION', '');
  QueryPropTransaction:= CrudFile.ReadString('CRUD','QUERYPROPTRANSACTION', '');

  if FileExists(GetCurrentDir+ PathDelim+'CodeException.ini') then
    ExceptionCode.LoadFromFile(GetCurrentDir+ PathDelim+'CodeException.ini');
  CrudFile.UpdateFile;
  finally
    FreeAndNil(CrudFile);
  end;
end;


end.

