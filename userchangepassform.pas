unit UserChangePassForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ActnList;

type

  TChangePassCallback = function(u, p: string; var msg: string): Boolean of object;

  { TfrmUserChangePass }

  TfrmUserChangePass = class(TForm)
    actOk: TAction;
    ActionList1: TActionList;
    btnCancel: TButton;
    btnOk: TButton;
    edtNewPass: TLabeledEdit;
    edtConfirmPass: TLabeledEdit;
    edtCurrentPass: TLabeledEdit;
    lblMessage: TLabel;
    procedure actOkExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public
    User: string;
    CurrentPass: string;
    ChangePassCallback: TChangePassCallback;
  end;

var
  frmUserChangePass: TfrmUserChangePass;

implementation

uses md5;

{$R *.lfm}

{ TfrmUserChangePass }

procedure TfrmUserChangePass.actOkExecute(Sender: TObject);
var
  u, p, cp, msg: string;
begin        
  cp := MD5Print(MD5String(edtCurrentPass.Text));
  msg := '';
  if cp <> CurrentPass then msg := 'Incorrect password.'
  else if edtNewPass.Text='' then msg:= 'New password required.'
  else if edtNewPass.Text<>edtConfirmPass.Text then msg:= 'New password does not match.';  
  lblMessage.Caption:= msg;
  if msg <> '' then exit; // <==

  if ChangePassCallback <> nil then
  begin
    btnOk.Enabled:= false;
    msg := '';
    u := User;
    p := edtNewPass.Text;
    if ChangePassCallback(u, p, msg) then
      ModalResult:= mrOk
    else
      begin
        MessageDlg('Info', msg, mtConfirmation, [mbOk], 0);
        edtCurrentPass.SetFocus;
      end;
    btnOk.Enabled := true;
  end
  else
    ModalResult:= mrOk;
end;

procedure TfrmUserChangePass.FormCreate(Sender: TObject);
begin
  lblMessage.Caption:= '';
end;

end.

