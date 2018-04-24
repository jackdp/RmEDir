unit RMED.Main;

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF MSWINDOWS} ShellApi, {$ENDIF}
  Classes, SysUtils, LazFileUtils,
  JPL.Strings, JPL.Conversion, JPL.FileSearch,
  JPL.CmdLineParser,
  RMED.Types;


var
  AppParams: TAppParams;


procedure Init;
procedure Run;
procedure Done;

procedure DisplayShortUsage;
procedure DisplayNameVersion(bExitApp: Boolean);
procedure ExitApp(Msg: string = ''; ExitCode: integer = EXIT_OK);
procedure ExitAppWithShortUsage(Msg: string = '');
procedure DisplayHelp;
procedure DisplayExamples;
function LastParam: string;

procedure ParseRunParams;

procedure RemoveEmptyDirs;
function RemoveOneDir(const Dir: string; var ErrStr: string): Boolean;
function CountFilesAndFolders(const Dir: string): integer;





implementation



procedure Init;
begin
  AppParams.MyShortName := ExtractFileName(ParamStr(0));
  AppParams.UsageStr := '';

  AppParams.RecurseDepth := RECURSE_DEFAULT;
  AppParams.InDir := '';
  AppParams.RemoveSrcDir := False;
  {$IFDEF MSWINDOWS}
  AppParams.RemoveSpecialDirs := True;
  {$ENDIF}
end;

procedure Done;
begin
  // No global objects, so there is nothing to clean.
end;



{$region '           DisplayShortUsage          '}
procedure DisplayShortUsage;
begin
  Writeln(
    'Usage: ', AppParams.MyShortName,
    ' [-r=X] [-d]' +
    {$IFDEF MSWINDOWS} ' [-k]' + {$ENDIF}
    ' [-h] [-V]' +
    {$IFDEF MSWINDOWS} ' [--home]' + {$ENDIF}
    ' Directory'
  );
  Writeln;
  Writeln('Mandatory arguments to long options are mandatory for short options too.');
  Write('Options are case-sensitive. ');
  Writeln('Options in square brackets are optional.');
  Writeln('The last parameter must be the name of an existing directory.');
  //Writeln(DASH_LINE);
  Writeln;
end;
{$endregion}

{$region '             DisplayNameVersion            '}
procedure DisplayNameVersion(bExitApp: Boolean);
begin
  Writeln(APP_FULL_NAME, ' (', APP_DATE, ')');
  Writeln(APP_SHORT_DESC);
  Writeln(APP_AUTHOR, ', ', APP_URL);
  if bExitApp then ExitApp('', EXIT_OK);
end;
{$endregion}

procedure ExitApp(Msg: string = ''; ExitCode: integer = EXIT_OK);
begin
  if Msg <> '' then Writeln(Msg);
  Halt(ExitCode);
end;

procedure ExitAppWithShortUsage(Msg: string = '');
begin
  if Msg <> '' then Writeln(Msg + ENDL);
  DisplayShortUsage;
  ExitApp('Try "' + AppParams.MyShortName + ' --help" for more info.', EXIT_ERROR);
end;

function LastParam: string;
begin
  Result := ParamStr(ParamCount);
end;


{$region '             DisplayHelp / Examples               '}
procedure DisplayHelp;
begin
  DisplayNameVersion(False);
  Writeln;
  DisplayShortUsage;
  Writeln(AppParams.UsageStr);
  DisplayExamples;
  ExitApp('', EXIT_OK);
end;

procedure DisplayExamples;
var
  s: string;
begin
  {$IFDEF MSWINDOWS} s := 'D:\SomeDir'; {$ELSE} s := '\home\user\some_dir\'; {$ENDIF}
  Writeln;
  Writeln('Examples:');
  Writeln;
  Writeln('Delete all empty subdirectories from "' + s + '", but do not delete "' + s + '" even if it is empty:');
  Writeln('  ' + AppParams.MyShortName + ' ' + s);
  Writeln;
  Writeln('Delete all empty subdirectories from "' + s + '", and delete "' + s + '" if it is empty.');
  Writeln('  ' + AppParams.MyShortName + ' -d ' + s);
  Writeln;
  Writeln('Remove all empty subdirectories from the current directory.');
  Writeln('  ' + AppParams.MyShortName + ' .\');
end;
{$endregion DisplayHelp / Examples}


{$region '             ParseRunParams              '}
procedure ParseRunParams;
const
  MAX_LINE_LEN = 102;
var
  Cmd: TJPCmdLineParser;
  s, sErr, Category: string;
  x: integer;
begin

  Cmd := TJPCmdLineParser.Create;
  try

    Cmd.CommandLineParsingMode := cpmDelphi; // cpmCustom;
    Cmd.UsageFormat := cufWget;


    Category := 'main';


    Cmd.RegisterOption(
      'r', 'recurse', cvtRequired, False, False,
      'Recursively removes empty directories up to level X in the directory structure (default X=' + itos(RECURSE_DEFAULT) + ').',
      'X', Category
    );

    Cmd.RegisterOption('d', 'remove-main-dir', cvtNone, False, False, 'Also removes the input directory given on the command line (if empty).', '', Category);
    {$IFDEF MSWINDOWS}
    Cmd.RegisterOption(
      'k', 'keep-special-dirs', cvtNone, False, False,
      'By default, the program deletes empty directories with the "Read-only",    "Hidden" and "System" attributes set. ' +
      'If you want to keep such directories, use this option.',
      '', Category
    );
    {$ENDIF}

    Cmd.RegisterOption('h', 'help', cvtNone, False, False, 'Show this help.', '', Category);
    Cmd.RegisterShortOption('?', cvtNone, False, True, '', '', '');
    Cmd.RegisterOption('V', 'version', cvtNone, False, False, 'Show application version.', '', Category);

    {$IFDEF MSWINDOWS}
    Cmd.RegisterLongOption('home', cvtNone, False, False, 'Opens program home page in the default browser.', '', Category);
    {$ENDIF}

    AppParams.UsageStr := 'Available options:' + ENDL + Cmd.OptionsUsageStr('  ', 'main', MAX_LINE_LEN, '  ', 30);


    //////////////////////
    Cmd.Parse;
    //////////////////////


    // Show help and exit
    if (ParamCount = 0) or (Cmd.IsLongOptionExists('help')) or (Cmd.IsOptionExists('?')) then
    begin
      Cmd.Free;
      DisplayHelp;
    end;

    // Display version nad exit
    if Cmd.IsOptionExists('version') then
    begin
      Cmd.Free;
      DisplayNameVersion(True);
    end;

    {$IFDEF MSWINDOWS}
    // Open program home page and exit
    if Cmd.IsLongOptionExists('home') then
    begin
      Cmd.Free;
      ShellExecute(0, 'open', APP_URL, '', '', 5); // SW_SHOW = 5
      ExitApp('', EXIT_OK);
    end;
    {$ENDIF}


    // Recurse subdirectories
    if Cmd.IsOptionExists('r') then
    begin
      s := Trim(Cmd.GetOptionValue('r', itos(RECURSE_DEFAULT)));
      if s = '' then s := itos(RECURSE_DEFAULT);
      sErr := 'Invalid recurse depth value: ' + s + '. Should be a non-negative integer.';
      if not TryStrToInt(s, x) then ExitAppWithShortUsage(sErr); { TODO : Przed ExitAppWithShortUsage trzeba zwolnić Cmd }
      if x < 0 then
      begin
        Cmd.Free;
        ExitAppWithShortUsage(sErr);
      end;
      AppParams.RecurseDepth := x;
    end;


    // Input directory
    AppParams.InDir := ExpandFileName(LastParam);
    if (not DirectoryExists(AppParams.InDir)) or (Trim(AppParams.InDir) = '') then
    begin
      Cmd.Free;
      sErr := 'The last parameter should be the name of an existing directory.';
      ExitAppWithShortUsage(sErr);
    end;

    {$IFDEF MSWINDOWS}
    // Keep special folders
    if Cmd.IsOptionExists('k') then AppParams.RemoveSpecialDirs := False;
    {$ENDIF}

    // Remove source directory
    if Cmd.IsOptionExists('d') then AppParams.RemoveSrcDir := True;

  finally
    if Assigned(Cmd) then Cmd.Free;
  end;
end;
{$endregion ParseRunParams}


function CountFilesAndFolders(const Dir: string): integer;
var
  sl: TStringList;
  x: integer = 0;
begin
  sl := TStringList.Create;
  try
    JPGetFileList('*', Dir, sl, 0, True, True, nil, nil, nil);
    x := sl.Count;
    sl.Clear;
    JPGetDirectoryList(Dir, sl, True, 0, nil);
    x += sl.Count;
    Result := x;
  finally
    sl.Free;
  end;
end;

function RemoveOneDir(const Dir: string; var ErrStr: string): Boolean;
{$IFDEF MSWINDOWS}
var
  xa: LongInt;
{$ENDIF}
begin
  { TODO : Dodać ErrStr := ''; }
  try
    {$IFDEF MSWINDOWS}
    if AppParams.RemoveSpecialDirs then
    begin
      xa := FileGetAttr(AddUncPrefix(Dir));
      if xa <> -1 then
      begin
        xa := xa and (not faReadOnly) and (not faSysFile{%H-}) and (not faHidden{%H-});
        FileSetAttr(AddUncPrefix(Dir), xa);
      end;
    end;
    {$ENDIF}

    // Windows: RemoveDir calls RemoveDirectoryW with Dir as lpPathName
    // https://msdn.microsoft.com/en-us/library/windows/desktop/aa365488(v=vs.85).aspx

    RemoveDir(AddUncPrefix(Dir));

    ///////////////

    Result := not DirectoryExists(AddUncPrefix(Dir));
  except
    on E: Exception do
    begin
      Result := False;
      ErrStr := E.Message;
    end;
  end;
end;

{$region '                                    RemoveEmptyDirs                                  '}
procedure RemoveEmptyDirs;
var
  slDirs: TStringList;
  i, xFiles: integer;
  Dir, ErrStr: string;
  xEmptyDirs: integer = 0;
  xRemoved: integer = 0;
  xErrCount: integer = 0;
  xAllDirs: integer = 0;
  b: Boolean;
begin
  slDirs := TStringList.Create;
  try
    JPGetDirectoryList(AppParams.InDir, slDirs, True, AppParams.RecurseDepth, nil);

    slDirs.Sort;
    if AppParams.RemoveSrcDir then slDirs.Insert(0, AppParams.InDir);

    xAllDirs := slDirs.Count;

    for i := slDirs.Count - 1 downto 0 do
    begin

      Dir := slDirs[i];
      xFiles := CountFilesAndFolders(Dir);
      if xFiles > 0 then Continue;

      Inc(xEmptyDirs);

      Write('Removing directory: ' + qs(Dir));

      { TODO : Dodać ErrStr := ''; }
      try
        b := RemoveOneDir(Dir, ErrStr);
      finally
        if b then
        begin
          Writeln(' ... OK');
          Inc(xRemoved);
        end
        else
        begin
          Writeln(' ... FAILED');
          if ErrStr <> '' then Writeln(ErrStr);
          Inc(xErrCount);
        end;
      end;


    end; // for i


  finally
    slDirs.Free;
    if xRemoved > 0 then Writeln;
    Writeln('All directories: ' + itos(xAllDirs));
    Writeln('Empty directories: ' + itos(xEmptyDirs));
    Writeln('Removed directories: ' + itos(xRemoved));
    if xErrCount > 0 then Writeln('Errors: ' + itos(xErrCount));
    if xErrCount > 0 then ExitCode := EXIT_ERROR;
  end;
end;
{$endregion RemoveEmptyDirs}




{$endregion ParseRunParams}


procedure Run;
begin
  ParseRunParams;
  RemoveEmptyDirs;
end;

end.

