unit changeDatabaseUnit;

{$mode objfpc}{$H+}

interface

uses
  IBConnection, Classes, SQLDB;

type

  { TDatabaseChanger }

  TDatabaseChanger = class(TObject)

  private
    Fconnection: TIBConnection;
    Fdatabasename: string;
    Fservername: string;
    Ftransaction: TSQLTransaction;
  public
    function Connect(servername, databasename: string): boolean;
    property transaction: TSQLTransaction read Ftransaction write Ftransaction;
    property connection: TIBConnection read Fconnection write Fconnection;
    property databasename: string read Fdatabasename write Fdatabasename;
    property servername: string read Fservername write Fservername;
    constructor Create(AOwner: TComponent);
  end;
implementation
uses
  SysUtils;

{ TDatabaseChanger }


function TDatabaseChanger.Connect(servername, databasename: string): boolean;
begin
  Fconnection.HostName:= servername;
  Fconnection.DatabaseName:= databasename;
  Fconnection.Connected:= True;
end;

constructor TDatabaseChanger.Create(AOwner: TComponent);
begin
  Ftransaction := TSQLTransaction.Create(AOwner);
  Fconnection := TIBConnection.Create(AOwner);
  Fconnection.Transaction := Ftransaction;
end;


end.

