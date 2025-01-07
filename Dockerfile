FROM lscr.io/linuxserver/bazarr:development

RUN busybox sed -i.bak ':a;N;$!ba;s/self\.server_version_info = self\._get_server_version_info(\n[[:space:]]*connection\n[[:space:]]*)/self.server_version_info = (10,0,0)/' /app/bazarr/bin/libs/sqlalchemy/engine/default.py

# ports and volumes
EXPOSE 6767

VOLUME /config