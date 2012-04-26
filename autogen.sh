#!/bin/bash
## Begin autogen.sh


## if ``$LINK`` value is "STATIC", then shell scripts will be modified by
## inlining ``include`` calls.

SHLIB_SCRIPTS="dd_rhelp dd_rhelp.test"
LINK=${LINK:-STATIC}

## List of files that will have %%tags%% replaced
UPDATE_FILES="dd_rhelp"


##
## Functions
##

exname="$(basename "$0")"

function get_path() {
    local type

    type="$(type -t "$1")"
    case $type in
        ("file")
            type -p "$1"
            return 0
            ;;
        ("function" | "builtin" )
            echo "$1"
            return 0
            ;;
    esac
    return 1
}

function print_exit() {
    echo $@
    exit 1
}

function print_syntax_error() {
    [ "$*" ] || print_syntax_error "$FUNCNAME: no arguments"
    print_exit "${ERROR}script error:${NORMAL} $@" >&2
}

function print_syntax_warning() {
    [ "$*" ] || print_syntax_error "$FUNCNAME: no arguments."
    [ "$exname" ] || print_syntax_error "$FUNCNAME: 'exname' var is null or not defined."
    echo "$exname: ${WARNING}script warning:${NORMAL} $@" >&2
}

function print_error() {
    [ "$*" ] || print_syntax_warning "$FUNCNAME: no arguments."
    [ "$exname" ] || print_exit "$FUNCNAME: 'exname' var is null or not defined." >&2
    print_exit "$exname: ${ERROR}error:${NORMAL} $@" >&2
}

function depends() {

    local i tr path

    tr=$(get_path "tr")
    test "$tr" ||
        print_error "dependency check : couldn't find 'tr' command."

    for i in $@ ; do

      if ! path=$(get_path $i); then
          new_name=$(echo $i | "$tr" '_' '-')
          if [ "$new_name" != "$i" ]; then
             depends "$new_name"
          else
             print_error "dependency check : couldn't find '$i' command."
          fi
      else
          if ! test -z "$path" ; then
              export "$(echo $i | "$tr" '-' '_')"=$path
          fi
      fi

    done
}

function die() {
    [ "$*" ] || print_syntax_warning "$FUNCNAME: no arguments."
    [ "$exname" ] || print_exit "$FUNCNAME: 'exname' var is null or not defined." >&2
    print_exit "$exname: ${ERROR}error:${NORMAL} $@" >&2
}

function matches() {
   echo "$1" | "$grep" -E "^$2\$" >/dev/null 2>&1
}

##
## Code
##

depends git sed grep

if ! "$git" rev-parse HEAD >/dev/null 2>&1; then
    die "Didn't find a git repository. autogen.sh uses git to create changelog \
         and version information."
fi

long_tag="[0-9]+\.[0-9]+(\.[0-9]+)?-[0-9]+-[0-9a-f]+"
short_tag="[0-9]+\.[0-9]+(\.[0-9]+)?"

get_short_tag="s/^($short_tag).*\$/\1/g"


function get_current_git_date_timestamp() {
    "$git" show -s --pretty=format:%ct
}


function dev_version_tag() {
    date -d "@$(get_current_git_date_timestamp)" +%Y%m%d%H%M
}


function get_current_version() {

    version=$("$git" describe --tags)
    if matches "$version" "$short_tag"; then
        echo "$version"
    else
        version=$(echo "$version" | "$sed" -r "$get_short_tag")
        echo "${version}.1dev_r$(dev_version_tag)"
    fi

}

function set_meta_tags() {
    local p i short_version patterns year;

    version=$(get_current_version)
    short_version=$(echo "$version" | cut -f 1,2,3 -d ".")

    year=$(date -d "@$(get_current_git_date_timestamp)" +%Y)

    patterns="s/%%version%%/$version/g
s/%%year%%/$year/g
s/%%short-version%%/${short_version}/g"

    for p in $patterns; do
        for f in $UPDATE_FILES ChangeLog; do
            sed -ri $p $f
        done
    done

}


##
## ChangeLog generation
##

if type -t gitchangelog > /dev/null 2>&1 ; then
    GITCHANGELOG_CONFIG_FILENAME="./.gitchangelog.rc" gitchangelog > ChangeLog
    if [ "$?" != 0 ]; then
        print_error "Error while generating ChangeLog."
    fi
    echo "ChangeLog generated."
else
    echo "No changelog generated (gitchangelog not found)"
fi

##
## Set version information
##

set_meta_tags
if [ "$?" != 0 ]; then
    print_error "Error while updating version information."
fi
echo "Version updated to $version."


##
## Launch autoreconf if needed
##

if [ -f configure.ac -o -f configure.in ]; then
    if ! type -p autoreconf >/dev/null; then
        echo "``autoreconf`` not found."
        echo "To autogen this package, please install autotools suite. (package ``autoconf`` in debian)"
        exit 1
    fi

    if ! [ -f README ] && [ -f README.rst ]; then
        cp README.rst README
    fi

    touch NEWS AUTHORS ChangeLog

    autoreconf
fi


if [ "$LINK" == "STATIC" ]; then

    ##
    ## Inlines library code into all shell script that uses ``shlib``
    ##

    depends file find grep

    ### YYYvlab: my problem is that I do not want kal-scripts scripts to be
    ### always inlined... This should be only the case if we want to make
    ### a standalone package...
    ### difference is when we need to make a package, and autogen is to prepare
    ### for installation on local system or for creation of a package.

    ## CWD is the root of the project ?
    if ! [ -f "autogen.sh" ]; then
        print_error "please launch this script from the root directory of this project."
    fi

    ## Get all the shell script, and run ``shlib s <shell-script>`` on it.
    candidates=$(for i in $SHLIB_SCRIPTS;do
	            "$file" -b "$i" | \
        		    "$grep" "shell" | \
		            "$grep" "script" | \
		            "$grep" "text" >/dev/null 2>&1 || continue
	            if grep "^#!- " "$i" 2>&1 >/dev/null; then
        	        echo "$i"
	            fi	
	         done)

    if [ "$candidates" ]; then
        type shlib >/dev/null 2>&1 || print_error "couldn't find the 'shlib' executable..."

        for script in $candidates; do
	    shlib s "$script" || print_error "shlib executable exited with non-zero errorlevel."
            echo "Inlined 'include' calls in $script."
        done

        ## requires shlib to be installed
        if ! [ -e /etc/shlib ]; then

            echo -n "$exname requires kal-shlib-core package to generate a statical"
            echo "version of shell scripts of this package."

            echo "kal-shlib-core is available:"
            echo " - in deb package at:"
            echo "    repository (line to add to your /etc/apt/sources.list):"
            echo "        deb http://deb.kalysto.org no-dist kal-alpha kal-beta kal-main"
            echo "    package-name (command to execute):"
            echo "        apt-get update; apt-get install kal-shlib-core"
            echo " - in source code:"
            echo "    url: "
            echo "        http://github.com/vaab/kal-shlib-core"
            echo "    git (command to clone):"
            echo "        git clone git://github.com/vaab/kal-shlib-core.git"

            exit 1
        fi
    fi
fi



## End autogen.sh
