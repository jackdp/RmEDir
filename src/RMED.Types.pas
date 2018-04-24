unit RMED.Types;

{$mode objfpc}{$H+}

interface

uses
  Classes;

const
  {$IFDEF CPUX64} APP_BITS_STR = '64'; {$ELSE} APP_BITS_STR = '32'; {$ENDIF}
  {$IFDEF MSWINDOWS} APP_OS = 'Win'; {$ELSE} APP_OS = 'Linux'; {$ENDIF}
  APP_NAME = 'RmEDir';
  APP_VER_STR = '1.0';
  APP_FULL_NAME = APP_NAME + ' version ' + APP_VER_STR + ' [' + APP_OS + ' ' + APP_BITS_STR + '-bit]';
  APP_SHORT_DESC = 'Recursively removes empty subdirectories from the specified directory.';
  APP_DATE = '2018.01.19';
  APP_URL = 'http://www.pazera-software.com/products/rmedir/';
  APP_AUTHOR = 'Jacek Pazera';
  APP_LICENSE = 'Freeware, OpenSource';
  ENDL = sLineBreak;
  DASH_LINE = '--------------------------------------------------------------------------------';

  URL_PSCOM = 'http://www.pazera-software.com';
  URL_APP = APP_URL;

  RECURSE_DEFAULT = 500;

  EXIT_OK = 0;
  EXIT_ERROR = 1;

type

  TAppParams = record
    MyShortName: string;
    UsageStr: string;
    RecurseDepth: integer; // -r, --recurse
    InDir: string;         // input directory
    RemoveSrcDir: Boolean; // -d, --remove-main-dir
    {$IFDEF MSWINDOWS}
    RemoveSpecialDirs: Boolean; // -k, --keep-special-dirs
    {$ENDIF}
  end;

implementation

end.

