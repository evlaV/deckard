#!/bin/bash

set -euo pipefail
shopt -s nullglob

# For debugging
#set -x

# These _must_ be set, or nothing works.
REQUIRED_VARIABLES=(
    USB_GADGET_PRODUCT_ID
    USB_GADGET_VENDOR_ID
    USB_GADGET_MANUFACTURER
    USB_GADGET_PRODUCT_NAME
    USB_GADGET_SERIAL
    USB_GADGET_NAME
)
for VAR in "${REQUIRED_VARIABLES[@]}"; do
    if [[ ! -v "${VAR}" ]]; then
        echo "ERROR: Variable '${VAR}' not set!" >&2
        exit 1
    fi
done


COMMAND="${1}"
case "${COMMAND}" in
    start)
        mkdir -p "${USB_GADGET_NAME}/functions"
        mkdir -p "${USB_GADGET_NAME}/configs/c.1"

        echo "${USB_GADGET_VENDOR_ID}" >"${USB_GADGET_NAME}/idVendor"
        echo "${USB_GADGET_PRODUCT_ID}" >"${USB_GADGET_NAME}/idProduct"

        mkdir -p "${USB_GADGET_NAME}/strings/0x409"
        echo "${USB_GADGET_SERIAL}" >"${USB_GADGET_NAME}/strings/0x409/serialnumber"
        echo "${USB_GADGET_MANUFACTURER}" >"${USB_GADGET_NAME}/strings/0x409/manufacturer"
        echo "${USB_GADGET_PRODUCT_NAME}" >"${USB_GADGET_NAME}/strings/0x409/product"

        mkdir -p "${USB_GADGET_NAME}/configs/c.1/strings/0x409"
        echo "${USB_GADGET_PRODUCT_NAME}" >"${USB_GADGET_NAME}/configs/c.1/strings/0x409/configuration"
        echo 120 > "${USB_GADGET_NAME}/configs/c.1/MaxPower"
        ;;
    stop)
        rmdir "${USB_GADGET_NAME}/configs/c.1/strings/0x409"
        # This shouldn't strictly be necessary, but let's be helpful when dealing with unclean shutdowns
        find  "${USB_GADGET_NAME}/configs/c.1" -type l -delete
        for FUNC in "${USB_GADGET_NAME}/functions/"*; do
            rmdir "${FUNC}"
        done
        rmdir "${USB_GADGET_NAME}/configs/c.1"
        rmdir "${USB_GADGET_NAME}/strings/0x409"
        rmdir "${USB_GADGET_NAME}"
        ;;
     *)
        echo "ERROR: Unknown command ${COMMAND}" >&2
        exit 1
        ;;
esac