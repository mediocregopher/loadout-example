#!/bin/sh
set -e
dir=$(dirname "$0")
source $dir/remote-dev.env

_MACHINE_NAME=${MACHINE_NAME:-remote-dev}
_DOCKER_IMG=${DOCKER_IMG:-gcr.io/$CLOUDSDK_CORE_PROJECT/remote-dev:latest}

function getStatus {
    descr=$(gcloud compute instances describe --format json $_MACHINE_NAME)
    status=$(echo "$descr" | jq -r '.status')
    echo "$status"
}

function ensureUp {
    echo -n "getting $_MACHINE_NAME status: "
    status=$(getStatus)
    echo "$status"
    if [ "$status" = "TERMINATED" ]; then
        echo "starting $_MACHINE_NAME"
        gcloud compute instances start $_MACHINE_NAME
    elif [ "$status" != "RUNNING" ]; then
        echo "unknown status"
        exit 1
    fi
}

cmd=$1
shift

case "$cmd" in
status)
    getStatus
    ;;
up)
    ensureUp
    ;;

down)
    gcloud compute instances stop --async $_MACHINE_NAME
    ;;

ssh)
    ensureUp
    exec gcloud compute ssh --ssh-flag=-tt $_MACHINE_NAME
    ;;

dev)
    ensureUp
    sshcmd=$(cat <<EOF
        set -e
        if [ ! -e /dev/mapper/remote-dev-home ]; then
            sudo cryptsetup open /dev/sdb remote-dev-home
        fi
        if [ "\$(mount | grep /opt/remote-dev-home)" = "" ]; then
            sudo mount /dev/mapper/remote-dev-home /opt/remote-dev-home
        fi

        export REMOTE_DEV=1
        echo '
            source /etc/bashrc
            if [ ! -z "\$REMOTE_DEV" ]; then
                exec sudo gcloud docker -- run -it --rm \
                    --privileged \
                    --network host \
                    -v /opt/remote-dev-home:/home \
                    -v /var/run/docker.sock:/var/run/docker.sock \
                    $_DOCKER_IMG
            fi
        ' > ~/.bashrc

        tmux new-session -A -s remote-dev
EOF
)
        exec gcloud compute ssh --ssh-flag=-tt --command="$sshcmd" $_MACHINE_NAME
    ;;

fwd)
    ensureUp
    exec gcloud compute ssh --ssh-flag="-L $1:127.0.0.1:$1" --ssh-flag="-N" $_MACHINE_NAME
    ;;

*)
    echo "Usage: $0 [status|up|down|ssh]"
    exit 1
    ;;
esac
