#!/bin/sh
RESOLVED_CONF="/etc/systemd/resolved.conf"
DNS_SERVER="172.18.0.1"

stop_kind_cluster() {
    docker ps -q --filter "name=local" | xargs -r docker stop && \
    docker ps -a -q --filter "name=local" | xargs -r docker update --restart=no && \
    sudo systemctl stop named && \
    dns_remove
}

start_kind_cluster() {
    docker ps -a -q --filter "name=local" | xargs -r docker start && \
    sudo systemctl start named && \
    dns_add
}

restart_kind_cluster() {
    stop_kind_cluster
    start_kind_cluster
}

dns_add() {
    if grep -q "DNS=$DNS_SERVER" $RESOLVED_CONF; then
        echo "DNS server $DNS_SERVER is already configured."
    else
        sudo sed -i "/^\[Resolve\]/a DNS=$DNS_SERVER" $RESOLVED_CONF
        echo "Added DNS server $DNS_SERVER to $RESOLVED_CONF."
    fi
    # Restart systemd-resolved to apply changes
    sudo systemctl restart systemd-resolved
    echo "systemd-resolved restarted. DNS server $DNS_SERVER added."
}

dns_remove() {
    # Remove DNS server from resolved.conf
    if grep -q "DNS=$DNS_SERVER" $RESOLVED_CONF; then
        sudo sed -i "/DNS=$DNS_SERVER/d" $RESOLVED_CONF
        echo "Removed DNS server $DNS_SERVER from $RESOLVED_CONF."
    else
        echo "DNS server $DNS_SERVER is not configured."
    fi
    # Restart systemd-resolved to apply changes
    sudo systemctl restart systemd-resolved
    echo "systemd-resolved restarted. DNS server $DNS_SERVER removed."
}

case "$1" in
    start)
        start_kind_cluster
        ;;
    stop)
        stop_kind_cluster
        ;;
    restart)
        restart_kind_cluster
        ;;
    dns-add)
        dns_add
        ;;
    dns-remove)
        dns_remove
        ;;
    *)
        echo "Usage: $0 {start|stop|restart}"
        exit 1
        ;;
esac

