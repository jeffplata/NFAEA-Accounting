unit mainForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, ActnList,
  ComCtrls;

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
    StatusBar1: TStatusBar;
    procedure actExitExecute(Sender: TObject);
    procedure actSetdatabaseExecute(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    procedure UpdateConnectedIndicator;

  public

  end;

var
  fmMain: TfmMain;

implementation

uses
  appConnectionU, mainDM;

{$R *.lfm}

{ TfmMain }

procedure TfmMain.actExitExecute(Sender: TObject);
begin
  close;
end;

procedure TfmMain.actSetdatabaseExecute(Sender: TObject);
begin
  dmMain.SetDatabase;
  UpdateConnectedIndicator;
end;

procedure TfmMain.FormActivate(Sender: TObject);
begin
  UpdateConnectedIndicator;
end;

procedure TfmMain.UpdateConnectedIndicator;
begin  
  if dmMain.isConnected then
    StatusBar1.SimpleText := 'Connected'
  else
    StatusBar1.SimpleText:= 'Not connected';
end;

end.

