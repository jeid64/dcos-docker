#!/bin/bash
set -e

# usage: ./generate.sh [versions]
#    ie: ./generate.sh
#        to update all Dockerfiles in this directory
#    or: ./generate.sh debian-jessie
#        to only update debian-jessie/Dockerfile
#    or: ./generate.sh debian-newversion
#        to create a new folder and a Dockerfile within it

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
fi
versions=( "${versions[@]%/}" )

for version in "${versions[@]}"; do
	distro="${version%-*}"
	suite="${version##*-}"
	from="${distro}:${suite}"
	if [[ "$distro" == "coreos" ]]; then
		from="jess/coreos"
	fi

	mkdir -p "$version"
	echo "$version -> FROM $from"
	cat > "$version/Dockerfile" <<-EOF
	#
	# THIS FILE IS AUTOGENERATED; SEE "distros/generate.sh"!
	#

	FROM $from
	EOF

	echo >> "$version/Dockerfile"

	# this list is sorted alphabetically; please keep it that way
	packages=(
	aufs-tools # for the aufs graphdriver
	bash-completion # for bash-completion integration
	btrfs-tools # for "btrfs/ioctl.h" (and "version.h" if possible)
	curl ca-certificates # for downloading Go
	git # for "git commit" info in "docker -v"
	iproute ipset iptables # for ip, iptables commands
	iputils-ping # ping
	libcgroup-dev # for cgroup support
	libpopt0 # needed by logrotate binary
	nano # editor for dev purposes
	net-tools
	openssh-client openssh-server # for doing installs via ssh
	sudo
	systemd
	tar
	tree
	unzip
	vim-nox # editor for dev purposes
	which # make hdfs work
	xz-utils
	)

	# add libselinux-utils for centos, fedora & rhel
	case "$distro" in
		centos|fedora|rhel) packages+=( libselinux-utils );;
		*) ;;
	esac

	# change package names for centos, fedora & rhel
	case "$distro" in
		centos|fedora|rhel)
			packages=( "${packages[@]/aufs-tools/}" )
			packages=( "${packages[@]/btrfs-tools/btrfs-progs}" )
			packages=( "${packages[@]/iputils-ping/iputils}" )
			packages=( "${packages[@]/libcgroup-dev/libcgroup}" )
			packages=( "${packages[@]/libpopt0/}" )
			packages=( "${packages[@]/vim-nox/vim-minimal}" )
			packages=( "${packages[@]/xz-utils/xz}" )
			;;
		debian|ubuntu) packages+=( gawk );; ## needs GNU awk
		*) ;;
	esac

	if [[ "$distro" == "fedora" ]]; then
		packages=( "${packages[@]/openssh-client/openssh-clients}" )
	fi

	case "$distro" in
		centos|rhel)
			echo "RUN yum install -y ${packages[*]} \\" >> "$version/Dockerfile"
			;;
		fedora)
			echo "RUN dnf install -y ${packages[*]} \\" >> "$version/Dockerfile"
			;;
		debian|ubuntu)
			echo "RUN apt-get update && apt-get install -y ${packages[*]} --no-install-recommends && rm -rf /var/lib/apt/lists/* \\" >> "$version/Dockerfile"
			;;
		*) ;;
	esac

	if [[ "$distro" != "coreos" ]]; then
		cat >> "$version/Dockerfile" <<-'EOF'
		&& ( \
			cd /lib/systemd/system/sysinit.target.wants/; \
			for i in *; do \
				if [ "$i" != "systemd-tmpfiles-setup.service" ]; then \
					rm -f $i; \
				fi \
			done \
			) \
			&& rm -f /lib/systemd/system/multi-user.target.wants/* \
			&& rm -f /etc/systemd/system/*.wants/* \
			&& rm -f /lib/systemd/system/local-fs.target.wants/* \
			&& rm -f /lib/systemd/system/sockets.target.wants/*udev* \
			&& rm -f /lib/systemd/system/sockets.target.wants/*initctl* \
			&& rm -f /lib/systemd/system/anaconda.target.wants/* \
			&& rm -f /lib/systemd/system/basic.target.wants/* \
			&& rm -f /lib/systemd/system/graphical.target.wants/* \
			&& ln -vf /lib/systemd/system/multi-user.target /lib/systemd/system/default.target
		EOF
	fi
done
