unit appConnectionU;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, IBConnection;

type

  { TAppConnection }

  TAppConnection = class(TObject)

  private
    FConnection: TIBConnection;
    FTransaction: TSQLTransaction;
  public
    property Transaction: TSQLTransaction read FTransaction write FTransaction;
    property Connection: TIBConnection read FConnection write FConnection;
    constructor Create(AOwner: TComponent);
    function Connect(const servername: string = ''; databasename: string = ''): Boolean;
  end;
    
var
  AppConnection : TAppConnection;

implementation

uses
  Dialogs, myUtils;


{ TAppConnection }

constructor TAppConnection.Create(AOwner: TComponent);
begin
  FTransaction:= TSQLTransaction.Create(AOwner);
  FConnection := TIBConnection.Create(AOwner);
  FConnection.Transaction := FTransaction;
end;

function TAppConnection.Connect(const servername: string; databasename: string
  ): Boolean;
var
  dataDir : string;
begin
  dataDir := AppDataDirectory;
  // TODO: check for empty AppDataDirectory

  Result := True;
end;

initialization
  AppConnection := TAppConnection.Create(nil);

finalization
  AppConnection.Free;

end.

