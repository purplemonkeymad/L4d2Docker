# steamcmd base matained by cm2network https://github.com/CM2Walki/steamcmd

FROM cm2network/steamcmd:build_stage as build_stage

ENV STEAMAPPID=222860
ENV STEAMAPPDIR="l4d2"
ENV START_MAP_LIST="/l4d2/startmaps.txt"

COPY entrypoint.sh "${HOMEDIR}/entrypoint.sh"
COPY "./defaultfiles" /etc/defaultfiles

RUN set -x \
    # from https://github.com/CM2Walki/CSGO/blob/master/bullseye/Dockerfile
	# Install, update & upgrade packages
	&& apt-get update \
	&& apt-get install -y --no-install-recommends --no-install-suggests \
		wget=1.21-1+deb11u1 \
		ca-certificates=20210119 \
		lib32z1=1:1.2.11.dfsg-2+deb11u2 \
	&& mkdir -p "${STEAMAPPDIR}" \
	# Add entry script
	&& { \
		echo '@ShutdownOnFailedCommand 1'; \
		echo '@NoPromptForPassword 1'; \
		echo 'force_install_dir '"${STEAMAPPDIR}"''; \
		echo 'login anonymous'; \
		echo 'app_update '"${STEAMAPPID}"''; \
		echo 'quit'; \
	   } > "${HOMEDIR}/${STEAMAPP}_update.txt" \
	&& chmod +x "${HOMEDIR}/entry.sh" \
	&& chown -R "${USER}:${USER}" "${HOMEDIR}/entry.sh" "${STEAMAPPDIR}" "${HOMEDIR}/${STEAMAPP}_update.txt" \
	# Clean up
	&& rm -rf /var/lib/apt/lists/* 

# set stage name
FROM build_stage AS game

# Switch to user
USER ${USER}
WORKDIR ${HOMEDIR}

# set container's start command
CMD bash entrypoint.sh

EXPOSE \
    # game data
    27015/udp \
    # rcon port
    27015/tcp