unit UserManagerForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, ActnList, user_BOM, VirtualTrees;

type

  PUserTreeData = ^TUser;
  PAssignedRoleTreeData = ^TAssignedRole;

  //TUserTreeData = record
  //  User: TUser;
  //end;

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
    lvRoles: TListView;
    PageControl1: TPageControl;
    tabUsers: TTabSheet;
    tabRoles: TTabSheet;
    vstAssignedRoles: TVirtualStringTree;
    vstUser: TVirtualStringTree;
    procedure actAddUserExecute(Sender: TObject);
    procedure actAddUserUpdate(Sender: TObject);
    procedure actAssignRoleExecute(Sender: TObject);
    procedure actDeleteUserExecute(Sender: TObject);
    procedure actDeleteUserUpdate(Sender: TObject);
    procedure actRemoveRoleExecute(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lvRolesData(Sender: TObject; Item: TListItem);
    procedure PageControl1Change(Sender: TObject);
    procedure vstAssignedRolesGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: String);
    procedure vstUserChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstUserGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: String);
  private
    FRoles: TRoles;
    FUsers: TUsers;
    function GetSelectedUser: TUser;
    procedure UpdateAssignedRolesView();
  private
    property SelectedUser: TUser read GetSelectedUser;
    //property SelectedUser: TUser read FSelectedUser write FSelectedUser;
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

procedure TfrmUserManager.lvRolesData(Sender: TObject; Item: TListItem);
var
  r: TRole;
begin
  r := TRole(FRoles[Item.Index]);
  Item.Caption := r.Rolename;
end;

procedure TfrmUserManager.PageControl1Change(Sender: TObject);
begin
  if PageControl1.ActivePage = tabUsers then
    edtUser.SetFocus;
end;

procedure TfrmUserManager.vstAssignedRolesGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  Data: PAssignedRoleTreeData;
begin
  Data := (sender as TBaseVirtualTree).GetNodeData(Node);
  CellText := Data^.Rolename;
end;

procedure TfrmUserManager.vstUserChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  UpdateAssignedRolesView();
end;

procedure TfrmUserManager.vstUserGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  Data: PUserTreeData;
begin
  Data := (sender as TBaseVirtualTree).GetNodeData(Node);
  CellText := Data^.Username;
end;

function TfrmUserManager.GetSelectedUser: TUser;
var
  node: PVirtualNode;
  ind: Cardinal;
begin
  result := nil;
  node := vstUser.GetFirstSelected();
  if not assigned(node) then exit;
  ind := vstUser.AbsoluteIndex(node);
  result := FUsers[ind];
end;

procedure TfrmUserManager.UpdateAssignedRolesView();
var
  i: Integer;
begin
  vstAssignedRoles.Clear;
  //todo: check error here
  for i := 0 to SelectedUser.Roles.Count-1 do
    vstAssignedRoles.AddChild(nil,SelectedUser.Roles[i]);
end;

procedure TfrmUserManager.actAddUserExecute(Sender: TObject);
var
  u: TUser;
  s: string;
  node: PVirtualNode;
begin
  s := edtUser.Text;
  if (s <> '') and (FUsers.IndexOf(s) = -1) then
  begin
    u := TUser.Create;
    u.ID:= 999;
    u.Username:= s;
    FUsers.Add(u);
    node := vstUser.AddChild(nil,Fusers[Fusers.Count-1]);
    vstUser.Selected[node] := True;

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
    //lvAssignedRoles.Items.Count := SelectedUser.Roles.Count;
  end;
end;

procedure TfrmUserManager.actDeleteUserExecute(Sender: TObject);
var
  ind: Cardinal;
  node, nextnode: PVirtualNode;
begin
  node := vstUser.GetFirstSelected;
  if not assigned(node) then exit;
  nextnode := node^.NextSibling;
  if nextnode = nil then nextnode := node^.PrevSibling;
  ind := vstUser.AbsoluteIndex(node);
  FUsers.Delete(FUsers[ind]);
  vstUser.DeleteNode(node);
  vstUser.Selected[nextnode] := True;
  edtUser.SetFocus;
end;

procedure TfrmUserManager.actDeleteUserUpdate(Sender: TObject);
begin
  (sender as taction).Enabled := Assigned(SelectedUser)
    and (SelectedUser.Username <> '')
    and (SelectedUser.Username <> 'admin')
end;

procedure TfrmUserManager.actRemoveRoleExecute(Sender: TObject);
var
  node, nextnode : PVirtualNode;
  ind: Cardinal;
begin
  node := vstAssignedRoles.GetFirstSelected();
  if not assigned(node) then exit;
  ind := vstAssignedRoles.AbsoluteIndex(node);
  nextnode := node^.NextSibling;
  if nextnode = nil then nextnode := node^.PrevSibling;
  ind := vstUser.AbsoluteIndex(node);

  if (SelectedUser.Username='admin') and (PAssignedRoleTreeData(node)^.Rolename='admin') then
    MessageDlg('Action not allowed.',mtInformation,[mbOk],0)
  else
  begin
    SelectedUser.Roles.Delete(ind);
    vstAssignedRoles.DeleteNode(node);
    vstAssignedRoles.Selected[nextnode] := True;
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
    //vstUser.RootNodeCount:= 3;
    vstUser.AddChild(nil,FUsers[0]);
    vstUser.AddChild(nil,FUsers[1]);
    vstUser.AddChild(nil,FUsers[2]);
    vstUser.Selected[vstUser.GetFirst()] := True;

    for i := 0 to FRoles.Count-1 do
      cmbRoles.AddItem(FRoles[i].Rolename,TObject(FRoles[i].ID));

    ShowModal;
  finally
    Free;
  end;
end;

end.

