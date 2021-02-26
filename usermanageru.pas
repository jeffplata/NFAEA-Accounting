unit UserManagerU;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, user_BOM, SQLDB, DB;

type

  TArrayOfDatasets = array of TSQLQuery;

  { TUserManager }

  TUserManager = class(Tcomponent)

  private    
    qUsers: TSQLQuery;
    qRoles: TSQLQuery;
  public
    constructor Create(AOwner: TComponent); override;
    procedure OpenForm;
  end;

implementation

uses UserManagerForm, appConnectionU, Forms, Dialogs;

{ TUserManager }

constructor TUserManager.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  //qUsers := TSQLQuery.Create(AOwner);
  //qRoles := TSQLQuery.Create(AOwner);
end;

procedure TUserManager.OpenForm;
var
  Roles : TRoles;
  Users : TUsers;
  u: TUser;
  r: TRole;
  ar: TAssignedRole;
  qAssRoles: TSQLQuery;
  ds: TDataSource;
begin
  
  qUsers := TSQLQuery.Create(Owner);
  qRoles := TSQLQuery.Create(Owner);

  // Read users and user roles
  Users := TUsers.Create;

  qAssRoles := TSQLQuery.Create(self.Owner);

  ds := TDataSource.Create(self.owner);
  ds.DataSet := qUsers;
  qAssRoles.DataSource := ds;
  qAssRoles.SQL.add('select ID, USER_NAME, ROLE_NAME, IS_SYSTEM from USER_ROLES') ;
  qAssRoles.SQL.add(' where USER_NAME=:USER_NAME;');

  with qUsers do
  begin
    database := AppConnection.Connection;
    sql.Add('select ID, USER_NAME, PASS, IS_SYSTEM from USERS;');
    qAssRoles.database := database;

    try
      Open;
      qAssRoles.Open;
      //transfer to List
      while not Eof do
      begin
        u := TUser.Create;
        u.ID:= Fields[0].AsInteger;
        u.Username:= Fields[1].AsString;
        //u.Pass:= Fields[2].AsString;
        u.IsSystem:= Fields[3].AsInteger;
        while not qAssRoles.EOF do
        begin
          ar := u.Roles.Add;
          ar.ID:= qAssRoles.Fields[0].AsInteger;
          ar.Username:= qAssRoles.Fields[1].AsString;
          ar.Rolename:= qAssRoles.Fields[2].AsString;
          ar.IsSystem:= qAssRoles.Fields[3].AsInteger;
          qAssRoles.Next;
        end;
        Users.Add(u);
        Next;
      end;
    except
      on e: Exception do
      begin
        MessageDlg(e.Message, mtError, [mbOk], 0);
        qUsers.Free;
        exit;
      end;
    end;
  end;

  // Read Roles
  Roles := TRoles.Create;
  with qRoles do
  begin
    database := AppConnection.Connection;
    sql.Add('select ID, ROLE_NAME, LABEL, IS_SYSTEM from ROLES;');
    try
      Open;
      while not Eof do
      begin
        r := TRole.Create;
        r.ID:= Fields[0].AsInteger;
        r.Rolename:= Fields[1].AsString;
        r.RoleLabel:= Fields[2].AsString;
        r.IsSystem:= Fields[3].AsInteger;
        Roles.Add(r);
        Next;
      end;
    except
      on e: Exception do
      begin
        MessageDlg(e.Message, mtError, [mbOk], 0);
        qRoles.Free;
        exit;
      end;
    end;
  end;
  try
    TfrmUserManager.Open(Users, Roles, qUsers, qRoles, [qAssRoles]);
  finally

    Users.Free;
    Roles.Free;
  end;

  qUsers.Free;
  qRoles.Free;
end;

end.

