unit appUserU;

{$mode objfpc}{$H+}

interface

uses
  appConnectionU, Classes, SysUtils;

type

  TConnectCallback = function(u, p: string; var msg: string): Boolean of object;  

  { TAppUser }

  TAppUser = class(TObject)

  private
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
    function changepass_(u, p: string; var msg: string): Boolean;
  public
    constructor Create;
    // always set username, password, rememberme and loggedin
    //   after a successful login, especially on callbacks
    property Username: string read FUsername write FUsername;
    property Pass: string read FPass write FPass;
    property Rememberme: string read FRememberme write FRememberme;
    property Loggedin: Boolean read FLoggedin write FLoggedin;

    property TableReady: Boolean read FTableReady write FTableReady;
    function Login: Boolean;
    function LoginDialog: Boolean;
    function LoginFiles(var msg: string): Boolean;
    function Logout(const eraseFromFile: Boolean=False): Boolean;
    function ChangePassDialog: Boolean;
    function AddUser( AUser, APass: string ): Boolean;
    function AddRole( ARole_name, ALabel: string ): Boolean; 
    function AddUserRoles( AUser, ARole: string ): Boolean;
  end;

//var
//  AppUser: TAppUser;

implementation

uses SQLDB, UserLoginForm, myUtils, hilogeneratorU, UserChangePassForm, md5,
  IniFiles, Forms, Controls, Dialogs;


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
       '   IS_SYSTEM Integer,'     +
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
       '   IS_SYSTEM Integer,'     +
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
       '   IS_SYSTEM Integer,'     +
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
  msg, p: string;
  r: Char;

begin
  Result := false;
  msg := '';
  Application.CreateForm(TfrmUserLogin, frmUserLogin);
  with frmUserLogin do
  try
    LoginCallback:= @login_;
    if ShowModal = mrOk then
    begin
      p := MD5Print(MD5String(edtPassword.Text));
      if (LoginCallback <> nil) then
        Result := Self.Loggedin
      else
      begin
        r := '0';
        if chkRememberme.Checked then
          r := '1';
        Result := login_(edtUsername.Text,p,r,msg);
      end;
    end
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
                     
  //connect using saved credentials
  if FileExists(FConfigfile) then
    Result := LoginFiles(msg);
                              
  //connect using login form
  if not Result then
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

function TAppUser.Logout( const eraseFromFile: Boolean = False ): Boolean;
begin
  FLoggedin:= False;
  FUsername:= '';
  FPass:= '';
  FRememberme:= '0';
  Result := True;
  if eraseFromFile then
    with TIniFile.Create(FConfigfile) do
    try
      EraseSection('user');
    finally
      Free;
    end;
end;

function TAppUser.ChangePassDialog: Boolean;
var
  msg: string;
begin
  Result := True;
  msg := '';
  Application.CreateForm(TfrmUserChangePass, frmUserChangePass);
  with frmUserChangePass do
  try
    ChangePassCallback:= @changepass_;
    User:= FUsername;
    CurrentPass := FPass;
    if ShowModal = mrOk then
      if (ChangePassCallback = nil) then
        Result := changepass_(FUsername,edtNewPass.Text,msg);

  finally
    Free;
  end;

  if Result then
  begin
    if (FRememberme='1') then
      with TIniFile.Create(FConfigfile) do
      try
        WriteString('user','p',BRK+EncryptString(Self.Pass)+BRK);
      finally
        Free;
      end;
  end;
end;

function TAppUser.AddUser(AUser, APass: string): Boolean;
begin
  Result := false;
  with TSQLQuery.Create(nil) do
  try
    DataBase := AppConnection.Connection;
    sql.add('insert into USERS(id, user_name, pass, is_system) values(:id, :u, :p, 1);');
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
    sql.add('insert into ROLES(id, role_name, label, is_system) values(:id, :n, :l, 1);');
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
    sql.add('insert into USER_ROLES(id, user_name, role_name, is_system) values(:id, :u, :r, 1);');
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
    // the password should already be in hashed format
    with TSQLQuery.Create(nil) do
    try
      Database := AppConnection.Connection;
      sql.Add('select user_name, pass from users');
      sql.add(' where (user_name=:u) and (pass=:p)');
      ParamByName('u').AsString:= u;  
      ParamByName('p').AsString:= p;
      Prepare;
      Open;
      // always set this properties after a successful login
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

function TAppUser.changepass_(u, p: string; var msg: string): Boolean;
begin
  Result := true;
  msg := '';
  try
    with TSQLQuery.Create(nil) do
    try
      Database := AppConnection.Connection;
      sql.Add('update users set pass=:p');
      sql.add(' where user_name=:u;');
      ParamByName('u').AsString:= u;
      ParamByName('p').AsString:= MD5Print(MD5String(p));
      ExecSQL;
      SQLConnection.Transaction.CommitRetaining;

      FPass:= p;

    finally
      Free;
    end;
  except   
    on e:exception do
    begin
      msg := e.Message;
      Result := False;
    end;
  end;
end;

//initialization
//  AppUser := TAppUser.Create;
//
//finalization
//  AppUser.Free;

end.

