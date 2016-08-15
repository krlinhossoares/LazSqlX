unit UFrmParams;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Grids, ValEdit, Buttons, ZDataSet;

type

  { TFrmParams }

  TFrmParams = class(TForm)
   BitBtn1: TBitBtn;
   BitBtn2: TBitBtn;
    Panel1: TPanel;
    Panel2: TPanel;
    SgParams: TStringGrid;
    procedure BitBtn1Click(Sender: TObject);
 private
    { private declarations }
  public
    { public declarations }
    Class function CreateForm(Var Query: TZQuery):Boolean;
  end;

var
  FrmParams: TFrmParams;

implementation

{$R *.lfm}

{ TFrmParams }

procedure TFrmParams.BitBtn1Click(Sender: TObject);
begin

end;

class function TFrmParams.CreateForm(var  Query: TZQuery): Boolean;
Var
I: Integer;
begin
  Result := False;
  FrmParams := TFrmParams.Create(Application);
  Try
    FrmParams.SgParams.RowCount := Query.Params.Count + 1;
    FrmParams.SgParams.ColCount := 2;
    FrmParams.SgParams.Cells[0,0] := 'Param';
    FrmParams.SgParams.Cells[1,0] := 'Value';
    For I:= 0  to Query.Params.Count -1 do
    begin
      FrmParams.SgParams.Cells[0,I+1] := UpperCase(Query.Params[I].Name);
    end;
    if FrmParams.ShowModal = mrOK then
    begin
      Result := True;
      For I:= 0  to Query.Params.Count -1 do
      begin
        if Trim(FrmParams.SgParams.Cells[1,I+1]) <> '' then
          Query.Params[I].Value := FrmParams.SgParams.Cells[1,I+1]
        else
          Query.Params[I].Clear;
      end;
    end;
  finally
    FreeAndNil(FrmParams);
  end;
end;

end.

