unit mainDM;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, hilogeneratorU, appConnectionU, appUserUnit, IBConnection,
  SQLDB;

type

  { TdmMain }

  TdmMain = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    FConnection: TAppConnection;
    FHiLoGenerator: THiloGenerator;
    FisConnected: boolean;
    FUser: TAppUser;
  public
    property Connection: TAppConnection read FConnection;
    property isConnected: boolean read FisConnected;
    property User: TAppUser read FUser write FUser;
    property HiLoGenerator: THiloGenerator read FHiLoGenerator write FHiLoGenerator;
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
  writeln('Don''t forget to turn off heaptrc in project options on production.');
  writeln;
  FConnection:= TAppConnection.Create(self);
  FHiLoGenerator:= THiloGenerator.Create;
  FUser := TAppUser.Create;
  FisConnected := FConnection.Connected;
  if FisConnected then
    FUser.Login();
end;

procedure TdmMain.DataModuleDestroy(Sender: TObject);
begin
  FHiLoGenerator.Free;
  FUser.Free;
  FConnection.Free;
end;

procedure TdmMain.SetDatabase;
begin
  FConnection.ConnectDialog(FConnection.Connection.HostName,
    FConnection.Connection.DatabaseName);
  FisConnected:= FConnection.Connection.Connected;
end;



end.

