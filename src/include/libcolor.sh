
# If COLUMNS hasn't been set yet (bash sets it but not when called as
# sh), do it ourself

if [ -z "$COLUMNS" ]
then
    # Get the console device if we don't have it already
    # This is ok by the FHS as there is a fallback if
    # /usr/bin/tty isn't available, for example at bootup.

    test -x /usr/bin/tty && CONSOLE=`/usr/bin/tty`
    test -z "$CONSOLE" && CONSOLE=/dev/console

    # Get the console size (rows columns)

    stty size > /dev/null 2>&1
    if [ "$?" == 0 ]
    then
	[ "$CONSOLE" == "/dev/console" ] && SIZE=$(stty size < $CONSOLE) \
                                         || SIZE=$(stty size)

        # Strip off the rows leaving the columns

        COLUMNS=${SIZE#*\ }
    else
	COLUMNS=80
    fi

fi

COL=$[$COLUMNS - 10]
WCOL=$[$COLUMNS - 30]
SCOL=$[$COLUMNS - 4]
LCOL=$[$COLUMNS - 1]



SET_COL=$(echo -en "\\033[${COL}G")
SET_SCOL=$(echo -en "\\033[${SCOL}G")
SET_WCOL=$(echo -en "\\033[${WCOL}G")
SET_LCOL=$(echo -en "\\033[${LCOL}G")

SET_BEGINCOL=$(echo -en "\\033[0G")



NORMAL=$(echo -en "\\033[0;37m")
RED=$(echo -en "\\033[1;31m")
GREEN=$(echo -en "\\033[1;32m")
YELLOW=$(echo -en "\\033[1;33m")
BLUE=$(echo -en "\\033[1;34m")
GRAY=$(echo -en "\\033[1;30m")
WHITE=$(echo -en "\\033[1;37m")

SUCCESS=$GREEN
WARNING=$YELLOW
FAILURE=$RED
NOOP=$BLUE
ON=$SUCCESS
OFF=$FAILURE
ERROR=$FAILURE

