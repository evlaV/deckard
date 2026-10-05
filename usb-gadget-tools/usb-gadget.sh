#!/bin/bash

set -euo pipefail

# For debugging
#set -x

# These _must_ be set, or nothing works.
REQUIRED_VARIABLES=(
    USB_GADGET_NAME
)
for VAR in "${REQUIRED_VARIABLES[@]}"; do
    if [[ ! -v "${VAR}" ]]; then
        echo "ERROR: Variable '${VAR}' not set!" >&2
        exit 1
    fi
done

# This must be run in the {configfs}/usb_gadget directory
if [[ ! -e "${USB_GADGET_NAME}/UDC" ]]; then
    echo "ERROR: Must be run in the usb_gadget directory!" >&2
    exit 1
fi

COMMAND="${1}"
case "${COMMAND}" in
    start)
        # If no functions are declared, just silently pass
        if [[ -z "$(find "${USB_GADGET_NAME}/configs/c.1" -type l 2>/dev/null)" ]]; then
            echo "No functions in configuration, early-exit"
            exit 0
        fi
    
        # Allow an unset value here to default to the first `udc` that exists
        if [[ -z "${USB_GADGET_CONTROLLER:-}" ]]; then
            USB_GADGET_CONTROLLER="$(ls /sys/class/udc | head -1)"
        fi
        echo "${USB_GADGET_CONTROLLER}" > "${USB_GADGET_NAME}/UDC"
        ;;
    stop)
        echo > "${USB_GADGET_NAME}/UDC"
        ;;
     *)
        echo "ERROR: Unknown command ${COMMAND}" >&2
        exit 1
        ;;
esac
