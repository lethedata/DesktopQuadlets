service_path := "./services"
hostwatch_path := "./hostwatch"
quadlets := "syncthing|none"
srv := 'none'

deploy-service: check-service
    cp {{service_path}}/{{srv}}/{{srv}}.container "${XDG_CONFIG_HOME:-${HOME}/.config}"/containers/systemd/{{srv}}.container
    cp {{service_path}}/{{srv}}/{{srv}}.target "${XDG_CONFIG_HOME:-${HOME}/.config}"/systemd/user/{{srv}}.target
    systemctl --user daemon-reload

deploy-hostwatch:
    cp {{hostwatch_path}}/quadlets-hostwatch* "${XDG_CONFIG_HOME:-${HOME}/.config}"/systemd/user/
    systemctl --user daemon-reload

deploy-meta:
    cp quadlets-meta.target "${XDG_CONFIG_HOME:-${HOME}/.config}"/systemd/user/quadlets-meta.target
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
    if [ {{srv}} == 'none' ]; then
    echo "Please select service with: just remove-service srv=SERVICENAME"
    exit 1
    else
        if [[ ! "{{srv}}" == @({{quadlets}}) ]]; then
            echo "{{srv}} does not exist"
            exit 1
        fi
    fi