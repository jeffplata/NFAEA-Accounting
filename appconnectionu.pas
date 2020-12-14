unit appConnectionU;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, IBConnection;

type
  TConnectCallback = function(s, d, u, p: string; var msg: string): Boolean of object;
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
    function ConnectDialog(const servername: string = ''; databasename: string = ''): Boolean;
    function connect_(s, d, u, p: string; var msg: string): Boolean;
  end;
    
var
  AppConnection : TAppConnection;

implementation

uses
  Dialogs, Forms, Controls, myUtils, changedatabaseform, IniFiles, md5;


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
  configfile : string;
  ini: TIniFile;
  svr, db, usr, pwd: string;
  saveIni: Boolean;

begin
  Result := False;

  //pwd := 'masterkey';
  //pwd := MD5Print(MD5String(pwd));
  dataDir := AppDataDirectory;
  // TODO: check for empty AppDataDirectory

  configfile:= ChangeFileExt(dataDir + AppConfigFilename, '.fcr');

  //if not FileExists(configfile) then
  if true then
  begin
    //show change database form
    ConnectDialog();
  end
  else
  begin

  end;


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
    //writeln(usr + ':' +pwd);
    try
      //FConnection.Connected:= True;
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

function TAppConnection.ConnectDialog(const servername: string;
  databasename: string): Boolean;
begin
  //show change database form
  Result := False;
  Application.CreateForm(TfrmChangeDatabase, frmChangeDatabase);
  with frmChangeDatabase do
  try
    ConnectCallback:= @connect_;
    edtServer.Text := servername;
    edtDatabase.Text := databasename;
    if ShowModal = mrOk then
      begin
        FConnection.HostName := edtServer.text;
        FConnection.DatabaseName  := edtDatabase.Text;
        FConnection.UserName := edtUser.Text;
        FConnection.Password := edtPass.Text;
        try
          FConnection.Connected:= True;
          Result := True;
        except
          Result := False;
          raise;
        end;
      end;
  finally
    free;
  end;
end;

function TAppConnection.connect_(s, d, u, p: string; var msg:string): Boolean;
begin   
  Result := False;
  FConnection.HostName:= s;
  FConnection.DatabaseName:= d;
  FConnection.UserName:= u;
  FConnection.Password:= p;
  try
    FConnection.Connected:= True;
    Result := True;
  except
      on e: Exception do
      begin
        if Pos('password', e.Message) > 0 then
          msg := 'Username or password is not valid.'
        else
          msg := e.Message;  
      end;
  end;
end;

initialization
  AppConnection := TAppConnection.Create(nil);

finalization
  AppConnection.Free;

end.

