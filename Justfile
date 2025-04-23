SERVICE_PATH := "./services"
HOSTWATCH_PATH := "./hostwatch"
QUADLETS := "syncthing|langtool|none"
srv := 'UNSET'

HOME_DATA := "${XDG_DATA_HOME:-${HOME}/.local/share}"
CONFIG_HOME := "${XDG_CONFIG_HOME:-${HOME}/.config}"

deploy-service: check-hostwatch
    #!/bin/sh
    if [ {{srv}} == 'none' ]; then
        echo "'none' is not a valid service"
        exit 1
    fi;
    echo "Installing Quadlet"
    cp {{SERVICE_PATH}}/{{srv}}/{{srv}}.container \
        {{CONFIG_HOME}}/containers/systemd/{{srv}}.container;
    cp {{SERVICE_PATH}}/{{srv}}/{{srv}}.target \
    {{CONFIG_HOME}}/systemd/user/{{srv}}.target;
    if [ -f "{{SERVICE_PATH}}/{{srv}}/dotdesktop.sh" ]; then
        echo "Adding dot desktop file"
        sh {{SERVICE_PATH}}/{{srv}}/dotdesktop.sh
    fi
    systemctl --user daemon-reload;

deploy-hostwatch:
    cp {{HOSTWATCH_PATH}}/QUADLETS-hostwatch* \
        {{CONFIG_HOME}}/systemd/user/
    systemctl --user daemon-reload

deploy-meta_target:
    cp QUADLETS-meta.target \
        {{CONFIG_HOME}}/systemd/user/QUADLETS-meta.target
    systemctl --user daemon-reload

deploy-distrobox_target:
    cp toolboxes/QUADLETS-distrobox.target \
        {{CONFIG_HOME}}/systemd/user/QUADLETS-distrobox.target
    systemctl --user daemon-reload

remove-service: check-service
    rm {{CONFIG_HOME}}/containers/systemd/{{srv}}.container
    rm {{CONFIG_HOME}}/systemd/user/{{srv}}.target
    find "{{HOME_DATA}}/applications" "{{HOME_DATA}}/icons/hicolor" \
        -name "{{srv}}*.*" -delete
    update-desktop-database "{{HOME_DATA}}/applications"
    systemctl --user daemon-reload

remove-hostwatch:
    rm {{CONFIG_HOME}}/systemd/user/QUADLETS-hostwatch*
    systemctl --user daemon-reload

remove-meta:
    rm {{CONFIG_HOME}}/systemd/user/QUADLETS-meta.target

disable-service: check-service
    systemctl --user mask {{srv}}.service

enable-service: check-service
    systemctl --user unmask {{srv}}.service

check-service:
    #!/bin/sh
    if [ {{srv}} == 'UNSET' ]; then
    echo "Please select service with: just srv=SERVICENAME RECIPE"
    exit 1
    else
        if [[ ! "{{srv}}" == @({{QUADLETS}}) ]]; then
            echo "{{srv}} does not exist"
            exit 1
        fi
    fi

check-hostwatch: check-service
    #!/bin/sh
    if grep -q "QUADLETS-hostwatch.target" "{{SERVICE_PATH}}/{{srv}}/{{srv}}.container"; then
         echo "Service uses hostwatch";
         just --justfile {{justfile()}} deploy-hostwatch
    fi