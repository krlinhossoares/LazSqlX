unit UFrmCfgCRUD;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynHighlighterPas, SynEdit, SynHighlighterSQL,
  Forms, Controls, Graphics, Dialogs, StdCtrls, Spin, Buttons, EditBtn,
  ZSqlUpdate, IniFiles, AsCrudInfo;

type

  { TFrmCfgCRUD }

  TFrmCfgCRUD = class(TForm)
    btnAccept: TBitBtn;
    btnCancel: TBitBtn;
    ChCkDelete: TCheckBox;
    ChCkGetRecord: TCheckBox;
    ChCkInsert: TCheckBox;
    ChCkListRecords: TCheckBox;
    ChCkUpdate: TCheckBox;
    EdtClassQuery: TEdit;
    EdtClassSQL: TEdit;
    EdtAownerCreate: TEdit;
    EdtConDatabase: TEdit;
    EdtConDatabase1: TEdit;
    EdtConnection: TEdit;
    EdtConTransaction: TEdit;
    EdtCopyTableName: TSpinEdit;
    EdtDirModel: TDirectoryEdit;
    EdtDirDAO: TDirectoryEdit;
    EdtException: TEdit;
    EdtProcNameDelete: TEdit;
    EdtProcNameGetRecord: TEdit;
    EdtProcNameInsert: TEdit;
    EdtProcNameListRecords: TEdit;
    EdtProcNameUpdate: TEdit;
    EdtQryPropDatabase: TEdit;
    EdtQryPropTransaction: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    LbProcDelete: TLabel;
    LbProcGetRecord: TLabel;
    LbProcInsert: TLabel;
    LbProcListRecord: TLabel;
    LbProcUpdate: TLabel;
    MmExceptionCode: TSynEdit;
    MmSelectWhereDefault: TSynEdit;
    MmUses: TMemo;
    SynPasSyn1: TSynPasSyn;
    SynSQLSyn1: TSynSQLSyn;
    procedure btnAcceptClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure EdtDirDAOAcceptDirectory(Sender: TObject; var Value: String);
    procedure EdtDirModelAcceptDirectory(Sender: TObject; var Value: String);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MmExceptionCodeChange(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    CrudInfo: TCrudInfo;
  end;

var
  FrmCfgCRUD: TFrmCfgCRUD;

implementation

{$R *.lfm}

{ TFrmCfgCRUD }

procedure TFrmCfgCRUD.FormCreate(Sender: TObject);
begin
end;

procedure TFrmCfgCRUD.FormShow(Sender: TObject);
begin
  EdtCopyTableName.Value:= CrudInfo.CopyTableName;

  MmUses.Lines.Clear;
  MmUses.Lines.Text := CrudInfo.UsesDefault;
  EdtConnection.Text:= CrudInfo.Connection;
  EdtException.Text := CrudInfo.ReturnException;
  EdtDirModel.Text  := CrudInfo.DirModel;
  EdtDirDAO.Text    := CrudInfo.DirDAO;

  ChCkInsert.Checked    := CrudInfo.ProcInsert.Enable;
  EdtProcNameInsert.Text:= CrudInfo.ProcInsert.ProcName;

  ChCkUpdate.Checked    := CrudInfo.ProcUpdate.Enable;
  EdtProcNameUpdate.Text:= CrudInfo.ProcUpdate.ProcName;

  ChCkDelete.Checked    := CrudInfo.ProcDelete.Enable;
  EdtProcNameDelete.Text:= CrudInfo.ProcDelete.ProcName;

  ChCkGetRecord.Checked    := CrudInfo.ProcGetRecord.Enable;
  EdtProcNameGetRecord.Text:= CrudInfo.ProcGetRecord.ProcName;

  ChCkListRecords.Checked    := CrudInfo.ProcListRecords.Enable;
  EdtProcNameListRecords.Text:= CrudInfo.ProcListRecords.ProcName;
  EdtConDatabase.Text:= CrudInfo.QueryConDatabase;
  EdtQryPropDatabase.Text:= CrudInfo.QueryPropDatabase;
  EdtConTransaction.Text:= CrudInfo.QueryConTransaction;
  EdtQryPropTransaction.Text:= CrudInfo.QueryPropTransaction;
  EdtClassQuery.Text:= CrudInfo.ClassQuery;
  EdtClassSQL.Text:= CrudInfo.ClassSQL;
  EdtAownerCreate.Text:= CrudInfo.AOwnerCreate;
  MmSelectWhereDefault.lines.text := CrudInfo.SelectWhereDefault;

  MmExceptionCode.Lines.Text := CrudInfo.ExceptionCode.Text;
end;

procedure TFrmCfgCRUD.MmExceptionCodeChange(Sender: TObject);
begin

end;

procedure TFrmCfgCRUD.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmCfgCRUD.EdtDirDAOAcceptDirectory(Sender: TObject;
  var Value: String);
begin

end;

procedure TFrmCfgCRUD.EdtDirModelAcceptDirectory(Sender: TObject;
  var Value: String);
begin
  Value := Value + PathDelim;
end;

procedure TFrmCfgCRUD.btnAcceptClick(Sender: TObject);
begin
  CrudInfo.CopyTableName := EdtCopyTableName.Value;
  CrudInfo.UsesDefault   := MmUses.Lines.Text;
  CrudInfo.Connection    := EdtConnection.Text;
  CrudInfo.ReturnException := EdtException.Text;

  CrudInfo.ProcInsert.Enable   := ChCkInsert.Checked;
  CrudInfo.ProcInsert.ProcName := EdtProcNameInsert.Text;

  CrudInfo.ProcUpdate.Enable := ChCkUpdate.Checked;
  CrudInfo.ProcUpdate.ProcName := EdtProcNameUpdate.Text;

  CrudInfo.ProcDelete.Enable := ChCkDelete.Checked;
  CrudInfo.ProcDelete.ProcName := EdtProcNameDelete.Text;

  CrudInfo.ProcGetRecord.Enable := ChCkGetRecord.Checked;
  CrudInfo.ProcGetRecord.ProcName := EdtProcNameGetRecord.Text;

  CrudInfo.ProcListRecords.Enable := ChCkListRecords.Checked;
  CrudInfo.ProcListRecords.ProcName := EdtProcNameListRecords.Text;

  CrudInfo.ExceptionCode.Text := MmExceptionCode.Lines.Text;
  CrudInfo.DirModel := EdtDirModel.Text;
  CrudInfo.DirDAO   := EdtDirDAO.Text;

  CrudInfo.QueryPropTransaction := EdtQryPropTransaction.Text;
  CrudInfo.QueryConTransaction  := EdtConTransaction.Text;
  CrudInfo.QueryPropDatabase    := EdtQryPropDatabase.Text;
  CrudInfo.QueryConDatabase     := EdtConDatabase.Text;
  CrudInfo.ClassQuery := EdtClassQuery.Text;
  CrudInfo.ClassSQL   := EdtClassSQL.Text;
  CrudInfo.AOwnerCreate:= EdtAownerCreate.Text;
  CrudInfo.SelectWhereDefault := MmSelectWhereDefault.lines.text;
  CrudInfo.SaveToFile(GetCurrentDir+ PathDelim+'CRUD.ini');
  Close;
end;



end.

