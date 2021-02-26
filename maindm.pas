unit mainDM;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, hilogeneratorU, appConnectionU, appUserU, UserManagerU,
  IBConnection, SQLDB;

type

  { TdmMain }

  TdmMain = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    FConnection: TAppConnection;
    FHiLoGenerator: THiloGenerator;
    FUser: TAppUser;
    FUserManager: TUserManager;
    function GetisConnected: boolean;
  public
    property Connection: TAppConnection read FConnection;
    property isConnected: boolean read GetisConnected;
    property User: TAppUser read FUser write FUser;
    property HiLoGenerator: THiloGenerator read FHiLoGenerator write FHiLoGenerator;
    property UserManager: TUserManager read FUserManager write FUserManager;
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
  FUserManager:= TUserManager.Create(self);
  FUser := TAppUser.Create;
  if GetisConnected then
    FUser.Login();
end;

procedure TdmMain.DataModuleDestroy(Sender: TObject);
begin
  FHiLoGenerator.Free;
  FUser.Free;
  FUserManager.Free;
  FConnection.Free;
end;

function TdmMain.GetisConnected: boolean;
begin
  result := FConnection.Connected;
end;

procedure TdmMain.SetDatabase;
begin
  if FConnection.ConnectDialog(FConnection.Connection.HostName,
    FConnection.Connection.DatabaseName) then
  begin
    FUser.Logout;
    FUser.Login;
  end;
end;



end.

