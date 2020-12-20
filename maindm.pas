unit mainDM;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, appConnectionU, appUserUnit, IBConnection, SQLDB;

type

  { TdmMain }

  TdmMain = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
  private
    FConnection: TAppConnection;
    FisConnected: boolean;
  public
    property TAppConnection: TAppConnection read FConnection;
    property isConnected: boolean read FisConnected;
    procedure SetDatabase;
    procedure test_user_table;
  end;

var
  dmMain: TdmMain;

implementation

uses DB;


{$R *.lfm}

{ TdmMain }

procedure TdmMain.DataModuleCreate(Sender: TObject);
begin
  writeln('Project Options.../ Compiler Options/ Config and Target/ Win32...');
  writeln('Debug / Development only; disable in Production.');
  writeln;
  FConnection:= AppConnection;
  FisConnected := AppConnection.Connect();
  test_user_table;
end;

procedure TdmMain.SetDatabase;
begin
  AppConnection.ConnectDialog(AppConnection.Connection.HostName,
    AppConnection.Connection.DatabaseName);
  FisConnected:= AppConnection.Connection.Connected;
end;

procedure TdmMain.test_user_table;
var
  query: TSQLQuery;
  f: TField;
begin
  query := TSQLQuery.Create(self);
  with query do
  try
    DataBase := AppConnection.Connection;
    SQL.add('select * from rdb$relations where rdb$flags=1');
    Open;
    while not EOF do begin
      writeln(FieldByName('rdb$relation_name').AsString);
      Next;
    end;
  finally
    free;
  end;

end;

end.

