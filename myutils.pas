unit myUtils;

{$mode objfpc}{$H+}

interface


uses
  Classes, SysUtils;

function IsDirectoryWriteable(const AName: string): Boolean;
function AppDataDirectory: string;

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

end.

