program rmedir;

{$mode objfpc}{$H+}

{$IFDEF MSWINDOWS}
{$SetPEFlags $1} // IMAGE_FILE_RELOCS_STRIPPED
{$SetPEFlags $20} // IMAGE_FILE_LARGE_ADDRESS_AWARE

{$APPTYPE CONSOLE}
{$ENDIF}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils,
  RMED.Main, RMED.Types
  ;

{$R *.res}

begin

  try

    Init;
    Run;
    Done;

  except
    on E: Exception do Writeln(E.ClassName, ': ', E.Message);
  end;

end.

