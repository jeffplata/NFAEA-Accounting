unit hilogeneratorU;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, appConnectionU;

const
  // 2,147,483,647 = max integer value
  // (214,748 * 10,000) = 2,147,480,000 max value
  MAX_LO = 10000;
  MAX_HI = 214748;

type

  THiloType = Integer;

  { THiloGenerator }

  THiloGenerator = class(TObject)
  private
    current_lo, current_hi, start_value: THiloType;
    FCurrentValue: THiloType;
    config_file: string;
    FConnection: TAppConnection;
    procedure LoadValues(Aconfigfile: string);
    function get_next_hi: THiloType;
  public
    function NextValue: THiloType;
    constructor Create;
    destructor Destroy; override;
    procedure SaveValues;
    property Connection: TAppConnection read FConnection write FConnection;
    property CurrentValue: THiloType read FCurrentValue write FCurrentValue;
  end;  

var
  HiLoGenerator: THiloGenerator;


implementation

uses IniFiles, myUtils, SQLDB, Dialogs;

{ THiloGenerator }

procedure THiloGenerator.LoadValues(Aconfigfile: string);
var
  dbval: integer;
begin
  with TIniFile.create(Aconfigfile) do
  try
    current_hi := ReadInteger('hilo','hi',0);
    current_lo := ReadInteger('hilo','lo',0);
  finally
    Free;
  end;

  //validate with database, just in case
  if current_hi > 0 then
  begin
    with TSQLQuery.Create(nil) do
    try
      Database := AppConnection.Connection;
      sql.add('select gen_id(GEN_HILO,0) from rdb$database;');
      try
        Open;
        dbval := Fields[0].AsInteger;
        AppConnection.Transaction.CommitRetaining;
        if dbval < current_hi then
          //not in sync, db prevails, fetch new hi
          current_hi := 0;
      except
        AppConnection.Transaction.RollbackRetaining;
        current_hi := 0;
      end;
    finally
      Free;
    end;
  end;
end;

function THiloGenerator.get_next_hi: THiloType;
begin
  Result := 0;
  with TSQLQuery.Create(nil) do
  try
    DataBase:= AppConnection.Connection;
    sql.add('select gen_id(GEN_HILO,1) from rdb$database;');
    try
      Open;
      First;
      Result := Fields[0].AsInteger;
      AppConnection.Transaction.CommitRetaining;
    except
      on e: exception do
        AppConnection.Transaction.RollbackRetaining;
    end;
    if Result = 0 then
    begin
      sql.Clear;
      sql.add('CREATE GENERATOR GEN_HILO;');
      ExecSQL;         
      sql.Clear;
      sql.add('SET GENERATOR GEN_HILO TO 1;');
      ExecSQL;
      try
        ExecSQL;
        Result := 1;  
        AppConnection.Transaction.CommitRetaining;
      except     
        AppConnection.Transaction.RollbackRetaining;
      end;
    end;
  finally
    Free;
  end;
  if result = 0 then
    MessageDlg('HiLoGenerator: get_next_hi failed.',mtError,[mbOK],0)
  else if result >= MAX_HI then
    MessageDlg('HiLoGenerator: MAX_HI hit. Time to panic!',mtError,[mbOK],0);
end;

function THiloGenerator.NextValue: THiloType;
begin
  Result := 0;

  if (current_hi = 0) or (current_lo >= MAX_LO) then
  begin
    current_hi := get_next_hi;
    current_lo := 0;
  end;

  //todo: improve this code
  if current_hi > 0 then
  begin
    Result := current_hi * MAX_LO + current_lo;
    CurrentValue:= Result;
    current_lo := current_lo + 1;
  end

end;

constructor THiloGenerator.Create;
begin
  inherited Create;
  if AppConnection = nil then
    MessageDlg('HiLoGenerator: No database connection.',mtError,[mbOk],0);
  FConnection := AppConnection;

  config_file:= ChangeFileExt(AppDataDirectory + AppConfigFilename, '.fcr');
  LoadValues(config_file);
  start_value := current_hi * MAX_LO + current_lo;
  FCurrentValue:= start_value;

  HiLoGenerator := Self;

end;

destructor THiloGenerator.Destroy;
begin
  SaveValues;
  inherited Destroy;
end;

procedure THiloGenerator.SaveValues;
begin
  if start_value = (current_hi * MAX_LO + current_lo) then
    exit;
  with TIniFile.create(config_file) do
  try
    WriteString('hilo','hi',IntToStr(current_hi));
    WriteString('hilo','lo',IntToStr(current_lo));
  finally
    Free;
  end;
  start_value:= current_hi * MAX_LO + current_lo;
end;

//initialization
//  HiLoGenerator := THiloGenerator.Create;
//
//finalization
//  HiLoGenerator.Free;
//
end.

