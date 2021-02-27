unit mainForm;

{$mode objfpc}{$H+}

interface

uses
  Forms, Menus, ActnList,
  ComCtrls, SQLDB, Classes;

type

  { TfmMain }

  TfmMain = class(TForm)
    actExit: TAction;
    actAbout: TAction;
    actChangePass: TAction;
    actUserManager: TAction;
    actLogout: TAction;
    actSetdatabase: TAction;
    ActionList1: TActionList;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    Setdatabase1: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem3: TMenuItem;
    StatusBar1: TStatusBar;
    procedure actChangePassExecute(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure actLogoutExecute(Sender: TObject);
    procedure actLogoutUpdate(Sender: TObject);
    procedure actSetdatabaseExecute(Sender: TObject);
    procedure actUserManagerExecute(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    procedure UpdateConnectedIndicator;
    procedure UpdateFormUI;
  public

  end;

var
  fmMain: TfmMain;

implementation

uses
  mainDM;

{$R *.lfm}

{ TfmMain }

procedure TfmMain.actExitExecute(Sender: TObject);
begin
  close;
end;

procedure TfmMain.actChangePassExecute(Sender: TObject);
begin
  //action change password
  if dmMain.User.Loggedin then
    dmMain.User.ChangePassDialog;
end;

procedure TfmMain.actLogoutExecute(Sender: TObject);
begin
  dmMain.User.Logout(True);
  UpdateConnectedIndicator;
  if dmMain.User.LoginDialog then
  begin
    UpdateConnectedIndicator;
    UpdateFormUI;
  end
  else
    actExit.Execute;
end;

procedure TfmMain.actLogoutUpdate(Sender: TObject);
begin
  (Sender as TAction).enabled := dmMain.User.Loggedin;
end;

procedure TfmMain.actSetdatabaseExecute(Sender: TObject);
begin
  dmMain.SetDatabase;
  UpdateConnectedIndicator;
  UpdateFormUI;
end;

procedure TfmMain.actUserManagerExecute(Sender: TObject);
begin
  dmMain.UserManager.OpenForm;
end;

procedure TfmMain.FormActivate(Sender: TObject);
begin
  UpdateConnectedIndicator;
  UpdateFormUI;
end;

procedure TfmMain.UpdateConnectedIndicator;
var
  st_text : String;
begin  
  if dmMain.isConnected then
    st_text := 'Connected'
  else
    st_text := 'Not connected';

  if dmMain.User.Loggedin then
    st_text := st_text + ' | Logged in'
  else
    st_text := st_text + ' | Not logged in';

  StatusBar1.SimpleText := st_text;
end;

procedure TfmMain.UpdateFormUI;
begin
  // set action/memu visibility/accessibility here
  actUserManager.Visible:= dmMain.User.Username = 'admin';
end;

end.

