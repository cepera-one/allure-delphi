library AllureDelphi;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  System.SysUtils,
  System.Classes,
  allureDelphiInterface in 'src\allureDelphiInterface.pas',
  allureLifecycle in 'src\allureLifecycle.pas',
  allureCommon in 'src\allureCommon.pas',
  allureConfig in 'src\allureConfig.pas',
  allureDelphiHelper in 'src\allureDelphiHelper.pas',
  allureModel in 'src\allureModel.pas',
  allureThreadSafeList in 'src\allureThreadSafeList.pas',
  allureFileSystemResultsWriter in 'src\allureFileSystemResultsWriter.pas';

{$R *.res}

begin
end.
