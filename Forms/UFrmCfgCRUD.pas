unit UFrmCfgCRUD;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynHighlighterPas, SynEdit, SynHighlighterSQL,
  Forms, Controls, Graphics, Dialogs, StdCtrls, Spin, Buttons, EditBtn,
  ComCtrls, ZSqlUpdate, IniFiles, AsCrudInfo, Types;

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
    EdtCondition2: TEdit;
    EdtCondition3: TEdit;
    EdtField1: TEdit;
    EdtField2: TEdit;
    EdtField3: TEdit;
    EdtOperator1: TEdit;
    EdtOperator2: TEdit;
    EdtOperator3: TEdit;
    EdtValue1: TEdit;
    EdtCondition1: TEdit;
    EdtAownerCreate: TEdit;
    EdtClassQuery: TEdit;
    EdtClassQueryOpenCommand: TEdit;
    EdtClassSQLExecComand: TEdit;
    EdtClassSQL: TEdit;
    EdtConDatabase: TEdit;
    EdtConDatabase1: TEdit;
    EdtConDatabaseSQL: TEdit;
    EdtConnection: TEdit;
    EdtConTransaction: TEdit;
    EdtConTransactionSQL: TEdit;
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
    EdtSQLPropDatabase: TEdit;
    EdtQryPropTransaction: TEdit;
    EdtSQLPropTransaction: TEdit;
    EdtValue2: TEdit;
    EdtValue3: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Label3: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    LbProcDelete: TLabel;
    LbProcGetRecord: TLabel;
    LbProcInsert: TLabel;
    LbProcListRecord: TLabel;
    LbProcUpdate: TLabel;
    MmExceptionCode: TSynEdit;
    MmHeaderCode: TSynEdit;
    MmUses: TMemo;
    PageControl1: TPageControl;
    SynPasSyn1: TSynPasSyn;
    SynSQLSyn1: TSynSQLSyn;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    procedure btnAcceptClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure EdtCondition1Change(Sender: TObject);
    procedure EdtDirModelAcceptDirectory(Sender: TObject; var Value: String);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TabSheet1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
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

  {Propety Query Select - Get and List}
  EdtClassQuery.Text:= CrudInfo.ClassQuery;
  EdtConDatabase.Text:= CrudInfo.QueryConDatabase;
  EdtQryPropDatabase.Text:= CrudInfo.QueryPropDatabase;
  EdtConTransaction.Text:= CrudInfo.QueryConTransaction;
  EdtQryPropTransaction.Text:= CrudInfo.QueryPropTransaction;
  EdtClassQueryOpenCommand.Text := CrudInfo.QueryCommand;
  {--------------------------------------}
  {Propety Query Insert, Update and Delete functions}
  EdtClassSQL.Text:= CrudInfo.ClassSQL;
  EdtConDatabaseSQL.Text:= CrudInfo.SQLConDatabase;
  EdtSQLPropDatabase.Text:= CrudInfo.SQLPropDatabase;
  EdtConTransactionSQL.Text:= CrudInfo.SQLConTransaction;
  EdtSQLPropTransaction.Text:= CrudInfo.SQLPropTransaction;
  EdtClassSQLExecComand.Text := CrudInfo.SQLCommand;
  {--------------------------------------}

  EdtAownerCreate.Text:= CrudInfo.AOwnerCreate;

  EdtField1.Text    := CrudInfo.SelectDefault1.Field;
  EdtOperator1.Text := CrudInfo.SelectDefault1.Oper;
  EdtValue1.Text    := CrudInfo.SelectDefault1.Value;
  EdtCondition1.Text:= CrudInfo.SelectDefault1.Condition;

  EdtField2.Text    := CrudInfo.SelectDefault2.Field;
  EdtOperator2.Text := CrudInfo.SelectDefault2.Oper;
  EdtValue2.Text    := CrudInfo.SelectDefault2.Value;
  EdtCondition2.Text:= CrudInfo.SelectDefault2.Condition;

  EdtField3.Text    := CrudInfo.SelectDefault3.Field;
  EdtOperator3.Text := CrudInfo.SelectDefault3.Oper;
  EdtValue3.Text    := CrudInfo.SelectDefault3.Value;
  EdtCondition3.Text:= CrudInfo.SelectDefault3.Condition;

  MmExceptionCode.Lines.Text := CrudInfo.ExceptionCode.Text;
  MmHeaderCode.Lines.Text := CrudInfo.CabecalhoCode.Text;
end;

procedure TFrmCfgCRUD.TabSheet1ContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin

end;

procedure TFrmCfgCRUD.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmCfgCRUD.EdtCondition1Change(Sender: TObject);
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

  CrudInfo.CabecalhoCode.Text := MmHeaderCode.Lines.Text;

  {Propety Query Select - Get and List}
  CrudInfo.ClassQuery           := EdtClassQuery.Text;
  CrudInfo.QueryConDatabase     := EdtConDatabase.Text;
  CrudInfo.QueryPropDatabase    := EdtQryPropDatabase.Text;
  CrudInfo.QueryConTransaction  := EdtConTransaction.Text;
  CrudInfo.QueryPropTransaction := EdtQryPropTransaction.Text;
  CrudInfo.QueryCommand         := EdtClassQueryOpenCommand.Text;
  {--------------------------------------}
  {Propety Query Insert, Update and Delete functions}
  CrudInfo.ClassSQL           := EdtClassSQL.Text;
  CrudInfo.SQLConDatabase     := EdtConDatabaseSQL.Text;
  CrudInfo.SQLPropDatabase    := EdtSQLPropDatabase.Text;
  CrudInfo.SQLConTransaction  := EdtConTransactionSQL.Text;
  CrudInfo.SQLPropTransaction := EdtSQLPropTransaction.Text;
  CrudInfo.SQLCommand         := EdtClassSQLExecComand.Text;
  {--------------------------------------}

  CrudInfo.AOwnerCreate:= EdtAownerCreate.Text;

  if not Assigned(CrudInfo.SelectDefault1) then
    CrudInfo.SelectDefault1 := TCRUDWhereDefault.Create;
  CrudInfo.SelectDefault1.Field := EdtField1.Text;
  CrudInfo.SelectDefault1.Oper  := EdtOperator1.Text;
  CrudInfo.SelectDefault1.Value := EdtValue1.Text;
  CrudInfo.SelectDefault1.Condition := EdtCondition1.Text;

  if not Assigned(CrudInfo.SelectDefault2) then
    CrudInfo.SelectDefault2 := TCRUDWhereDefault.Create;
  CrudInfo.SelectDefault2.Field := EdtField2.Text;
  CrudInfo.SelectDefault2.Oper  := EdtOperator2.Text;
  CrudInfo.SelectDefault2.Value := EdtValue2.Text;
  CrudInfo.SelectDefault2.Condition := EdtCondition2.Text;

  if not Assigned(CrudInfo.SelectDefault3) then
    CrudInfo.SelectDefault3 := TCRUDWhereDefault.Create;
  CrudInfo.SelectDefault3.Field := EdtField3.Text;
  CrudInfo.SelectDefault3.Oper  := EdtOperator3.Text;
  CrudInfo.SelectDefault3.Value := EdtValue3.Text;
  CrudInfo.SelectDefault3.Condition := EdtCondition3.Text;

  CrudInfo.SaveToFile(GetCurrentDir+ PathDelim+'CRUD.ini');
  Close;
end;



end.

