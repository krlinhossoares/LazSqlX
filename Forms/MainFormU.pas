unit MainFormU;

interface

uses
  Classes, SysUtils, DB, fpstdexports, fpcsvexport, fpSimpleXMLExport,
  fpsimplejsonexport, fprtfexport, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, DBGrids, DBCtrls, ComCtrls, Buttons, Menus, ActnList, StdCtrls,
  ZDataset, ZConnection, ZSqlUpdate, ZAbstractRODataset, ZStoredProcedure,
  ZSqlMetadata, ZSqlProcessor, ZSqlMonitor, ZIBEventAlerter, SynHighlighterSQL,
  SynMemo, SynEdit, SynCompletion, RTTIGrids, LCL, LCLType, LCLIntf, Grids,
  EditBtn, Spin, StdActns, fpDBExport, fpdbfexport, fpSQLExport, sqldb,
  sqldblib, IBConnection, FBAdmin,
  {$ifndef win64}oracleconnection,{$endif} SdfData, sqlite3conn,
  mysql55conn, mysql51conn, mysql50conn, mysql40conn, mysql41conn, mssqlconn,
  strutils, SqlConnBuilderFormU, BlobFieldFormU, Clipbrd, types, EditMemoFormU,
  DesignTableFormU, AsTableInfo, AsDbType, AsProcedureInfo, AsSqlGenerator,
  FtDetector, SqlExecThread, AsSqlParser, LazSqlXResources, RegExpr, Regex,
  versionresource, UnitGetSetText, QueryDesignerFormU, UFrmModel, UFrmCfgCRUD,
  UFrmScriptExecutive, LoadingIndicator, SynEditMarkupSpecialLine, SynEditTypes,
  SynEditKeyCmds, fpsqlparser, LazSqlXCtrls, fpsqltree, LR_PGrid, AsDbFormUtils,
  LR_Class, DOM, XMLRead, XMLWrite, AsCrudInfo;

var
  AppVersion: string = '';

type

  { TMainForm }

  TMainForm = class(TForm)
    actExecute: TAction;
    actCloseTab: TAction;
    actConnect: TAction;
    actFormatQuery: TAction;
    actCloseAllButThis: TAction;
    actGenerateSelectQuery: TAction;
    actGenerateSelectItemQuery: TAction;
    actGenerateInsertQuery: TAction;
    actGenerateUpdateQuery: TAction;
    actGenerateDeleteQuery: TAction;
    actGenerateAllQuery: TAction;
    actGenerateSelectProc: TAction;
    actGenerateSelectItemProc: TAction;
    actGenerateInsertProc: TAction;
    actGenerateUpdateProc: TAction;
    actGenerateDeleteProc: TAction;
    actGenerateAllproc: TAction;
    actDropTable: TAction;
    actGridCopy: TAction;
    actGridCopyAll: TAction;
    actGridCopyRow: TAction;
    actGridCopyAllWithHeaders: TAction;
    actGridCopyRowsWithHeaders: TAction;
    actGridCopyRowsAsInsert: TAction;
    actDatabaseCloner: TAction;
    actDataImporter: TAction;
    actGenerateCreateScript: TAction;
    actFind: TAction;
    actCheckSyntax: TAction;
    actDisconnect: TAction;
    actDropDatabase: TAction;
    actDesignTable: TAction;
    actEditFormAll: TAction;
    actEditLimitRecords: TAction;
    actEditFormCustomFilter: TAction;
    actCopyRunProcedureText: TAction;
    actFindReplace: TAction;
    actClearSessionHistory: TAction;
    actAbout: TAction;
    actChmHelp: TAction;
    actCreateCRUDDelphi: TAction;
    ActCreateCRUDJava: TAction;
    ActExportCSV: TAction;
    ActExportXML: TAction;
    ActExportRTF: TAction;
    ActExportJSon: TAction;
    ActCreateORMAllTables: TAction;
    ActScriptExecutive: TAction;
    actPdfHelp: TAction;
    actRefreshProcedures: TAction;
    actOpen: TAction;
    actPrint: TAction;
    actOpenTable: TAction;
    actSelectAllRows: TAction;
    actQueryDesigner: TAction;
    actRunStoredProcedure: TAction;
    actShowStoredProcedureText: TAction;
    actNewTable: TAction;
    actRefreshTables: TAction;
    actNewTab: TAction;
    actSaveAs: TAction;
    actClose: TAction;
    ApplicationActions: TActionList;
    ApplicationProperties: TApplicationProperties;
    btnExportJson: TToolButton;
    cmbSchema: TComboBox;
    CSVExporter: TCSVExporter;
    FindDialog1: TFindDialog;
    GridPrinter: TFrPrintGrid;
    MenuItem1: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MnCreateORMAllTables: TMenuItem;
    MnItemProj: TMenuItem;
    MmCRUD_Delphi: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    PpSchemaORM: TPopupMenu;
    RTFExporter: TRTFExporter;
    JSonExport: TSimpleJSONExporter;
    XMLExporter: TSimpleXMLExporter;
    timerSearch: TTimer;
    ToolButton3: TToolButton;
    trvProcedures: TTreeView;
    TreeViewImages: TImageList;
    imgLogo: TImage;
    itmDataIporter: TMenuItem;
    mitSep13: TMenuItem;
    mitHelpPDF: TMenuItem;
    mitHelpCHM: TMenuItem;
    mitClearSession: TMenuItem;
    mitPrint: TMenuItem;
    Sep13: TMenuItem;
    mitReplace: TMenuItem;
    mitSearch: TMenuItem;
    mitMSearch: TMenuItem;
    ReplaceDialog1: TReplaceDialog;
    sp13: TMenuItem;
    mitCopyStoredRunProcedureText: TMenuItem;
    mitRefreshSP: TMenuItem;
    sep12: TMenuItem;
    mitOpenFile: TMenuItem;
    mitSep12: TMenuItem;
    mitOpenTable: TMenuItem;
    mitEditCustomFilter: TMenuItem;
    mitEditTopRec: TMenuItem;
    mitEdit: TMenuItem;
    mitEditAll: TMenuItem;
    mitSep11: TMenuItem;
    mitSelectAll: TMenuItem;
    mitFind: TMenuItem;
    mitSep7: TMenuItem;
    mitGenerateCreateScript: TMenuItem;
    mitGenerateScript: TMenuItem;
    mitQueryDesigner: TMenuItem;
    mitCloneDatabase: TMenuItem;
    mitTools: TMenuItem;
    mitSPRun: TMenuItem;
    mitSPShowText: TMenuItem;
    mitGridSep4: TMenuItem;
    mitSep8: TMenuItem;
    mitGridSep2: TMenuItem;
    mitGridSep1: TMenuItem;
    mitGridCopyAllWithHeaders: TMenuItem;
    mitGridCopyRowsWithHeaders: TMenuItem;
    mitGridCopyRow: TMenuItem;
    mitGridCopy: TMenuItem;
    mitGridCopyAll: TMenuItem;
    mitDropTable: TMenuItem;
    mitNewTable: TMenuItem;
    mitSep6: TMenuItem;
    mitRefreshTables: TMenuItem;
    mitSep5: TMenuItem;
    GridPopupMenu: TPopupMenu;
    pnlIndicator: TPanel;
    sp14: TMenuItem;
    StoredProcedurePopUp: TPopupMenu;
    btnQueryDesigner: TToolButton;
    btnDatabseCloner: TToolButton;
    btnDataImporter: TToolButton;
    LibraryLoader: TSQLDBLibraryLoader;
    btnCheckSyntax: TToolButton;
    btnPrint: TToolButton;
    btnOpen: TToolButton;
    sep4: TToolButton;
    sep22: TToolButton;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    trvTables: TTreeView;
    txtSearchTable: TEdit;
    EditCopy1: TEditCopy;
    EditCut1: TEditCut;
    EditDelete1: TEditDelete;
    EditPaste1: TEditPaste;
    EditSelectAll1: TEditSelectAll;
    EditUndo1: TEditUndo;
    ApplicationImages: TImageList;
    mitHelp: TMenuItem;
    mitAbout: TMenuItem;
    mitTabExportToSqlInsert: TMenuItem;
    mitTabExportToRTF: TMenuItem;
    mitTabExportToJason: TMenuItem;
    mitTabExportToXml: TMenuItem;
    mitTabExportToCSV: TMenuItem;
    mitDataExport: TMenuItem;
    mitSep4: TMenuItem;
    mitCloseAllButActive: TMenuItem;
    mitAllProc: TMenuItem;
    mitSep3: TMenuItem;
    mitDeleteProc: TMenuItem;
    mitUpdateProc: TMenuItem;
    mitInsertProc: TMenuItem;
    mitSelectItemProc: TMenuItem;
    mitSelectProc: TMenuItem;
    mitGenerateSP: TMenuItem;
    mitSep2: TMenuItem;
    mitQueryAll: TMenuItem;
    mitEditorSelectAll: TMenuItem;
    mitEditorSep2: TMenuItem;
    mitEditorPaste: TMenuItem;
    mitEditorCopy: TMenuItem;
    mitEditorCut: TMenuItem;
    mitEditorUndo: TMenuItem;
    mitEditorSep1: TMenuItem;
    mitDeleteQuery: TMenuItem;
    mitUpdateQuery: TMenuItem;
    mitInsertQuery: TMenuItem;
    mitSelectItemQuery: TMenuItem;
    mitSelectQuery: TMenuItem;
    mitQuery: TMenuItem;
    mitTableInfo: TMenuItem;
    mitSep10: TMenuItem;
    mitConnect: TMenuItem;
    MenuItem2: TMenuItem;
    mitSqlExport: TMenuItem;
    mitJsonExport: TMenuItem;
    mitRtfExport: TMenuItem;
    mitExportToXml: TMenuItem;
    mitExportToCSV: TMenuItem;
    mitExport: TMenuItem;
    pgcLeft: TPageControl;
    pnlMain: TPanel;
    TablesPopupMenu: TPopupMenu;
    pnlTables: TPanel;
    QueryEditorPopupMenu: TPopupMenu;
    sbMain: TStatusBar;
    Splitter2: TSplitter;
    SqlExporter: TSQLExporter;
    tabTables: TTabSheet;
    tabProcedures: TTabSheet;
    tlbMain: TToolBar;
    btnConnect: TToolButton;
    sep1: TToolButton;
    btnSave: TToolButton;
    sep3: TToolButton;
    btnExportCsv: TToolButton;
    btnExportXml: TToolButton;
    btnExecute: TToolButton;
    ToolButton4: TToolButton;
    btnNew: TToolButton;
    sep5: TToolButton;
    txtSearchproc: TEdit;
    ApplicationMainMenu: TMainMenu;
    OpenDialog: TOpenDialog;
    pmiClose: TMenuItem;
    pmiNew: TMenuItem;
    mitClose: TMenuItem;
    mitSep1: TMenuItem;
    mitSaveQuery: TMenuItem;
    mitFile: TMenuItem;
    PageControlPopupMenu: TPopupMenu;
    SaveDialog: TSaveDialog;
    SqlSyntax: TSynSQLSyn;
    procedure actAboutExecute(Sender: TObject);
    procedure actCheckSyntaxExecute(Sender: TObject);
    procedure actClearSessionHistoryExecute(Sender: TObject);
    procedure actCopyRunProcedureTextExecute(Sender: TObject);
    procedure actCreateDAOExecute(Sender: TObject);
    procedure ActCreateORMAllTablesExecute(Sender: TObject);
    procedure actDatabaseClonerExecute(Sender: TObject);
    procedure actCloseAllButThisExecute(Sender: TObject);
    procedure actConnectExecute(Sender: TObject);
    procedure actDisconnectExecute(Sender: TObject);
    procedure actDropDatabaseExecute(Sender: TObject);
    procedure actDropTableExecute(Sender: TObject);
    procedure actEditFormAllExecute(Sender: TObject);
    procedure actEditFormCustomFilterExecute(Sender: TObject);
    procedure actDesignTableExecute(Sender: TObject);
    procedure actEditLimitRecordsExecute(Sender: TObject);
    procedure actExecuteExecute(Sender: TObject);
    procedure actCloseExecute(Sender: TObject);
    procedure actCloseTabExecute(Sender: TObject);
    procedure ActExportCSVExecute(Sender: TObject);
    procedure actExportSQLExecute(Sender: TObject);
    procedure ActExportXMLExecute(Sender: TObject);
    procedure actFindExecute(Sender: TObject);
    procedure actFindReplaceExecute(Sender: TObject);
    procedure actFormatQueryExecute(Sender: TObject);
    procedure actGenerateAllprocExecute(Sender: TObject);
    procedure actGenerateAllQueryExecute(Sender: TObject);
    procedure actGenerateCreateScriptExecute(Sender: TObject);
    procedure actGenerateDeleteProcExecute(Sender: TObject);
    procedure actGenerateDeleteQueryExecute(Sender: TObject);
    procedure actGenerateInsertProcExecute(Sender: TObject);
    procedure actGenerateInsertQueryExecute(Sender: TObject);
    procedure actGenerateSelectItemProcExecute(Sender: TObject);
    procedure actGenerateSelectItemQueryExecute(Sender: TObject);
    procedure actGenerateSelectProcExecute(Sender: TObject);
    procedure actGenerateSelectQueryExecute(Sender: TObject);
    procedure actGenerateUpdateProcExecute(Sender: TObject);
    procedure actGenerateUpdateQueryExecute(Sender: TObject);
    procedure actGridCopyAllExecute(Sender: TObject);
    procedure actGridCopyAllWithHeadersExecute(Sender: TObject);
    procedure actGridCopyExecute(Sender: TObject);
    procedure actGridCopyRowExecute(Sender: TObject);
    procedure actGridCopyRowsAsInsertExecute(Sender: TObject);
    procedure actGridCopyRowsWithHeadersExecute(Sender: TObject);
    procedure actDataImporterExecute(Sender: TObject);
    procedure actChmHelpExecute(Sender: TObject);
    procedure actNewTabExecute(Sender: TObject);
    procedure actExportJSONExecute(Sender: TObject);
    procedure actExportRTFExecute(Sender: TObject);
    procedure actNewTableExecute(Sender: TObject);
    procedure actOpenExecute(Sender: TObject);
    procedure actOpenTableExecute(Sender: TObject);
    procedure actPdfHelpExecute(Sender: TObject);
    procedure actPrintExecute(Sender: TObject);
    procedure actQueryDesignerExecute(Sender: TObject);
    procedure actRefreshProceduresExecute(Sender: TObject);
    procedure actRefreshTablesExecute(Sender: TObject);
    procedure actRunStoredProcedureExecute(Sender: TObject);
    procedure actSaveAsExecute(Sender: TObject);
    procedure actScriptExecutiveExecute(Sender: TObject);
    procedure actSelectAllRowsExecute(Sender: TObject);
    procedure actShowStoredProcedureTextExecute(Sender: TObject);
    procedure ApplicationPropertiesException(Sender: TObject; E: Exception);
    procedure ApplicationPropertiesIdle(Sender: TObject; var Done: boolean);
    procedure Button1Click(Sender: TObject);
    procedure cmbSchemaChange(Sender: TObject);

    procedure EditSelectAll1Execute(Sender: TObject);
    procedure EditUndo1Execute(Sender: TObject);
    procedure FindDialog1Find(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure GridPrinterGetValue(const ParName: string; var ParValue: variant);
    procedure MenuItem4Click(Sender: TObject);
    procedure MnCreateORMAllTablesClick(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure mitOpenDataClick(Sender: TObject);
    procedure mitRefreshTablesClick(Sender: TObject);
    procedure MnItemProjClick(Sender: TObject);
    procedure OnCaretPosition(Line, Pos: integer);
    procedure OnDynamicEditKeyDown(Sender: TObject; var Key: word;
      Shift: TShiftState);
    procedure OnPageControlChange(Sender: TObject);
    procedure pgcMainMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure ReplaceDialog1Find(Sender: TObject);
    procedure ReplaceDialog1Replace(Sender: TObject);
    procedure sbMainDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure timerSearchTimer(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure trvTablesChange(Sender: TObject; Node: TTreeNode);
    procedure trvTablesExpanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: boolean);
    procedure trvTablesKeyPress(Sender: TObject; var Key: char);
    procedure txtSearchprocChange(Sender: TObject);
    procedure txtSearchprocEnter(Sender: TObject);
    procedure txtSearchprocExit(Sender: TObject);
    procedure txtSearchprocKeyPress(Sender: TObject; var Key: char);
    procedure txtSearchTableChange(Sender: TObject);
    procedure txtSearchTableEnter(Sender: TObject);
    procedure txtSearchTableExit(Sender: TObject);
    procedure txtSearchTableKeyPress(Sender: TObject; var Key: char);
    procedure ZSQLMonitor1LogTrace(Sender: TObject; Event: TZLoggingEvent);
    procedure actCreateCRUDDelphiExecute(Sender: TObject);
  private
    FCrudInfo: TCRUDInfo;

    {Used in FPageControl for Autocomplete usage}
    FtableIcon: TBitmap;
    {Used in FPageControl for Autocomplete usage}
    FfunctionIcon: TBitmap;
    {Used in FPageControl for Autocomplete usage}
    FfieldIcon: TBitmap;
    {Used in FPageControl for Autocomplete usage}
    FvarIcon: TBitmap;
    {Used in FPageControl for Autocomplete usage}
    FprocedureIcon: TBitmap;



    {MainControl to hold all Tabs with Queries/returned results}
    FPageControl: TLazSqlXPageControl;

    {Loading indicator appears on statusbar if the executing query is in progress}
    FLoadingIndicator: TLoadingIndicator;

    {this is used for FindText/FindDialog }
    FFound: boolean;

    {this is used for FindText/FindDialog }
    FPos: integer;

    {This is used for QuickSearch for Tables and procedures}
    FQuickSearchLastWord: string;

    {This is used to search for tables and procedures in TreeView}
    FTableSearch: string;
    FContTimeSearch: word;

    {Ativa a pesquisa }
    procedure CriaSubMenusProjetos;
    procedure CriaSubMenusProjetosCreateORMALLTables;
    procedure SearchActive;

    {disconnectes sqldb/zeos}
    procedure DoDisconnect;

    {Connects sqldb or zeos}
    procedure DoSelectiveConnect;
    function GetDbInfo: TAsDbConnectionInfo;

    {Gets field name as FieldName(type(length), allow null)}
    function GetFieldNameForTreeView(f: TCollectionItem): string;

    {Updates GUI controls based on status connected/disconnected}
    procedure UpdateGUI(aIsConnected: boolean);

    // Show connection form to user and connect to database
    procedure Connect;
    {Exports active tab's grid data}
    procedure DoExport(exporter: TCustomDatasetExporter; FileExt: string);

    {Shows AsDbForm for the selected table in tableList}
    procedure ShowEditForm(FormFilter: TAsDbFormFilter);

    {fills schemas}
    procedure FillSchemas;

    {Fills table list}
    procedure FillTables;

    {Fills procedure list}
    procedure FillProcedures;

    {Executes a StoredProcedure Dialog,puts the execution command in active tab and runs it}
    procedure RunProcedure(procname: string);

    {Gets Stored Procedures's body}
    function GetProcedureText(procname: string): string;

    {Executes ActiveTab's query}
    procedure ExecuteQuery(IsTableData: boolean);

    {Generates sql query for given table based on given queryType qrSelect,qtSelectItem,qtInsert,qtUpdate,qtDelete}
    procedure GenerateSqlQuery(table: string; queryType: TQueryType;
      IsStoredProcedure: boolean);

    {Copy selected rows of activeTab's grid to Clipboard as TabDelimited text}
    procedure CopySelectedRows(IncludeHeaders: boolean);

    {Copy selected rows of activeTab's grid to Clipboard as SQL Insert Script}
    procedure CopySelectedRowsAsSqlInsert(tblName: string);

    {Copy rows of activeTab's grid to Clipboard as TabDelimited text}
    procedure CopyAllRows(IncludeHeaders: boolean);

    {Used in FindDialog }
    procedure FindText(aText: string);

    {QuickSearch table list}
    procedure QuickSearchTables(StartIndex: integer = 0);

    {Search table list}
    procedure SearchTables(aText: string; StartIndex: integer = 0);

    {QuickSearch Procedures}
    procedure QuickSearchProcedure(StartIndex: integer = 0);

    {Resizes active tab's gridColumns to the specified width}
    procedure ResizeGridColumns(ColumnWidth: integer = 100);

    {Event fired When query finished executing }
    procedure OnExecutionFinished(Sender: TObject; IsTableData: boolean);

    {Event fired when the user stopped the query execution}
    procedure OnExecutionStopped(Sender: TObject);

    {Event fired when Grid draws cells; this event is assigned to a LazSqlXTab property}
    procedure OnDBGridDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: integer; Column: TColumn; State: TGridDrawState);

    {Event fired when ActiveTab's Grid Cell is clicked and the type is of Blob or Memo; this event is assigned to a LazSqlXTab property}
    procedure EditSpecialField(Sender: TObject);   {*****Edit Special Fields*****}

    {Loads queries to tabs; Called after connnect}
    procedure LoadSession;
    {Saves queries in tabs to file called before disconnect, MainForm.OnClose, ApplicationProperties.OnException}
    procedure SaveSession;

  public
    {Main db connection }
    FDBInfo: TAsDbConnectionInfo;

    {Image used for QueryDesigner}
    ArrowImageLeft: TBitmap;
    {Image used for QueryDesigner}
    ArrowImageRight: TBitmap;
    {Image used for QueryDesigner}
    RectImage: TBitmap;
    {Configuration CRUD}
    property CrudInfo: TCRUDInfo read FCrudInfo write FCrudInfo;

    property DbInfo: TAsDbConnectionInfo read GetDbInfo;

  end;

const
  LazSqlXSessionFile = 'LazSqlX.sess';
  SEARCH_DELAY = 2;
{Tempo em segundos entre um KeyPress e outro para considerar na pesquisa de tabelas}



var
  MainForm: TMainForm;

implementation

uses AboutFormU, DatabaseClonerFormU, ProgressFormU, DataImporterFormU,
  DataImporterDialogU, Utils, AsStringUtils, AsDatabaseCloner;

{$R *.lfm}

{ TMainForm }

procedure TMainForm.OnDBGridDrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: integer; Column: TColumn; State: TGridDrawState);
var
  //determine if we're going to override normal Lazarus draw routines
  OverrideDraw: boolean;
  OurDisplayString: string;
  CurrentField: TField;
  DataRow: integer;
begin
  OverrideDraw := False;

  // Make sure selected cells are highlighted
  if (gdSelected in State) then
  begin
    (Sender as TDBGrid).Canvas.Brush.Color := clHighlight;
  end
  else
  begin
    (Sender as TDBGrid).Canvas.Brush.Color := (Sender as TDBGrid).Color;
  end;

  // Draw background in any case - thanks to ludob on the forum:
  (Sender as TDBGrid).Canvas.FillRect(Rect);

  //Foreground
  try
    CurrentField := Column.Field;
    if CurrentField.DataType = ftMemo then
    begin
      OverrideDraw := True;
    end;
  except
    on E: Exception do
    begin
      // We might have an inactive datalink or whatever,
      // in that case, pass on our problems to the LCL
      OverrideDraw := False;
    end;
  end;

  //Exception: fixed header should always be drawn like normal:
  // this never gets picked up as OnDrawColumnCell apparently only deals with data cells!!!
  if (gdFixed in State) then
  begin
    OverrideDraw := False;
  end;

  if OverrideDraw = False then
  begin
    // Call normal procedure to handle drawing for us.
    (Sender as TDBGrid).DefaultDrawColumnCell(Rect, DataCol, Column, State);
  end
  else
  begin
    // Get to work displaying our memo contents
    // Basically shamelessly ripped from
    // DefaultDrawColumnCell
    OurDisplayString := '';
    if CurrentField <> nil then
    begin
      //DO display memo ;) OurDisplayString is string to be displayed
      try
        OurDisplayString := CurrentField.AsString; //DisplayText will only show (Memo)
      except
        // Ignore errors; use empty string as specified above
      end;
    end;
    //Actual foreground drawing, taken from Grids.DrawCellText coding:
    (Sender as TDBGrid).Canvas.TextRect(Rect, Rect.Left, Rect.Top, OurDisplayString);
  end;
end;

procedure TMainForm.LoadSession;
var
  xmldoc: TXMLDocument;
  ServerNode: TDOMNode;
  I: integer;
  Filename: string;
  s: DOMString;
begin
  if (FPageControl <> nil) then
  begin
    Filename := GetTempDir + LazSqlXSessionFile;

    if FileExists(Filename) then
    begin
      FPageControl.RemoveAllTabs;
      ReadXMLFile(xmldoc, Filename);
      try
        ServerNode := xmldoc.DocumentElement.FindNode(FDBInfo.Identifier);
        if ServerNode <> nil then
          for I := 0 to ServerNode.ChildNodes.Count - 1 do
          begin
            s := ServerNode.ChildNodes[I].TextContent;
            if Trim(s) <> EmptyStr then
            begin
              actNewTab.Execute;
              if FPageControl.ActiveTab <> nil then
                FPageControl.ActiveTab.QueryEditor.Text := s;
            end;
          end;
        if FPageControl.PageCount = 0 then
          actNewTab.Execute;
        FPageControl.ScanNeeded;
      finally
        if xmldoc <> nil then
          xmldoc.Free;
      end;
    end;
  end;
end;

procedure TMainForm.SaveSession;
var
  xmldoc: TXMLDocument;
  RootElement: TDOMElement;
  QueryElement: TDOMElement;
  ServerNode: TDOMNode;
  I: integer;
  Filename: string;
  ServerIdentifier: string;
begin
  if (FDBInfo = nil) then
    exit;
  if (FPageControl <> nil) then
  begin
    Filename := GetTempDir + LazSqlXSessionFile;
    ServerNode := nil;
    if FileExists(Filename) then
      ReadXMLFile(xmldoc, Filename)
    else
      xmldoc := TXMLDocument.Create;
    try

      if FPageControl <> nil then
      begin
        ServerIdentifier := FDBInfo.Identifier;

        if xmldoc.DocumentElement = nil then
        begin
          RootElement := xmldoc.CreateElement('Tabs');
          xmldoc.AppendChild(RootElement);
        end
        else
        begin
          RootElement := xmldoc.DocumentElement;
        end;

        if RootElement <> nil then
        begin

          if RootElement.ChildNodes.Count > 0 then
            ServerNode := RootElement.FindNode(ServerIdentifier);

          if ServerNode <> nil then
          begin
            if ServerNode.ChildNodes <> nil then
              for I := 0 to ServerNode.ChildNodes.Count - 1 do
              begin
                ServerNode.RemoveChild(ServerNode.ChildNodes[0]);
              end;
          end
          else
          begin
            ServerNode := xmldoc.CreateElement(ServerIdentifier);
            xmldoc.DocumentElement.AppendChild(ServerNode);
          end;

          if FPageControl.Tag = 0 then
            for I := 0 to FPageControl.PageCount - 1 do
            begin
              QueryElement := xmldoc.CreateElement(FPageControl.Pages[I].Name);
              QueryElement.TextContent := FPageControl.Pages[I].QueryEditor.Text;
              ServerNode.AppendChild(QueryElement);
            end;
        end;

        WriteXMLFile(xmldoc, Filename);
      end;
    finally
      xmldoc.Free;
    end;
  end;
end;

procedure TMainForm.GenerateSqlQuery(table: string; queryType: TQueryType;
  IsStoredProcedure: boolean);
var
  p: TAsProcedureNames;
  s: TAsSqlGenerator;
  tis: TAsTableInfos;
  ti: TAsTableInfo;
  outPut: TStringList;
  tab: TLazSqlXTabSheet;
begin

  try
    FLoadingIndicator.StartAnimation;
    sbMain.Panels[1].Text := 'Generating query...';
    Application.ProcessMessages;


    p.PnDelete := table + '_delete';
    p.PnInsert := table + '_insert';
    p.PnSelect := table + '_select';
    p.PnSelectItem := table + '_selectItem';
    p.PnUpdate := table + '_update';

    actSaveAs.Enabled := True;
    actExecute.Enabled := True;

    try
      s := TAsSqlGenerator.Create(FDBInfo, p);
      tis := TAsTableInfos.Create(nil, FDBInfo);
      ti := tis.Add(cmbSchema.Text, table, False);

      if not IsStoredProcedure then
        Output := s.GenerateQuery(0, ti, queryType)
      else
        outPut := s.GenerateStoredProcedure(ti, queryType);

      tab := FPageControl.AddTab;

      tab.QueryEditor.Lines.Add('');
      tab.QueryEditor.Lines.Text := tab.QueryEditor.Lines.Text + outPut.Text;
      FPageControl.ScanNeeded;
    except
      on e: Exception do
        ShowMessage(e.Message);
    end;
    FPageControl.ScanNeeded;
  finally
    outPut.Free;
    s.Free;
    tis.Free;
    FLoadingIndicator.StopAnimation;
    sbMain.Panels[1].Text := EmptyStr;
  end;
end;

procedure TMainForm.CopySelectedRows(IncludeHeaders: boolean);
var
  RowStrings: TStringList;
  row, strGuid: string;
  blob: TBlobField;
  I, J: integer;
  g: TGuid;
  Hold_Bytes: TBytesField;
  dsize: integer;
begin
  RowStrings := TStringList.Create;
  try
    with FPageControl.ActiveTab.DataGrid do
    begin
      RowStrings.BeginUpdate();
      DataSource.DataSet.DisableControls();
      try

        if IncludeHeaders then
        begin
          for J := 0 to DataSource.DataSet.FieldCount - 1 do
          begin
            row := row + DataSource.DataSet.Fields[J].FieldName + #9;
          end;
          RowStrings.Add(Row);
        end;

        for i := 0 to (SelectedRows.Count - 1) do
        begin
          Datasource.DataSet.GotoBookmark(Pointer(SelectedRows[i]));
          row := '';
          for J := 0 to DataSource.DataSet.FieldCount - 1 do
          begin
            if DataSource.DataSet.Fields[J].IsBlob then
            begin
              strGuid := TAsStringUtils.BlobToString(DataSource.DataSet.Fields[J]);
              row := row + strGuid + #9;
            end
            else
            begin
              row := row + DataSource.DataSet.Fields[J].AsString + #9;
            end;
          end;
          RowStrings.Add(row);
        end;
      finally
        DataSource.DataSet.EnableControls();
        RowStrings.EndUpdate();
      end;
    end;
    Clipboard.AsText := RowStrings.Text;
  finally
    RowStrings.Free;
  end;
end;

procedure TMainForm.CopySelectedRowsAsSqlInsert(tblName: string);
var
  RowStrings: TStringList;
  row: string;
  blob: TBlobField;
  I, J: integer;
  FieldNames: string;
  FieldValue: string;
begin
  RowStrings := TStringList.Create;
  try
    with FPageControl.ActiveTab.DataGrid do
    begin
      RowStrings.BeginUpdate();
      DataSource.DataSet.DisableControls();
      try

        for I := 0 to DataSource.DataSet.FieldCount - 1 do
        begin
          FieldNames := FieldNames + DataSource.DataSet.Fields[I].FieldName +
            LoopSeperator[integer(I < DataSource.DataSet.FieldCount - 1)];
        end;

        for i := 0 to (SelectedRows.Count - 1) do
        begin
          Datasource.DataSet.GotoBookmark(Pointer(SelectedRows[i]));
          row := '';
          for J := 0 to DataSource.DataSet.FieldCount - 1 do
          begin

            if not DataSource.DataSet.Fields[J].IsNull then
              if DataSource.DataSet.Fields[J].IsBlob then
              begin
                FieldValue := TAsStringUtils.BlobToString(DataSource.DataSet.Fields[J]);
              end
              else
              begin
                FieldValue := DataSource.DataSet.Fields[J].AsString;
              end;

            if DataSource.DataSet.Fields[J].IsNull then
              FieldValue := 'NULL'
            else
              FieldValue := '''' + FieldValue + '''';

            row := row + FieldValue + LoopSeperator[integer(
              J < DataSource.DataSet.FieldCount - 1)];

          end;
          RowStrings.Add('INSERT INTO ' + tblName + '(' + Trim(FieldNames) +
            ') VALUES (' + Trim(row) + ')');
        end;
      finally
        DataSource.DataSet.EnableControls();
        RowStrings.EndUpdate();
      end;
    end;
    Clipboard.AsText := RowStrings.Text;
  finally
    RowStrings.Free;
  end;
end;

procedure TMainForm.CopyAllRows(IncludeHeaders: boolean);
var
  RowStrings: TStringList;
  row, strGuid: string;
  J: integer;
  b: TBookmark;
  blob: TBlobField;
begin
  RowStrings := TStringList.Create;
  try
    with FPageControl.ActiveTab.DataGrid do
    begin
      if (SelectedRows.Count > 0) then
        b := SelectedRows[0];

      if IncludeHeaders then
      begin
        for J := 0 to DataSource.DataSet.FieldCount - 1 do
        begin
          row := row + DataSource.DataSet.Fields[J].FieldName + #9;
        end;
        RowStrings.Add(Row);
      end;

      RowStrings.BeginUpdate();
      DataSource.DataSet.DisableControls();
      DataSource.DataSet.First;
      try
        while not DataSource.DataSet.EOF do
        begin
          row := '';
          for J := 0 to DataSource.DataSet.FieldCount - 1 do
          begin
            if DataSource.DataSet.Fields[J].IsBlob then
            begin
              strGuid := TAsStringUtils.BlobToString(DataSource.DataSet.Fields[J]);
              row := row + strGuid + #9;
            end
            else
            begin
              row := row + DataSource.DataSet.Fields[J].AsString + #9;
            end;
          end;
          RowStrings.Add(row);
          DataSource.DataSet.Next;
        end;
      finally
        DataSource.DataSet.EnableControls();
        RowStrings.EndUpdate();
      end;

      if b <> nil then
        try
          DataSource.DataSet.GotoBookmark(b);
        except
        end;
    end;
    Clipboard.AsText := RowStrings.Text;
  finally
    RowStrings.Free;
  end;
end;

procedure TMainForm.FindText(aText: string);
var
  FindS: string;
  IPos, FLen, SLen: integer; {Internpos, Lengde søkestreng, lengde memotekst}
  Res: integer;
  qe: TSynEdit;
begin

  qe := FPageControl.ActiveTab.QueryEditor;
  {FPos is global}
  FFound := False;
  FLen := Length(aText);
  SLen := Length(qe.Text);
  FindS := aText;

  //following 'if' added by mike
  if frMatchcase in findDialog1.Options then
    IPos := Pos(FindS, Copy(qe.Text, FPos + 1, SLen - FPos))
  else
    IPos := Pos(AnsiUpperCase(FindS), AnsiUpperCase(
      Copy(qe.Text, FPos + 1, SLen - FPos)));

  if IPos > 0 then
  begin
    FPos := FPos + IPos;
    qe.SetFocus;
    Self.ActiveControl := qe;
    qe.SelStart := FPos;  // -1;   mike   {Select the string FFound by POS}
    qe.SelEnd := FPos + Length(aText);
    FFound := True;
    FPos := FPos + FLen - 1;   //mike - move just past end of FFound item
  end
  else
  begin
    FPos := 0;     //mike  nb user might cancel dialog, so setting here is not enough
  end;

end;

procedure TMainForm.QuickSearchTables(StartIndex: integer = 0);
var
  I: integer;
begin
  for I := StartIndex to trvTables.Items.Count - 1 do
  begin
    if Pos(UPPERCASE(txtSearchTable.Text), UPPERCASE(trvTables.Items[I].Text)) > 0 then
    begin
      trvTables.Items[I].Selected := True;
      Break;
    end;
  end;
end;

procedure TMainForm.SearchTables(aText: string; StartIndex: integer);
var
  I: integer;
begin

  if Trim(FTableSearch) = '' then
    Exit;

  for I := StartIndex to trvTables.Items.Count - 1 do
  begin
    if Pos(UPPERCASE(FTableSearch), UPPERCASE(trvTables.Items[I].Text)) > 0 then
    begin
      trvTables.Items[I].Selected := True;
      Break;
    end;
  end;
end;

procedure TMainForm.QuickSearchProcedure(StartIndex: integer = 0);
var
  I: integer;
begin
  for I := StartIndex to trvProcedures.Items.Count - 1 do
  begin
    if AnsiContainsText(trvProcedures.Items[I].Text, txtSearchproc.Text) then
    begin
      trvProcedures.Items[I].Selected := True;
    end;
  end;
end;


procedure TMainForm.ResizeGridColumns(ColumnWidth: integer);
var
  I: integer;
  qe: TDBGrid;
begin
  qe := FPageControl.ActiveTab.DataGrid;
  qe.BeginUpdate;
  try
    for I := 0 to qe.Columns.Count - 1 do
    begin
      qe.Columns[I].Width := ColumnWidth;
    end;
  finally
    qe.EndUpdate(True);
  end;
end;

procedure TMainForm.OnExecutionFinished(Sender: TObject; IsTableData: boolean);
begin
  FLoadingIndicator.StopAnimation;
  actExecute.ImageIndex := 22;
  sbMain.Panels[3].Text := FPageControl.ActiveTab.Message;
end;


procedure TMainForm.pgcMainMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  if Button = mbMiddle then
    actCloseTab.Execute;
end;

procedure TMainForm.ReplaceDialog1Find(Sender: TObject);
begin
  FindText(ReplaceDialog1.FindText);
end;

procedure TMainForm.ReplaceDialog1Replace(Sender: TObject);
var
  s: TSynSearchOptions;
begin

  if FPageControl.ActiveTab = nil then
    exit;

  if frEntireScope in ReplaceDialog1.Options then
    s := [ssoEntireScope];

  if frReplace in ReplaceDialog1.Options then
    s := s + [ssoReplace];

  if frReplaceAll in ReplaceDialog1.Options then
    s := s + [ssoReplaceAll];

  if frMatchCase in ReplaceDialog1.Options then
    s := s + [ssoMatchCase];

  if frWholeWord in ReplaceDialog1.Options then
    s := s + [ssoWholeWord];

  if FPageControl.ActiveTab.QueryEditor.SelAvail then
    s := s + [ssoSelectedOnly];

  FPageControl.ActiveTab.QueryEditor.SearchReplace(
    ReplaceDialog1.FindText, ReplaceDialog1.ReplaceText, s);

end;

procedure TMainForm.sbMainDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
  const Rect: TRect);
begin
  if Panel = StatusBar.Panels[1] then
  begin
    StatusBar.Canvas.Brush.Style := bsClear;
    StatusBar.Canvas.TextOut(Rect.Left + 18, Rect.Top + 1, Panel.Text);
  end;
end;

procedure TMainForm.timerSearchTimer(Sender: TObject);
begin
  Inc(FContTimeSearch);

  if FContTimeSearch >= SEARCH_DELAY then
  begin
    FTableSearch := '';
    timerSearch.Enabled := False;
  end;
end;

procedure TMainForm.ToolButton1Click(Sender: TObject);
var
  frm: TAsDbForm;
  ti: TAsTableInfos;
begin
  ti := TAsTableInfos.Create(nil, FDBInfo);
  try
    frm := TAsDbForm.Create(FDBInfo, cmbSchema.Text, ti.Add(
      cmbSchema.Text, trvTables.Selected.Text));
    frm.OpenData;
    frm.CloseData;
  finally
    ti.Free;
    frm.Free;
  end;

end;

procedure TMainForm.ToolButton2Click(Sender: TObject);
var
  cs: TAsColumns;
begin
  try
    cs := TAsDbUtils.GetColumns(FDBInfo, trvTables.Selected.Text);
  finally
    cs.Free;
  end;
end;

procedure TMainForm.trvTablesChange(Sender: TObject; Node: TTreeNode);
begin
  if Node.Level = 0 then
    trvTables.PopupMenu := TablesPopupMenu
  else
    trvTables.PopupMenu := nil;
end;

procedure TMainForm.trvTablesExpanding(Sender: TObject; Node: TTreeNode;
  var AllowExpansion: boolean);

var
  tis: TAsTableInfos;
  ti: TAsTableInfo;
  tn, nkeys, nfkeys, nIndexes, nTriggers: TTreeNode;
  I: integer;
  fstr: string;
  f: TAsFieldInfo;
  FieldsO, FieldsD: string;
begin

  if Node.Level > 0 then
    Exit;

  try

    tis := TAsTableInfos.Create(nil, FDBInfo);
    ti := tis.Add(cmbSchema.Text, Node.Text);
    Node.DeleteChildren;
    for I := 0 to ti.AllFields.Count - 1 do
    begin
      f := ti.AllFields[I];
      tn := trvTables.Items.AddChild(Node, GetFieldNameForTreeView(f));
      if f.IsPrimaryKey then
        tn.ImageIndex := 1
      else
      if f.IsReference then
        tn.ImageIndex := 2
      else
        tn.ImageIndex := 3;

      tn.SelectedIndex := tn.ImageIndex;
    end;

    nkeys := trvTables.Items.AddChild(Node, 'Keys');
    nkeys.ImageIndex := 6;
    nkeys.SelectedIndex := nkeys.ImageIndex;
    for I := 0 to ti.PrimaryKeys.Count - 1 do
    begin
      tn := trvTables.Items.AddChild(nkeys, GetFieldNameForTreeView(ti.PrimaryKeys[I]));
      tn.ImageIndex := 1;
      tn.SelectedIndex := tn.ImageIndex;
    end;

    nfkeys := trvTables.Items.AddChild(Node, 'Foreign Keys');
    nfkeys.ImageIndex := 6;
    nfkeys.SelectedIndex := nfkeys.ImageIndex;
    for I := 0 to ti.ImportedKeys.Count - 1 do
    begin
      if FieldsO = '' then
        FieldsO := ti.ImportedKeys[I].ForeignColumnName // Fields FK TableName
      else
      if Pos(ti.ImportedKeys[I].ForeignColumnName, FieldsO) = 0 then
        FieldsO := FieldsO + ',' + ti.ImportedKeys[I].ForeignColumnName;

      if FieldsD = '' then
        FieldsD := ti.ImportedKeys[I].ColumnName // Fields FK TableName
      else
      if Pos(ti.ImportedKeys[I].ColumnName, FieldsD) = 0 then
        FieldsD := FieldsD + ',' + ti.ImportedKeys[I].ColumnName;

      if (I = ti.ImportedKeys.Count - 1) or
        (ti.ImportedKeys[I].ConstraintName <> ti.ImportedKeys[I + 1].ConstraintName) then
      begin
        tn := trvTables.Items.AddChild(nfkeys, ti.ImportedKeys[I].ConstraintName +
          ' - On Fields(' + FieldsD + ')' + ' FK Table(' + ti.ImportedKeys[I].ForeignTableName +
          '(' + FieldsO + '))');
        tn.ImageIndex := 2;
        tn.SelectedIndex := tn.ImageIndex;
      end;
{       tn := trvTables.Items.AddChild(nfkeys,GetFieldNameForTreeView(ti.ImportedKeys[I]));
       tn.ImageIndex:= 2;
       tn.SelectedIndex:=tn.ImageIndex;}
    end;

    nIndexes := trvTables.Items.AddChild(Node, 'Indexes');
    nIndexes.ImageIndex := 6;
    nIndexes.SelectedIndex := nIndexes.ImageIndex;
    for I := 0 to ti.Indexes.Count - 1 do
    begin
      tn := trvTables.Items.AddChild(nIndexes, GetFieldNameForTreeView(ti.Indexes[I]));
      tn.ImageIndex := 5;
      tn.SelectedIndex := tn.ImageIndex;
    end;

    nTriggers := trvTables.Items.AddChild(Node, 'Triggers');
    nTriggers.ImageIndex := 6;
    nTriggers.SelectedIndex := nTriggers.ImageIndex;
    for I := 0 to ti.Triggers.Count - 1 do
    begin
      tn := trvTables.Items.AddChild(nTriggers, GetFieldNameForTreeView(ti.Triggers[I]));
      tn.ImageIndex := 4;
      tn.SelectedIndex := tn.ImageIndex;
    end;


  finally
    tis.Free;
  end;
end;


procedure TMainForm.trvTablesKeyPress(Sender: TObject; var Key: char);
begin
  FTableSearch := FTableSearch + Key;
  SearchTables(FTableSearch);
  SearchActive;
end;

procedure TMainForm.txtSearchprocChange(Sender: TObject);
begin
  QuickSearchProcedure;
end;

procedure TMainForm.txtSearchprocEnter(Sender: TObject);
begin
  txtSearchproc.Clear;
  txtSearchproc.Font.Color := clWindowText;
end;

procedure TMainForm.txtSearchprocExit(Sender: TObject);
begin
  txtSearchproc.Font.Color := clSilver;
  txtSearchproc.Text := 'Search Procedure';
end;

procedure TMainForm.txtSearchprocKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
    QuickSearchProcedure;
end;

procedure TMainForm.txtSearchTableChange(Sender: TObject);
begin
  QuickSearchTables;
end;

procedure TMainForm.txtSearchTableEnter(Sender: TObject);
begin
  txtSearchTable.Clear;
  txtSearchTable.Font.Color := clWindowText;
end;

procedure TMainForm.txtSearchTableExit(Sender: TObject);
begin
  txtSearchTable.Font.Color := clSilver;
  txtSearchTable.Text := 'Search Table';
end;

procedure TMainForm.txtSearchTableKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
    QuickSearchTables;
end;

procedure TMainForm.ZSQLMonitor1LogTrace(Sender: TObject; Event: TZLoggingEvent);
begin

end;


procedure TMainForm.SearchActive;
begin
  FContTimeSearch := 0;
  timerSearch.Enabled := True;
end;


procedure TMainForm.Connect;
begin
  DoDisconnect;
  FDBInfo.Properties.Text := SqlConnBuilderForm.txtAdvancedProperties.Text;
  if SqlConnBuilderForm.ShowModal(FDBInfo) = mrOk then
  begin
    trvTables.Items.Clear;
    QueryDesignerForm.Clear;

    try
      //DoSelectiveConnect; //connection done in sqlconnbuilderform

      if FPageControl.PageCount = 0 then
      begin
        actNewTabExecute(nil);
      end;
      FillSchemas;
      FDBInfo.Schema := cmbSchema.Text;
      FillTables;
      FillProcedures;
      pgcLeft.ActivePageIndex := 0;
    except
      on e: Exception do
        ShowMessage(e.Message);
    end;
  end;
end;

procedure TMainForm.UpdateGUI(aIsConnected: boolean);
begin
  actConnect.Enabled := not aIsConnected;
  actDisconnect.Enabled := aIsConnected;
  actNewTab.Enabled := aIsConnected;
  actFind.Enabled := aIsConnected;
  actFindReplace.Enabled := aIsConnected;
  actOpen.Enabled := aIsConnected;
  actPrint.Enabled := aIsConnected;
  actSaveAs.Enabled := aIsConnected;

  if aIsConnected then
  begin
    pnlTables.Visible := True;
    FPageControl.Visible := True;
    pnlMain.Color := clDefault;
    trvTables.PopupMenu := TablesPopupMenu;
    trvProcedures.PopupMenu := StoredProcedurePopUp;
    actNewTab.Enabled := True;
    tabProcedures.TabVisible := FDBInfo.DbType <> dtSQLite;
    mitGenerateSP.Visible := tabProcedures.TabVisible;
    actGenerateAllproc.Visible := tabProcedures.TabVisible;
    actGenerateSelectItemProc.Visible := tabProcedures.TabVisible;
    actGenerateInsertProc.Visible := tabProcedures.TabVisible;
    actGenerateUpdateProc.Visible := tabProcedures.TabVisible;
    actGenerateDeleteProc.Visible := tabProcedures.TabVisible;
    actGenerateSelectProc.Visible := tabProcedures.TabVisible;
    sbMain.Panels[0].Text := FDBInfo.Server + '/' + FDBInfo.Database;
    btnConnect.Action := actDisconnect;
    mitConnect.Action := actDisconnect;
  end
  else
  begin
    FPageControl.Visible := False;
    pnlTables.Visible := False;
    pnlMain.Color := clWindow;
    btnConnect.Action := actConnect;
    mitConnect.Action := actConnect;
  end;

end;

procedure TMainForm.DoSelectiveConnect;
begin
  FDBInfo.Open;
end;

function TMainForm.GetDbInfo: TAsDbConnectionInfo;
begin
  Result := FDBInfo;
end;

function TMainForm.GetFieldNameForTreeView(f: TCollectionItem): string;
var
  fi: TAsFieldInfo;
  ik: TAsImportedKeyInfo;
  idx: TAsIndexInfo;
  tri: TAsTriggerInfo;
begin
  if f is TAsFieldInfo then
  begin
    fi := f as TAsFieldInfo;
    Result := fi.FieldName + ' (' + fi.FieldType + ' (' + IntToStr(fi.Length) + ',';
    if fi.AllowNull then
      Result := Result + 'null'
    else
      Result := Result + ' not null';
    Result := Result + '))';
  end
  else
  if f is TAsImportedKeyInfo then
  begin
    ik := f as TAsImportedKeyInfo;
    Result := ik.ColumnName + ' (' + ik.ForeignTableName + '(' + ik.ForeignColumnName + '))';
  end
  else
  if f is TAsIndexInfo then
  begin
    idx := f as TAsIndexInfo;
    Result := idx.INDEX_Name + ' (' + idx.Column_Name + ', ' + idx.ASC_OR_DESC + ')';
  end
  else
  if f is TAsTriggerInfo then
  begin
    tri := f as TAsTriggerInfo;
    Result := tri.Name + ' (' + tri.Event + ')';
  end;

end;

procedure TMainForm.DoDisconnect;
begin
  try
    FDBInfo.Close;
    sbMain.Panels[2].Text := '';
    sbMain.Panels[3].Text := '';
  except
    //usually when discconnection doesn't work for some reason
    FDBInfo.Free;
    FDBInfo := TAsDbConnectionInfo.Create;
  end;
end;


procedure TMainForm.DoExport(exporter: TCustomDatasetExporter; FileExt: string);
var
  tblName: string;
  se: TSQLExporter;
  ds: TDataSource;
var
  i: integer;
begin

  ds := FPageControl.ActiveTab.DataSource;

  if ds = nil then
  begin
    ShowMessage('Active data source is null');
    Exit;
  end;

  if not ds.DataSet.Active then
  begin
    ShowMessage('There is no data to export. Please run a query then try again.');
    Exit;
  end;

  with TSaveDialog.Create(nil) do
  begin
    try

      if (exporter is TSQLExporter) then
      begin
        se := exporter as TSQLExporter;
        tblName := InputBox('Input', 'Tablename', trvTables.Selected.Text);
        se.FormatSettings.TableName := tblName;

        se.ExportFields.Clear;

        for i := 0 to se.Dataset.Fields.Count - 1 do
        begin
          if (se.Dataset.Fields[I].DataType <> ftAutoInc) and
            (se.Dataset.Fields[I].DataType <> ftGuid) then
          begin
            se.ExportFields.AddField(se.Dataset.Fields[I].FieldName);
          end;
        end;
      end;

      DefaultExt := FileExt;
      Filter := '(*' + FileExt + ')|*' + FileExt;
      if Execute then
      begin
        (exporter as TCustomFileExporter).FileName := FileName;
        ds.DataSet.DisableControls;
        try
          exporter.Dataset := ds.DataSet;
          exporter.Dataset.First;
          exporter.Execute;
        finally
          ds.DataSet.First;
          ds.DataSet.EnableControls;
        end;
      end;
    finally
      Free;
    end;
  end;
end;

procedure TMainForm.ShowEditForm(FormFilter: TAsDbFormFilter);
var
  frm: TAsDbForm;
  ti: TAsTableInfos;
begin
  if trvTables.Selected <> nil then
  begin
    ti := TAsTableInfos.Create(nil, FDBInfo);
    try
      try
        ti.AddTable(cmbSchema.Text, trvTables.Selected.Text);
        frm := TAsDbForm.Create(FDBInfo, cmbSchema.Text, ti[0]);
        frm.ShowModal(FormFilter);
        frm.CloseData;
      except
        on E: Exception do
          ShowMessage(E.Message);
      end;
    finally
      ti.Free;
      if frm <> nil then
        frm.Free;
    end;
  end;
end;

procedure TMainForm.FillSchemas;
var
  list: TStringList;
begin
  try
    cmbSchema.Clear;
    list := TAsDbUtils.GetSchemas(FDBInfo);
    cmbSchema.Items.AddStrings(list);
  finally
    list.Free;
  end;


  case FDBInfo.DbType of
    dtMsSql: cmbSchema.ItemIndex := cmbSchema.Items.IndexOf('dbo');
    dtOracle: cmbSchema.ItemIndex := cmbSchema.Items.IndexOf(FDBInfo.UserName);
    dtPostgreSql: cmbSchema.ItemIndex := cmbSchema.Items.IndexOf('public');
    else
      cmbSchema.ItemIndex := 0;
  end;

  if cmbSchema.ItemIndex < 0 then
  begin
    if cmbSchema.Items.Count > 0 then
      cmbSchema.ItemIndex := 0;
  end;
end;

procedure TMainForm.FillTables;
var
  list: TStringList;
  I: integer;
  tn, tc: TTreeNode;
begin

  try
    list := TAsDbUtils.GetTablenames(FDBInfo);
    trvTables.Items.Clear;
    list.Sort;
    for I := 0 to list.Count - 1 do
    begin
      tn := trvTables.Items.Add(nil, list[I]);
      tn.ImageIndex := 0;
      tn.SelectedIndex := 0;
      tc := trvTables.Items.AddChild(tn, '');
    end;
    FPageControl.Tables.Clear;
    FPageControl.Tables.AddStrings(list);
  finally
    list.Free;
  end;
  if trvTables.Items.Count > 0 then
    trvTables.Items[0].Selected := True;
end;

procedure TMainForm.FillProcedures;
var
  lst: TStringList;
  s: string;
  n: TTreeNode;
begin
  if FDBInfo.DbType = dtSQLite then
    exit;
  trvProcedures.Items.Clear;
  try
    lst := TAsDbUtils.GetProcedureNames(FDBInfo);
    for s in lst do
    begin
      n := trvProcedures.Items.AddChild(nil, s);
      n.ImageIndex := 9;
      n.SelectedIndex := 9;
    end;
    FPageControl.Procedures.Clear;
    FPageControl.Procedures.AddStrings(lst);
  finally
    lst.Free;
  end;
end;


procedure TMainForm.RunProcedure(procname: string);
var
  I: integer;
  lst: TList;
  s: string;
  ProcInfo: TAsProcedureInfo;
  tab: TLazSqlXTabSheet;
begin

  try
    ProcInfo := TAsProcedureInfo.Create(FDBInfo);
    s := ProcInfo.GetRunProcedureText(procname, True);
    if s <> EmptyStr then
    begin
      actNewTab.Execute;
      tab := FPageControl.ActiveTab;
      tab.QueryEditor.Text := s;
      tab.RunQuery;
    end;
  finally
    ProcInfo.Free;
  end;

end;

function TMainForm.GetProcedureText(procname: string): string;
var
  qr: TAsQuery;
begin

  qr := TAsQuery.Create(FDBInfo);

  try

    case FDBInfo.DbType of
      dtMsSql:
      begin
        qr.SQL.Text := 'sp_helptext ''' + procname + '''';
      end;
      dtOracle:
      begin
        qr.SQL.Text := 'select text from user_source where name = ''' +
          procname + ''' order by line';
      end;
      dtMySql:
      begin
        qr.SQL.Text := 'SELECT ROUTINE_DEFINITION FROM INFORMATION_SCHEMA.ROUTINES ' +
          ' WHERE ROUTINE_SCHEMA = ''' + FDBInfo.Database +
          ''' AND ROUTINE_TYPE = ''PROCEDURE'' AND ROUTINE_NAME = ''' + procname + ''';';
      end;
      dtFirebirdd:
      begin
        qr.SQL.Text :=
          'SELECT r.RDB$PROCEDURE_SOURCE FROM RDB$PROCEDURES r where r.RDB$PROCEDURE_NAME='''
          + procname + '''';
      end;
      dtPostgreSql:
      begin
        qr.SQL.Text := 'SELECT ROUTINE_DEFINITION FROM INFORMATION_SCHEMA.ROUTINES ' +
          ' WHERE ROUTINE_SCHEMA = ''' + cmbSchema.Text +
          ''' AND (ROUTINE_TYPE = ''PROCEDURE'' or ROUTINE_TYPE = ''FUNCTION'' ) AND SPECIFIC_NAME = '''
          +
          procname + ''';';
      end;
    end;

    if FDBInfo.DbType <> dtSQLite then
    begin
      qr.Open;

      while not qr.EOF do
      begin
        Result := Result + qr.Fields[0].AsString;
        qr.Next;
      end;

    end;

  finally
    qr.Free;
  end;

end;

procedure TMainForm.ExecuteQuery(IsTableData: boolean);
var
  strActiveTablename: string;
begin
  actExecute.ImageIndex := 61;
  actExecute.Hint := 'Stop execution';
  FLoadingIndicator.StartAnimation;

  if trvTables.Selected <> nil then
    if trvTables.Selected.Level = 0 then
      strActiveTablename := trvTables.Selected.Text;

  if strActiveTablename <> '' then
    FPageControl.ActiveTab.RunQuery(IsTableData, cmbSchema.Text, strActiveTablename);
end;

procedure TMainForm.EditSpecialField(Sender: TObject);
var
  blob: TBlobField;
  grd: TDBGrid;
  DialogResult: integer;
  fDetect: TFileDetector;
  fType: TFileType;
  m: TMemoryStream;

begin

  if not (Sender is TDBGrid) then
    Exit;

  grd := (Sender as TDBGrid);

  if (not grd.DataSource.DataSet.Active) then
    exit;

  try

    if not grd.ReadOnly then
      grd.DataSource.DataSet.Edit;

    BlobFieldForm.btnLoadFromfile.Visible := not grd.ReadOnly;
    EditMemoForm.btnOk.Visible := not grd.ReadOnly;

    case grd.SelectedField.DataType of
      ftBlob, ftOraBlob:
      begin
        try
          fDetect := TFileDetector.Create;
          if fDetect.Errors.Count > 0 then
            ShowMessage(fDetect.Errors.Text);
          m := TMemoryStream.Create;
          TBlobField(grd.SelectedField).SaveToStream(m);
          fType := fDetect.Detect(m);
          BlobFieldForm.lblFileType.Caption := fType.Description;
          BlobFieldForm.HasImagePreview := False;
          BlobFieldForm.imgPreview.Picture := nil;
          if fType.PreviewType <> ftpNone then
          begin
            try
              m.Position := 0;
              BlobFieldForm.imgPreview.Picture.LoadFromStream(m);
              BlobFieldForm.HasImagePreview := True;
            except
              on e: Exception do
                BlobFieldForm.pnlPreview.Caption := e.Message;
            end;
          end;

          if not BlobFieldForm.HasImagePreview then
          begin
            BlobFieldForm.lblFileType.Caption :=
              TAsStringUtils.BlobToString(grd.SelectedField);
          end;

          DialogResult := BlobFieldForm.ShowModal;
        finally
          m.Free;
          fDetect.Free;
          fType.Free;
        end;


        if DialogResult = mrOk then

          with TOpenDialog.Create(nil) do
          begin
            if Execute then
            begin
              try
                grd.DataSource.DataSet.Edit;
                blob := TBlobField(grd.SelectedField);
                blob.LoadFromFile(FileName);
              except
                on e: Exception do
                begin
                  ShowMessage(e.Message);
                end;
              end;
            end;
            Free;
          end;
        if DialogResult = mrYes then
          with TSaveDialog.Create(nil) do
          begin
            if Execute then
            begin
              try
                if grd.SelectedField <> nil then
                begin
                  blob := TBlobField(grd.SelectedField);
                  blob.SaveToFile(FileName);
                end
                else
                begin
                  ShowMessage('Selected binary is empty!');
                end;
              except
                on e: Exception do
                begin
                  ShowMessage(e.Message);
                end;
              end;
            end;
            Free;
          end;
      end;
      ftMemo, ftWideMemo:
      begin

        if (grd.SelectedField is TWideMemoField) then
          EditMemoForm.memEdit.Text := (grd.SelectedField as TWideMemoField).Value;

        if (grd.SelectedField is TMemoField) then
          EditMemoForm.memEdit.Text := (grd.SelectedField as TMemoField).Value;

        if EditMemoForm.ShowModal = mrOk then
        begin
          try
            grd.DataSource.DataSet.Edit;
            if (grd.SelectedField is TWideMemoField) then
              (grd.SelectedField as TWideMemoField).Value := EditMemoForm.memEdit.Text;
            if (grd.SelectedField is TMemoField) then
              (grd.SelectedField as TMemoField).Value := EditMemoForm.memEdit.Text;
          except
            on e: Exception do
            begin
              ShowMessage(e.Message);
            end;
          end;
        end;
      end;
    end;
  except

  end;
end;

procedure TMainForm.EditUndo1Execute(Sender: TObject);
begin
  FPageControl.ActiveTab.QueryEditor.Undo;
end;

procedure TMainForm.FindDialog1Find(Sender: TObject);
begin
  FindText(FindDialog1.FindText);
  FindDialog1.CloseDialog;
end;

procedure TMainForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  SaveSession;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FDBInfo := TAsDbConnectionInfo.Create;
  FCrudInfo := TCRUDInfo.Create;

  AppVersion := TFileUtils.GetApplicationVersion;

  FtableIcon := TBitmap.Create;
  FfunctionIcon := TBitmap.Create;
  FprocedureIcon := TBitmap.Create;
  FvarIcon := TBitmap.Create;
  FfieldIcon := TBitmap.Create;

  TreeViewImages.GetBitmap(0, FtableIcon);
  TreeViewImages.GetBitmap(4, FfunctionIcon);
  TreeViewImages.GetBitmap(3, FfieldIcon);
  TreeViewImages.GetBitmap(8, FvarIcon);
  TreeViewImages.GetBitmap(9, FprocedureIcon);

  ApplicationImages.GetBitmap(46, ArrowImageLeft);
  ApplicationImages.GetBitmap(47, ArrowImageRight);
  ApplicationImages.GetBitmap(48, RectImage);

  FPageControl := TLazSqlXPageControl.Create(Self, FDBInfo);
  FPageControl.Highlighter := SqlSyntax;
  FPageControl.Keywords.AddStrings(TLazSqlXResources.SqlReservedKeywords);
  FPageControl.OnExecutionFinished := @OnExecutionFinished;
  FPageControl.OnExecutionStopped := @OnExecutionStopped;
  FPageControl.OnDataGridDblClick := @EditSpecialField;
  FPageControl.QueryEditorPopUpMenu := QueryEditorPopupMenu;
  FPageControl.DataGridPopUpMenu := GridPopupMenu;
  FPageControl.PopupMenu := PageControlPopupMenu;
  FPageControl.OnChange := @OnPageControlChange;
  FPageControl.OnCaretPositionChanged := @OnCaretPosition;

  FPageControl.TableIcon := FtableIcon;
  FPageControl.FunctionIcon := FfunctionIcon;
  FPageControl.FieldIcon := FfieldIcon;
  FPageControl.VarIcon := FvarIcon;
  FPageControl.ProcedureIcon := FprocedureIcon;


  FPageControl.Parent := pnlMain;
  FPageControl.Visible := False;
  FPageControl.Align := alClient;

  sbMain.Panels[1].Style := psOwnerDraw;
  FLoadingIndicator := TLoadingIndicator.Create(pnlIndicator);
  FLoadingIndicator.Parent := pnlIndicator;
  FLoadingIndicator.Align := alClient;
  Self.WindowState := wsMaximized;
  Self.Top:= 0;
  Self.Left:= 0;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FvarIcon.Free;
  FtableIcon.Free;
  FfunctionIcon.Free;
  FfieldIcon.Free;
  FprocedureIcon.Free;
  FPageControl.Free;
  ArrowImageRight.Free;
  ArrowImageLeft.Free;
  RectImage.Free;
  FLoadingIndicator.Free;
  FDBInfo.Free;

end;

procedure TMainForm.actOpenExecute(Sender: TObject);
begin
  if FPageControl.PageCount < 0 then
    exit;
  if OpenDialog.Execute then
  begin
    actNewTab.Execute;
    FPageControl.ActiveTab.QueryEditor.Lines.LoadFromFile(OpenDialog.FileName);
    FPageControl.ActiveTab.Caption := ExtractFileNameWithoutExt(OpenDialog.FileName);
  end;
end;

procedure TMainForm.actOpenTableExecute(Sender: TObject);
begin
  actNewTabExecute(nil);
  ExecuteQuery(True);
end;

procedure TMainForm.actPdfHelpExecute(Sender: TObject);
begin
  OpenDocument(ChangeFileExt(Application.ExeName, '.pdf'));
end;

procedure TMainForm.actPrintExecute(Sender: TObject);
var
  p: TAsSqlParser;
  fromTable: string;
begin
  try
    p := TAsSqlParser.Create(cmbSchema.Text, FDBInfo);
    p.ParseCommand(FPageControl.ActiveTab.QueryEditor.Text);
    if (p.FromTables.Count > 0) then
      fromTable := p.FromTables[0].Name
    else
      fromTable := FPageControl.ActiveTab.Caption;
  finally
    p.Free;
  end;
  GridPrinter.Caption := fromTable;
  GridPrinter.DBGrid := FPageControl.ActiveTab.DataGrid;
  GridPrinter.Template := TLazSqlXResources.ReportTemplatePath;
  GridPrinter.PreviewReport;
end;

procedure TMainForm.actQueryDesignerExecute(Sender: TObject);
begin
  if FDBInfo.Connected then
  begin
    QueryDesignerForm.Schema := cmbSchema.Text;
    if QueryDesignerForm.ShowModal(FDBInfo) = mrOk then
    begin
      actNewTab.Execute;
      FPageControl.ActiveTab.QueryEditor.Lines.AddStrings(QueryDesignerForm.SQLQuery);
      FPageControl.ScanNeeded;
    end;
  end;
end;

procedure TMainForm.actRefreshProceduresExecute(Sender: TObject);
begin
  FillProcedures;
end;

procedure TMainForm.actRefreshTablesExecute(Sender: TObject);
begin
  DoDisconnect;
  FillTables;
  DoSelectiveConnect;
end;

procedure TMainForm.actRunStoredProcedureExecute(Sender: TObject);
begin
  if trvProcedures.Selected <> nil then
    RunProcedure(trvProcedures.Selected.Text);
end;

procedure TMainForm.actExecuteExecute(Sender: TObject);
begin
  ExecuteQuery(False);
end;

procedure TMainForm.actConnectExecute(Sender: TObject);
begin
  Connect;
  LoadSession;
  UpdateGUI(FDBInfo.Connected);
end;

procedure TMainForm.actDisconnectExecute(Sender: TObject);
begin
  SaveSession;
  DoDisconnect;
  FPageControl.RemoveAllTabs;
  UpdateGUI(FDBInfo.Connected);
end;

procedure TMainForm.actDropDatabaseExecute(Sender: TObject);
begin
  try
    if MessageDlg('EXTRA WARNING', 'You''re about to DROP THE DATABASE. Continue?',
      mtWarning, mbYesNo, 0) = mrYes then
    begin
      actDisconnect.Execute;
      Application.ProcessMessages;
      Sleep(3000);
      TAsDbUtils.ExecuteQuery('DROP DATABASE ' + FDBInfo.Database, FDBInfo);
    end;
  except
    on e: Exception do
      ShowMessage(e.Message);
  end;
end;

procedure TMainForm.actDropTableExecute(Sender: TObject);
begin

  if MessageDlg('Confirm', 'Are you sure you want to drop the table?',
    mtConfirmation, mbYesNo, 0) = mrYes then
    try
      DoDisconnect;
      try
        TAsDbUtils.ExecuteQuery('DROP TABLE ' + trvTables.Selected.Text, FDBInfo);
      finally
        DoSelectiveConnect;
        FillTables;
      end;
    except
      on E: Exception do
        ShowMessage(E.Message);
    end;

end;

procedure TMainForm.actEditFormAllExecute(Sender: TObject);
begin
  ShowEditForm(dffNone);
end;

procedure TMainForm.actEditFormCustomFilterExecute(Sender: TObject);
begin
  ShowEditForm(dffCustomFilter);
end;

procedure TMainForm.actDesignTableExecute(Sender: TObject);
begin
  if trvTables.Selected <> nil then
  begin
    DesignTableForm.Showmodal(FDBInfo, cmbSchema.Text, trvTables.Selected.Text);
  end;
end;

procedure TMainForm.actEditLimitRecordsExecute(Sender: TObject);
begin
  ShowEditForm(dffTopRecords);
end;

procedure TMainForm.actCloseAllButThisExecute(Sender: TObject);
begin
  FPageControl.RemoveAllTabsButActive;
end;

procedure TMainForm.actDatabaseClonerExecute(Sender: TObject);
var
  infos: TAsTableInfos;
  I: integer;
  db: string;
  lstErrors: TStringList;
  lst: TStringList;
begin
  try
    lstErrors := TStringList.Create;
    try

      ProgressForm.Show;
      Application.ProcessMessages;

      lst := TAsDbUtils.GetTablenames(FDBInfo);

      infos := TAsTableInfos.Create(nil, FDBInfo);

      ProgressForm.MaxProgress := lst.Count;

      for I := 0 to lst.Count - 1 do
      begin

        try
          //skip sequential tables for ORA
          if FDBInfo.DbType = dtOracle then
            if AnsiContainsStr(lst[I], '_SEQ') then
              Continue;

          infos.AddTable(cmbSchema.Items[cmbSchema.ItemIndex], lst[I]);
        except
          on e: Exception do
          begin
            lstErrors.Add(lst[I]);
          end;
        end;

        ProgressForm.Message :=
          'Extracting Table Informations [' + lst[I] + '] ... ';
        ProgressForm.StepProgress;
        Application.ProcessMessages;
      end;
    finally
      ProgressForm.Close;

    end;

    if FDBInfo.DbType <> dtSQLite then
      DatabaseClonerForm.txtDestinationDbName.Text := SqlConnBuilderForm.cmbDatabase.Text
    else
      DatabaseClonerForm.txtDestinationDbName.Text :=
        ExtractFileName(SqlConnBuilderForm.cmbDatabase.Text);


    if lstErrors.Count > 0 then
    begin
      MessageDlg('Warning', 'The following tables could not be added' +
        #13#10 + lstErrors.Text, mtWarning, [mbOK], 0);
    end;

    DatabaseClonerForm.ShowModal(FDBInfo, infos);
  finally
    lstErrors.Free;
    infos.Free;
    lst.Free;
  end;
end;

procedure TMainForm.actCheckSyntaxExecute(Sender: TObject);
begin
  FPageControl.ActiveTab.CheckSyntax;
end;

procedure TMainForm.actAboutExecute(Sender: TObject);
begin
  AboutForm.ShowModal;
end;

procedure TMainForm.actClearSessionHistoryExecute(Sender: TObject);
begin
  DeleteFile(GetTempDir + LazSqlXSessionFile);
end;

procedure TMainForm.actCopyRunProcedureTextExecute(Sender: TObject);
var
  pi: TAsProcedureInfo;
begin
  if trvProcedures.Selected = nil then
    exit;

  pi := TAsProcedureInfo.Create(FDBInfo);
  try
    Clipboard.AsText := pi.GetRunProcedureText(trvProcedures.Selected.Text, False);
  finally
    pi.Free;
  end;
end;

procedure TMainForm.actCreateDAOExecute(Sender: TObject);
begin

end;

procedure TMainForm.ActCreateORMAllTablesExecute(Sender: TObject);
begin

end;

procedure TMainForm.actCreateCRUDDelphiExecute(Sender: TObject);
var
  dbC: TAsDatabaseCloner;
  ti: TAsTableInfos;
  t: TAsTableInfo;
begin
  CrudInfo.LoadFromFile(GetCurrentDir + PathDelim + 'CRUD' + PathDelim + TAction(Sender).Caption + PathDelim +'CRUD.ini');
  if trvTables.Selected = nil then
    Exit;

  if trvTables.Selected.Level > 0 then
    Exit;

  dbc := TAsDatabaseCloner.Create(FDBInfo, FDBInfo.Database);
  ti := TAsTableInfos.Create(nil, FDBInfo);
  t := ti.LoadTable(cmbSchema.Text, trvTables.Selected.Text, False);
  try
    if not Assigned(FrmModel) then
      FrmModel := TFrmModel.Create(Application);
    FrmModel.InfoTable := t;
    FrmModel.InfoCrud := Self.CrudInfo;
    FrmModel.ShowModal;
  finally
    dbc.Free;
    ti.Free;
    FreeAndNil(FrmModel);
  end;
end;

procedure TMainForm.actCloseExecute(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.actCloseTabExecute(Sender: TObject);
begin
  FPageControl.RemoveTab(FPageControl.ActiveTab);
end;

procedure TMainForm.ActExportCSVExecute(Sender: TObject);
begin
  DoExport(CSVExporter,'.csv');
end;

procedure TMainForm.actExportSQLExecute(Sender: TObject);
begin
  SqlExporter.Dataset := FPageControl.ActiveTab.DataGrid.DataSource.DataSet;
  DoExport(SqlExporter, '.sql');
end;

procedure TMainForm.ActExportXMLExecute(Sender: TObject);
begin
  DoExport(XMLExporter,'.xml');
end;

procedure TMainForm.actFindExecute(Sender: TObject);
begin
  FindDialog1.Execute;
end;

procedure TMainForm.actFindReplaceExecute(Sender: TObject);
begin
  ReplaceDialog1.Execute;
end;

procedure TMainForm.actFormatQueryExecute(Sender: TObject);
begin
  if FPageControl.PageCount > 0 then
    FPageControl.ActiveTab.QueryEditor.Text :=
      TAsDbUtils.FormatQuery(FPageControl.ActiveTab.QueryEditor.Text);
end;

procedure TMainForm.actGenerateAllprocExecute(Sender: TObject);
begin
  if trvTables.Selected <> nil then
  begin
    if trvTables.Selected.Level = 0 then
      GenerateSqlQuery(trvTables.Selected.Text, TQueryType(
        (Sender as TAction).Tag), True);
  end;
end;

procedure TMainForm.actGenerateAllQueryExecute(Sender: TObject);
begin
  if trvTables.Selected <> nil then
  begin
    if trvTables.Selected.Level = 0 then
      GenerateSqlQuery(trvTables.Selected.Text, TQueryType(
        (Sender as TAction).Tag), False);
  end;
end;

procedure TMainForm.actGenerateCreateScriptExecute(Sender: TObject);
var
  dbC: TAsDatabaseCloner;
  ti: TAsTableInfos;
  t: TAsTableInfo;
begin

  if trvTables.Selected = nil then
    Exit;

  if trvTables.Selected.Level > 0 then
    Exit;

  dbc := TAsDatabaseCloner.Create(FDBInfo, FDBInfo.Database);
  ti := TAsTableInfos.Create(nil, FDBInfo);
  t := ti.Add(cmbSchema.Text, trvTables.Selected.Text);
  try
    if actNewTab.Execute then
      FPageControl.ActiveTab.QueryEditor.Text := dbc.GetCreateScript(t, True, False);
    //FPageControl.ActiveTab.QueryEditor.Lines.Add(dbc.GetCreateScript(t, True, False));
  finally
    dbc.Free;
    ti.Free;
  end;

end;

procedure TMainForm.actGenerateDeleteProcExecute(Sender: TObject);
begin
  if trvTables.Selected <> nil then
  begin
    if trvTables.Selected.Level = 0 then
      GenerateSqlQuery(trvTables.Selected.Text, TQueryType(
        (Sender as TAction).Tag), True);
  end;
end;

procedure TMainForm.actGenerateDeleteQueryExecute(Sender: TObject);
begin
  if trvTables.Selected <> nil then
  begin
    if trvTables.Selected.Level = 0 then
      GenerateSqlQuery(trvTables.Selected.Text, TQueryType(
        (Sender as TAction).Tag), False);
  end;
end;

procedure TMainForm.actGenerateInsertProcExecute(Sender: TObject);
begin
  if trvTables.Selected <> nil then
  begin
    if trvTables.Selected.Level = 0 then
      GenerateSqlQuery(trvTables.Selected.Text, TQueryType(
        (Sender as TAction).Tag), True);
  end;
end;

procedure TMainForm.actGenerateInsertQueryExecute(Sender: TObject);
begin
  if trvTables.Selected <> nil then
  begin
    if trvTables.Selected.Level = 0 then
      GenerateSqlQuery(trvTables.Selected.Text, TQueryType(
        (Sender as TAction).Tag), False);
  end;
end;

procedure TMainForm.actGenerateSelectItemProcExecute(Sender: TObject);
begin
  if trvTables.Selected <> nil then
  begin
    if trvTables.Selected.Level = 0 then
      GenerateSqlQuery(trvTables.Selected.Text, TQueryType(
        (Sender as TAction).Tag), True);
  end;
end;

procedure TMainForm.actGenerateSelectItemQueryExecute(Sender: TObject);
begin
  if trvTables.Selected <> nil then
  begin
    if trvTables.Selected.Level = 0 then
      GenerateSqlQuery(trvTables.Selected.Text, TQueryType(
        (Sender as TAction).Tag), False);
  end;
end;

procedure TMainForm.actGenerateSelectProcExecute(Sender: TObject);
begin
  if trvTables.Selected <> nil then
  begin
    if trvTables.Selected.Level = 0 then
      GenerateSqlQuery(trvTables.Selected.Text, TQueryType(
        (Sender as TAction).Tag), True);
  end;
end;

procedure TMainForm.actGenerateSelectQueryExecute(Sender: TObject);
begin
  if trvTables.Selected <> nil then
  begin
    if trvTables.Selected.Level = 0 then
      GenerateSqlQuery(trvTables.Selected.Text, TQueryType(
        (Sender as TAction).Tag), False);
  end;
end;

procedure TMainForm.actGenerateUpdateProcExecute(Sender: TObject);
begin
  if trvTables.Selected <> nil then
  begin
    if trvTables.Selected.Level = 0 then
      GenerateSqlQuery(trvTables.Selected.Text, TQueryType(
        (Sender as TAction).Tag), True);
  end;
end;

procedure TMainForm.actGenerateUpdateQueryExecute(Sender: TObject);
begin
  if trvTables.Selected <> nil then
  begin
    if trvTables.Selected.Level = 0 then
      GenerateSqlQuery(trvTables.Selected.Text, TQueryType(
        (Sender as TAction).Tag), False);
  end;
end;

procedure TMainForm.actGridCopyAllExecute(Sender: TObject);
begin
  CopyAllRows(False);
end;

procedure TMainForm.actGridCopyAllWithHeadersExecute(Sender: TObject);
begin
  CopyAllRows(True);
end;

procedure TMainForm.actGridCopyExecute(Sender: TObject);
begin
  Clipboard.AsText := FPageControl.ActiveTab.DataGrid.SelectedField.AsString;
end;

procedure TMainForm.actGridCopyRowExecute(Sender: TObject);
begin
  CopySelectedRows(False);
end;

procedure TMainForm.actGridCopyRowsAsInsertExecute(Sender: TObject);
var
  t: string;
  parser: TAsSqlParser;
begin

  if FPageControl.ActiveTab.HasActiveData then
  begin
    parser := TAsSqlParser.Create(cmbSchema.Text, FDBInfo);
    try
      parser.ParseCommand(FPageControl.ActiveTab.SQLQuery);
      if parser.FromTables.Count > 0 then
      begin
        t := parser.FromTables[0].Name;
      end;
    finally
      parser.Free;
    end;
  end;

  CopySelectedRowsAsSqlInsert(t);
end;

procedure TMainForm.actGridCopyRowsWithHeadersExecute(Sender: TObject);
begin
  CopySelectedRows(True);
end;

procedure TMainForm.actDataImporterExecute(Sender: TObject);
var
  lst: TStringList;
begin
  with DataImporterDialog do
  begin
    cmbTablename.Clear;
    lst := TAsDbUtils.GetTablenames(FDBInfo);
    try
      cmbTablename.Items.AddStrings(lst);

      if trvTables.Selected <> nil then
        if trvTables.Selected.Level = 0 then
          cmbTablename.ItemIndex := lst.IndexOf(trvTables.Selected.Text);

      if ShowModal = mrOk then
      begin
        if cmbTablename.ItemIndex > -1 then
        begin
          DoDisconnect;
          DataImporterForm.ShowModal(FDbInfo,
            cmbSchema.Text, cmbTablename.Items[cmbTablename.ItemIndex]);
          DoSelectiveConnect;
        end
        else
          ShowMessage('You have to select table where to import to');
      end;

    finally
      lst.Free;
    end;
  end;
end;

procedure TMainForm.actChmHelpExecute(Sender: TObject);
begin
  OpenDocument(ChangeFileExt(Application.ExeName, '.chm'));
end;

procedure TMainForm.actNewTabExecute(Sender: TObject);
begin
  if FDBInfo.Connected then
  begin
    FPageControl.AddTab;
    UpdateGUI(True);
  end;
end;

procedure TMainForm.actExportJSONExecute(Sender: TObject);
begin
  DoExport(JSonExport,'.json');
end;

procedure TMainForm.actExportRTFExecute(Sender: TObject);
begin
  DoExport(RTFExporter,'.rtf');
end;

procedure TMainForm.actNewTableExecute(Sender: TObject);
begin
  DoDisconnect;
  DesignTableForm.Showmodal(FDBInfo, cmbSchema.Text, '');
  DoSelectiveConnect;
  FillTables;
end;

procedure TMainForm.actSaveAsExecute(Sender: TObject);
begin
  if SaveDialog.Execute then
  begin
    FPageControl.ActiveTab.QueryEditor.Lines.SaveToFile(SaveDialog.FileName);
    actSaveAs.Enabled := False;
  end;
end;

procedure TMainForm.actScriptExecutiveExecute(Sender: TObject);
begin
  try
    if not Assigned(FrmScriptExecutive) then
      FrmScriptExecutive := TFrmScriptExecutive.Create(Application);
    FrmScriptExecutive.ShowModal;
  finally
    FreeAndNil(FrmScriptExecutive);
  end;
end;

procedure TMainForm.actSelectAllRowsExecute(Sender: TObject);
var
  RecPos: longint;
begin
  with FPageControl.ActiveTab.DataGrid.DataSource.DataSet do
  begin
    DisableControls;
    RecPos := RecNo;
    First;
    while not EOF do
    begin
      FPageControl.ActiveTab.DataGrid.SelectedRows.CurrentRowSelected := True;
      Next;
    end;
    RecNo := RecPos;
    EnableControls;
  end;
end;

procedure TMainForm.actShowStoredProcedureTextExecute(Sender: TObject);
begin
  if trvProcedures.Selected <> nil then
  begin
    actNewTab.Execute;
    FPageControl.ActiveTab.QueryEditor.Text :=
      GetProcedureText(trvProcedures.Selected.Text);
  end;
end;

procedure TMainForm.ApplicationPropertiesException(Sender: TObject; E: Exception);
begin
  try
    SaveSession;
  except
  end;
  MessageDlg('Error', E.Message, mtError, [mbOK], 0);
end;

procedure TMainForm.ApplicationPropertiesIdle(Sender: TObject; var Done: boolean);
begin

  if Assigned(FDBInfo) then
  begin
    mitGenerateSP.Visible := FDBInfo.DbType <> dtFirebirdd;
    actDropDatabase.Enabled := FDBInfo.DbType in [dtMsSql, dtMySql, dtOracle];
  end;

  if FPageControl.PageCount > 0 then
  begin
    actExecute.Enabled := Trim(FPageControl.ActiveTab.QueryEditor.Text) <> EmptyStr;
    actCheckSyntax.Enabled := actExecute.Enabled;
    actFormatQuery.Enabled := actExecute.Enabled;
    actGridCopy.Enabled := (FPageControl.ActiveTab.HasActiveData);
    actPrint.Enabled := (FPageControl.ActiveTab.HasActiveData);

    actGridCopyRow.Enabled := actGridCopy.Enabled;
    actGridCopyAll.Enabled := actGridCopy.Enabled;

    actCheckSyntax.Enabled := actExecute.Enabled;
    actQueryDesigner.Enabled := FDBInfo.Connected;
    actDatabaseCloner.Enabled := FDBInfo.Connected;
    actDataImporter.Enabled := FDBInfo.Connected;
    actOpen.Enabled := FDBInfo.Connected;
    actFind.Enabled := FDBInfo.Connected;
    actFindReplace.Enabled := FDBInfo.Connected;

  end
  else
  begin
    actExecute.Enabled := False;
    actFormatQuery.Enabled := False;
    actCheckSyntax.Enabled := False;
    actGridCopy.Enabled := False;
    actGridCopyRow.Enabled := False;
    actGridCopyAll.Enabled := False;
    actCheckSyntax.Enabled := False;
    actQueryDesigner.Enabled := False;
    actDatabaseCloner.Enabled := False;
    actDataImporter.Enabled := False;
  end;
end;

procedure TMainForm.Button1Click(Sender: TObject);
begin
  ShowMessage(TAsStringUtils.GetSafeName('asasd12312a-a&*@&^#*&!@#^( -- ]]'));
end;

procedure TMainForm.cmbSchemaChange(Sender: TObject);
begin
  FDBInfo.Schema := cmbSchema.Text;
  FillTables;
  FillProcedures;
end;

procedure TMainForm.EditSelectAll1Execute(Sender: TObject);
begin
  FPageControl.ActiveTab.QueryEditor.SelectAll;
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin

  if ssCtrl in Shift then
    if Key = VK_F then
      if actFind.Enabled then
        FindDialog1.Execute;


  if (Key = VK_F3) and (Trim(FindDialog1.FindText) <> '') then
    if actFind.Enabled then
      FindText(FindDialog1.FindText);

end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  Caption := 'LazSqlX ' + AppVersion + ' (Beta)';
  pgcLeft.ActivePageIndex := 0;
  CriaSubMenusProjetos;
  CriaSubMenusProjetosCreateORMALLTables;
end;

procedure TMainForm.GridPrinterGetValue(const ParName: string; var ParValue: variant);
begin
  if ParName = 'title' then
    ParValue := GridPrinter.Caption;
end;

procedure TMainForm.MenuItem4Click(Sender: TObject);
begin
  try
    if not Assigned(FrmCfgCRUD) then
      FrmCfgCRUD := TFrmCFGCrud.Create(Application);
    FrmCfgCRUD.ShowModal;
    CriaSubMenusProjetos;
  finally
    FreeAndNil(FrmCfgCRUD);
  end;
end;

procedure TMainForm.MnCreateORMAllTablesClick(Sender: TObject);
var
  dbC: TAsDatabaseCloner;
  ti: TAsTableInfos;
  t: TAsTableInfo;
  I: Integer;
  Item:String;
begin
  CrudInfo.LoadFromFile(GetCurrentDir + PathDelim + 'CRUD' + PathDelim + TMenuItem(Sender).Caption + PathDelim +'CRUD.ini');
  try
    ProgressForm.Show;
    ProgressForm.Reset;
    ProgressForm.Message     := 'Create Code ORM';
    ProgressForm.MaxProgress := trvTables.Items.Count;
    For I:= 0 to trvTables.Items.Count -1 do
    begin
      Application.ProcessMessages;
      dbc := TAsDatabaseCloner.Create(FDBInfo, FDBInfo.Database);
      ti := TAsTableInfos.Create(nil, FDBInfo);
      Item := trvTables.Items[I].Text;
      if Trim(Item) <> '' then
      begin
        ProgressForm.Message         := 'Create Code ORM - ' + Item;
        ProgressForm.CurrentProgress := ProgressForm.CurrentProgress + 1;
        Application.ProcessMessages;

        t := ti.LoadTable(cmbSchema.Text, Item, False);
        try
          if not Assigned(FrmModel) then
            FrmModel := TFrmModel.Create(Application);
          FrmModel.TablesInfos := ti;
          FrmModel.InfoTable  := t;
          FrmModel.InfoCrud   := Self.CrudInfo;
          FrmModel.SchemaText := CmbSchema.text;
          FrmModel.CreateCodeORM;
          FrmModel.ToolButton2.Click;
        finally
          FreeAndNil(FrmModel);
//          FreeAndNil(T);
//          FreeAndNil(ti);
//          FreeAndNil(dbc);
        end;
        Application.ProcessMessages;
        Sleep(100);
        Application.ProcessMessages;
      end;
    end;
  finally
    ProgressForm.Close;
  end;
end;

procedure TMainForm.MenuItem7Click(Sender: TObject);
var
  infos: TAsTableInfos;
  I: integer;
  lstErrors: TStringList;
  lst: TStringList;
  s: TAsSqlGenerator;
  StrMetaData: TStringList;
  tab: TLazSqlXTabSheet;
  aux: string;
begin
  try
    lstErrors := TStringList.Create;
    s := TAsSqlGenerator.Create(DbInfo);
    StrMetaData := TStringList.Create;
    StrMetaData.Clear;
    try
      ProgressForm.Show;
      Application.ProcessMessages;

      lst := TAsDbUtils.GetTablenames(FDBInfo);
      lst.Sort;

      infos := TAsTableInfos.Create(nil, FDBInfo);

      ProgressForm.MaxProgress := lst.Count;

      for I := 0 to lst.Count - 1 do
      begin

        try
          //skip sequential tables for ORA
          if FDBInfo.DbType = dtOracle then
            if AnsiContainsStr(lst[I], '_SEQ') then
              Continue;

          infos.AddTable(cmbSchema.Items[cmbSchema.ItemIndex], lst[I]);
        except
          on e: Exception do
          begin
            lstErrors.Add(lst[I]);
          end;
        end;

        ProgressForm.Message :=
          'Extracting Table Informations [' + lst[I] + '] ... ';
        ProgressForm.StepProgress;
        Application.ProcessMessages;
      end;
    finally
      ProgressForm.Close;
    end;

    if lstErrors.Count > 0 then
    begin
      MessageDlg('Warning', 'The following tables could not be added' +
        #13#10 + lstErrors.Text, mtWarning, [mbOK], 0);
    end;

    //create tables
    try
      ProgressForm.Show;
      ProgressForm.MaxProgress := infos.Count;
      ProgressForm.Reset;
      for I := 0 to infos.Count - 1 do
      begin
        aux := Trim(S.GetCreateScript(DbInfo, infos[I], csTable).Text);
        if Trim(Aux) <> '' then
          StrMetaData.Add(Trim(Aux));
        ProgressForm.Message :=
          'Generator Metadata Create Table [' + lst[I] + '] ... ';
        ProgressForm.StepProgress;
        Application.ProcessMessages;
      end;
    finally
      ProgressForm.Close;
    end;
    //create tables Primary Keys
    try
      ProgressForm.Reset;
      ProgressForm.Show;
      for I := 0 to infos.Count - 1 do
      begin
        aux := Trim(S.GetCreateScript(DbInfo, infos[I], csPrimaryKey).Text);
        if Trim(Aux) <> '' then
          StrMetaData.Add(Trim(Aux));
        ProgressForm.Message :=
          'Generator Metadata Tables Primary Key [' + lst[I] + '] ... ';
        ProgressForm.StepProgress;
        Application.ProcessMessages;
      end;
    finally
      ProgressForm.Close;
    end;
    //create tables Foreing Keys
    try
      ProgressForm.Reset;
      ProgressForm.Show;
      for I := 0 to infos.Count - 1 do
      begin
        aux := Trim(S.GetCreateScript(DbInfo, infos[I], csForeingKey).Text);
        if Trim(Aux) <> '' then
          StrMetaData.Add(Trim(Aux));
        ProgressForm.Message :=
          'Generator Metadata Tables Foreing Key [' + lst[I] + '] ... ';
        ProgressForm.StepProgress;
        Application.ProcessMessages;
      end;
    finally
      ProgressForm.Close;
    end;

    tab := FPageControl.AddTab;
    tab.QueryEditor.Lines.Add('');
    tab.QueryEditor.Lines.Text := StrMetaData.Text;
    FPageControl.ScanNeeded;
  finally
    lstErrors.Free;
    infos.Free;
    lst.Free;
  end;
end;

procedure TMainForm.mitOpenDataClick(Sender: TObject);
begin
  if trvTables.Selected <> nil then;
  if trvTables.Selected.Level = 0 then
    ExecuteQuery(True);
end;

procedure TMainForm.mitRefreshTablesClick(Sender: TObject);
begin
  FillTables;
end;

procedure TMainForm.MnItemProjClick(Sender: TObject);
var
  dbC: TAsDatabaseCloner;
  ti: TAsTableInfos;
  t: TAsTableInfo;
begin
  CrudInfo.LoadFromFile(GetCurrentDir + PathDelim + 'CRUD' + PathDelim + TMenuItem(Sender).Caption + PathDelim +'CRUD.ini');
  if trvTables.Selected = nil then
    Exit;

  if trvTables.Selected.Level > 0 then
    Exit;

  dbc := TAsDatabaseCloner.Create(FDBInfo, FDBInfo.Database);
  ti := TAsTableInfos.Create(nil, FDBInfo);
  t := ti.Add(cmbSchema.Text, trvTables.Selected.Text);
  try
    if not Assigned(FrmModel) then
      FrmModel := TFrmModel.Create(Application);
    FrmModel.Projeto:= TMenuItem(Sender).Caption;
    FrmModel.SchemaText := cmbSchema.Text;
    FrmModel.TablesInfos := ti;
    FrmModel.InfoTable := t;
    FrmModel.InfoCrud := Self.CrudInfo;
    FrmModel.ShowModal;
  finally
    dbc.Free;
    ti.Free;
    FreeAndNil(FrmModel);
  end;
end;

procedure TMainForm.OnCaretPosition(Line, Pos: integer);
begin
  sbMain.Panels[2].Text := 'Row: ' + IntToStr(Pos) + ' Col: ' + IntToStr(Line);
end;

procedure TMainForm.OnDynamicEditKeyDown(Sender: TObject; var Key: word;
  Shift: TShiftState);
begin
  if (Key = VK_TAB) then
    if not (ssShift in Shift) then
      (Sender as TWinControl).PerformTab(True);
end;

procedure TMainForm.OnExecutionStopped(Sender: TObject);
begin
  if (Sender is TLazSqlXTabSheet) then
    if (Sender as TLazSqlXTabSheet) = FPageControl.ActiveTab then
    begin
      actExecute.ImageIndex := 22;
      actExecute.Hint := 'Execute Query';
      FLoadingIndicator.StopAnimation;
    end;
end;

procedure TMainForm.OnPageControlChange(Sender: TObject);
begin
  if FPageControl.ActiveTab.ExecutionInProgress then
  begin
    actExecute.Hint := 'Stop current execution';
    actExecute.ImageIndex := 61;
    FLoadingIndicator.StartAnimation;
  end
  else
  begin
    actExecute.Hint := 'Execute Query';
    actExecute.ImageIndex := 22;
    FLoadingIndicator.StopAnimation;
  end;
  sbMain.Panels[3].Text := FPageControl.ActiveTab.Message;
  sbMain.Panels[2].Text := '';
  FPageControl.ScanNeeded;
end;

procedure TMainForm.CriaSubMenusProjetos;
Var
  MnI: TMenuItem;
  Act: TAction;
  Projetos: TStringList;
  I: Integer;
begin
//  MmCRUD_Delphi.Clear;
  Projetos := TStringList.Create;
  try
    Projetos.LoadFromFile(GetCurrentDir + PathDelim + 'CRUD' + PathDelim + 'Projetos.Txt');
    For I:= 0  to Projetos.Count -1 do
    begin
      if MmCRUD_Delphi.IndexOfCaption(Projetos[I]) = -1 then
      begin
        MnI         := TMenuItem.Create(MmCRUD_Delphi);
        MnI.OnClick := MnItemProj.OnClick;
        MnI.Caption := Projetos[I];
        MmCRUD_Delphi.Add(MnI);
      end;
    end;
  finally
    FreeAndNil(Projetos);
  end;
end;

procedure TMainForm.CriaSubMenusProjetosCreateORMALLTables;
Var
  MnI: TMenuItem;
  Act: TAction;
  Projetos: TStringList;
  I: Integer;
begin
//  MmCRUD_Delphi.Clear;
  Projetos := TStringList.Create;
  try
    Projetos.LoadFromFile(GetCurrentDir + PathDelim + 'CRUD' + PathDelim + 'Projetos.Txt');
    For I:= 0  to Projetos.Count -1 do
    begin
      if MnCreateORMAllTables.IndexOfCaption(Projetos[I]) = -1 then
      begin
        MnI         := TMenuItem.Create(MnCreateORMAllTables);
        MnI.OnClick := MnCreateORMAllTables.OnClick;
        MnI.Caption := Projetos[I];
        MnCreateORMAllTables.Add(MnI);
      end;
    end;
  finally
    FreeAndNil(Projetos);
  end;
end;



end.
