#!/bin/bash

# startup script for l4d2 server
# based on https://github.com/CM2Walki/CSGO/

mkdir -p "${STEAMAPPDIR}" || true  

# install/update server before run.
bash "${STEAMCMDDIR}/steamcmd.sh" +force_install_dir "${STEAMAPPDIR}" \
				+login anonymous \
				+app_update "${STEAMAPPID}" \
				+quit


# Believe it or not, if you don't do this srcds_run shits itself
cd "${STEAMAPPDIR}"

starting_maplist="${START_MAP_LIST_FILE}"

if [ -f "$starting_maplist" ]; then
    SRCDS_STARTMAP=$(shuf -n 1 "$starting_maplist")
else
    SRCDS_STARTMAP="c1m1_hotel"
fi

# If no autoexec is present, use all parameters
bash "${STEAMAPPDIR}/srcds_run" -game "${STEAMAPP}" -console -autoupdate \
            -steam_dir "${STEAMCMDDIR}" \
            -steamcmd_script "${HOMEDIR}/${STEAMAPP}_update.txt" \
            -usercon \
            +fps_max "${SRCDS_FPSMAX}" \
            -port "${SRCDS_PORT}" \
            +maxplayers "${SRCDS_MAXPLAYERS}" \
            +map "$SRCDS_STARTMAP" \
            +sv_setsteamaccount "${SRCDS_TOKEN}" \
            +rcon_password "${SRCDS_RCONPW}" \
            +sv_password "${SRCDS_PW}" \
            +sv_region "${SRCDS_REGION}" \
            +net_public_adr "${SRCDS_NET_PUBLIC_ADDRESS}" \
            +sv_lan "${SRCDS_LAN}" \
            "${ADDITIONAL_ARGS}"
