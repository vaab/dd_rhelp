
# DEPEND on libcolor

[ -n "$exname" ] || exname=$(basename $0)

function print_exit()
{
    echo $@;
    exit 1;
};

function print_syntax_error()
{
    [ "$*" ] ||	print_syntax_error "$FUNCNAME: no arguments"
    print_exit "${ERROR}script error:${NORMAL} $@";
};

function print_syntax_warning()
{
    [ "$*" ] || print_syntax_error "$FUNCNAME: no arguments.";
    [ "$exname" ] || print_syntax_error "$FUNCNAME: 'exname' var is null or not defined.";
    echo "$exname: ${WARNING}script warning:${NORMAL} $@";
};

function print_error()
{
    [ "$*" ] || print_syntax_warning "$FUNCNAME: no arguments.";
    [ "$exname" ] || print_exit "$FUNCNAME: 'exname' var is null or not defined.";
    print_exit "$exname: ${ERROR}error:${NORMAL} $@"
};

function print_warning()
{
    [ "$*" ] || print_syntax_warning "$FUNCNAME: no arguments.";
    [ "$exname" ] || print_syntax_error "$FUNCNAME: 'exname' var is null or not defined.";
    echo "$exname: ${WARNING}warning:${WARNING} $@"
};

function print_usage()
{
    [ "$usage" ] || print_error "$FUNCNAME: 'usage' variable is not set or empty."
    echo "usage: $usage"

#    if [ "$_options" != "" ]
#    then	
	

#    fi
}

function invert_list()
{
    newlist=" "
    for i in $*
    do
      newlist=" $i${newlist}"
    done
    echo $newlist;
};

function depends()
{
    for i in $@
    do
	if ! type $i > /dev/null 2>&1
	then
	   print_error "dependency check : couldn't find '$i' command."
	fi
    done
}

function require()
{
    for i in $@
    do
	if ! type $i > /dev/null 2>&1
	then
	   return 1;
	fi
    done
}

function print_octets ()
{
    [ "$*" ] || print_syntax_error "$FUNCNAME: no arguments.";
    [ "$2" ] && print_syntax_error "$FUNCNAME: too much arguments.";

    [ "$( echo "$1 < 1024" | bc )" == "1" ] && { echo -n "$1 octets"; return 0;}

    kbytes=$(echo "$1 / 1024" | bc );
    [ "$( echo "$kbytes < 1024" | bc)" == "1" ] && { echo -n "$kbytes Ko" ; return 0; }

    mbytes=$(echo "$kbytes / 1024" | bc );
    [ "$( echo "$mbytes < 1024" | bc)" == "1" ] && { echo -n "$mbytes Mo" ; return 0; }
    gbytes=$(echo "$mbytes / 1024" | bc );
    [ "$( echo "$gbytes < 1024" | bc )" == "1" ] && { echo -n "$gbytes Go" ; return 0; }
    tbytes=$(echo "$gbytes / 1024" | bc );
    echo -n "$gbytes To"

}

function checkfile ()
{
    [ "$*" ] || print_syntax_error "$FUNCNAME: no arguments.";
    [ "$3" ] && print_syntax_error "$FUNCNAME: too much arguments.";


    for i in $(echo $1 | sed 's/\(.\)/ \1/g')
    do
	case "$i" in
		"")
			:
		;;
                "e")
                        if ! [ -e "$2" ]
			then 
	                        echo "'$2' is not found."
        	                return 1
			fi;;
		"f")
			if ! [ -f "$2" ]
			then
				echo "'$2' is not a regular file."
				return 1
			fi;;
		"d")
			if ! [ -d "$2" ]
			then
				echo "'$2' is not a directory."
				return 1
			fi;;
		"r")
	                if ! [ -r "$2" ]
			then
	                        echo "'$2' is not readable."
	                        return 1
			fi;;
                "w")
			if ! [ -w "$2" ]
			then
	                        echo "'$2' is not writable."
	                        return 1
			fi;;
                "x")
                        if ! [ -x "$2" ]
			then
	                        echo "'$2' is not executable/openable."
	                        return 1
			fi;;
		"l")
			if ! [ -L "$2" ]
			then
				echo "'$2' is not a symbolic link."
				return 1
			fi;;
	esac
    done

    return 0;
};


