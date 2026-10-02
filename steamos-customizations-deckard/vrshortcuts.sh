# Helpful navigation shortcuts for SteamVR
alias cdd='cd "$(steamvr path)/bin/linuxarm64/"'
alias cdc='cd "$(steamvr configpath)"'
alias cdl='cd "$(steamvr logpath)"'
alias cds='cd "${HOME}/.steam/steam/"'

streaming()
{
	case "${1}" in
		start)
			steamvr cmd --mailboxcmd web_steam_mailbox 'toggle_voicechat?enable=true'
			steamvr cmd --mailboxcmd web_steam_mailbox 'toggle_videobroadcast?enable=true'
			;;
		stop)
			steamvr cmd --mailboxcmd web_steam_mailbox 'toggle_videobroadcast?enable=false'
			steamvr cmd --mailboxcmd web_steam_mailbox 'toggle_voicechat?enable=false'
			;;
		restart)
			streaming stop
			streaming start
			;;
		*)
			echo "Usage: streaming [stop/start/restart]" >&2
			return 1
			;;
	esac
}
export -f streaming
complete -W "start stop restart" streaming

video_capture()
{
	# Parse arguments
	local TIMESTAMP="true"
	local OUTPUT_FILENAME="${HOME}/video_captures/video_capture-$(date "+%Y-%m-%d-%H-%M-%S").mp4"
	while [[ $# -gt 0 ]]; do
		case "$1" in
			--help)
				echo "Usage: $0 [--no-timestamp] [/path/to/output.mp4]"
				return 0
				;;
			--no-timestamp)
				TIMESTAMP="false"
				shift
				;;
			*)
				OUTPUT_FILENAME="$1"
				shift
				;;
		esac
	done

	# Make directory to store video capture into
	mkdir -p "$(dirname "${OUTPUT_FILENAME}")"
	chown $(id -u steamos):$(id -g steamos) "$(dirname "${OUTPUT_FILENAME}")"

	# Use ffmpeg to capture video and audio output
	echo "Capturing to ${OUTPUT_FILENAME}, use CTRL-C to stop..."

	DEFAULT_SINK=$(pactl info | grep 'Default Sink' | tr -d ' ' | cut -f 2 -d ':')

	FFMPEG_AUDIO_ARGS=(
		# Use pulse
		-f pulse
		# Read from our output monitor device
		-i "${DEFAULT_SINK}.monitor"
	)

	FFMPEG_VIDEO_ARGS=(
		# Use v4l2
		-f v4l2
		# Read from our special SteamVR loopback device
		-i /dev/video99
		# Use H264
		-c:v libx264 -preset ultrafast -pix_fmt yuv420p
		# Medium-ish quality
		-b:a 128k
		# Quiet, do what I say
		-loglevel error -hide_banner -y
	)

	if [[ "$TIMESTAMP" == "true" ]]; then
		# Add a video filter to insert a timestamp
		FFMPEG_VIDEO_ARGS+=(
			-vf drawtext=text='%{pts\\:hms}':fontcolor=white:fontsize=24:x=10:y=10
		)
	fi

	# Here we're just hoping to remove some blank frames at the start of the video 'most of the time', and trust that it actually starts
	timeout 1 ffmpeg -f v4l2 -i /dev/video99 -frames:v 4 -f null - -v error 2>/dev/null

	# Do the actual capture
	ffmpeg "${FFMPEG_AUDIO_ARGS[@]}" "${FFMPEG_VIDEO_ARGS[@]}" "${OUTPUT_FILENAME}"
}

screenshot()
{
	local OUTPUT_FILENAME="${1:-${HOME}/screenshots/screenshot-$(date "+%Y-%m-%d-%H-%M-%S").png}"
	local VRCMD="$(cdd && pwd)/run_vrcmd.sh"

	# Make directory to store video capture into
	mkdir -p "$(dirname "${OUTPUT_FILENAME}")"

	# Use ffmpeg to capture video and audio output
	echo "Capturing to ${OUTPUT_FILENAME}..."

	# VRCMD is async, wait for frames:
	# Even when recording is disabled, the video device outputs roughly 2 blank frames a second
	# Wait for 5 frames over a second, accounting for the async delay should be enough to confirm video has started
	# Not 100% reliable, it'll still capture a blank on occasion or declare that the video isn't active..
	if timeout 1 ffmpeg -f v4l2 -i /dev/video99 -frames:v 4 -f null - -v error 2>/dev/null; then
		# get our screenshot
		ffmpeg -f v4l2 -i /dev/video99 -frames:v 1 -q:v 1 -loglevel error -hide_banner -y "${OUTPUT_FILENAME}"
	else
		echo "Could not detect video."
	fi
}

# Auto-include lepton completion and add it to the path, if it's installed.
_LEPTON_DIR="${HOME}/.steam/steam/steamapps/common/Lepton"
if [[ -f "${_LEPTON_DIR}/liblepton/completions.sh" ]]; then
	export PATH="${PATH}:${_LEPTON_DIR}"
	source "${_LEPTON_DIR}/liblepton/completions.sh"
fi
unset _LEPTON_DIR
