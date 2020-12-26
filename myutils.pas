unit myUtils;

{$mode objfpc}{$H+}

interface


uses
  Classes, SysUtils, BlowFish;

function IsDirectoryWriteable(const AName: string): Boolean;
function AppDataDirectory: string;
function AppConfigFilename: string;
function EncryptString(aString:string):string;  
function DecryptString(aString:string):string;

const
  BRK = '/BRK/';

implementation

uses
  Windows, FileUtil, LazFileUtils, WinDirs, Forms;


function IsDirectoryWriteable(const AName: string): Boolean;
var
  FileName: String;
  H: THandle;
begin
  FileName := IncludeTrailingPathDelimiter(AName) + 'chk.tmp';
  H := CreateFile(PChar(FileName), GENERIC_READ or GENERIC_WRITE, 0, nil,
    CREATE_NEW, FILE_ATTRIBUTE_TEMPORARY or FILE_FLAG_DELETE_ON_CLOSE, 0);
  Result := H <> INVALID_HANDLE_VALUE;
  if Result then CloseHandle(H);
end;

function AppDataDirectory: string;
begin
  // try application install dir
  Result := AppendPathDelim(ProgramDirectory);
  ForceDirectories(Result);
  if not IsDirectoryWriteable(Result) then
  begin
    // try windows appdata/local folder
    Result := GetAppConfigDir(False);
    ForceDirectories(Result);
    if not IsDirectoryWriteable(Result) then
    begin
      // try user documents folder
      Result := AppendPathDelim(GetWindowsSpecialDir(CSIDL_PERSONAL)+
        ExtractFileNameOnly(Application.ExeName));
      ForceDirectories(Result);
      if not IsDirectoryWriteable(Result) then
        Result := '';
      // TODO: if it still fails, ask help from user
    end;
  end;
end;

function AppConfigFilename: string;
begin
  Result := ExtractFileNameOnly(Application.ExeName)+'.cfg';
end;

function EncryptString(aString: string): string;
var Key:string;
    EncrytpStream:TBlowFishEncryptStream;
    StringStream:TStringStream;
    EncryptedString:string;
begin
  Key := 'your_secret_encryption_key';
  StringStream := TStringStream.Create('');
  EncrytpStream := TBlowFishEncryptStream.Create(Key,StringStream);
  EncrytpStream.WriteAnsiString(aString);
  EncrytpStream.Free;
  EncryptedString := StringStream.DataString;
  StringStream.Free;
  EncryptString := EncryptedString;
end;

function DecryptString(aString: string): string;
var Key:string;
    DecrytpStream:TBlowFishDeCryptStream;
    StringStream:TStringStream;
    DecryptedString:string;
begin
  Key := 'your_secret_encryption_key';
  StringStream := TStringStream.Create(aString);
  DecrytpStream := TBlowFishDeCryptStream.Create(Key,StringStream);
  DecryptedString := DecrytpStream.ReadAnsiString;
  DecrytpStream.Free;
  StringStream.Free;
  DecryptString := DecryptedString;
end;

end.
