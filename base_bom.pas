unit base_BOM;

{$mode delphi}{$H+}

interface

uses
  SysUtils, TypInfo, generics.Collections;

type
  TEditState = (esNone, esInserted, esEdited, esDeleted);

const
  EDIT_STATE_NAMES: array[TEditState] of string =
    (
      'None'
      , 'Inserted'
      , 'Edited'
      , 'Deleted'
    ) ;

type

  { TBaseBOM }

  TBaseBOM = class
  private
    FEditState: TEditState;
    FID: integer;
    FIsSystem: Integer;
    function GetIsNew: Boolean;
  public
    constructor Create(AppendMode: Boolean=False);
    procedure Assign(src: TBaseBOM);
    procedure Mark(AEditState: TEditState = esEdited);
  published
    property EditState: TEditState read FEditState write FEditState;
    property ID: integer read FID write FID;
    property IsSystem: Integer read FIsSystem write FIsSystem;
    property IsNew: Boolean read GetIsNew;
  end;


  { TBaseBOMList }

  TBaseBOMList<T:TBaseBOM> = class
  private
    function GetCount: integer;
    function GetItem(Index: Integer): T;
  protected   
    FItems: TObjectList<T>;
    FDeletedItems: TObjectList<T>;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(NewItem: T=Default(T)): T;
    function Delete(Index: Integer): Boolean;
    function Find(APropertyName: string; const AValue: variant): Integer;    
    property Count: integer read GetCount;
    property Items[Index: Integer]: T read GetItem; default;
  end;

implementation

{ TBaseBOMList }

function TBaseBOMList<T>.GetCount: integer;
begin
  Result := FItems.Count;
end;

function TBaseBOMList<T>.GetItem(Index: Integer): T;
begin
  Result := FItems[Index];
end;

constructor TBaseBOMList<T>.Create;
begin     
  inherited Create;
  FItems := TObjectList<T>.Create(true);
  FDeletedItems := TObjectList<T>.Create(true);
end;

destructor TBaseBOMList<T>.Destroy;
begin
  FDeletedItems.Free;
  FItems.Free;
  inherited Destroy;
end;

function TBaseBOMList<T>.Add(NewItem: T): T;
begin   
  if NewItem = Default(T) then
    result := T.Create
  else
    result := NewItem;
  FItems.Add(result);
end;

function TBaseBOMList<T>.Delete(Index: Integer): Boolean;
var
  o: T;
begin
  if not FItems[Index].IsNew then
  begin
    o := T.Create;
    o.Assign(FItems[Index]);
    FDeletedItems.Add(o);
  end;
  FItems.Delete(Index); // error if index not valid
  result := true;
end;

function TBaseBOMList<T>.Find(APropertyName: string; const AValue: variant
  ): Integer;
var
  value : Variant;
  PropList: PPropList;
  PropCount, i: integer;
  PropExist: Boolean;
begin
  Result := -1;

  PropExist:= False;
  PropCount := GetPropList(T, PropList);
  try
    for i := 0 to PropCount-1 do
      if CompareText(PropList[i].Name, APropertyName) = 0 then
      begin
        PropExist := True;
        break;
      end;
  finally
    Freemem(PropList);
  end;

  if PropExist then
  begin
    for i := 0 to FItems.Count-1 do
    begin
      value := GetStrProp(FItems[i], APropertyName);
      if value = AValue then
      begin
        Result := i;
      end;
    end;
  end
  else
    Raise Exception.Create(Format('Property name ''%s'' not found.',[APropertyName]));
end;

{ TBaseBOM }

function TBaseBOM.GetIsNew: Boolean;
begin
  Result := self.EditState = esInserted;
end;

constructor TBaseBOM.Create(AppendMode: Boolean);
begin
  inherited Create;
  if AppendMode then
    FEditState:= esInserted
  else
    FEditState:= esNone;
  FIsSystem:= 0; //False
end;

procedure TBaseBOM.Assign(src: TBaseBOM);
begin
  with src do
  begin
    self.ID:= src.ID;
    self.EditState:= src.EditState;
    self.IsSystem:= src.IsSystem;
  end;
end;

procedure TBaseBOM.Mark(AEditState: TEditState);
begin
  if self.EditState <> esInserted then
    self.EditState:= AEditState;
end;


end.

