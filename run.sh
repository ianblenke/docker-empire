#!/bin/bash

# Fail fast, including pipelines
set -exo pipefail

cat > /etc/supervisor/conf.d/supervisord.conf <<EOF
[supervisord]
nodaemon = true
user = root

[unix_http_server]
file=/tmp/supervisor.sock   ; (the path to the socket file)

[eventlistener:stdout] 
command = supervisor_stdout 
buffer_size = 100 
events = PROCESS_LOG 
result_handler = supervisor_stdout:event_handler
EOF

cd /empserver

ls -la *bin*

yes | ./sbin/files

mkdir -p etc/empire/econfig.d

if [ -n "$ECONFIG" ]; then
  IFS=, configs=( $ECONFIG )
  for config in ${configs[*]}; do
    key="$(echo $config | awk '{print $1}')"
    echo "$line" | cut -d' ' -f2- > "etc/empire/econfig.d/$key"
  done
else
  cat etc/empire/econfig | grep -v -e '^#' | sed -e '/^$/d' | while read line ; do
    key="$(echo $line | awk '{print $1}')"
    echo "$line" | cut -d' ' -f2- > "etc/empire/econfig.d/$key"
  done
fi

for file in etc/empire/econfig.d/* ; do
  key=$(basename $file)
  value="$(cat $file)"
  echo "$key $value"
done > etc/empire/econfig

export EMPIREHOST=${EMPIREHOST:-localhost}
export EMPIREPORT=${EMPIREPORT:-6665}

env | grep -v 'HOME\|PWD\|PATH' | while read line; do
   key="$(echo $line | cut -d= -f1)"
   value="$(echo $line | cut -d= -f2-)"
   echo "export $key=\"$value\"" >> /home/term/.bashrc
done

cat <<EOF > /tmp/empire-client.sh
#!/bin/bash
cd /empserver
source /home/term/.bashrc
cd /empserver/var/empire
#exec /empserver/bin/empire
exec /usr/bin/screen -x emp_server
EOF

cat <<EOF > /tmp/empire-server.sh
#!/bin/bash
cd /empserver
source /home/term/.bashrc
#./sbin/fairland ${FAIRLAND_OPTS:-10 30}
#echo "Remember to run: exec newcap_script"
cd /empserver/var/empire
exec /usr/bin/screen -S emp_server -D -m /bin/bash -xc 'source /home/term/.bashrc; cd /empserver; ./sbin/emp_server'
EOF

chmod 755 /tmp/empire-client.sh /tmp/empire-server.sh

ln -sf /tmp/empire-client.sh /bin/login

cat > /etc/supervisor/conf.d/empserver.conf <<EOF
[program:empserver]
command=/tmp/empire-server.sh
priority=10
directory=/opt/wetty
process_name=%(program_name)s
autostart=true
autorestart=true
stdout_events_enabled=true
stderr_events_enabled=true
stopsignal=TERM
exitcodes=0
stopwaitsecs=1
EOF

cat > /etc/supervisor/conf.d/wetty.conf <<EOF
[program:wetty]
command=/usr/bin/node /opt/wetty/app.js -p 3000
priority=10
directory=/opt/wetty
process_name=%(program_name)s
autostart=true
autorestart=true
stdout_events_enabled=true
stderr_events_enabled=true
stopsignal=TERM
stopwaitsecs=1
EOF

chown daemon:daemon /etc/supervisor/conf.d/ /var/run/ /var/log/supervisor/ /empserver

# start supervisord
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
