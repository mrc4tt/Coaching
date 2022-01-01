#include <cstrike>
#include <sdkhooks>
#include <sdktools>
#include <sourcemod>

#define TAG_COACH_CLR "[\x06COACH\x01]"

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name        = "CSGO: Coaching",
	author      = "mrc4t#2090", // dranix helped :)
	description = "Make coach commands to work ingame-console again: coach ct, coach t, and uncoach",
	version     = "1.0.3",
	url         = "-"
}

public void OnPluginStart()
{
    RegConsoleCmd("coach", Command_Coach);
    RegConsoleCmd("uncoach", Command_UnCoach);
    RegConsoleCmd("sm_coach", Command_Coach);
    RegConsoleCmd("sm_uncoach", Command_UnCoach);
    RegConsoleCmd("sm_coach_t", Command_CoachT);
    RegConsoleCmd("sm_coach_ct", Command_CoachCT);
}

public Action Command_Coach(int iClient, int iArgs)
{
    char szArg[4];
    GetCmdArg(1, szArg, sizeof(szArg));

    if (iArgs == 0)
    {
	    SetClientCoach(iClient, GetClientTeam(iClient));
    }
    else if (!strncmp(szArg, "t", 2))
    {
        SetClientCoach(iClient, CS_TEAM_T);
    }
    else
    {
        SetClientCoach(iClient, CS_TEAM_CT);
    }

    return Plugin_Handled;
}

public Action Command_UnCoach(int iClient, int iArgs)
{
	RemoveClientCoach(iClient);
	return Plugin_Handled;
}

public Action Command_CoachT(int iClient, int iArgs)
{
	SetClientCoach(iClient, CS_TEAM_T);
	return Plugin_Handled;
}

public Action Command_CoachCT(int iClient, int iArgs)
{
	SetClientCoach(iClient, CS_TEAM_CT);
	return Plugin_Handled;
}

public void OnClientSayCommand_Post(int iClient, const char[] szCommand, const char[] sArgs)
{
	static const char szCommandCoach[][]   = { ".coach", "coach" };
	static const char szCommandUnCoach[][] = { ".uncoach", "uncoach" };
	static const char szCommandCoachT[][]  = { ".coach t", "coach t" };
	static const char szCommandCoachCT[][] = { ".coach ct", "coach ct" };

	for (int i = 0; i < sizeof(szCommandCoach); i++)
	{
		if (!strncmp(sArgs, szCommandCoach[i], 7, false))
		{
			SetClientCoach(iClient, GetClientTeam(iClient));
			break;
		}
	}

	for (int i = 0; i < sizeof(szCommandUnCoach); i++)
	{
		if (!strncmp(sArgs, szCommandUnCoach[i], 8, false))
		{
			RemoveClientCoach(iClient);
			break;
		}
	}

	for (int i = 0; i < sizeof(szCommandCoachT); i++)
	{
		if (!strncmp(sArgs, szCommandCoachT[i], 8, false))
		{
			SetClientCoach(iClient, CS_TEAM_T);
			break;
		}
	}

	for (int i = 0; i < sizeof(szCommandCoachCT); i++)
	{
		if (!strncmp(sArgs, szCommandCoachCT[i], 8, false))
		{
			SetClientCoach(iClient, CS_TEAM_CT);
			break;
		}
	}
}

void SetClientCoach(int iClient, int iTeam)
{
    if (GetClientTeam(iClient) != iTeam)
    {
        PrintToChat(iClient, "%s You cannot coach the opposite team!", TAG_COACH_CLR);
        return;
    }

    if (!GameRules_GetProp("m_bWarmupPeriod"))
    {
        GameRules_SetProp("m_bWarmupPeriod", 1);
	}

    ChangeClientTeam(iClient, CS_TEAM_SPECTATOR);

    SetEntProp(iClient, Prop_Send, "m_iCoachingTeam", iTeam);
    int iRandom = GetRandomTeamClient(iTeam);

    if (IsValidClient(iRandom, false))
    {
        SetEntProp(iClient, Prop_Send, "m_iObserverMode", 4);
        SetEntPropEnt(iClient, Prop_Send, "m_hObserverTarget", iRandom);
    }

    GameRules_SetProp("m_bWarmupPeriod", 0);
}

void RemoveClientCoach(int iClient)
{
    CS_SwitchTeam(iClient, GetEntProp(iClient, Prop_Send, "m_iCoachingTeam"));
    SetEntProp(iClient, Prop_Send, "m_iObserverMode", 5);  
    SetEntProp(iClient, Prop_Send, "m_iCoachingTeam", 0);
}

stock bool IsValidClient(int client, bool nobots = true)
{
	if (client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)))
	{
		return false;
	}
	return IsClientInGame(client);
}

stock int Math_GetRandomInt(int min, int max)
{
	int random = GetURandomInt();

	if (random == 0)
	{
		random++;
	}

	return RoundToCeil(float(random) / (float(2147483647) / float(max - min + 1))) + min - 1;
}

stock int GetRandomTeamClient(int iTeam = 0)
{
	int[] clients = new int[MaxClients + 1];
	int total;

	clients[total++] = -1;

	for (int client = 1; client <= MaxClients; client++)
		if (IsValidClient(client, false))
			if (IsPlayerAlive(client))
				if ((iTeam != 0 && GetClientTeam(client) == iTeam || iTeam == 0))
					clients[total++] = client;

	return clients[Math_GetRandomInt(0, total)];
}
