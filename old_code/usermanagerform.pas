unit UserManagerForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, ActnList, user_BOM;

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
    lvRoles: TListView;
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
    procedure FormCreate(Sender: TObject);
    procedure lvAssignedRolesData(Sender: TObject; Item: TListItem);
    procedure lvRolesData(Sender: TObject; Item: TListItem);
    procedure lvUsersData(Sender: TObject; Item: TListItem);
    procedure lvUsersSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure PageControl1Change(Sender: TObject);
  private
    FRoles: TRoles;
    FSelectedUser: TUser;
    FUsers: TUsers;
  private
    //property SelectedUser: TUser read GetSelectedUser;
    property SelectedUser: TUser read FSelectedUser write FSelectedUser;
  public
    class procedure Open(AUsers: TUsers; ARoles: TRoles);

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

procedure TfrmUserManager.FormCreate(Sender: TObject);
begin
  PageControl1.ActivePage := tabUsers;
end;

procedure TfrmUserManager.lvAssignedRolesData(Sender: TObject; Item: TListItem);
var
  ar: TAssignedRole;
begin
  try
    ar := TAssignedRole(SelectedUser.Roles[Item.Index]);
    Item.Caption:= ar.Rolename;
  except
    item.caption := selecteduser.Username;
  end;

end;

procedure TfrmUserManager.lvRolesData(Sender: TObject; Item: TListItem);
var
  r: TRole;
begin
  r := TRole(FRoles[Item.Index]);
  Item.Caption := r.Rolename;
end;


procedure TfrmUserManager.lvUsersData(Sender: TObject; Item: TListItem);
var
  u: TUser;
begin
  u := TUser(FUsers.Items[Item.Index]);
  Item.Caption:= u.Username;
end;

procedure TfrmUserManager.lvUsersSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if selected then
  begin             
    FSelectedUser := FUsers[Item.Index];
    lvAssignedRoles.items.count := SelectedUser.Roles.Count;
  end;
end;


procedure TfrmUserManager.PageControl1Change(Sender: TObject);
begin
  if PageControl1.ActivePage = tabUsers then
    edtUser.SetFocus;
end;

procedure TfrmUserManager.actAddUserExecute(Sender: TObject);
var
  u: TUser;
  s: string;
begin
  s := edtUser.Text;
  if (s <> '') and (FUsers.IndexOf(s) = -1) then
  begin
    u := TUser.Create;
    u.ID:= 999;
    u.Username:= s;
    FUsers.Add(u);

    lvUsers.items.count := fusers.count;
    lvusers.invalidate;
    edtUser.Text:= '';
    edtUser.SetFocus;
  end;
end;

procedure TfrmUserManager.actAddUserUpdate(Sender: TObject);
begin
  (sender as taction).Enabled := edtUser.Text <> '';
end;

procedure TfrmUserManager.actAssignRoleExecute(Sender: TObject);
var
  r: TAssignedRole;
  duplicate: Boolean;
  i: Integer;
begin
  duplicate := False;
  for i := 0 to SelectedUser.Roles.Count-1 do
  begin
    if TAssignedRole(SelectedUser.Roles[i]).Rolename = cmbRoles.Text then
    begin
      duplicate := True;
      break;
    end;
  end;
  if not duplicate then
  begin
    r := TAssignedRole.Create;
    r.RecordID:= 0;
    r.RoleID:= Integer(cmbRoles.Items.Objects[cmbRoles.ItemIndex]);
    r.Rolename:= cmbRoles.Text;
    SelectedUser.Roles.Add(r);
    lvAssignedRoles.Items.Count := SelectedUser.Roles.Count;
  end;
end;

procedure TfrmUserManager.actDeleteUserExecute(Sender: TObject);
var
  currentInd, newCurrentInd: Integer;
begin
  currentInd := lvUsers.ItemFocused.Index;
  newCurrentInd := currentInd;
  if currentInd = (FUsers.Count-1) then newCurrentInd := FUsers.Count-2;
  FUsers.Delete(FUsers[currentInd]);
  if newCurrentInd < 0 then
    begin
      SelectedUser := nil;
      lvUsers.Items.Count := 0;
      lvAssignedRoles.Items.Count := 0;
    end
  else
    begin
      lvUsers.ItemFocused := lvUsers.Items[newCurrentInd] ;
      SelectedUser := FUsers[newCurrentInd];
      lvUsers.Items.Count := FUsers.Count;
      lvAssignedRoles.Items.Count := SelectedUser.Roles.Count;
    end;
  edtUser.SetFocus;
end;

procedure TfrmUserManager.actDeleteUserUpdate(Sender: TObject);
begin
  //if Assigned(SelectedUser) then
  //  (sender as taction).Enabled := (SelectedUser.Username <> '')
  //    and (SelectedUser.Username<>'admin');
end;

procedure TfrmUserManager.actRemoveRoleExecute(Sender: TObject);
begin
  if Assigned(lvAssignedRoles.Selected) then
  begin
    if (SelectedUser.Username='admin') and (lvAssignedRoles.Selected.Caption='admin') then
      MessageDlg('Action not allowed.',mtInformation,[mbOk],0)
    else
    begin
      SelectedUser.Roles.Delete(lvAssignedRoles.Selected.Index);
      lvAssignedRoles.Items.Count := SelectedUser.Roles.Count;
    end;
  end;
end;

class procedure TfrmUserManager.Open(AUsers: TUsers; ARoles: TRoles);
var
  i: Integer;
begin
  with TfrmUserManager.Create(nil) do
  try
    FRoles := ARoles;
    lvRoles.Items.Count := FRoles.Count;
    FUsers := AUsers;
    lvUsers.Items.Count := FUsers.Count;

    for i := 0 to FRoles.Count-1 do
      cmbRoles.AddItem(FRoles[i].Rolename,TObject(FRoles[i].ID));

    ShowModal;
  finally
    Free;
  end;
end;

end.

