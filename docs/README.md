# Desktop Quadlets

Set of systemd units and quadlet services primarily for use on immutable desktops
such as [ublue](https://universal-blue.org/).

- `quadlets-meta.target`: Start all attached quadlets
- hostwatch: Systemd units to handle container restarts on certain host file changes.
- toolboxes: Autostarting ephemeral and non-ephemeral distroboxes

## Requirements
- Requires: systemd podman
- optional: git just

## Service Installation

* 1\. `git clone` repo
* 2\. Install with [just](https://github.com/casey/just) or manual
	* 2.2\. Just Install:
		- service: `just srv=SERVICENAME`
			- hostwatch will automatically be installed for services that utilize
			it.
		- quadlets-meta.target: `just srv=none deploy-meta_target`
	* 2.1\. Manual Install:
		- Place `.target` files under `$XDG_CONFIG_HOME/systemd/user`
		- Place `.container` files under `$XDG_CONFIG_HOME/containers/systemd/`.
		- Run `systemctl --user daemon-reload`
* 3\. Enable and Start desired target with `systemctl enable --now TARGETNAME.target`
	- Avoid enabling lower level targets when higher level targets are enabled.


# Unit Logic
![systemd service diagram](./assets/diagram-unit-logic.svg)