#!/bin/bash
 
#@
#@ ==============================================================================
#@
#@ ZEN'S BASH TEMPLATE SCRIPT
#@ bash script template for creating scripts that supports commands 
#@ 
#@ example:
#@ zenbash.sh helloworld "HELL YEAH"
#@
#@ (c) 2010 zen sugiarto / zugiart.com
#@ you can find this script + my bash notes at zugiart.com/wiki/bash 
#@ 
#@ ==============================================================================
#@
 
 
 
_mypid=$$
_appName=displayService
_app_tmp_baseline="/tmp/$_appName.xrandr.baseline"
_app_tmp_current="/tmp/$_appName.xrandr.current"
 
 
# =============================================================================================================
# HELPER METHOD
# =============================================================================================================
 
 
function log()
{		
	# modify accordingly if you want msg to go to files etc
	echo "`date +'%Y.%m.%d %H:%M:%S'` INFO  | $1"
}
 
function error()
{
	echo "`date +'%Y.%m.%d %H:%M:%S'` ERROR | $1"
}
 
# =============================================================================================================
# CMD DEFINITION
# =============================================================================================================
 
#% 
#@ help 
#@  - show help for a given cmd. if not specified, shows all help cmd 
#@ 
#%  
function help() {
	cmd=$1
	if [ "$cmd" == "" ]; then
		cat $0 | grep "#@" | grep -v "grep \"#@\"" | cut -d'@' -f2-1000
	else
		strcmd="sed -n '/<doc:$cmd>/,/<\/doc:$cmd>/p' $0"
		eval $strcmd | grep -v "#%" | cut -d'@' -f2-1000
	fi
}
 

#% 
#@ init 
#@  - initiates xrandr  
#% 
function init() {
	rm "$_app_tmp_current"
	rm "$_app_tmp_baseline" 
}
 
#% 
#@ check  
#@   - check if display have changed via xrandr. if no change done
#@     will outout a line with #NODIFF. Else, will print out the content
#@     of the latest xrandr output
#% 
function check()
{
	xrandr > /tmp/$_appName.xrandr.current
	if [ ! -e /tmp/$_appName.xrandr.baseline ]; then
		cat /tmp/$_appName.xrandr.current
	else
		diff /tmp/$_appName.xrandr.current /tmp/$_appName.xrandr.baseline &> /dev/null
		if [ $? == 0 ]; then
			echo "#NODIFF `date +'%Y/%m/%d %H:%M:%S'`"
		else
			cat /tmp/$_appName.xrandr.current	
		fi
	fi
	cp /tmp/$_appName.xrandr.current /tmp/$_appName.xrandr.baseline
}
 

# =============================================================================================================
# MAIN BLOCK
# =============================================================================================================
 
_cmd="help"
if [ "$1" != "" ]; then _cmd=$1; fi
$_cmd "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "${10}" "${11}" "${12}"
result=$?
if [ $result == 127 ]; then
	error "Command not found: $1"
	help
elif [ $result != 0 ]; then
	help $1
fi
exit $result