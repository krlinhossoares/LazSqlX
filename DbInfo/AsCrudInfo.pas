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
    FConnection: string;
    FCopyTableName: integer;
    FExceptionCode: String;
    FProcDelete: TCRUDProc;
    FProcGetRecord: TCRUDProc;
    FProcInsert: TCRUDProc;
    FProcListRecords: TCRUDProc;
    FProcUpdate: TCRUDProc;
    FReturnException: string;
    FUsesDefault: string;
  public
    constructor Create;
    procedure SaveToFile(FileName: String);
    procedure LoadFromFile(FileName: String);

    property CopyTableName: integer read FCopyTableName write FCopyTableName;
    property UsesDefault: string read FUsesDefault write FUsesDefault;
    property Connection: string read FConnection write FConnection;
    property ReturnException: string read FReturnException write FReturnException;
    property ExceptionCode: String read FExceptionCode write FExceptionCode;

    property ProcInsert: TCRUDProc read FProcInsert write FProcInsert;
    property ProcUpdate: TCRUDProc read FProcUpdate write FProcUpdate;
    property ProcDelete: TCRUDProc read FProcDelete write FProcDelete;
    property ProcGetRecord: TCRUDProc read FProcGetRecord write FProcGetRecord;
    property ProcListRecords: TCRUDProc read FProcListRecords write FProcListRecords;

  end;


implementation

{ TCRUDInfo }

constructor TCRUDInfo.Create;
begin
  ProcInsert := TCRUDProc.Create;
  ProcUpdate := TCRUDProc.Create;
  ProcDelete := TCRUDProc.Create;
  ProcGetRecord := TCRUDProc.Create;
  ProcListRecords := TCRUDProc.Create;
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
  CrudFile.WriteString('CRUD','EXCEPTIONCODE', ExceptionCode);
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
  UsesDefault  := CrudFile.ReadString('CRUD','USES', 'System, Controls, Variants, DB;');
  Connection  := CrudFile.ReadString('CRUD','CLASSCONNECTION', 'TZConnection');
  ReturnException := CrudFile.ReadString('CRUD','RETURNEXCEPTION','Erro: String' );

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

  ExceptionCode := CrudFile.ReadString('CRUD','EXCEPTIONCODE',
   '  On E:Exception do   '+ #13 +
   '  begin               '+ #13 +
   '    Result := False;  '+ #13 +
   '    Erro := E.Message;'+ #13 +
   '  end;                ');
  CrudFile.UpdateFile;
  finally
    FreeAndNil(CrudFile);
  end;
end;


end.

