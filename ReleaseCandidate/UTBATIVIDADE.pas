Unit UTBATIVIDADE;

uses 
  System, Controls, Variants, DB;

interface;

type
  TTBATIVIDADE= class

  private
    FCDEMPRESA   :smallint;
    FCDATIVIDADE :smallint;
    FDSATIVIDADE :String  ;
  public
    //Propertys Model
    Property CDEMPRESA  :smallint read FCDEMPRESA    write FCDEMPRESA   ;
    Property CDATIVIDADE:smallint read FCDATIVIDADE  write FCDATIVIDADE ;
    Property DSATIVIDADE:String   read FDSATIVIDADE  write FDSATIVIDADE ;
    //Functions and Procedures Model CRUD
    function Insert(TZConnection; TBATIVIDADE:TTBATIVIDADE; Erro: String):Boolean;
    function Update(TZConnection; TBATIVIDADE:TTBATIVIDADE; Erro: String):Boolean;
    function Delete(TZConnection; TBATIVIDADE:TTBATIVIDADE; Erro: String):Boolean;
    function GetRecord(TZConnection; TBATIVIDADE:TTBATIVIDADE; Erro: String):Boolean;
    function ListRecords(TZConnection; ObjLst: TObjectList; TBATIVIDADE:TTBATIVIDADE; WhereSQL: String; Erro: String):Boolean;
  end; 
  
implementation
  
uses 
  UTBATIVIDADEDAO;
  
Var 
  TBATIVIDADEDAO:TTBATIVIDADEDAO;
  
function TTBATIVIDADE.Insert(TZConnection; TBATIVIDADE:TTBATIVIDADE; Erro: String):Boolean;
begin
  Result := TBATIVIDADEDAO.Insert(, TBATIVIDADE, Erro);
end;
  
function TTBATIVIDADE.Update(TZConnection; TBATIVIDADE:TTBATIVIDADE; Erro: String):Boolean;
begin
  Result := TBATIVIDADEDAO.Update(, TBATIVIDADE, Erro);
end;
  
function TTBATIVIDADE.Delete(TZConnection; TBATIVIDADE:TTBATIVIDADE; Erro: String):Boolean;
begin
  Result := TBATIVIDADEDAO.Delete(, TBATIVIDADE, Erro);
end;
  
function TTBATIVIDADE.GetRecord(TZConnection; TBATIVIDADE:TTBATIVIDADE; Erro: String):Boolean;
begin
  Result := TBATIVIDADEDAO.GetRecord(, TBATIVIDADE, Erro);
end;
  
function TTBATIVIDADE.ListRecords(TZConnection; ObjLst: TObjectList; TBATIVIDADE:TTBATIVIDADE; WhereSQL: String; Erro: String):Boolean;
begin
  Result := TBATIVIDADEDAO.ListRecords(, ObjLst, TBATIVIDADE, Erro);
End
