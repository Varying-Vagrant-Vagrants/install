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
VVV_ON_LINUX=0
if [[ "$OS" == "Linux" ]]; then
	VVV_ON_LINUX=1
elif [[ "$OS" != "Darwin" ]]; then
	abort "This script is only supported on macOS and Linux."
fi

function is_macos() {
	if [[ "${OS}" != "Darwin" ]]; then
		return 1
	fi
	return 0
}

function is_linux() {
	return VVV_ON_LINUX
}

function is_x86_64() {
	# Fetch CPU architecture
	local ARCH=$(uname -m)
	if [[ "${ARCH}" != "x86_64" ]]; then
		return 1
	fi
	return 0
}

function is_arm64() {
	# Fetch CPU architecture
	local ARCH=$(uname -m)
	if [[ "${ARCH}" != "aarch64" ]]; then
		return 1
	fi
	return 0
}

function is_arch_supported() {
	# return yes if x86_64, no if anything else
	if is_x86_64; then
		return 0
	fi
	return 1
}

function is_homebrew_installed() {
	# /usr/local/bin/brew
	return 0
}

function is_vbox_installed() {
	if ! command -v VBoxManage >/dev/null; then
		return 1
	fi
	return 0
}

function is_vagrant_installed() {
	if ! command -v vagrant >/dev/null; then
		return 1
	fi
	return 0
}

function install_vagrant() {
	if is_homebrew_installed; then
		brew tap hashicorp/tap
		brew install hashicorp/tap/vagrant
	fi
}

function install_vbox() {
	if ! is_x86_64; then
		abort "VirtualBox requires an x86 processor from Intel or AMD, but this machine is not x86_64/Amd64. Are you running under Arm?"
	fi

	if is_homebrew_installed; then
		brew cask --install virtualbox
		abort "You must restart your computer after installing VirtualBox. Do that, then re-run this script."
	fi
}


function install_homebrew() {
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

function is_git_installed() {
	if ! command -v git >/dev/null; then
		return 1
	fi
	return 0
}

function install_git() {
	if is_homebrew_installed; then
		brew install git
	else
		return 1
	fi
}

function get_vvv_dir() {
	echo "~/vvv-local"
}

function is_vvv_cloned() {
	if -d $(get_vvv_dir); then
		return 0
	fi
	return 1
}

function clone_vvv() {
	git clone https://github.com/Varying-Vagrant-Vagrants/VVV.git $(get_vvv_dir)
}

function install_vvv_vagrant_plugins() {
	pushd $(get_vvv_dir)
	vagrant plugin install --local
	popd
}

function setup_vvv_config() {
	#
}

function provision_vvv() {
	pushd $(get_vvv_dir)
	vagrant up --provision
	popd
}

function is_root_cert_trusted() {
	return 0
}

function trust_root_cert() {
	if is_macos then
		pushd $(get_vvv_dir)
		sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain certificates/ca/ca.crt
		popd
	fi
}

if ! is_arch_supported; then
	abort "Unsupported CPU architecture detected, this script only works for 64bit AMD and Intel processors. Arm64/Apple Silicon users should consult the installation instructions instead."
fi

if ! is_vbox_installed; then
	install_vbox
fi

if ! is_vagrant_installed; then
	install_vagrant
fi

if ! is_git_installed; then
	install_git
fi

if ! is_vvv_cloned; then
	clone_vvv
fi

install_vvv_vagrant_plugins
setup_vvv_config
provision_vvv

if ! is_root_cert_trusted; then
	trust_root_cert
fi
