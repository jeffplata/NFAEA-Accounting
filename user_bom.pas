unit user_BOM;

{$mode delphi}{$H+}

interface

uses
  base_BOM;

type

  { TRole }

  TRole = class(TBaseBOM)
  private
    FRoleLabel: string;
    FRolename: string;
  public
    procedure Assign(src: TRole);
  published
    property Rolename: string read FRolename write FRolename;
    property RoleLabel: string read FRoleLabel write FRoleLabel;
  end;

  { TAssignedRole }

  TAssignedRole = class(TBaseBOM)
  private
    FRolename: string;
    FUsername: string;
  public
    procedure Assign( src: TAssignedRole );
  published
    property Rolename: string read FRolename write FRolename;  
    property Username: string read FUsername write FUsername;
  end;

  TAssignedRoles = TBaseBOMList<TAssignedRole>;

  { TUser }

  TUser = class(TBaseBOM)
  private
    FRoles: TAssignedRoles;
    FUsername: string;
  public
    constructor Create(AppendMode: Boolean=False);
    destructor Destroy; override;
    procedure Assign( src: TUser );
  published
    property Username: string read FUsername write FUsername;
    property Roles: TAssignedRoles read FRoles write FRoles;
  end;

  TRoles = TBaseBOMList<TRole>;
  TUsers = TBaseBOMList<TUser>;

implementation

{ TRole }

procedure TRole.Assign(src: TRole);
begin
  inherited Assign(src);
  with src do
  begin
    self.Rolename:= src.Rolename;
  end;
end;

{ TAssignedRole }

procedure TAssignedRole.Assign(src: TAssignedRole);
begin
  inherited Assign(src);
  with src do
  begin
    self.Username:= src.Username;
    self.Rolename:= src.Rolename;
  end;
end;

{ TUser }

constructor TUser.Create(AppendMode: Boolean);
begin
  inherited Create(AppendMode);
  FRoles := TAssignedRoles.Create;
end;

destructor TUser.Destroy;
begin
  FRoles.Free;
  inherited Destroy;
end;

procedure TUser.Assign(src: TUser);
var
  i: Integer;
begin
  inherited Assign(src);
  with src do
  begin
    self.Username:= src.Username;
    for i := 0 to src.Roles.Count-1 do
    begin
      self.Roles[i].Assign(src.Roles[i]);
    end;
  end;
end;

end.

