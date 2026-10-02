#!/bin/bash

shopt -s nullglob

# systemd passes `setup usb0` or somesuch to us
COMMAND="${1}"
IF_NAME="${2}"

if [[ ! -v "USB_GADGET_NAME" ]]; then
    echo "ERROR: Variable 'USB_GADGET_NAME' not set!" >&2
    exit 1
fi

# This must be run in the {configfs}/usb_gadget directory
if [[ ! -e "${USB_GADGET_NAME}/UDC" ]]; then
    echo "ERROR: Must be run in the usb_gadget directory!" >&2
    exit 1
fi


case "${COMMAND}" in
    start)
        # Hash the USB interface name to generate MAC addresses.
        # Seed with wifi mac address to make this unique per-device.
        WIFI_MAC="$(/usr/lib/deckard-eeprom/eeprom_console get mac_addr_wifi 2>/dev/null)"
        # Echo out something like `1a2b3c4d`
        ADDR_SUFFIX="$(sha256sum <<<"${WIFI_MAC}${IF_NAME}" | cut -f1 -d' ' | head -c 8)"

        HOST_MAC="02:00:$(sed -E 's/(..)/\1:/g;s/:$//' <<<"${ADDR_SUFFIX}")"
        DEV_MAC="02:01:$(sed -E 's/(..)/\1:/g;s/:$//' <<<"${ADDR_SUFFIX}")"

        # Configure host and device mac addresses
        mkdir -p "${USB_GADGET_NAME}/functions/ncm.${IF_NAME}"

        echo "${HOST_MAC}" >"${USB_GADGET_NAME}/functions/ncm.${IF_NAME}/host_addr"
        echo "${DEV_MAC}" >"${USB_GADGET_NAME}/functions/ncm.${IF_NAME}/dev_addr"

        # Enable the config
        ln -Tsvf "${USB_GADGET_NAME}/functions/ncm.${IF_NAME}" "${USB_GADGET_NAME}/configs/c.1/ncm.${IF_NAME}"
        ;;

    stop)
        rm -f "${USB_GADGET_NAME}/configs/c.1/ncm.${IF_NAME}"
        rmdir "${USB_GADGET_NAME}/functions/ncm.${IF_NAME}"
        ;;
    *)
        echo "ERROR: Unknown command ${COMMAND}" >&2
        exit 1
        ;;
esac
