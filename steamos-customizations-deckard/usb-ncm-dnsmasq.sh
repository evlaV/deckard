#!/bin/bash

set -euo pipefail

# Generate a dnsmasq config.  We are going to reserve 10.86.${IF_NET}.233/29, which we allocate as:
#
#   10.86.${IF_NET}.232      - Network address
#   10.86.${IF_NET}.233      - The frame device
#   10.86.${IF_NET}.234      - The PC host, identified by USB-ncm mac address, as specified in the gadget above
#   10.86.${IF_NET}.235-238  - DHCP leases for VMs, subhosts, etc...
#   10.86.${IF_NET}.239      - Broadcast Address
#
# We move `IF_NET` into the `20X` range to be as unlikely to conflict with a random `10.X.0.0` subnet as possible.

COMMAND="${1}"
IF_NAME="${2}"
IF_IDX="${IF_NAME#usb}"
IF_NET="$((${IF_IDX} + 200))"

case "${COMMAND}" in
    start)
        # Wait for `usbX` to appear.  If it never appears that's fine, when the user replugs their USB cable
        # we'll get killed.
        while [[ ! -e /sys/class/net/${IF_NAME} ]]; do
            sleep 0.1
        done

        # Bring up the interface, set a static IP address
        ip addr add "10.86.${IF_NET}.233/29" dev "${IF_NAME}"
        ip link set "${IF_NAME}" up

        # We default to the same firewall setup as on the softap
        firewall-cmd --zone=nm-shared --add-interface="${IF_NAME}" 2>/dev/null || true
        firewall-cmd --zone=nm-shared --add-port=1024-65535/{tcp,udp} 2>/dev/null || true

        # Read out the dev and host addresses that were previously set by `usb-ncm-gadget.sh`
        DEV_ADDR="$(strings "/sys/kernel/config/usb_gadget/${USB_GADGET_NAME}/functions/ncm.${IF_NAME}/dev_addr")"
        HOST_ADDR="$(strings "/sys/kernel/config/usb_gadget/${USB_GADGET_NAME}/functions/ncm.${IF_NAME}/host_addr")"

        cat >"/var/run/dnsmasq_${IF_NAME}.conf" <<-EOF
interface=${IF_NAME}
except-interface=lo
dhcp-range=10.86.${IF_NET}.235,10.86.${IF_NET}.238,12h
bind-interfaces

dhcp-host=${DEV_ADDR},10.86.${IF_NET}.233,infinite
dhcp-host=${HOST_ADDR},10.86.${IF_NET}.234,infinite
dhcp-option=3
dhcp-option=6
EOF
        ;;

    stop)
        firewall-cmd --zone=nm-shared --remove-interface="${IF_NAME}" 2>/dev/null || true
        ip link set "${IF_NAME}" down 2>/dev/null || true
        rm -f "/var/run/dnsmasq_${IF_NAME}.conf"
        ;;

    *)
        echo "ERROR: Unknown command ${COMMAND}" >&2
        exit 1
        ;;
esac