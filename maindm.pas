unit mainDM;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type

  { TdmMain }

  TdmMain = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
  private
    FisConnected: boolean;
  public
    property isConnected: boolean read FisConnected;
    procedure SetDatabase;
  end;

var
  dmMain: TdmMain;

implementation

uses
  appConnectionU;

{$R *.lfm}

{ TdmMain }

procedure TdmMain.DataModuleCreate(Sender: TObject);
begin
  writeln('Project Options.../ Compiler Options/ Config and Target/ Win32...');
  writeln('Debug / Development only; disable in Production.');
  writeln;
  FisConnected := AppConnection.Connect();
end;

procedure TdmMain.SetDatabase;
begin
  AppConnection.ConnectDialog(AppConnection.Connection.HostName,
    AppConnection.Connection.DatabaseName);
  FisConnected:= AppConnection.Connection.Connected;
end;

end.

