#!/bin/bash

# do not run adbd if tmp file set to block.  This allows MTE test packages such as ftm to
# create their own usb gadgets.  Remove `/tmp/adbd_block` once MTE test packages are updated.
if [[ -f /tmp/adbd_block ]] || [[ -f /tmp/usb_gadget_block ]]; then
    exit 0
fi

start_services()
{
    # Start the target, which pulls in all services (including any USB interface we're dealing with)
    systemctl enable usb-ncm-gadget@${USB_IF}
    systemctl start --no-block usb-gadget.target
}

stop_services()
{
    # Stop the service, which just unbinds.  Services like `adbd` will auto-stop as well,
    # due to their `PartOf=` on `usb-gadget.service`.  This minimizes the amount of work
    # we have to do to set things up again, if we wanted a clean restart we'd stop
    # `usb-gadget.target` entirely, and re-set everything up again.
    systemctl stop --no-block usb-gadget.service
}

exec > >(systemd-cat -t typc-plug-event) 2>&1

# It's incredibly difficult to get udev to play nice with us looking for the `data_role` attribute.
# Only the "change" events on the port itself have it, but it fires like 10 change events every time
# you breathe on the cable, and even worse the first few events have one `data_role`, and the last
# few have a totally different `data_role`.  We give up making this ideal and instead just wait for
# a second and read the `data_role` ourselves straight from `sysfs`.
PARTNER="$1"
ACTION_VALUE="$2"
PORT="${PARTNER%-partner}"
DATA_ROLE_PATH="/sys/class/typec/$PORT/data_role"

# We'll name our usb interface after the typec port; e.g. if `${PORT}` == `port0`
# then our interface name will be `usb0`.
USB_IF="usb${PORT#port}"

if [ "$ACTION_VALUE" == "add" ]; then
    # Wait for USB-C negotiation to finish
    sleep 1

    if [[ "$(cat "${DATA_ROLE_PATH}")" == *"[device]"* ]]; then
        start_services
    else
        stop_services
    fi
elif [ "$ACTION_VALUE" == "remove" ]; then
    stop_services
fi

