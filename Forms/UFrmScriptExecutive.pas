unit UFrmScriptExecutive;

{$mode objfpc}{$H+}

interface

uses
  Windows, Classes, SysUtils, FileUtil, SynEdit, SynHighlighterSQL, SynMemo,
  SynCompletion, Forms, Controls, Graphics, Dialogs, ComCtrls, ActnList,
  ExtCtrls, ZSqlProcessor, ZSqlMetadata, ZConnection, ZSqlMonitor, ZDataset,
  sqldb, asDBType, ZDbcIntfs;

type

  { TFrmScriptExecutive }

  TFrmScriptExecutive = class(TForm)
    ActStopScript: TAction;
    ActRunScript: TAction;
    ActSaveAs: TAction;
    ActSave: TAction;
    ActLoad: TAction;
    ActNew: TAction;
    ActScriptExecutive: TActionList;
    OpenDlg: TOpenDialog;
    Panel1: TPanel;
    SaveDlg: TSaveDialog;
    Splitter1: TSplitter;
    SynAutoComplete1: TSynAutoComplete;
    SynCompletion1: TSynCompletion;
    SynEditScript: TSynEdit;
    MmMessages: TSynMemo;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ZeosScript: TZSQLProcessor;
    QryExecute: TZQuery;
    procedure ActLoadExecute(Sender: TObject);
    procedure ActNewExecute(Sender: TObject);
    procedure ActRunScriptExecute(Sender: TObject);
    procedure ActSaveAsExecute(Sender: TObject);
    procedure ActSaveExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ZeosScriptError(Processor: TZSQLProcessor;
      StatementIndex: Integer; E: Exception;
      var ErrorHandleAction: TZErrorHandleAction);
    procedure ZSQLProcessorError(Processor: TZSQLProcessor;
      StatementIndex: Integer; E: Exception;
      var ErrorHandleAction: TZErrorHandleAction);
  private
    { private declarations }
    Procedure RunScritpZeos;
  public
    { public declarations }
    SQLScript: TSQLScript;
  end;

var
  FrmScriptExecutive: TFrmScriptExecutive;

implementation

uses MainFormU;

{$R *.lfm}

{ TFrmScriptExecutive }


procedure TFrmScriptExecutive.ActNewExecute(Sender: TObject);
begin
  if SynEditScript.Modified then
  begin
    if Application.MessageBox('Script was modified. Save changes?','Confirmation', MB_YESNO + MB_ICONWARNING) = MrYes then
    begin
      ActSave.Execute;
    end;
  end;
  SynEditScript.Lines.Clear;
end;

procedure TFrmScriptExecutive.ActLoadExecute(Sender: TObject);
begin
  ActNew.Execute;
  if OpenDlg.Execute then
  begin
    if OpenDlg.FileName <> '' then
      SynEditScript.Lines.LoadFromFile(OpenDlg.FileName);
  end;
end;

procedure TFrmScriptExecutive.ActRunScriptExecute(Sender: TObject);
begin
  RunScritpZeos;
end;

procedure TFrmScriptExecutive.ActSaveAsExecute(Sender: TObject);
begin
  if SaveDlg.Execute then
  begin
    if SaveDlg.FileName <> '' then
      SynEditScript.Lines.SaveToFile(SaveDlg.FileName);
  end;
end;

procedure TFrmScriptExecutive.ActSaveExecute(Sender: TObject);
begin
  if SaveDlg.FileName = '' then
  begin
    if SaveDlg.Execute then
     if SaveDlg.FileName <> '' then
       SynEditScript.Lines.SaveToFile(SaveDlg.FileName);
  end;
end;

procedure TFrmScriptExecutive.FormCreate(Sender: TObject);
begin
  if MainForm.DbInfo.DbEngineType =  deSqlDB then //SqlDB
  begin
    SQLScript := TSQLScript.Create(Application);
    SQLScript.DataBase := MainForm.DbInfo.SqlConnection;
    SQLScript.Transaction := MainForm.DbInfo.SqlConnection.Transaction;
  end
  else if MainForm.DbInfo.DbEngineType = deZeos then //Zeos Lib
  begin
    QryExecute.Connection := MainForm.DbInfo.ZeosConnection;
  end;
end;

procedure TFrmScriptExecutive.ZeosScriptError(Processor: TZSQLProcessor;
  StatementIndex: Integer; E: Exception;
  var ErrorHandleAction: TZErrorHandleAction);
begin
  MmMessages.Lines.Add(E.Message);
end;

procedure TFrmScriptExecutive.ZSQLProcessorError(Processor: TZSQLProcessor;
  StatementIndex: Integer; E: Exception;
  var ErrorHandleAction: TZErrorHandleAction);
begin
  MmMessages.Lines.Add('Line: ' + IntToStr(StatementIndex) + ' Message: ' + E.Message);
end;

procedure TFrmScriptExecutive.RunScritpZeos;
begin
  try
    QryExecute.SQL.Text := SynEditScript.Lines.Text;
    QryExecute.ExecSQL;
  except
    On e: exception do
      ShowMessage(e.Message);
  end;
end;

end.

