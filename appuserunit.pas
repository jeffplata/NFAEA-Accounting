unit appUserUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type

  TConnectCallback = function(u, p: string; var msg: string): Boolean of object;

  { TAppUser }

  TAppUser = class(TObject)

  private
    configfile: string;
    FLoggedin: Boolean;
    FPass: string;
    FRememberme: string;
    FTableReady: Boolean;
    FUsername: string;
    function CheckUserTable: Boolean;
    function SetupTables(var msg: string): Boolean; 
    function Login_Internal: Boolean;  
    function login_(u, p: string; var msg: string): Boolean;
  public
    constructor Create;
    property Username: string read FUsername write FUsername;
    property Pass: string read FPass write FPass;
    property Rememberme: string read FRememberme write FRememberme;
    property Loggedin: Boolean read FLoggedin write FLoggedin;
    property TableReady: Boolean read FTableReady write FTableReady;
    function Login: Boolean;
    function LoginDialog: Boolean;
    function LoginFiles(var msg: string): Boolean;
    function AddUser( AUser, APass: string ): Boolean;
  end;

var
  AppUser: TAppUser;

implementation

uses SQLDB, appConnectionU, UserLoginForm, myUtils, md5, IniFiles, Forms,
  Controls, Dialogs;


{ TAppUser }

function TAppUser.CheckUserTable: Boolean;
var
  query: TSQLQuery;
begin
  Result := False;
  query:= TSQLQuery.Create(nil);
  with query do
  try
    DataBase := AppConnection.Connection;
    SQL.add('select * from rdb$relations where rdb$flags=1');
    SQL.add(' and rdb$relation_name=''USERS''');
    Open;
    Result := not Eof;
  finally
    free;
  end;
end;

function TAppUser.SetupTables( var msg: string ): Boolean;
var
  s : string;
  msglocal : string;

const
  BRK = #13#10;

  procedure CreateTable( var msg: string );
  begin
    with TSQLQuery.Create(nil) do
    begin
      DataBase := AppConnection.Connection;
      SQL.Text:= s;
      try
        ExecSQL;
        Result := True;
        AppConnection.Transaction.CommitRetaining;
      except
        on e: Exception do
          begin
            msg := e.Message;
            AppConnection.Transaction.RollbackRetaining;
          end;
      end;
    end;
  end;

begin
  Result := false;
  msg := '';
  msglocal :='';
  s := ' CREATE TABLE USERS'       +
       ' ('                        +
       '   ID Integer NOT NULL,'   +
       '   USER_NAME Varchar(80),' +
       '   PASS Varchar(255),'     +
       '   CONSTRAINT PK_USERS PRIMARY KEY (ID)' +
       ' );';

  CreateTable(msglocal);
  if msglocal = '' then
    msglocal := 'USERS table successfully created.';
  msg := msglocal;

  s := ' CREATE TABLE ROLES'       +
       ' ('                        +
       '   ID Integer NOT NULL,'   +
       '   ROLE_NAME Varchar(80),' +
       '   LABEL Varchar(80),'     +
       '   CONSTRAINT PK_ROLE PRIMARY KEY (ID)' +
       ' );';

  msglocal:= '';
  CreateTable(msglocal);
  if msglocal = '' then
    msglocal := 'ROLES table successfully created.';
  msg := msg + BRK + msglocal;

  writeln(msg);
  AddUser('admin','Password1');
end;

constructor TAppUser.Create;
var
  msg : string;
  datadir: string;
begin
  inherited Create;

  dataDir := AppDataDirectory;
  configfile:= ChangeFileExt(dataDir + AppConfigFilename, '.fcr');

  msg := '';
  FTableReady := CheckUserTable;
  if not FTableReady then
    SetupTables(msg);
end;

function TAppUser.Login: Boolean;
begin
  Result := Login_Internal;
end;

function TAppUser.LoginDialog: Boolean;
var
  msg: string;
  ini: tinifile;

begin
  Result := false;
  msg := '';
  Application.CreateForm(TfrmUserLogin, frmUserLogin);
  with frmUserLogin do
  try
    LoginCallback:= @login_;
    if ShowModal = mrOk then
      if (LoginCallback <> nil) then
        Result := AppUser.Loggedin
      else
        Result := login_(edtUsername.Text,edtPassword.Text,msg);
  finally
    Free;
  end;

  if Result then
  begin
    ini := TIniFile.Create(configfile);
    with ini do
    try
      if (FRememberme='1') then
      begin
        WriteString('user','u',BRK+EncryptString(AppUser.UserName)+BRK);
        WriteString('user','p',BRK+EncryptString(AppUser.Pass)+BRK);
      end else
        EraseSection('user');
    finally
      ini.Free;
    end;
  end;
end;

function TAppUser.Login_Internal: Boolean;
var
  msg: string;
begin
  Result := False;
  msg := '';

  if FileExists(configfile) then
    //connect using saved credentials
    Result := LoginFiles(msg);

  if not Result then
    //connect using login form
    Result := LoginDialog();

end;

function TAppUser.LoginFiles(var msg: string): Boolean;
var
  ini : TIniFile;
  u, p: string;
begin
  Result := False;
  ini := TIniFile.Create(configFile);
  with ini do
  try
    u:= ReadString('user','u','');
    p:= ReadString('user','p','');  
    if (u <> '') and (p <> '') then
    begin
      u:= DecryptString(StringReplace(u,BRK,'',[rfReplaceAll]));
      p:= DecryptString(StringReplace(p,BRK,'',[rfReplaceAll]));
      Result := login_(u, p, msg);
    end;
  finally
    ini.Free;
  end;

end;

function TAppUser.AddUser(AUser, APass: string): Boolean;
begin
  Result := false;
  with TSQLQuery.Create(nil) do
  try
    DataBase := AppConnection.Connection;
    sql.add('insert into USERS(user_name, pass) values(:u, :p);');
    ParamByName('u').Asstring := AUser;
    ParamByName('p').Asstring := MD5Print(MD5String(APass));
    try
      ExecSQL;
      Result := (RowsAffected >0);
      AppConnection.Transaction.CommitRetaining;
    except
      on e: exception do
      begin
        AppConnection.Transaction.RollbackRetaining;
        MessageDlg('Info', e.Message, mtConfirmation, [mbOk], 0);
      end;
    end;
  finally
    Free;
  end;
end;

function TAppUser.login_(u, p: string; var msg: string): Boolean;
var
  q: TSQLQuery;
begin
  Result := false;
  msg := '';
  try
    //try to login
    q := TSQLQuery.Create(nil);
    with q do
    try
      Database := AppConnection.Connection;
      sql.Add('select user_name, pass from users');
      sql.add(' where (user_name=:u) and (pass=:p)');
      ParamByName('u').AsString:= QuotedStr(u);
      ParamByName('p').AsString:= QuotedStr(MD5Print(MD5String(p)));
      Prepare;
      Open;
      if eof then
        msg := 'Username or password is not valid.'
      else begin
        FUsername:= u;
        FPass:= p;
        Result := true;
      end;
    finally
      Free;
    end;
  except
    on e:exception do
    begin
      msg := e.Message;
    end;
  end;
end;

initialization
  AppUser := TAppUser.Create;

finalization
  AppUser.Free;

end.

