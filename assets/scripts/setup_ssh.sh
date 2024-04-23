function get_service_status() {
    service_name="sshd.service"
    if systemctl is-active --quiet "$service_name" && systemctl is-enabled --quiet "$service_name"; then
        echo "y"
    else
        echo "n"
    fi
}

function configure_service() {
    service_name="sshd.service"

    systemctl enable "$service_name"
    systemctl start "$service_name"
}

service_status="$get_service_status"

if [ "$service_status" == "n" ]; then
    configure_service
fi

