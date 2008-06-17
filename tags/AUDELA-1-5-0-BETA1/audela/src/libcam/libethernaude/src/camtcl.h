/* camtcl.h
 * 
 * Copyright (C) 2002-2004 Michel MEUNIER <michel.meunier@tiscali.fr>
 * 
 * Mettre ici le texte de la license.
 *
 */

#ifndef __CAMTCL_H__
#define __CAMTCL_H__

#define SPECIFIC_CMDLIST \
    {"channel", (Tcl_CmdProc *) cmdEthernaudeChannel}, \
    {"reinit", (Tcl_CmdProc *) cmdEthernaudeReinit}, \
    {"scan", (Tcl_CmdProc *) cmdEthernaudeScan}, \
    {"breakscan", (Tcl_CmdProc *) cmdEthernaudeBreakScan}, \
    {"canspeed", (Tcl_CmdProc *) cmdEthernaudeCanSpeed}, \
    {"directclear", (Tcl_CmdProc *) cmdEthernaudeDirectClear}, \
    {"directreset", (Tcl_CmdProc *) cmdEthernaudeDirectReset}, \
    {"directidentity", (Tcl_CmdProc *) cmdEthernaudeDirectIdentity}, \
    {"debug_eth", (Tcl_CmdProc *) cmdEthernaudeDebug}, \
    {"gps", (Tcl_CmdProc *) cmdEthernaudeGPS}, \
    {"getccd_infos", (Tcl_CmdProc *) cmdEthernaudeGetCCDInfos},


 /* === Specific commands for that camera === */
int cmdEthernaudeDirectClear(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdEthernaudeDirectReset(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdEthernaudeDirectIdentity(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdEthernaudeChannel(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdEthernaudeReinit(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdEthernaudeShutterType(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdEthernaudeCanSpeed(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdEthernaudeScan(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdEthernaudeBreakScan(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdEthernaudeDebug(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdEthernaudeGPS(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
int cmdEthernaudeGetCCDInfos(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);

#endif
