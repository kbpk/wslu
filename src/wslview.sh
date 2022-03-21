# shellcheck shell=bash
version="10"

lname=""

help_short="$0 [-hvur]\n$0 [-E ENGINE] LINK/FILE"

function del_reg_alt {
	if [ "$distro" == "archlinux" ] || [ "$distro" == "alpine" ]; then
		echo "${error} Unsupported action for this distro. Aborted. "
		exit 34
	else
		sudo update-alternatives --remove x-www-browser "$(readlink -f "$0")"
		sudo update-alternatives --remove www-browser "$(readlink -f "$0")"
		exit
	fi
}

function add_reg_alt {
	if [ "$distro" == "archlinux" ] || [ "$distro" == "alpine" ]; then
		error_echo "Unsupported action for this distro. Aborted." 34
	else
		sudo update-alternatives --install "$wslu_prefix"/bin/x-www-browser x-www-browser "$(readlink -f "$0")" 1
		sudo update-alternatives --install "$wslu_prefix"/bin/www-browser www-browser "$(readlink -f "$0")" 1
		exit
	fi
}

for args; do
	case $args in
		-r|--reg-as-browser) add_reg_alt;;
		-u|--unreg-as-browser) del_reg_alt;;
		-h|--help) help "$0" "$help_short"; exit;;
		-v|--version) echo "wslu v$wslu_version; wslview v$version"; exit;;
		-E|--engine) WSLVIEW_DEFAULT_ENGINE="$1"; shift;;
		*) lname="$lname$args";;
	esac
done

if [[ "$lname" != "" ]]; then
	wslutmpbuild=$(wslu_get_build)
	# file:/// protocol used in linux
	if [[ "$lname" =~ ^file:\/\/.*$ ]] && [[ ! "$lname" =~ ^file:\/\/(\/)+[A-Za-z]\:.*$ ]]; then
		[ $wslutmpbuild -ge "$BN_MAY_NINETEEN" ] || error_echo "This protocol is not supported before version 1903." 34
		properfile_full_path="$(readlink -f "${lname//file:\/\//}")"
	# Linux absolute path
	elif [[ "$lname" =~ ^(/[^/]+)*(/)?$ ]]; then
		[ $wslutmpbuild -ge "$BN_MAY_NINETEEN" ] || error_echo "This protocol is not supported before version 1903." 34
		properfile_full_path="$(readlink -f "${lname}")"
	# Linux relative path
	elif [[ -d "$(readlink -f "$lname")" ]] || [[ -f "$(readlink -f "$lname")" ]]; then
		[ $wslutmpbuild -ge "$BN_MAY_NINETEEN" ] || error_echo "This protocol is not supported before version 1903." 34
		properfile_full_path="$(readlink -f "${lname}")"
	fi
	if [[ "$WSLVIEW_DEFAULT_ENGINE" == "powershell" ]]; then
		winps_exec Start "\"$(wslpath -w "$properfile_full_path" 2>/dev/null || echo "$lname")\""
	elif [[ "$WSLVIEW_DEFAULT_ENGINE" == "cmd" ]]; then
		cmd_exec start "\"$(wslpath -w "$properfile_full_path" 2>/dev/null || echo "$lname")\""
	elif [[ "$WSLVIEW_DEFAULT_ENGINE" == "cmd_explorer" ]]; then
		cmd_exec explorer.exe "\"$(wslpath -w "$properfile_full_path" 2>/dev/null || echo "$lname")\""
	fi
else
	error_echo "No input, aborting" 21
fi
