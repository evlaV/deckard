# Automatically run resize on real serial terminals
if [[ -n "$PS1" ]] && [[ -t 0 ]]; then
    case "$(tty)" in
        # Steam frame serial interface is /dev/ttyMSM0
        /dev/ttyMSM*)
            eval "$(resize 2>/dev/null)"
            ;;
    esac
fi
