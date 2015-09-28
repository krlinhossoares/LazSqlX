unit UFrmCfgCRUD;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynHighlighterPas, SynEdit, Forms, Controls,
  Graphics, Dialogs, StdCtrls, Spin, Buttons, EditBtn, IniFiles, AsCrudInfo;

type

  { TFrmCfgCRUD }

  TFrmCfgCRUD = class(TForm)
    btnAccept: TBitBtn;
    btnCancel: TBitBtn;
    ChCkListRecords: TCheckBox;
    ChCkGetRecord: TCheckBox;
    ChCkInsert: TCheckBox;
    ChCkDelete: TCheckBox;
    ChCkUpdate: TCheckBox;
    EdtConTransaction: TEdit;
    EdtQryPropDatabase: TEdit;
    EdtConDatabase: TEdit;
    EdtDirModel: TDirectoryEdit;
    EdtDirDAO: TDirectoryEdit;
    EdtException: TEdit;
    EdtClassQuery: TEdit;
    EdtProcNameInsert: TEdit;
    EdtConnection: TEdit;
    EdtProcNameUpdate: TEdit;
    EdtProcNameDelete: TEdit;
    EdtProcNameGetRecord: TEdit;
    EdtProcNameListRecords: TEdit;
    EdtQryPropTransaction: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    EdtCopyTableName: TSpinEdit;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    LbProcListRecord: TLabel;
    LbProcInsert: TLabel;
    LbProcDelete: TLabel;
    LbProcGetRecord: TLabel;
    LbProcUpdate: TLabel;
    MmUses: TMemo;
    MmExceptionCode: TSynEdit;
    SynPasSyn1: TSynPasSyn;
    procedure btnAcceptClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure EdtDirDAOAcceptDirectory(Sender: TObject; var Value: String);
    procedure EdtDirModelAcceptDirectory(Sender: TObject; var Value: String);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
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
  EdtClassQuery.Text:= CrudInfo.ClassQuery;;

  MmExceptionCode.Lines.Text := CrudInfo.ExceptionCode.Text;
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
  CrudInfo.ClassQuery:= EdtClassQuery.Text;

  CrudInfo.SaveToFile(GetCurrentDir+ PathDelim+'CRUD.ini');
  Close;
end;



end.

