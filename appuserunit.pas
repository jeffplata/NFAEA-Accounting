unit appUserUnit;

{$mode objfpc}{$H+}

interface

uses
  appConnectionU, Classes, SysUtils;

type

  TConnectCallback = function(u, p: string; var msg: string): Boolean of object;

  { TAppUser }

  TAppUser = class(TObject)

  private
    //FAppConnection: TAppConnection;
    FConfigfile: string;
    FLoggedin: Boolean;
    FPass: string;
    FRememberme: string;
    FTableReady: Boolean;
    FUsername: string;
    function CheckUserTable: Boolean;
    function SetupTables(var msg: string): Boolean; 
    function Login_Internal: Boolean;  
    function login_(u, p, r: string; var msg: string): Boolean;
  public
    constructor Create;
    //property AppConnection: TAppConnection read FAppConnection write FAppConnection;
    property Username: string read FUsername write FUsername;
    property Pass: string read FPass write FPass;
    property Rememberme: string read FRememberme write FRememberme;
    property Loggedin: Boolean read FLoggedin write FLoggedin;
    property TableReady: Boolean read FTableReady write FTableReady;
    function Login: Boolean;
    function LoginDialog: Boolean;
    function LoginFiles(var msg: string): Boolean;
    function Logout: Boolean;
    function AddUser( AUser, APass: string ): Boolean;
    function AddRole( ARole_name, ALabel: string ): Boolean; 
    function AddUserRoles( AUser, ARole: string ): Boolean;
  end;

//var
//  AppUser: TAppUser;

implementation

uses SQLDB, UserLoginForm, myUtils, hilogeneratorU, md5, IniFiles, Forms,
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

  procedure CreateTable( s: string; var msg: string );
  begin
    with TSQLQuery.Create(nil) do
    try
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
    finally
      Free;
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

  CreateTable(s, msglocal);
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
  CreateTable(s, msglocal);
  if msglocal = '' then
    msglocal := 'ROLES table successfully created.';  

  msg := msg + BRK + msglocal;

  s := ' CREATE TABLE USER_ROLES'       +
       ' ('                        +
       '   ID Integer NOT NULL,'   +  
       '   USER_NAME Varchar(80),' +
       '   ROLE_NAME Varchar(80),' +
       '   CONSTRAINT PK_USER_ROLES PRIMARY KEY (ID)' +
       ' );';
            
  msglocal:= '';
  CreateTable(s, msglocal);
  if msglocal = '' then
    msglocal := 'USER_ROLES table successfully created.';

  msg := msg + BRK + msglocal;

  writeln(msg);
  AddUser('admin','Password1');
  AddRole('admin','Admin');
  AddUserRoles('admin','admin');
end;

constructor TAppUser.Create;
var
  msg : string;
begin
  inherited Create;

  //AppConnection:= AAppConnection; 
  if AppConnection = nil then
    MessageDlg('AppUser: No database connection.',mtError,[mbOk],0);
  if HiLoGenerator = nil then
    MessageDlg('AppUser: Hi/lo generator not set.',mtError,[mbOk],0);
  FConfigfile:= ChangeFileExt(AppDataDirectory + AppConfigFilename, '.fcr');
  writeln('TAppUser: '+FConfigfile);

  msg := '';
  FTableReady := CheckUserTable;
  if not FTableReady then
    SetupTables(msg);

  //AppUser := self;
end;

function TAppUser.Login: Boolean;
begin
  Result := Login_Internal;
end;

function TAppUser.LoginDialog: Boolean;
var
  msg: string;
  r: Char;

begin
  Result := false;
  msg := '';
  Application.CreateForm(TfrmUserLogin, frmUserLogin);
  with frmUserLogin do
  try
    LoginCallback:= @login_;
    if ShowModal = mrOk then
      if (LoginCallback <> nil) then
        Result := Self.Loggedin
      else
        begin
          r := '0';
          if chkRememberme.Checked then
            r := '1';
          Result := login_(edtUsername.Text,edtPassword.Text,r,msg);
        end;

  finally
    Free;
  end;

  if Result then
  begin
    with TIniFile.Create(FConfigfile) do
    try
      if (FRememberme='1') then
      begin
        WriteString('user','u',BRK+EncryptString(Self.UserName)+BRK);
        WriteString('user','p',BRK+EncryptString(Self.Pass)+BRK);
      end else
        EraseSection('user');
    finally
      Free;
    end;
  end;
end;

function TAppUser.Login_Internal: Boolean;
var
  msg: string;
begin
  Result := False;
  msg := '';

  if FileExists(FConfigfile) then
    //connect using saved credentials
    Result := LoginFiles(msg);

  if not Result then
    //connect using login form
    Result := LoginDialog();

end;

function TAppUser.LoginFiles(var msg: string): Boolean;
var
  u, p: string;
begin
  Result := False;
  with TIniFile.Create(FConfigfile) do
  try
    u:= ReadString('user','u','');
    p:= ReadString('user','p','');  
    if (u <> '') and (p <> '') then
    begin
      u:= DecryptString(StringReplace(u,BRK,'',[rfReplaceAll]));
      p:= DecryptString(StringReplace(p,BRK,'',[rfReplaceAll]));
      Result := login_(u, p, '0', msg);
    end;
  finally
    Free;
  end;

end;

function TAppUser.Logout: Boolean;
begin
  FLoggedin:= False;
  FUsername:= '';
  FPass:= '';
  FRememberme:= '0';
  Result := True;
  with TIniFile.Create(FConfigfile) do
  try
    EraseSection('user');
  finally
    Free;
  end;
  //TODO: User Manager form
end;

function TAppUser.AddUser(AUser, APass: string): Boolean;
begin
  Result := false;
  with TSQLQuery.Create(nil) do
  try
    DataBase := AppConnection.Connection;
    sql.add('insert into USERS(id, user_name, pass) values(:id, :u, :p);');
    ParamByName('id').AsInteger:= HiLoGenerator.NextValue;
    ParamByName('u').Asstring := AUser;
    ParamByName('p').Asstring := MD5Print(MD5String(APass));
    try
      ExecSQL;
      Result := (RowsAffected >0);
      HiLoGenerator.SaveValues;
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

function TAppUser.AddRole(ARole_name, ALabel: string): Boolean;
begin
  Result := false;
  with TSQLQuery.Create(nil) do
  try
    DataBase := AppConnection.Connection;
    sql.add('insert into ROLES(id, role_name, label) values(:id, :n, :l);');
    ParamByName('id').AsInteger:= HiLoGenerator.NextValue;
    ParamByName('n').Asstring := ARole_name;
    ParamByName('l').Asstring := ALabel;
    try
      ExecSQL;
      Result := (RowsAffected >0);
      HiLoGenerator.SaveValues;
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

function TAppUser.AddUserRoles(AUser, ARole: string): Boolean;
begin
  Result := false;
  with TSQLQuery.Create(nil) do
  try
    DataBase := AppConnection.Connection;
    sql.add('insert into USER_ROLES(id, user_name, role_name) values(:id, :u, :r);');
    ParamByName('id').AsInteger:= HiLoGenerator.NextValue;
    ParamByName('u').Asstring := AUser;
    ParamByName('r').Asstring := ARole;
    try
      ExecSQL;
      Result := (RowsAffected >0);
      HiLoGenerator.SaveValues;
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

function TAppUser.login_(u, p, r: string; var msg: string): Boolean;
begin
  Result := False;
  FLoggedin:= False;
  FRememberme:= '0';
  msg := 'Username or password is not valid.';
  try
    //try to login
    with TSQLQuery.Create(nil) do
    try
      Database := AppConnection.Connection;
      sql.Add('select user_name, pass from users');
      sql.add(' where (user_name=:u) and (pass=:p)');
      ParamByName('u').AsString:= u;
      ParamByName('p').AsString:= MD5Print(MD5String(p));
      Prepare;
      Open;
      if not eof then
      begin
        FUsername:= u;
        FPass:= p;
        FLoggedin:= True;
        FRememberme:= r;
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

//initialization
//  AppUser := TAppUser.Create;
//
//finalization
//  AppUser.Free;

end.

