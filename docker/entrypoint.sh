#!/bin/bash
set -euo pipefail

NODE_ID=${HOSTNAME:6}
LISTENERS="PLAINTEXT://:9092,CONTROLLER://:9093"
ADVERTISED_LISTENERS="PLAINTEXT://kafka-$NODE_ID.$SERVICE.$NAMESPACE.svc.cluster.local:9092"

if [ -n "$ADD_LISTENERS" ]; then LISTENERS+=,$ADD_LISTENERS ; fi
if [ -n "$ADD_ADVERTISED_LISTENERS" ]; then ADVERTISED_LISTENERS+=,$ADD_ADVERTISED_LISTENERS; fi

VOTERS=()
for i in $(seq 0 $(($REPLICAS-1))); do
    VOTERS+=("$i@kafka-$i.$SERVICE.$NAMESPACE.svc.cluster.local:9093")
done
CONTROLLER_QUORUM_VOTERS=$(IFS=,; echo "${VOTERS[*]}")

mkdir -p $SHARE_DIR/$NODE_ID

sed -e "s+^node.id=.*+node.id=$NODE_ID+" \
    -e "s+^controller.quorum.voters=.*+controller.quorum.voters=$CONTROLLER_QUORUM_VOTERS+" \
    -e "s+^listeners=.*+listeners=$LISTENERS+" \
    -e "s+^advertised.listeners=.*+advertised.listeners=$ADVERTISED_LISTENERS+" \
    -e "s+^log.dirs=.*+log.dirs=$SHARE_DIR/$NODE_ID+" \
    /etc/kafka/docker/server.properties > /tmp/server.properties

if [ -n "$ADD_LISTENER_SECURITY_PROTOCOL_MAP" ]; then
    sed -Ei "s/(^listener\.security\.protocol\.map=.*)/\1,$ADD_LISTENER_SECURITY_PROTOCOL_MAP/" /tmp/server.properties
fi

sed -i "s/\$NODE_ID/$NODE_ID/g" /tmp/server.properties

cat <<EOF >> /tmp/server.properties
default.replication.factor=${DEFAULT_REPLICATION_FACTOR:=3}
min.insync.replicas=${DEFAULT_MIN_INSYNC_REPLICAS:=2}
offsets.topic.replication.factor=${DEFAULT_REPLICATION_FACTOR:=3}
transaction.state.log.replication.factor=${DEFAULT_REPLICATION_FACTOR:=3}
transaction.state.log.min.isr=${DEFAULT_MIN_INSYNC_REPLICAS:=2}
log.retention.bytes=${LOG_RETENTION_BYTES:=1048576}
log.retention.hours=${LOG_RETENTION_HOURS:=168}
log.retention.ms=${LOG_RETENTION_MS:=-1}
offsets.retention.minutes=${OFFSETS_RETENTION_MINUTES:=1440}
auto.create.topics.enable=${AUTO_CREATE_TOPICS_ENABLE:=false}
delete.topic.enable=${DELETE_TOPIC_ENABLE:=true}
sasl.enabled.mechanisms=${SASL_ENABLED_MECHANISMS:=PLAIN,SCRAM-SHA-256,SCRAM-SHA-512}
EOF

kafka-storage.sh format --ignore-formatted -t $CLUSTER_ID -c /tmp/server.properties

exec kafka-server-start.sh /tmp/server.properties