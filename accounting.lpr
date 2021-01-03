program accounting;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, mainForm, appConnectionU, mainDM, myUtils, changedatabaseform,
  pascalscript, appUserU, UserLoginForm, hilogeneratorU, UserManagerForm,
  UserManagerU, user_BOM;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TdmMain, dmMain);
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.

