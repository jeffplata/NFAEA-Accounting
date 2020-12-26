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
  FisConnected := AppConnection.Connected;
  if FisConnected then
    AppUser.Login();
  //test_user_table;
end;

procedure TdmMain.SetDatabase;
begin
  AppConnection.ConnectDialog(AppConnection.Connection.HostName,
    AppConnection.Connection.DatabaseName);
  FisConnected:= AppConnection.Connection.Connected;
end;



end.

