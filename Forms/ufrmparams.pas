unit UFrmParams;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Grids, ValEdit, AsDbType;

type

  { TFrmParams }

  TFrmParams = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Panel1: TPanel;
    Panel2: TPanel;
    SgParams: TValueListEditor;
 private
    { private declarations }
  public
    { public declarations }
    Class Procedure CreateForm(Var Query: TAsQuery);
  end;

var
  FrmParams: TFrmParams;

implementation

{$R *.lfm}

{ TFrmParams }

class procedure TFrmParams.CreateForm(var  Query: TAsQuery);
Var
I: Integer;
begin
  FrmParams := TFrmParams.Create(Application);
  Try
    FrmParams.SgParams.RowCount:= Query.Params.Count + 1;
    For I:= 0  to Query.Params.Count -1 do
    begin
      FrmParams.SgParams.Cells[0,I+1] := Query.Params[I].Name;
    end;
    if FrmParams.ShowModal = mrOK then
    begin
      For I:= 0  to Query.Params.Count -1 do
      begin
        Query.Params[I].Value := FrmParams.SgParams.Cells[1,I+1];
      end;
      Query.Open;
    end;
  finally
    FreeAndNil(FrmParams);
  end;
end;

end.

