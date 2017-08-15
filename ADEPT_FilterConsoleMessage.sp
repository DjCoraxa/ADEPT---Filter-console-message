#include <PTaH>
#pragma newdecls required

#define PREFIX_LOG  "[ADEPT_FilterConsoleMessage] Blocked message: "

ConVar blockMapSpam;
ConVar blockServerPureSpam;
ConVar blockSoundErrorSpam;
ConVar blockUTILSpam;
ConVar blockSendNetMsgOverflow;


ConVar logOnBlockMessage;

char mapSpamMessages[][] =
{
  "Attempted to create unknown entity type",
  "specified! Verify that SKIN is valid, and has a corresponding options block in the model QC file",
  "BUG: CCSGameMovement::CheckParameters - too many stacking levels.",
  "using obsolete or unknown material type",
  ", but there is no matching entry in propdata.txt.",
  "LEVEL DESIGN ERROR: Entity"
};

public Plugin myinfo =
{
	name = "ADEPT -> Filter Console Message",
	author = "Koraks",
	version = "0.2",
	url = "http://www.StudioADEPT.net"
};
public void OnPluginStart()
{
  CreateConVar("sm_adept_filterconsolemessage_version", "0.2", "Plugin version", FCVAR_DONTRECORD);
  blockSoundErrorSpam = CreateConVar("sm_adept_blocksoundspam", "1", "This cvar block type messages 'CSoundEmitterSystemBase::GetParametersForSound:  No such sound Error'", FCVAR_HIDDEN , true, 0.0, true, 1.0);
  blockUTILSpam = CreateConVar("sm_adept_blockutilspam", "1", "This cvar blocks type messages 'UTIL_GetListenServerHost() called from a dedicated server or single-player game.'", FCVAR_HIDDEN , true, 0.0, true, 1.0);
  blockMapSpam = CreateConVar("sm_adept_blockmapspam", "1", "This cvar blocks type messages 'entity_type at loc_entity using obsolete or unknown material type'", FCVAR_HIDDEN , true, 0.0, true, 1.0);
  blockServerPureSpam = CreateConVar("sm_adept_blockpurespam", "1", "This cvar blocks type messages '[steamid] Pure server: file: {file_path} could not open file to hash ( benign for now ) : {file_hash}'", FCVAR_HIDDEN , true, 0.0, true, 1.0);
  blockSendNetMsgOverflow = CreateConVar("sm_adept_blocknetbufferoverflow", "1", "This cvar blocks type messages 'SendNetMsg {IP}: stream[(null)] buffer overflow (maxsize = 4000)!'", FCVAR_HIDDEN , true, 0.0, true, 1.0);

  logOnBlockMessage = CreateConVar("sm_adept_debug_filterconsolemessage", "0", "If cvar equals 1, the plugin will notify you of blocked messages [DEBUG]", FCVAR_HIDDEN, true, 0.0, true, 1.0);


  AutoExecConfig(true, "ADEPT_FilterConsoleMessage");

  PTaH(PTaH_ServerConsolePrint, Hook, Event_OnConsolePrint);
}
public void OnPluginEnd()
{
  delete blockSoundErrorSpam;
  delete blockUTILSpam;
  delete blockMapSpam;
  delete blockServerPureSpam;
  delete blockSendNetMsgOverflow;
  delete logOnBlockMessage;

  PTaH(PTaH_ServerConsolePrint, UnHook, Event_OnConsolePrint);
}
public Action Event_OnConsolePrint(const char[] sMessage, LoggingSeverity severity)
{
  if(blockMapSpam.BoolValue)
  {
    for(int i = 0; i < sizeof(mapSpamMessages);i++)
    {
      if(StrContains(sMessage, mapSpamMessages[i]) != -1 && StrContains(sMessage, PREFIX_LOG) == -1)
      {
        if(logOnBlockMessage.BoolValue) PrintToServer("%s%s", PREFIX_LOG, sMessage);
        return Plugin_Handled;
      }
    }
  }
  if(blockUTILSpam.BoolValue)
  {
    if(StrContains(sMessage, "UTIL_GetListenServerHost() called from a dedicated server or single-player game.") != -1 && StrContains(sMessage, PREFIX_LOG) == -1)
    {
      if(logOnBlockMessage.BoolValue) PrintToServer("%sUTIL_GetListenServerHost() called from a dedicated server or single-player game.", PREFIX_LOG);
      return Plugin_Handled;
    }
  }
  if(blockSoundErrorSpam.BoolValue)
  {
    if(StrContains(sMessage, "CSoundEmitterSystemBase::GetParametersForSound:  No such sound") != -1 && StrContains(sMessage, PREFIX_LOG) == -1)
    {
      if(logOnBlockMessage.BoolValue) PrintToServer("%sCSoundEmitterSystemBase::GetParametersForSound:  No such sound.", PREFIX_LOG);
      return Plugin_Handled;
    }
  }
  if(blockServerPureSpam.BoolValue)
  {
    if(StrContains(sMessage, "could not open file to hash ( benign for now )") != -1 && StrContains(sMessage, PREFIX_LOG) == -1)
    {
      if(logOnBlockMessage.BoolValue) PrintToServer("%s[steamid] Pure server: file: {file_path} could not open file to hash ( benign for now ) : {file_hash}", PREFIX_LOG);
      return Plugin_Handled;
    }
  }
  if(blockSendNetMsgOverflow.BoolValue)
  {
    if(StrContains(sMessage, ": stream[(null)] buffer overflow (maxsize = 4000)!") != -1 && StrContains(sMessage, PREFIX_LOG) == -1)
    {
      if(logOnBlockMessage.BoolValue) PrintToServer("%sSendNetMsg {IP}: stream[(null)] buffer overflow (maxsize = 4000)!", PREFIX_LOG);
      return Plugin_Handled;
    }
  }
  return Plugin_Continue;
}
