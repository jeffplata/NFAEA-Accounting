unit mainForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, ActnList;

type

  { TfmMain }

  TfmMain = class(TForm)
    actExit: TAction;
    actAbout: TAction;
    actSetdatabase: TAction;
    ActionList1: TActionList;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    Setdatabase1: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem3: TMenuItem;
    procedure actExitExecute(Sender: TObject);
  private

  public

  end;

var
  fmMain: TfmMain;

implementation

uses
  appConnectionU;

{$R *.lfm}

{ TfmMain }

procedure TfmMain.actExitExecute(Sender: TObject);
begin
  close;
end;

end.

