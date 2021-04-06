#!/bin/bash

abort() {
	printf "%s\n" "$@"
	exit 1
}

if [ -z "${BASH_VERSION:-}" ]; then
  abort "Bash is required to interpret this script."
fi

# First check OS.
OS="$(uname)"
if [[ "$OS" == "Linux" ]]; then
	VVV_ON_LINUX=1
elif [[ "$OS" != "Darwin" ]]; then
	abort "This script is only supported on macOS and Linux."
fi

function is_arch_supported() {
	# return yes if x86_64, no if anything else
}

function is_homebrew_installed() {
	return 0
}

function is_vbox_installed() {
	return 0
}

function is_vagrant_installed() {
	return 0
}

function install_vagrant() {
	if is_homebrew_installed; then
		brew cask --install vagrant
	fi
}

function install_vbox() {
	if is_homebrew_installed; then
		brew cask --install virtualbox
		abort "You must restart your computer after installing VirtualBox. Do that, then re-run this script."
	fi
}


function install_homebrew() {
	#
}

function is_vvv_installed() {
	return 0
}

function check_git_installed() {
	if ! command -v git >/dev/null; then
		abort "You must install Git before running this script."
	fi
}

function get_vvv_dir() {
	echo "~/vagrant-local"
}

function clone_vvv() {
	git clone https://github.com/Varying-Vagrant-Vagrants/VVV.git $(get_vvv_dir)
}

function install_vvv_vagrant_plugins() {
	cd $(get_vvv_dir)
	vagrant plugin install --local
	cd -
}

function setup_vvv_config() {
	#
}

function provision_vvv() {
	cd $(get_vvv_dir)
	vagrant up --provision
	cd -
}

function trust_root_cert() {
	#
}

if ! is_vbox_installed; then
	install_vbox
fi

if ! is_vagrant_installed; then
	install_vagrant
fi

if ! is_vvv_installed; then
	clone_vvv
	install_vvv_vagrant_plugins
	setup_vvv_config
	provision_vvv
	trust_root_cert
fi