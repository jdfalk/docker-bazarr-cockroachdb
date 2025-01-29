FROM lscr.io/linuxserver/bazarr:development

# RUN busybox sed -i.bak ':a;N;$!ba;s/self\.server_version_info = self\._get_server_version_info(\n[[:space:]]*connection\n[[:space:]]*)/self.server_version_info = (10,0,0)/' /app/bazarr/bin/libs/sqlalchemy/engine/default.py
RUN echo "@testing https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
  echo "sqlalchemy-cockroachdb" >> /app/bazarr/bin/requirements.txt && \
  echo "psycopg[binary]" >> /app/bazarr/bin/requirements.txt && \
  echo "psycopg[pool]" >> /app/bazarr/bin/requirements.txt && \
  python3 -m venv /lsiopy && \
  pip install -U --no-cache-dir \
  pip \
  wheel && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/alpine-3.21/ \
  -r /app/bazarr/bin/requirements.txt

RUN sed -i.bak 's/drivername="postgresql"/drivername="cockroachdb+psycopg2"/' /app/bazarr/bin/bazarr/app/database.py && \
  sed -i.bak "s/elif bind\.engine\.name == \'postgresql\':/# PostgreSQL detected/g" /app/bazarr/bin/migrations/env.py && \
  sed -i.bak 's/bind\.execute(text\(\"SET CONSTRAINTS ALL DEFERRED;\"\))/# Constraints deferred/' /app/bazarr/bin/migrations/env.py && \
  sed -i.bak 's/bind\.execute(text\(\"SET CONSTRAINTS ALL IMMEDIATE;\"\))/# Constraints immediate/' /app/bazarr/bin/migrations/env.py && \
  sed -i.bak 's/isolation_level=\"AUTOCOMMIT\"/isolation_level=\"AUTOCOMMIT\",\ pool_pre_ping=True/' /app/bazarr/bin/bazarr/app/database.py
  # sed -i.bak 's/isolation_level=\"AUTOCOMMIT\"/pool_pre_ping=True/' /app/bazarr/bin/bazarr/app/database.py


# ports and volumes
EXPOSE 6767

VOLUME /config