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
	version = "1.0.2",
	url = ""
};

public APLRes AskPluginLoad2(Handle hPlugin, bool late, char[] error, int maxlen) {
	RegPluginLibrary("tf2_stun");
	
	return APLRes_Success;
}

public void OnPluginStart() {
	GameData data = new GameData("tf2.stun");
	if (data == null) {
		SetFailState("Failed to load gamedata(tf2.stun).");
	} else if (!ReadDHooksDefinitions("tf2.stun")) {
		SetFailState("Failed to read definitions in gamedata(tf2.stun).");
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
	
	DataPack pack = new DataPack();
	pack.WriteCell(client);
	pack.WriteFloat(GetEntPropFloat(client, Prop_Send, "m_flMovementStunTime"));
	pack.WriteCell(GetEntProp(client, Prop_Send, "m_iMovementStunAmount"));
	pack.WriteCell(GetEntProp(client, Prop_Send, "m_iStunFlags"));
	pack.WriteCell(GetEntPropEnt(client, Prop_Send, "m_hStunner"));
	
	RequestFrame(NextFrame_CallAddStunnedFwd, pack);
	
	return MRES_Ignored;
}

MRESReturn DynDetour_OnRemoveStunnedPre(Address shared) {
	int client = TF2Util_GetPlayerFromSharedAddress(shared);
	
	DataPack pack = new DataPack();
	pack.WriteCell(client);
	pack.WriteFloat(GetEntPropFloat(client, Prop_Send, "m_flMovementStunTime"));
	pack.WriteCell(GetEntProp(client, Prop_Send, "m_iMovementStunAmount"));
	pack.WriteCell(GetEntProp(client, Prop_Send, "m_iStunFlags"));
	pack.WriteCell(GetEntPropEnt(client, Prop_Send, "m_hStunner"));
	
	RequestFrame(NextFrame_CallRemoveStunnedFwd, pack);
	
	return MRES_Ignored;
}

void NextFrame_CallAddStunnedFwd(DataPack pack) {
	pack.Reset();
	int client = pack.ReadCell();
	float duration = pack.ReadFloat();
	int slowdown = pack.ReadCell();
	int stunFlags = pack.ReadCell();
	int stunner = pack.ReadCell();
	delete pack;
	
	Call_StartForward(g_FwdOnAddStunned);
	Call_PushCell(client);
	Call_PushFloat(duration);
	Call_PushCell(slowdown);
	Call_PushCell(stunFlags);
	Call_PushCell(stunner);
	Call_Finish();
}

void NextFrame_CallRemoveStunnedFwd(DataPack pack) {
	pack.Reset();
	int client = pack.ReadCell();
	float duration = pack.ReadFloat();
	int slowdown = pack.ReadCell();
	int stunFlags = pack.ReadCell();
	int stunner = pack.ReadCell();
	delete pack;
	
	Call_StartForward(g_FwdOnRemoveStunned);
	Call_PushCell(client);
	Call_PushFloat(duration);
	Call_PushCell(slowdown);
	Call_PushCell(stunFlags);
	Call_PushCell(stunner);
	Call_Finish();
}