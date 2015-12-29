#!/bin/bash
 
#@
#@ ==============================================================================
#@
#@ ZEN'S BASH TEMPLATE SCRIPT
#@ bash script template for creating scripts that supports commands 
#@ each command is declared as a function. to add new command, just add new
#@ function with the same name. run this script and inspect its command.
#@ 
#@ example:
#@ zenbash.sh helloworld "HELL YEAH"
#@
#@ (c) 2014 zen sugiarto / zugiart.com
#@ 
#@ ==============================================================================
#@

# =============================================================================================================
# CONFIG
# =============================================================================================================
 
__SCRIPT_NAME="based"
 
# =============================================================================================================
# HELPER METHOD
# =============================================================================================================
 
 
function log_info()
{		
	# modify accordingly if you want msg to go to files etc
	echo "`date +'%Y.%m.%d %H:%M:%S'` | $__SCRIPT_NAME | INFO  | $1"
}
 
function log_error()
{
	echo "`date +'%Y.%m.%d %H:%M:%S'` | $__SCRIPT_NAME | ERROR | $1"
}

#% <doc:help>
#@ help
#@  - show help for a given cmd. if not specified, shows all help cmd
#@    example: help helloworld
#@
#% </doc:help>
function help() {
        cmd=$1
        if [ "$cmd" == "" ]; then
                cat $0 | grep "#@" | grep -v "grep"  | cut -d'@' -f2-1000
        else
                strcmd="sed -n '/<doc:$cmd>/,/<\/doc:$cmd>/p' $0"
                eval $strcmd | grep -v "#%" | cut -d'@' -f2-1000
        fi
}
 
# =============================================================================================================
# CMD DEFINITION
# =============================================================================================================
 
#% <doc:helloworld>
#@ helloworld <param1:msg> 
#@  - prints a hello world message with additional parameter
#@    example: helloworld "world hello"
#@ 
#% </doc:helloworld>
function start() {
	log_info "STARTING"
}

function status() {
	log_info "STATUS"
}
 
#% <doc:cmd1>
#@ cmd1
#@  - substitue this with your command
#@
#% </doc:cmd1>
function stop()
{
	log_info "STOPPING"
}

# =============================================================================================================
# MAIN BLOCK
# =============================================================================================================

# if no command passed, exit
if [ "" == "$1" ]; then cmd="help"; else cmd="$1"; fi

# if cmd is passed, call it passing in all parameter (up to 12th..)
"$cmd" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "${10}" "${11}" "${12}"

# check result, if cmd not found exit & print help
result=$?
if [ $result == 127 ]; then
	log_error "Command not found: $1"
	help
elif [ $result != 0 ]; then
	# if cmd is found, but exit is still nonzero, print help for that command
	help $1
fi
# whatever the result, return the exit code from the command
exit $result

