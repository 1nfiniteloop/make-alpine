#!/bin/sh

readonly overlays_dir=$(dirname ${0})

_error()
{
  local msg="${@}"
  >&2 echo "Error in ${FUNCNAME[1]}: ${msg}"
  false
}

_info()
{
  local msg="${@}"
  echo "* ${msg}"
}

rootfs__add_packages()
{
  local packages="${@}"
  echo "Installing: ${packages}..."
  apk add \
    --quiet \
    --no-cache \
    ${packages}
}

rootfs__enable_services_on()
{
  local runlevel="${1}"
  shift
  local all_services="${@}"
  for service in ${all_services}; do
    rc-update add ${service} ${runlevel}
  done
}

# only needed in run-from-ram
rootfs__configure_kernel()
{
  local flavor="${1}"
  local initfs_features="${2}"
  local packages="${3}"
  update-kernel \
      --media \
      --flavor "${flavor}" \
      --feature "${initfs_features}" \
      --package "${packages}" \
      /boot
}

rootfs__add_overlay_from()
{
  local conf_path="${overlays_dir}/${1}.d"
  if [ -e ${conf_path} ]; then
    cp -r ${conf_path}/. /
  else
    _error "no configuration exist: ${conf_path}"
  fi
}
