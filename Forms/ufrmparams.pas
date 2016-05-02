unit uFrmParams;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, DividerBevel, LvlGraphCtrl, ZConnection,
  ZSqlMonitor, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  ComCtrls, Grids, ButtonPanel, Buttons;

type

  { TFrmParams }

  TFrmParams = class(TForm)
    btCancel: TBitBtn;
    btOk: TBitBtn;
    Drw: TDrawGrid;
    pnTitulo: TPanel;
    pnBottons: TPanel;
    pnBody: TPanel;
    procedure ButtonPanel1Click(Sender: TObject);
    procedure DrwClick(Sender: TObject);
    procedure ZConnection1AfterConnect(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FrmParams: TFrmParams;

implementation

{$R *.lfm}

{ TFrmParams }

procedure TFrmParams.DrwClick(Sender: TObject);
begin

end;

procedure TFrmParams.ZConnection1AfterConnect(Sender: TObject);
begin

end;

procedure TFrmParams.ButtonPanel1Click(Sender: TObject);
begin

end;

end.

