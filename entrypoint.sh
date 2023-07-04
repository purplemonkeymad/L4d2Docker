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

# find if rcon secret file was set and use that if it is

rcon_passwd_secret="/run/secrets/rcon_password"
if [ -f "$rcon_passwd_secret" ]; then
    RCON_PASSWORD="$(cat "$rcon_passwd_secret")"
elif [ -z "${SRCDS_RCONPW}"]; then
    RCON_PASSWORD="${SRCDS_RCONPW}"
else
    RCON_PASSWORD="$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13)"
    echo "Random rcon password assigned: $RCON_PASSWORD"
fi

# map settings
starting_maplist="${START_MAP_LIST_FILE}"

if [ -f "$starting_maplist" ]; then
    SRCDS_STARTMAP=$(shuf -n 1 "$starting_maplist")
else
    SRCDS_STARTMAP="c1m1_hotel"
fi

# copy customizations to the game dir
if [ -f "/customfiles/" ]; then
    echo "Custom files found, copying files."
    cp -r /customfiles/* "${STEAMAPPDIR}"
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
            +rcon_password "$RCON_PASSWORD" \
            +sv_password "${SRCDS_PW}" \
            +sv_region "${SRCDS_REGION}" \
            +net_public_adr "${SRCDS_NET_PUBLIC_ADDRESS}" \
            +sv_lan "${SRCDS_LAN}" \
            +exec "${SRCDS_AUTOEXEC}" \
            "${ADDITIONAL_ARGS}"
