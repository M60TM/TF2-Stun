#include <sourcemod>
#include <dhooks_gameconf_shim>
#include <tf2utils>

#pragma semicolon 1
#pragma newdecls required

GlobalForward g_FwdOnAddStunned;
GlobalForward g_FwdOnRemoveStunned;

public Plugin myinfo = {
	name = "[TF2] Stun Forward",
	author = "Sandy",
	description = "TF2_OnConditionRemoved wasn't enough.",
	version = "1.0.0",
	url = ""
};

public APLRes AskPluginLoad2(Handle hPlugin, bool late, char[] error, int maxlen) {
	RegPluginLibrary("tf2_stun");
	
	return APLRes_Success;
}

public void OnPluginStart() {
	GameData data = new GameData("tf2.stun_player");
	if (data == null) {
		SetFailState("Failed to load gamedata(tf2.stun_player).");
	} else if (!ReadDHooksDefinitions("tf2.stun_player")) {
		SetFailState("Failed to read definitions in gamedata(tf2.stun_player).");
	}
	
	DynamicDetour dynDetourOnAddStunned = GetDHooksDetourDefinition(data, "CTFPlayerShared::OnAddStunned");
	dynDetourOnAddStunned.Enable(Hook_Post, DynDetour_OnAddStunnedPost);
	
	DynamicDetour dynDetourOnRemoveStunned = GetDHooksDetourDefinition(data, "CTFPlayerShared::OnRemoveStunned");
	dynDetourOnRemoveStunned.Enable(Hook_Pre, DynDetour_OnRemoveStunnedPre);
	
	ClearDHooksDefinitions();
	delete data;
	
	g_FwdOnAddStunned = new GlobalForward("TF2_OnAddStunned", ET_Ignore, Param_Cell, Param_Float, Param_Cell, Param_Cell, Param_Cell);
	g_FwdOnRemoveStunned = new GlobalForward("TF2_OnRemoveStunned", ET_Ignore, Param_Cell, Param_Float, Param_Cell, Param_Cell, Param_Cell);
}

MRESReturn DynDetour_OnAddStunnedPost(Address shared) {
	int client = TF2Util_GetPlayerFromSharedAddress(shared);
	
	float duration = GetEntPropFloat(client, Prop_Send, "m_flMovementStunTime");
	int slowdown = GetEntProp(client, Prop_Send, "m_iMovementStunAmount");
	int stunFlags = GetEntProp(client, Prop_Send, "m_iStunFlags");
	int stunner = GetEntPropEnt(client, Prop_Send, "m_hStunner");
	
	Call_StartForward(g_FwdOnAddStunned);
	Call_PushCell(client);
	Call_PushFloat(duration);
	Call_PushCell(slowdown);
	Call_PushCell(stunFlags);
	Call_PushCell(stunner);
	Call_Finish();
	
	return MRES_Ignored;
}

MRESReturn DynDetour_OnRemoveStunnedPre(Address shared) {
	int client = TF2Util_GetPlayerFromSharedAddress(shared);
	
	float duration = GetEntPropFloat(client, Prop_Send, "m_flMovementStunTime");
	int slowdown = GetEntProp(client, Prop_Send, "m_iMovementStunAmount");
	int stunFlags = GetEntProp(client, Prop_Send, "m_iStunFlags");
	int stunner = GetEntPropEnt(client, Prop_Send, "m_hStunner");
	
	Call_StartForward(g_FwdOnRemoveStunned);
	Call_PushCell(client);
	Call_PushFloat(duration);
	Call_PushCell(slowdown);
	Call_PushCell(stunFlags);
	Call_PushCell(stunner);
	Call_Finish();
	
	return MRES_Ignored;
}