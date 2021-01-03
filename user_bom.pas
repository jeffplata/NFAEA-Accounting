unit user_BOM;

{$mode objfpc}{$H+}

interface

uses
  Contnrs;

type

  { TRole }

  TRole = class
  private
    FID: integer;
    FRoleLabel: string;
    FRolename: string;
  public
    property ID: integer read FID write FID;
    property Rolename: string read FRolename write FRolename;
    property RoleLabel: string read FRoleLabel write FRoleLabel;
  end;

  { TRoles }

  TRoles = class
  private
    FItems: TObjectList;
    function GetCount: integer;
    function GetRole(Index: Integer): TRole;
  public    
    constructor Create(const AOwnItems: Boolean = True);
    destructor Destroy; override;

    function Add( ARole: TRole ): Integer; overload;
    function Add: TRole; overload;
    function Delete( ARole: TRole ): Boolean;
    function IndexOf(ARolename: string): Integer;

    property Count: integer read GetCount;
    property Items[Index: Integer]: TRole read GetRole; default;
  end;

  { TUser }

  TUser = class
  private
    FID: integer;
    FRoles: TObjectList;
    FUsername: string;
  public
    constructor Create;
    destructor Destroy; override;
    property ID: integer read FID write FID;
    property Username: string read FUsername write FUsername;
    property Roles: TObjectList read FRoles write FRoles;
  end;

  { TUsers }

  TUsers = class
  private
    FItems: TObjectList;
    function GetCount: integer;
    function GetUser(Index: Integer): TUser;
  public
    constructor Create(const AOwnItems: Boolean = True);
    destructor Destroy; override;

    function Add( AUser: TUser ): Integer; overload;
    function Add: TUser; overload;
    function Delete( AUser: TUser ): Boolean;
    function IndexOf(AUsername: string): Integer;

    property Count: integer read GetCount;
    property Items[Index: Integer]: TUser read GetUser; default;
  end;

  { TAssignedRole }

  TAssignedRole = class
  private
    FRecordID: integer;
    FRoleID: integer;
    FRolename: string;
  public
    property RecordID: integer read FRecordID write FRecordID;
    property RoleID: integer read FRoleID write FRoleID;
    property Rolename: string read FRolename write FRolename;
  end;

implementation

{ TUser }

constructor TUser.Create;
begin
  inherited Create;
  FRoles := TObjectList.Create(True);
end;

destructor TUser.Destroy;
begin
  Froles.Free;
  inherited Destroy;
end;

{ TRoles }

function TRoles.GetCount: integer;
begin
  result := FItems.Count;
end;

function TRoles.GetRole(Index: Integer): TRole;
begin
  result := TRole(FItems[Index]);
end;

constructor TRoles.Create(const AOwnItems: Boolean);
begin
  FItems := TObjectList.Create(AOwnItems);
end;

destructor TRoles.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

function TRoles.Add(ARole: TRole): Integer;
begin
  result := FItems.Add(ARole);
end;

function TRoles.Add: TRole;
begin
  result := TRole.Create;
  FItems.Add(result);
end;

function TRoles.Delete(ARole: TRole): Boolean;
begin
  result := FItems.Remove(ARole) > -1;
end;

function TRoles.IndexOf(ARolename: string): Integer;
var
  i, ind: Integer;
  found: boolean;
begin
  found := false;
  result := -1;
  ind := -1;
  for i := 0 to FItems.Count-1 do
  begin
    Inc(ind);
    if TRole(FItems[i]).Rolename=ARolename then
    begin
      found:= true;
      break;
    end;
  end;
  if found then result := ind;
end;

{ TUsers }

function TUsers.GetUser(Index: Integer): TUser;
begin
  Result := TUser(FItems[Index]);
end;

constructor TUsers.Create(const AOwnItems: Boolean);
begin
  FItems := TObjectList.Create(AOwnItems);
end;

destructor TUsers.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

function TUsers.Add(AUser: TUser): Integer;
begin
  result := FItems.Add(AUser);
end;

function TUsers.Add: TUser;
begin
  result := TUser.Create;
  Add(result);
end;

function TUsers.Delete(AUser: TUser): Boolean;
begin
  result := FItems.Remove(AUser) > -1;
end;

function TUsers.IndexOf(AUsername: string): Integer;
var
  i, ind: Integer;
  found: boolean;
begin
  found := false;
  result := -1;
  ind := -1;
  for i := 0 to FItems.Count-1 do
  begin
    Inc(ind);
    if TUser(FItems[i]).Username=AUsername then
    begin
      found:= true;
      break;
    end;
  end;
  if found then result := ind;
end;

function TUsers.GetCount: integer;
begin
  result := FItems.Count;
end;

end.

