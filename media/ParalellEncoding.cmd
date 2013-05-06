@echo off
setlocal enableextensions,disabledelayedexpansion
:: ParallelEncoding
:: Version 1.5
:: By A Hoser

:: script input
set _InputAviSynthScript="%~f1"
set _OutputAviSynthScript=%~f2
set _LosslessOutputPathPE=%~f3
if defined _LosslessOutputPathPE (
  set _TEMPDIR=%~f3
)

:: user params
set _AVS2AVIPathPE="C:\bin\avs2avi.exe"
set _X264PathPE="C:\Encoding\Codecs\CLI\x264\x264.1251.exe"
set _TotalThreads=4
set _AviSynthMemoryPerThread=512
set _LosslessCodec4CC=FFVH
set _ProcessPriority=Low

set _X264ExtraParameters=--ref 1 --no-deblock --no-cabac --subme 1 --partitions none --me dia --aq-mode 0 --no-mbtree

:: override script parameters from env vars in Nichorai script
if defined _PARALELLINPUTAVS (
  set _InputAviSynthScript="%_PARALELLINPUTAVS:"=%"
)
if defined _PARALELLOUTPUTAVS (
  set _OutputAviSynthScript="%_PARALELLOUTPUTAVS:"=%"
)
if defined _LOSSLESSOUTPUTPATH (
  set _LosslessOutputPathPE="%_LOSSLESSOUTPUTPATH:"=%"
)
if defined _PARALELLOUTPUTFILE (
  set _ThreadedLosslessFile="%_PARALELLOUTPUTFILE:"=%"
)
if defined _AVS2AVIPATH (
  set _AVS2AVIPathPE="%_AVS2AVIPATH:"=%"
)
if defined _X264PATH (
  set _X264PathPE="%_X264PATH:"=%"
)
if defined _PARALELLX264SETTINGS (
  set _X264ExtraParameters=%_PARALELLX264SETTINGS%
)
if defined _THREADS (
  set _TotalThreads=%_THREADS%
)
if defined _MEMPERTHREAD (
  set _AviSynthMemoryPerThread=%_MEMPERTHREAD%
)
if defined _LOSSLESSCODEC (
  set _LosslessCodec4CC=%_LOSSLESSCODEC%
)
if defined _PPRIORITY (
  set _ProcessPriority=%_PPRIORITY%
)


:: initial test
if not exist %_InputAviSynthScript% (
  echo. No input AviSynth Script specified.
  echo. Script quitting.
  pause
  exit /B 1
)


:: script vars
set _ScriptFile="%~f0"
for %%G in (%_ScriptFile%) do (
  set _ScriptDir="%%~dpG."
)
if defined _PROJECTEP (
  rem.override from nichorai script
  set _ProjectName="%_PROJECTEP:"=%"
) else (
  for %%G in (%_InputAviSynthScript%) do (
    set _ProjectName="%%~nG"
  )
)

if defined _TEMPDIR (
  rem.override from nichorai script
  set _ScriptsOutputPath="%_TEMPDIR:"=%\ParallelEncoding"
) else (
  set _ScriptsOutputPath="%_ScriptDir:"=%\%_ProjectName:"=%"
)
set _TempPath="%_ScriptsOutputPath:"=%\Temp"
if not defined _LosslessOutputPathPE (
  set _LosslessOutputPathPE="%_ScriptsOutputPath:"=%\Lossless"
)

if defined _LOGFILE (
  rem.override from nichorai script
  set _GeneralLogFile="%_LOGFILE:"=%"
) else (
  set _GeneralLogFile="%_TempPath:"=%\LogFile.log"
)
set _AVS2AVISettingsFile="%_TempPath:"=%\avs2avi.codec.settings"
set _ThreadedLogFile="%_TempPath:"=%\avs2avi.[NUM].thread.log"
set _VersionAVS="%_TempPath:"=%\Version.avs"
set _RegistryFile="%_TempPath:"=%\RegSettings.reg"
set _RegistryBackupFile="%_TempPath:"=%\RegBackupSettings.reg"
set _LagarithBackupINI="%_TempPath:"=%\lagarith.backup.ini"

set _ThreadedBatchFile="%_ScriptsOutputPath:"=%\[NUM].thread.cmd"
set _ThreadedAviSynthScript="%_ScriptsOutputPath:"=%\[NUM].thread.avs"
if not defined _OutputAviSynthScript (
  set _OutputAviSynthScript="%_ScriptsOutputPath:"=%\joined.avs"
)

if not defined _ThreadedLosslessFile (
  if /I [%_LosslessCodec4CC%]==[x264] (
    set _ThreadedLosslessFile="%_LosslessOutputPathPE:"=%\%_ProjectName:"=%.%_LosslessCodec4CC%.thread.[NUM].mp4"
  ) else (
    set _ThreadedLosslessFile="%_LosslessOutputPathPE:"=%\%_ProjectName:"=%.%_LosslessCodec4CC%.thread.[NUM].avi"
  )
)

set _LagarithINI="%WINDIR:"=%\lagarith.ini"
set _FFDSEncRegistryPath=HKCU\Software\GNU\ffdshow_enc




:: remove old scripts and files before script is run
rmdir /S /Q %_ScriptsOutputPath% >NUL 2>&1

:: check to make sure dirs exist
for %%G in (_ScriptsOutputPath,_TempPath,_LosslessOutputPathPE) do (
  setlocal enabledelayedexpansion
  call set _nul.dir=%%%%G%%\NUL
  set _nul.dir=!_nul.dir:"=!
  if not exist !_nul.dir! (
    call mkdir %%%%G%% >NUL 2>&1
  )
  endlocal
)

:: create trimmed scripts
echo. Creating trimmed scripts.
for /L %%G in (1,1,%_TotalThreads%) do (
  set _CurrentThread=%%G
  call set _NewThreadScript=%%_ThreadedAviSynthScript:[NUM]=%%G%%
  call :ParallelAviSynthScript _NewThreadScript,_InputAviSynthScript,_AviSynthMemoryPerThread,_TotalThreads,_CurrentThread
)

:: create avs2avi codec settings file
if /I [%_LosslessCodec4CC%]==[x264] (
  set _X264Parameters=%_X264ExtraParameters% --qp 0 --threads 1 --thread-input
) else (
  echo. Generating codec settings for avs2avi.
  call :GetAVS2AVICodecSettings _AVS2AVISettingsFile
  set _AVS2AVISwitches=-l %_AVS2AVISettingsFile% -w
)

:: create cmd batch files
call :CreateCMDBatches

echo. Encoding %_TotalThreads% scripts to %_LosslessCodec4CC%.
cd %_ScriptsOutputPath%
call %_CMDBatchLine:"=%

:: create joined lossless script
echo. Generating joined script.
call :JoinedAviSynthScript _OutputAviSynthScript,_ThreadedLosslessFile,_AviSynthMemoryPerThread,_TotalThreads

echo. Done.
pause
endlocal
exit /B
goto :eof main script over




:ParallelAviSynthScript creates trimmed files for parallel encoding
setlocal disabledelayedexpansion
call set _PAS.OutputAviSynthScript=%%%1%%
call set _PAS.MainAviSynthScript=%%%2%%
call set _PAS.AviSynthMemoryPerThread=%%%3%%
call set _PAS.TotalThreads=%%%4%%
call set _PAS.ThreadNumber=%%%5%%

set /A _PAS.ThreadMultiplier=_PAS.ThreadNumber-1

>%_PAS.OutputAviSynthScript%	echo.SetMemoryMax(%_PAS.AviSynthMemoryPerThread%)
>>%_PAS.OutputAviSynthScript%	echo.Import(%_PAS.MainAviSynthScript%)
>>%_PAS.OutputAviSynthScript%	echo.start = (FrameCount() / %_PAS.TotalThreads%) * %_PAS.ThreadMultiplier%
if %_PAS.ThreadNumber% EQU %_PAS.TotalThreads% (
  >>%_PAS.OutputAviSynthScript%	echo.end = FrameCount(^)
) else (
  >>%_PAS.OutputAviSynthScript%	echo.end = start + (FrameCount(^) / %_PAS.TotalThreads%^) + 100
)
>>%_PAS.OutputAviSynthScript%	echo.Trim(start,end)

endlocal
goto :eof


:JoinedAviSynthScript joins lossless files from parallel encoding
setlocal disabledelayedexpansion
call set _JAS.OutputAviSynthScript=%%%1%%
call set _JAS.LosslessFile=%%%2%%
call set _JAS.AviSynthMemoryPerThread=%%%3%%
call set _JAS.TotalThreads=%%%4%%

>%_JAS.OutputAviSynthScript%	echo.#SetMemoryMax(%_JAS.AviSynthMemoryPerThread%)

for /L %%G in (1,1,%_JAS.TotalThreads%) do (
  call set _JAS.NewLosslessFile=%%_JAS.LosslessFile:[NUM]=%%G%%
  if /I [%_LosslessCodec4CC%]==[x264] (
    >>%_JAS.OutputAviSynthScript%	call echo.tmp = FFVideoSource(%%_JAS.NewLosslessFile%%,track=-1,cache=false,pp=""^)
  ) else (
    >>%_JAS.OutputAviSynthScript%	call echo.tmp = AVISource(%%_JAS.NewLosslessFile%%,audio=false^)
  )

  if %%G EQU 1 (
    if %_JAS.TotalThreads% EQU 1 (
      rem.first and only thread
      >>%_JAS.OutputAviSynthScript%	echo.total1 = tmp
    ) else (
      rem.first thread
      >>%_JAS.OutputAviSynthScript%	echo.total1 = tmp.Trim(0,tmp.FrameCount(^) - 51^)
    )
  ) else (
  
  if %%G EQU %_JAS.TotalThreads% (
    rem.final thread
    >>%_JAS.OutputAviSynthScript%	echo.total1 = total1 + tmp.Trim(51,tmp.FrameCount(^)^)
  ) else (
    rem.intermediate threads
    >>%_JAS.OutputAviSynthScript%	echo.total1 = total1 + tmp.Trim(51,tmp.FrameCount(^) - 51^)
  )
  )
)

>>%_JAS.OutputAviSynthScript%	echo.total1

goto :eof
endlocal


:GetAVS2AVICodecSettings
setlocal disabledelayedexpansion
call set _GACS.AVS2AVISettingsFile=%%%1%%

if /I [%_LosslessCodec4CC%]==[ffvh] (
  call :ImportRegistrySettings RegistryFFVH,_RegistryFile,_FFDSEncRegistryPath,_RegistryBackupFile
  set _GACS.AVS2AVISwitches=-c ffds
) else (

if /I [%_LosslessCodec4CC%]==[ffv1] (
  call :ImportRegistrySettings RegistryFFV1,_RegistryFile,_FFDSEncRegistryPath,_RegistryBackupFile
  set _GACS.AVS2AVISwitches=-c ffds
) else (

if /I [%_LosslessCodec4CC%]==[lags] (
  call :SetLagarithINI
  set _GACS.AVS2AVISwitches=-c lags
) else (

  echo. No such Codec specified for this script, you better hope the default settings are correct.
  set _GACS.AVS2AVISwitches=-c %_LosslessCodec4CC%
)
)
)

:: stupid little script
>%_VersionAVS%	echo.Version()

set _GACS.NulOutput=
set _GACS.AVS2AVISwitches=%_GACS.AVS2AVISwitches% -s %_GACS.AVS2AVISettingsFile% -e
set _GACS.Thread=0
call :AVS2AVI _VersionAVS,_GACS.NulOutput,_GACS.AVS2AVISwitches,_GeneralLogFile,_GACS.Thread

if /I [%_LosslessCodec4CC%]==[ffvh] (
  call :RevertRegistrySettings _RegistryBackupFile,_FFDSEncRegistryPath
) else (

if /I [%_LosslessCodec4CC%]==[ffv1] (
  call :RevertRegistrySettings _RegistryBackupFile,_FFDSEncRegistryPath
) else (

if /I [%_LosslessCodec4CC%]==[lags] (
  call :RevertLagarithINI
)
)
)

endlocal
goto :eof


:CreateCMDBatches
setlocal disabledelayedexpansion
set _CCMDB.BatchLine=
set _CCMDB.ThreadNumber=1
:CCMDB.StartLoop
call set _CCMDB.BatchFile=%%_ThreadedBatchFile:[NUM]=%_CCMDB.ThreadNumber%%%
call set _CCMDB.AviSynthScript=%%_ThreadedAviSynthScript:[NUM]=%_CCMDB.ThreadNumber%%%
call set _CCMDB.LossLessFile=%%_ThreadedLosslessFile:[NUM]=%_CCMDB.ThreadNumber%%%
call set _CCMDB.LogFile=%%_ThreadedLogFile:[NUM]=%_CCMDB.ThreadNumber%%%

>%_CCMDB.BatchFile%2>&1		echo.@echo off
>>%_CCMDB.BatchFile%2>&1	echo.setlocal enableextensions,disabledelayedexpansion
>>%_CCMDB.BatchFile%2>&1	echo.
:: separate logfile for each parallel encoding
:: /B suppresses new windows from popping up, and logfile redirection keeps screen clear
::>>%_CCMDB.LogFile%2>&1 /B
if /I [%_LosslessCodec4CC%]==[x264] (
  >>%_CCMDB.BatchFile%2>&1	echo.start "x264 - Thread #%_CCMDB.ThreadNumber%" /Wait /%_ProcessPriority% %_X264PathPE% %_X264Parameters% --output %_CCMDB.LossLessFile% %_CCMDB.AviSynthScript%
) else (
  >>%_CCMDB.BatchFile%2>&1	echo.start "avs2avi - %_LosslessCodec4CC% - Thread #%_CCMDB.ThreadNumber%" /Wait /%_ProcessPriority% %_AVS2AVIPathPE% %_CCMDB.AviSynthScript% %_CCMDB.LossLessFile% %_AVS2AVISwitches%
)
>>%_CCMDB.BatchFile%2>&1	echo.exit /B

if defined _CCMDB.BatchLine (
  set _CCMDB.BatchLine=%_CCMDB.BatchLine% "|" %_CCMDB.ThreadNumber%.thread.cmd
) else (
  set _CCMDB.BatchLine=%_CCMDB.ThreadNumber%.thread.cmd
)
set /A _CCMDB.ThreadNumber+=1
if not %_CCMDB.ThreadNumber% GTR %_TotalThreads% (
  goto :CCMDB.StartLoop create next batch
)
echo. %_CCMDB.BatchLine% > C:\lol.txt
endlocal & set _CMDBatchLine=%_CCMDB.BatchLine%
goto :eof


:AVS2AVI run AVS2AVI without /Wait for parllel encoding
setlocal disabledelayedexpansion
call set _A2A.InputAviSynthScript=%%%1%%
call set _A2A.OutputFile=%%%2%%
call set _A2A.UserParams=%%%3%%
call set _A2A.LogFile=%%%4%%
call set _A2A.ThreadNumber=%%%5%%

>>%_A2A.LogFile%2>&1	start "avs2avi - %_LosslessCodec4CC% - Thread #%_A2A.ThreadNumber%" /B /Wait /%_ProcessPriority% %_AVS2AVIPathPE% %_A2A.InputAviSynthScript% %_A2A.OutputFile% %_A2A.UserParams%

endlocal
goto :eof


:ImportRegistrySettings
setlocal disabledelayedexpansion
set _IRS.Function=%1
call set _IRS.RegistryFile=%%%2%%
call set _IRS.RegistryPath=%%%3%%
call set _IRS.RegistryBackupFile=%%%4%%

call :%%_IRS.Function%% _IRS.RegistryFile
>>%_GeneralLogFile%2>&1	reg export %_IRS.RegistryPath% %_IRS.RegistryBackupFile%
>>%_GeneralLogFile%2>&1	reg delete %_IRS.RegistryPath% /F
>>%_GeneralLogFile%2>&1	reg import %_IRS.RegistryFile%

endlocal
goto :eof


:RevertRegistrySettings return to previous settings from backup
setlocal disabledelayedexpansion
call set _RRS.RegistryBackupFile=%%%1%%
call set _RRS.RegistryPath=%%%2%%

>>%_GeneralLogFile%2>&1	reg delete %_RRS.RegistryPath% /F
>>%_GeneralLogFile%2>&1	reg import %_RRS.RegistryBackupFile%

endlocal
goto :eof


:RegistryFFVH hardcoded to optimal settings
setlocal disabledelayedexpansion
call set _RFFVH.RegFile=%%%1%%

>%_RFFVH.RegFile%	echo.Windows Registry Editor Version 5.00
>>%_RFFVH.RegFile%	echo.
>>%_RFFVH.RegFile%	echo.[HKEY_CURRENT_USER\Software\GNU\ffdshow_enc]
>>%_RFFVH.RegFile%	echo."codecId"=dword:00000021
>>%_RFFVH.RegFile%	echo."fourcc"=dword:48564646
>>%_RFFVH.RegFile%	echo."huffyuv_csp"=dword:00000001
>>%_RFFVH.RegFile%	echo."huffyuv_ctx"=dword:00000001
>>%_RFFVH.RegFile%	echo."huffyuv_pred"=dword:00000001
>>%_RFFVH.RegFile%	echo."lastPage"=dword:000000d4

endlocal
goto :eof


:RegistryFFV1 hardcoded to optimal settings
setlocal disabledelayedexpansion
call set _RFFV1.RegFile=%%%1%%

>%_RFFV1.RegFile%	echo.Windows Registry Editor Version 5.00
>>%_RFFV1.RegFile%	echo.
>>%_RFFV1.RegFile%	echo.[HKEY_CURRENT_USER\Software\GNU\ffdshow_enc]
>>%_RFFV1.RegFile%	echo."codecId"=dword:00000023
>>%_RFFV1.RegFile%	echo."fourcc"=dword:31564646
>>%_RFFV1.RegFile%	echo."ffv1_coder"=dword:00000001
>>%_RFFV1.RegFile%	echo."ffv1_context"=dword:00000001
>>%_RFFV1.RegFile%	echo."ffv1_csp"=dword:32315659
>>%_RFFV1.RegFile%	echo."ffv1_key_interval"=dword:0000000a
>>%_RFFV1.RegFile%	echo."lastPage"=dword:000000cf

endlocal
goto :eof


:SetLagarithINI hardcoded to yv12
setlocal disabledelayedexpansion

>>%_GeneralLogFile%2>&1 move /Y %_LagarithINI% %_LagarithBackupINI%

>%_LagarithINI%		echo.[settings]
>>%_LagarithINI%	echo.lossy_option=3
>>%_LagarithINI%	echo.multithreading=1

endlocal
goto :eof


:RevertLagarithINI
setlocal disabledelayedexpansion

>>%_GeneralLogFile%2>&1 copy /Y %_LagarithBackupINI% %_LagarithINI%

endlocal
goto :eof
