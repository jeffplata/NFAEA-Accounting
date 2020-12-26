unit UserLoginForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ActnList;

type
              
  TLoginCallback = function(u, p: string; var msg: string): Boolean of object;

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

{$R *.lfm}

{ TfrmUserLogin }

procedure TfrmUserLogin.actOkUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled:= (edtUsername.Text <> '') and
    (edtPassword.Text <> '');
end;

procedure TfrmUserLogin.actOkExecute(Sender: TObject);
var
  u, p, msg: string;
begin
  if LoginCallback <> nil then
  begin
    btnOk.Enabled:= false;
    msg := '';
    u := edtUsername.text;
    p := edtPassword.text;
    if LoginCallback(u, p, msg) then
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

