unit UFrmModel;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, SynHighlighterPas, Forms, Controls,
  Graphics, Dialogs, ComCtrls, AsTableInfo;

type

  { TFrmModel }

  TFrmModel = class(TForm)
    ApplicationImages: TImageList;
    SynEditPas: TSynEdit;
    PascalSyntax: TSynPasSyn;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
    procedure GeneratorPascalClass;
  public
    { public declarations }
    InfoTable: TAsTableInfo;
  end;

var
  FrmModel: TFrmModel;

implementation

Const
  Ident = '  ';

{$R *.lfm}

{ TFrmModel }

procedure TFrmModel.FormShow(Sender: TObject);
begin
  GeneratorPascalClass;
end;

procedure TFrmModel.GeneratorPascalClass;
begin
  SynEditPas.Lines.Clear;
  SynEditPas.Lines.Add('Unit U' + InfoTable.Tablename+ ';');
  SynEditPas.Lines.Add('');
  SynEditPas.Lines.Add('uses ');
  SynEditPas.Lines.Add('  SysUtils;');
  SynEditPas.Lines.Add('');
  SynEditPas.Lines.Add('interface;');
  SynEditPas.Lines.Add('');
  SynEditPas.Lines.Add('type');
  SynEditPas.Lines.Add(ident + InfoTable.Tablename +'=class');


  SynEditPas.Lines.Add('');
  SynEditPas.Lines.Add(ident+'private');

  SynEditPas.Lines.Add('');
  SynEditPas.Lines.Add(ident+'public');

  SynEditPas.Lines.Add('');
  SynEditPas.Lines.Add(ident+ 'end; ');
end;

end.

