unit UserManagerU;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, user_BOM;

type

  { TUserManager }

  TUserManager = class(Tcomponent)

  private
  public
    procedure OpenForm;
  end;

implementation

uses UserManagerForm;

{ TUserManager }

procedure TUserManager.OpenForm;
var
  Roles : TRoles;
  Users : TUsers;
  u: TUser;
  r: TRole;
  ar: TAssignedRole;
begin
  //Initialize TRoles
  Roles := TRoles.Create(true);
  r := TRole.Create;
  r.ID := 1;
  r.Rolename:= 'admin';
  r.RoleLabel:= 'Admin';
  Roles.Add(r);

  r := TRole.Create;
  r.ID := 2;
  r.Rolename:= 'processor';
  r.RoleLabel:= 'Processor';
  Roles.Add(r);

  r := TRole.Create;
  r.ID := 1;
  r.Rolename:= 'manager';
  r.RoleLabel:= 'Manager';
  Roles.Add(r);

  ;
  //initialize TUser data
  Users := TUsers.Create(true);
  u := TUser.Create;
  u.ID:= 1;
  U.Username:= 'admin';
  Users.Add(u);

  u := TUser.Create;
  u.ID:= 2;
  u.Username:= 'jeff';
    ar := TAssignedRole.create;
    ar.RecordID:= 1;
    ar.RoleID:= 1;
    ar.Rolename:= 'admin';
  u.Roles.add(ar);
  Users.Add(u);

  u := TUser.Create;
  u.ID:= 3;
  U.Username:= 'GrandSirThebus';
  Users.Add(u);

  try
    TfrmUserManager.Open(Users, Roles);
  finally
    Users.Free;
    Roles.Free;
  end;
end;

end.

