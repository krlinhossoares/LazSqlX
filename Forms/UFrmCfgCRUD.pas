unit UFrmCfgCRUD;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Spin, Buttons, IniFiles, AsCrudInfo;

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
    EdtException: TEdit;
    EdtProcNameInsert: TEdit;
    EdtConnection: TEdit;
    EdtProcNameUpdate: TEdit;
    EdtProcNameDelete: TEdit;
    EdtProcNameGetRecord: TEdit;
    EdtProcNameListRecords: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    EdtCopyTableName: TSpinEdit;
    Label16: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    LbProcListRecord: TLabel;
    LbProcInsert: TLabel;
    LbProcDelete: TLabel;
    LbProcGetRecord: TLabel;
    LbProcUpdate: TLabel;
    LbTable: TLabel;
    LbClassExemple: TLabel;
    MmUses: TMemo;
    MmExceptionCode: TMemo;
    procedure btnAcceptClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
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

  ChCkInsert.Checked:= CrudInfo.ProcInsert.Enable;
  EdtProcNameInsert.Text:= CrudInfo.ProcInsert.ProcName;

  ChCkUpdate.Checked:= CrudInfo.ProcUpdate.Enable;
  EdtProcNameUpdate.Text:= CrudInfo.ProcUpdate.ProcName;

  ChCkDelete.Checked:= CrudInfo.ProcDelete.Enable;
  EdtProcNameDelete.Text:= CrudInfo.ProcDelete.ProcName;

  ChCkGetRecord.Checked:= CrudInfo.ProcGetRecord.Enable;
  EdtProcNameGetRecord.Text:= CrudInfo.ProcGetRecord.ProcName;

  ChCkListRecords.Checked:= CrudInfo.ProcListRecords.Enable;
  EdtProcNameListRecords.Text:= CrudInfo.ProcListRecords.ProcName;

  MmExceptionCode.Text := CrudInfo.ExceptionCode;
end;

procedure TFrmCfgCRUD.btnCancelClick(Sender: TObject);
begin
  Close;
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

  CrudInfo.ExceptionCode := MmExceptionCode.Text;
  CrudInfo.SaveToFile(GetCurrentDir+ PathDelim+'CRUD.ini');
  Close;
end;



end.

