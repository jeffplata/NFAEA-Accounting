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
  Dialogs, myUtils, IniFiles, md5;


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
  dataDir, secretDir : string;
  configfile : string;
  ini: TIniFile;
  svr, db, usr, pwd: string;
  saveIni: Boolean;

begin
  Result := True;

  //pwd := 'masterkey';
  //pwd := MD5Print(MD5String(pwd));
  //writeln(pwd);
  dataDir := AppDataDirectory;
  // TODO: check for empty AppDataDirectory
  secretDir := GetAppConfigDir(false);

  configfile:= dataDir + AppConfigFilename;
  ini := TIniFile.Create(configfile);
  with ini do
  try
    saveIni:= not SectionExists('DB');
    svr:= ReadString('DB', 'server', 'localhost');
    db := ReadString('DB', 'database', '');
    usr:= ReadString('DB', 'username', 'sysdba');
    pwd:= ReadString('DB', 'pass', 'masterkey');
    if db = '' then
      db := 'c:\projects\NFAEA accounting\accounting.fdb';
    FConnection.HostName:= svr;
    FConnection.DatabaseName:= db;
    FConnection.UserName:= usr;
    FConnection.Password:= pwd;
    try
      FConnection.Connected:= True;
    except
      raise;
      Result := False;
    end;
  finally
    if saveIni then begin
      usr:= MD5Print(MD5String(usr));
      pwd:= MD5Print(MD5String(pwd));
      WriteString('DB', 'server', svr);
      WriteString('DB', 'database', db);
      WriteString('DB', 'username', usr);
      WriteString('DB', 'pass', pwd);
    end;
    Free;
  end;

end;

initialization
  AppConnection := TAppConnection.Create(nil);

finalization
  AppConnection.Free;

end.

