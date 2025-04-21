service_path := "./services"
hostwatch_path := "./hostwatch"
quadlets := "syncthing|none"
srv := 'UNSET'

deploy-service: check-hostwatch
    #!/bin/sh
    if [ {{srv}} != 'none' ]; then
        cp {{service_path}}/{{srv}}/{{srv}}.container \
            "${XDG_CONFIG_HOME:-${HOME}/.config}"/containers/systemd/{{srv}}.container;
        cp {{service_path}}/{{srv}}/{{srv}}.target \
        "${XDG_CONFIG_HOME:-${HOME}/.config}"/systemd/user/{{srv}}.target;
        systemctl --user daemon-reload;
    fi
    echo "'none' is not a valid service"
    exit 1

deploy-hostwatch:
    cp {{hostwatch_path}}/quadlets-hostwatch* \
        "${XDG_CONFIG_HOME:-${HOME}/.config}"/systemd/user/
    systemctl --user daemon-reload

deploy-meta:
    cp quadlets-meta.target \
        "${XDG_CONFIG_HOME:-${HOME}/.config}"/systemd/user/quadlets-meta.target
    systemctl --user daemon-reload

remove-service: check-service
    rm "${XDG_CONFIG_HOME:-${HOME}/.config}"/containers/systemd/{{srv}}.container
    rm "${XDG_CONFIG_HOME:-${HOME}/.config}"/systemd/user/{{srv}}.target
    systemctl --user daemon-reload

remove-hostwatch:
    rm "${XDG_CONFIG_HOME:-${HOME}/.config}"/systemd/user/quadlets-hostwatch*
    systemctl --user daemon-reload

remove-meta:
    rm "${XDG_CONFIG_HOME:-${HOME}/.config}"/systemd/user/quadlets-meta.target

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
        if [[ ! "{{srv}}" == @({{quadlets}}) ]]; then
            echo "{{srv}} does not exist"
            exit 1
        fi
    fi

check-hostwatch: check-service
    #!/bin/sh
    if grep -q "quadlets-hostwatch.target" "{{service_path}}/{{srv}}/{{srv}}.container"; then
         echo "Service uses hostwatch";
         just --justfile {{justfile()}} deploy-hostwatch
    fi