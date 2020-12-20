unit appUserUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type

  { TAppUser }

  TAppUser = class(TObject)

  private
    FLoggedin: Boolean;
    FUsername: string;

  public
    constructor Create(AOwner: TComponent);
    property Username: string read FUsername write FUsername;
    property Loggedin: Boolean read FLoggedin write FLoggedin;
    function Login(user, pass: string): Boolean;
  end;

var
  AppUser: TAppUser;

implementation


{ TAppUser }

constructor TAppUser.Create(AOwner: TComponent);
begin
  inherited Create;
end;

function TAppUser.Login(user, pass: string): Boolean;
begin
  Result := False;
  FUsername:= user;
end;

initialization
  AppUser := TAppUser.Create(nil);

finalization
  AppUser.Free;

end.

