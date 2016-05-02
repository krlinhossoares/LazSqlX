Unit UTBATIVIDADEDAO;

uses 
  UTBATIVIDADE,System, Controls, Variants, DB;

interface;

type
  TTBATIVIDADEDAO= class

  private
  public
    //Functions and Procedures Model CRUD
    function Insert(TZConnection; TBATIVIDADE:TTBATIVIDADE; Erro: String):Boolean;
    function Update(TZConnection; TBATIVIDADE:TTBATIVIDADE; Erro: String):Boolean;
    function Delete(TZConnection; TBATIVIDADE:TTBATIVIDADE; Erro: String):Boolean;
    function GetRecord(TZConnection; TBATIVIDADE:TTBATIVIDADE; Erro: String):Boolean;
    function ListRecords(TZConnection; ObjLst: TObjectList; TBATIVIDADE:TTBATIVIDADE; WhereSQL: String; Erro: String):Boolean;
  end; 
  
implementation
  
  
function TTBATIVIDADEDAO.Insert(TZConnection; TBATIVIDADE:TTBATIVIDADE; Erro: String):Boolean;
begin
  try
    Result := True;
  except
  end;
End
  
function TTBATIVIDADEDAO.Update(TZConnection; TBATIVIDADE:TTBATIVIDADE; Erro: String):Boolean;
begin
  try
    Result := True;
  except
  end;
End
  
function TTBATIVIDADEDAO.Delete(TZConnection; TBATIVIDADE:TTBATIVIDADE; Erro: String):Boolean;
begin
  try
    Result := True;
  except
  end;
End
  
function TTBATIVIDADEDAO.GetRecord(TZConnection; TBATIVIDADE:TTBATIVIDADE; Erro: String):Boolean;
begin
  try
    Result := True;
  except
  end;
End
  
function TTBATIVIDADEDAO.ListRecords(TZConnection; ObjLst: TObjectList; TBATIVIDADE:TTBATIVIDADE; WhereSQL: String; Erro: String):Boolean;
begin
  try
    Result := True;
  except
  end;
End
