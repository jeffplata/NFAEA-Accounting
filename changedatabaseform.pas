unit changedatabaseform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ActnList, Buttons, uGifViewer, uPSComponent;

type

  TConnectCallback = function(s, d, u, p: string): Boolean of object;

  { TfrmChangeDatabase }

  TfrmChangeDatabase = class(TForm)
    actBrowse: TAction;
    actOk: TAction;
    ActionList1: TActionList;
    btnOk: TButton;
    btnCancel: TButton;
    edtServer: TLabeledEdit;
    edtDatabase: TLabeledEdit;
    edtUser: TLabeledEdit;
    edtPass: TLabeledEdit;
    GIFViewer1: TGIFViewer;
    Label1: TLabel;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    SpeedButton1: TSpeedButton;
    procedure actBrowseExecute(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public
    ConnectCallback: TConnectCallback;
  end;

var
  frmChangeDatabase: TfrmChangeDatabase;

implementation

uses myUtils;

{$R *.lfm}

{ TfrmChangeDatabase }

procedure TfrmChangeDatabase.actOkUpdate(Sender: TObject);
begin          
  (sender as TAction).Enabled:= (edtServer.Text <> '') and
    (edtDatabase.Text <> '') and
    (edtUser.Text <> '') and
    (edtPass.Text <> '');
end;

procedure TfrmChangeDatabase.FormCreate(Sender: TObject);
begin
  OpenDialog1.InitialDir:= AppDataDirectory;
end;

procedure TfrmChangeDatabase.actOkExecute(Sender: TObject);
var
  s, d, u, p: string;
begin
  s := edtServer.Text;
  d := edtDatabase.Text;
  u := edtUser.Text;
  p := edtPass.Text;
  try          
    panel1.Visible:= true;
    Update;
    if ConnectCallback(s,d, u, p) then
      ModalResult:= mrOk;
  finally
    panel1.Visible:= false;
    Update;
  end;
end;

procedure TfrmChangeDatabase.actBrowseExecute(Sender: TObject);
begin
  // open fileopen dialog
  with OpenDialog1 do
  begin
    if Execute then
      edtDatabase.text := FileName;
    if edtServer.Text ='' then
      edtServer.text := 'localhost';
    edtUser.SetFocus;
  end;
end;

end.

