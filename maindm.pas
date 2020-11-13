unit mainDM;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type

  { TdmMain }

  TdmMain = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
  private

  public

  end;

var
  dmMain: TdmMain;

implementation

uses
  appConnectionU;

{$R *.lfm}

{ TdmMain }

procedure TdmMain.DataModuleCreate(Sender: TObject);
begin
  writeln('Project Options.../ Compiler Options/ Config and Target/ Win32...');
  writeln('Debug / Development only; disable in Production.');
  writeln;
  AppConnection.Connect();
end;

end.

