#include <cstrike>
#include <sdktools>
#include <sourcemod>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = {
    name        = "CSGO: Coaching",
    author      = "mrc4t#2090",
    description = "Make coach commands to work ingame-console again: coach ct, coach t, and uncoach",
    version     = "1.0.1",
    url         = "https://steamcommunity.com/id/mrc4t"
};

public void OnPluginStart() {
    RegConsoleCmd("coach", Command_Coach);
    RegConsoleCmd("uncoach", Command_Uncoach);
}

public Action Command_Uncoach(int client, int args)
{
    int team = GetEntProp(client, Prop_Send, "m_iCoachingTeam");
    if(team == 0)
        return Plugin_Handled;
    int old = GameRules_GetProp("m_bWarmupPeriod");
    if(old == 0)
        GameRules_SetProp("m_bWarmupPeriod", 1);
    UpdateCoachingTeam(client, 0);
    ChangeClientTeam(client, team);
    GameRules_SetProp("m_bWarmupPeriod", old);
    return Plugin_Handled;
}
public Action Command_Coach(int client, int args)
{
    if(args == 0 && GetClientTeam(client) > 1)
    {
        int team = GetClientTeam(client);
        ChangeClientTeam(client, 1);
        UpdateCoachingTeam(client, team);
        return Plugin_Handled;
    }

    char arg[MAX_TARGET_LENGTH];
    GetCmdArg(1, arg, sizeof(arg));
    if(StrEqual(arg, "ct", false))
    {
        ChangeClientTeam(client, 1);
        UpdateCoachingTeam(client, 3);
    }
    else if(StrEqual(arg, "t", false))
    {
        ChangeClientTeam(client, 1);
        UpdateCoachingTeam(client, 2);
    }
    return Plugin_Handled;
}

stock void UpdateCoachingTeam(int client, int team)
{
    int old = GameRules_GetProp("m_bWarmupPeriod");
    if(old == 0)
        GameRules_SetProp("m_bWarmupPeriod", 1);
    SetEntProp(client, Prop_Send, "m_iCoachingTeam", team);
    int randomplayer = GetRandomTeamMember(team);
    if(randomplayer != 0)
    {
        SetEntProp(client, Prop_Send, "m_iObserverMode", 4);
        SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", randomplayer);
    }
    
    GameRules_SetProp("m_bWarmupPeriod", old);
}

stock int GetRandomTeamMember(int team)
{
    for(int i = 1; i <= MaxClients; i++)
    {
        if(IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == team)
            return i;
    }
    return 0;
}
