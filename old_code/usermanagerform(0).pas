unit UserManagerForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  ActnList;

type

  { TfrmUserManager }

  TfrmUserManager = class(TForm)
    actAddUser: TAction;
    actDeleteUser: TAction;
    actAssignRole: TAction;
    actRemoveRole: TAction;
    ActionList1: TActionList;
    btnClose: TButton;
    btnAddUser: TButton;
    btnRemoveUser: TButton;
    Button1: TButton;
    Button2: TButton;
    cmbRoles: TComboBox;
    edtUser: TEdit;
    Label1: TLabel;
    lvAssignedRoles: TListView;
    lvUsers: TListView;
    PageControl1: TPageControl;
    tabUsers: TTabSheet;
    tabRoles: TTabSheet;
    procedure actAddUserExecute(Sender: TObject);
    procedure actAddUserUpdate(Sender: TObject);
    procedure actAssignRoleExecute(Sender: TObject);
    procedure actDeleteUserExecute(Sender: TObject);
    procedure actDeleteUserUpdate(Sender: TObject);
    procedure actRemoveRoleExecute(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
  private
    function GetSelectedUser: string;
  private
    property SelectedUser: string read GetSelectedUser;
  public
    class procedure Open;

  end;

//var
//  frmUserManager: TfrmUserManager;

implementation

{$R *.lfm}

{ TfrmUserManager }

procedure TfrmUserManager.btnCloseClick(Sender: TObject);
begin
  close;
end;

procedure TfrmUserManager.FormActivate(Sender: TObject);
begin
  edtUser.SetFocus;
end;


procedure TfrmUserManager.PageControl1Change(Sender: TObject);
begin
  if PageControl1.ActivePage = tabUsers then
    edtUser.SetFocus;
end;

function TfrmUserManager.GetSelectedUser: string;
begin
  result := '';
  if lvUsers.Selected <> nil then
    result := lvUsers.Selected.Caption;
end;

procedure TfrmUserManager.actAddUserExecute(Sender: TObject);
var
  s: string;
begin
  s := edtUser.Text;
  if (edtUser.Text <> '') and (lvUsers.FindCaption(0,s,False,True,False)=nil) then
  begin
    lvUsers.AddItem(edtUser.Text, nil);
    edtUser.Text:= '';
    edtUser.SetFocus;
  end;
end;

procedure TfrmUserManager.actAddUserUpdate(Sender: TObject);
begin
  (sender as taction).Enabled := edtUser.Text <> '';
end;

procedure TfrmUserManager.actAssignRoleExecute(Sender: TObject);
begin
  if lvAssignedRoles.Items.FindCaption(0,cmbRoles.Text,False,True,False) = nil then
    lvAssignedRoles.AddItem(cmbRoles.Text,nil);
end;

procedure TfrmUserManager.actDeleteUserExecute(Sender: TObject);
begin
  if SelectedUser='admin' then
    MessageDlg('Action not allowed.',mtInformation,[mbOk],0)
  else
    lvUsers.Selected.Delete;
  edtUser.SetFocus;
end;

procedure TfrmUserManager.actDeleteUserUpdate(Sender: TObject);
begin
  (sender as taction).Enabled := (lvUsers.Selected <> nil)
    or (SelectedUser='admin');
end;

procedure TfrmUserManager.actRemoveRoleExecute(Sender: TObject);
begin
  if lvAssignedRoles.Selected <> nil then
  begin
    if (SelectedUser='admin') and (lvAssignedRoles.Selected.Caption='admin') then
      MessageDlg('Action not allowed.',mtInformation,[mbOk],0)
    else
      lvAssignedRoles.Selected.Delete;
  end;
end;

class procedure TfrmUserManager.Open;
begin
  with TfrmUserManager.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

end.

