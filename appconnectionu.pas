unit appConnectionU;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, IBConnection;

type
  TConnectionType = TIBConnection;
  TConnectCallback = function(s, d, u, p: string; var msg: string): Boolean of object;
  { TAppConnection }

  TAppConnection = class(TComponent)

  private
    FConnection: TConnectionType;
    FTransaction: TSQLTransaction;
    function GetConnected: Boolean;
    function Connect_Internal( servername, databasename: string; var msg: string): Boolean;
  public
    property Transaction: TSQLTransaction read FTransaction write FTransaction;
    property Connection: TConnectionType read FConnection write FConnection;
    property Connected: Boolean read GetConnected;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Connect(const servername: string = ''; databasename: string = ''): Boolean; overload;
    function Connect(const servername: string; databasename: string; var msg: string): Boolean; overload;
    function ConnectDialog(const servername: string = ''; databasename: string = ''): Boolean;
    function ConnectFiles( configFile: string; var msg: string ): Boolean;
    function connect_(s, d, u, p: string; var msg: string): Boolean;
  end;
    
var
  AppConnection : TAppConnection;

const
  BRK = '/BRK/';

implementation

uses
  Dialogs, Forms, Controls, myUtils, changedatabaseform, IniFiles;


{ TAppConnection }

function TAppConnection.GetConnected: Boolean;
begin
  Result := FConnection.Connected;
end;

function TAppConnection.Connect_Internal(servername, databasename: string;
  var msg: string): Boolean;

var
  dataDir : string;
  configfile : string;
  ini: TIniFile;

begin
  Result := False;

  //pwd := 'masterkey';
  //pwd := MD5Print(MD5String(pwd));
  dataDir := AppDataDirectory;
  // TODO: check for empty AppDataDirectory

  configfile:= ChangeFileExt(dataDir + AppConfigFilename, '.fcr');

  if FileExists(configfile) then
    //connect using saved credentials
    Result := ConnectFiles(configfile, msg);

  if not Result then
  //connect using change database form
  begin
    Result := ConnectDialog(servername, databasename);

    if Result then
    begin
      ini := TIniFile.Create(configfile);
      with ini do
      try
        WriteString('db','s',FConnection.HostName);
        WriteString('db','d',FConnection.DatabaseName);
        WriteString('db','u',BRK+EncryptString(FConnection.UserName)+BRK);
        WriteString('db','p',BRK+EncryptString(FConnection.Password)+BRK);
      finally
        ini.Free;
      end;
    end;
  end;
end;

constructor TAppConnection.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTransaction:= TSQLTransaction.Create(AOwner);
  FConnection := TIBConnection.Create(AOwner);
  FConnection.Transaction := FTransaction;
  Connect();

  AppConnection := Self;
end;

destructor TAppConnection.Destroy;
begin
  FTransaction.Free;
  FConnection.Free;
  inherited Destroy;
end;

function TAppConnection.Connect(const servername: string; databasename: string
  ): Boolean; overload;
var
  msg: string;
begin
  msg := '';
  Result := Connect_Internal(servername, databasename, msg);
end;

function TAppConnection.Connect(const servername: string; databasename: string;
  var msg: string): Boolean; overload;
begin
  Result := Connect_Internal(servername, databasename, msg);
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
      if (ConnectCallback <> nil) and FConnection.Connected then
        Result := True
  finally
    free;
  end;
end;

function TAppConnection.ConnectFiles(configFile: string; var msg: string
  ): Boolean;
var
  ini : TIniFile;
  s, d, u, p: string;
begin
  Result := False;
  ini := TIniFile.Create(configFile);
  with ini do
  try
    s:= ReadString('db','s','');
    d:= ReadString('db','d','');
    u:= ReadString('db','u','');
    p:= ReadString('db','p','');
    u:= DecryptString(StringReplace(u,BRK,'',[rfReplaceAll]));
    p:= DecryptString(StringReplace(p,brk,'',[rfReplaceAll]));
    Result := connect_(s, d, u, p, msg);
  finally
    ini.Free;
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
    FConnection.Close;
    FConnection.Open;
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

//initialization
//  AppConnection := TAppConnection.Create(nil);
//
//finalization
//  AppConnection.Free;
//
end.

