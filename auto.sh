function getStatus () {
    ifconfig | grep $1 > /dev/null && return 1
    return 0
}

while [[ 1 ]]; do
    getStatus tun0
    if [[ $? == 0 ]]; then
        echo "Tsinghua is not connected!"
        echo "Reconnecting!"
        ./isatap.sh
        echo "Reconnected."
        sleep 6
    fi
    sleep 6
done
