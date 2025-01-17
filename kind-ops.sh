#!/bin/sh

stop_kind_cluster() {
    docker ps -q --filter "name=local" | xargs -r docker stop && \
    docker ps -q --filter "name=local" | xargs -r docker update --restart=no
}

start_kind_cluster() {
    docker ps -a -q --filter "name=local" | xargs -r docker start
}

restart_kind_cluster() {
    stop_kind_cluster
    start_kind_cluster
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
    *)
        echo "Usage: $0 {start|stop|restart}"
        exit 1
        ;;
esac