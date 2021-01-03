unit UserManagerU;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type

  { TUserManager }

  TUserManager = class(TObject)

  public
    procedure OpenForm;
  end;

implementation

uses UserManagerForm;

{ TUserManager }

procedure TUserManager.OpenForm;
begin
  TfrmUserManager.Open;
end;

end.

