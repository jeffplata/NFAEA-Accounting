unit RoleEditForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ActnList;

type

  { TfrmRole }

  TfrmRole = class(TForm)
    actOk: TAction;
    ActionList1: TActionList;
    btnCancel: TButton;
    btnOk: TButton;
    edtRolename: TLabeledEdit;
    edtLabel: TLabeledEdit;
  private
    FNewRecord: boolean;

  public
    property NewRecord: boolean read FNewRecord write FNewRecord;
    class function GetInput(var ARoleName, ALabel: string; const isNew: boolean = False): boolean;

  end;

var
  frmRole: TfrmRole;

implementation

{$R *.lfm}

{ TfrmRole }



class function TfrmRole.GetInput(var ARoleName, ALabel: string;
  const isNew: boolean): boolean;
var
  aTitle: String;
begin
  aTitle := ' role';
  if isNew then aTitle := 'New' + aTitle
  else
    aTitle := 'Edit'+ aTitle;
  Result := False;
  with TfrmRole.Create(Application) do
  try
    if not isNew then
    begin
      edtRolename.Text := ARoleName;
      edtRolename.enabled := False;
      edtLabel.Text := ALabel;
    end;
    Caption := aTitle;
    if ShowModal = mrOk then
    begin
      ARolename := edtRolename.Text;
      ALabel := edtLabel.Text;
      Result := True;
    end;
  finally
    Free;
  end;
end;

end.

