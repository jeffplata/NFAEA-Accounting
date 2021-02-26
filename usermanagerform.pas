unit UserManagerForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, ActnList, DBGrids, user_BOM, SQLDB, DB, VirtualTrees, Grids;

type       
  TArrayOfDatasets = array of TSQLQuery;

  PUserTreeData = ^TUser;
  PAssignedRoleTreeData = ^TAssignedRole;
  PRoleTreeData = ^TRole;

  { TfrmUserManager }

  TfrmUserManager = class(TForm)
    actAddUser: TAction;
    actDeleteUser: TAction;
    actAssignRole: TAction;
    actAddRole: TAction;
    actDeleteRole: TAction;
    actRemoveRole: TAction;
    ActionList1: TActionList;
    btnAddRole: TButton;
    btnClose: TButton;
    btnAddUser: TButton;
    btnRemoveUser: TButton;
    btnDeleteRole: TButton;
    Button1: TButton;
    Button2: TButton;
    cmbRoles: TComboBox;
    dsRoles: TDataSource;
    dsAssignedRoles: TDataSource;
    dsUsers: TDataSource;
    dbgUsers: TDBGrid;
    dbgAssignedRoles: TDBGrid;
    dbgRoles: TDBGrid;
    edtUser: TEdit;
    Label1: TLabel;
    PageControl1: TPageControl;
    tabUsers: TTabSheet;
    tabRoles: TTabSheet;
    procedure actAddRoleExecute(Sender: TObject);
    procedure actAddUserExecute(Sender: TObject);
    procedure actAddUserUpdate(Sender: TObject);
    procedure actAssignRoleExecute(Sender: TObject);
    procedure actDeleteRoleExecute(Sender: TObject);
    procedure actDeleteUserExecute(Sender: TObject);
    procedure actRemoveRoleExecute(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
  private
    FRoles: TRoles;
    FUsers: TUsers;
    FqUsers: TSQLQuery;
    FqRoles: TSQLQuery;
    FqAssignedRoles: TSQLQuery;
  private
    function GetNextSelectableNode(vt: TVirtualStringTree): PVirtualNode;
  public
    class procedure Open(AUsers: TUsers; ARoles: TRoles; qUsers, qRoles: TSQLQuery; q: TArrayOfDatasets);
  end;


implementation

uses RoleEditForm, hilogeneratorU, Variants, md5;  


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

procedure TfrmUserManager.PageControl1Change(Sender: TObject);
begin
  if PageControl1.ActivePage = tabUsers then
    edtUser.SetFocus;
end;



function TfrmUserManager.GetNextSelectableNode(vt: TVirtualStringTree
  ): PVirtualNode;
var
  currentNode: PVirtualNode;
begin
  currentNode := vt.GetFirstSelected;
  if not assigned(currentNode) then exit;
  Result := currentNode^.NextSibling;
  if not assigned(Result) then
    Result := currentNode^.PrevSibling;
end;

procedure TfrmUserManager.actAddUserExecute(Sender: TObject);
var
  s: string;
begin
  s := edtUser.Text;
  if s = '' then exit;  //<== exit

  FqUsers.Append;
  FqUsers.FieldByName('user_name').AsString:= s;
  FqUsers.FieldByName('pass').AsString:= MD5Print(MD5String('Password1'));
  FqUsers.FieldByName('ID').AsInteger:= HiLoGenerator.NextValue;
  FqUsers.Post;
  FqUsers.ApplyUpdates;
  FqUsers.SQLConnection.Transaction.CommitRetaining;
                                                      
  edtUser.Text:= '';
  edtUser.SetFocus;

end;

procedure TfrmUserManager.actAddRoleExecute(Sender: TObject);
var
  rolename, rolelabel: string;
begin
  rolename := '';
  rolelabel := '';
  if TfrmRole.GetInput(rolename, rolelabel, true) then
  begin
    if rolename = '' then exit;
    if rolelabel = '' then rolelabel := Uppercase(rolename[1])+copy(rolename,2,10000);

    FqRoles.Append;
    FqRoles.FieldByName('role_name').AsString:= rolename;
    FqRoles.FieldByName('label').AsString:= rolelabel;
    FqRoles.FieldByName('ID').AsInteger:= HiLoGenerator.NextValue;
    FqRoles.Post;
    FqRoles.ApplyUpdates;
    FqRoles.SQLConnection.Transaction.CommitRetaining;

    cmbRoles.AddItem(FqRoles.FieldByName('role_name').AsString,
      TObject(FqRoles.FieldByName('ID').AsInteger));
  end;
end;

procedure TfrmUserManager.actAddUserUpdate(Sender: TObject);
begin
  (sender as taction).Enabled := edtUser.Text <> '';
end;

procedure TfrmUserManager.actAssignRoleExecute(Sender: TObject);
begin
  if cmbRoles.Text = '' then exit;  //<==
  if FqUsers.eof then exit;         //<==

  if not FqAssignedRoles.Locate('user_name;role_name', VarArrayOf([FqUsers.FieldByName('user_name').AsString,
    cmbRoles.Text]), [loCaseInsensitive]) then
  begin
    FqAssignedRoles.Append;
    FqAssignedRoles.FieldByName('user_name').AsString:= FqUsers.FieldByName('user_name').AsString; 
    FqAssignedRoles.FieldByName('role_name').AsString:= cmbRoles.Text; 
    FqAssignedRoles.FieldByName('ID').AsInteger:= HiLoGenerator.NextValue;
    FqAssignedRoles.Post;
    FqAssignedRoles.ApplyUpdates;
    FqAssignedRoles.SQLTransaction.CommitRetaining;
  end;

end;

procedure TfrmUserManager.actDeleteRoleExecute(Sender: TObject);
var
  ind: Integer;
begin
  if FqRoles.eof then exit;
  if FqRoles.FieldByName('IS_SYSTEM').AsInteger=1 then
    MessageDlg('Action not allowed.',mtInformation,[mbOk],0)
  else
  begin          
    ind := cmbRoles.Items.IndexOf(FqRoles.FieldByName('role_name').AsString);

    FqRoles.Delete;
    FqRoles.ApplyUpdates;
    FqRoles.SQLConnection.Transaction.CommitRetaining;

    if ind > -1 then
      cmbRoles.Items.Delete(ind);
  end;
end;

procedure TfrmUserManager.actDeleteUserExecute(Sender: TObject);
begin
  if FqUsers.eof then exit;    
  if FqUsers.FieldByName('IS_SYSTEM').AsInteger=1 then
    MessageDlg('Action not allowed.',mtInformation,[mbOk],0)
  else
  begin
    FqUsers.Delete;
    FqUsers.ApplyUpdates;
    FqUsers.SQLConnection.Transaction.CommitRetaining;
  end;

end;

procedure TfrmUserManager.actRemoveRoleExecute(Sender: TObject);
begin
  if FqAssignedRoles.eof then exit;   // <==
  if FqAssignedRoles.FieldByName('is_system').AsInteger = 1 then
    MessageDlg('Action not allowed.',mtInformation,[mbOk],0)
  else
  begin
    FqAssignedRoles.Delete;
    FqAssignedRoles.ApplyUpdates;
    FqAssignedRoles.SQLTransaction.CommitRetaining;
  end;

end;

class procedure TfrmUserManager.Open(AUsers: TUsers; ARoles: TRoles; qUsers,
  qRoles: TSQLQuery; q: TArrayOfDatasets);
{
 Limit user management to the primary forms, specially the MainForm
}
begin
  with TfrmUserManager.Create(nil) do
  try
    FRoles := ARoles;
    FUsers := AUsers;

    FqUsers := qUsers;
    fqusers.first;
    FqRoles := qRoles;
    FqAssignedRoles := q[0];

    //set up grids    
    FqUsers.First;
    dsUsers.DataSet := FqUsers;
    dbgUsers.DataSource := dsUsers;
    //dbgUsers.AutoAdjustColumns;
    dbgUsers.AutoFillColumns:=true;
                                        
    FqAssignedRoles.First;
    dsAssignedRoles.DataSet := FqAssignedRoles;
    dbgAssignedRoles.DataSource := dsAssignedRoles;
    //dbgAssignedRoles.AutoAdjustColumns;
    dbgAssignedRoles.AutoFillColumns:=true;

    FqRoles.First;
    dsRoles.DataSet := FqRoles;
    dbgRoles.DataSource := dsRoles;
    //dbgRoles.AutoAdjustColumns;
    dbgRoles.AutoFillColumns:=true;

    //FqRoles to combobox
    with FqRoles do
    begin
      while not eof do
      begin
        cmbRoles.AddItem(FieldByName('role_name').AsString, TObject(FieldByName('ID').AsInteger));
        Next;
      end;
      First;
    end;

    ShowModal;
  finally
    Free;
  end;
end;

end.

