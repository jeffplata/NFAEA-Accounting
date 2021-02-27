unit UserLoginForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ActnList;

type
              
  TLoginCallback = function(u, p, r: string; var msg: string): Boolean of object;

  { TfrmUserLogin }

  TfrmUserLogin = class(TForm)
    actOk: TAction;
    ActionList1: TActionList;
    btnCancel: TButton;
    btnOk: TButton;
    chkRememberme: TCheckBox;
    edtUsername: TLabeledEdit;
    edtPassword: TLabeledEdit;
    procedure actOkExecute(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);
  private

  public
    LoginCallback: TLoginCallback;
  end;

var
  frmUserLogin: TfrmUserLogin;

implementation

uses md5;

{$R *.lfm}

{ TfrmUserLogin }

procedure TfrmUserLogin.actOkUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled:= (edtUsername.Text <> '') and
    (edtPassword.Text <> '');
end;

procedure TfrmUserLogin.actOkExecute(Sender: TObject);
var
  u, p, r, msg: string;
begin
  if LoginCallback <> nil then
  begin
    btnOk.Enabled:= false;
    msg := '';
    u := edtUsername.text;
    p := MD5Print(MD5String(edtPassword.Text));
    r := '0';
    if chkRememberme.Checked then
      r := '1';
    if LoginCallback(u, p, r, msg) then
      ModalResult:= mrOk
    else
      begin
        MessageDlg('Info', msg, mtConfirmation, [mbOk], 0);
        edtUsername.SetFocus;
      end;
    btnOk.Enabled := true;
  end
  else
    ModalResult:= mrOk;
end;

end.

