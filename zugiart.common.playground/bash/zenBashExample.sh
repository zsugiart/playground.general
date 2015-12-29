#!/bin/bash
 
#@
#@ ==============================================================================
#@
#@ ZEN'S BASH EXAMPLES
#@ example script that shows some of bash' most commonly used function
#@ uses the zkeleton.sh template to create the script quickly...
#@ 
#@ example:
#@ ./zenBashExample.sh test_forever
#@
#@ (c) 2014 zen sugiarto / zugiart.com
#@ 
#@ ==============================================================================
#@

# =============================================================================================================
# CONFIG
# =============================================================================================================
 
__SCRIPT_NAME="zenBashExample"
 
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
 
#% <doc:test_defaultVariables>
#@ test_defaultVariables [var1] [var2] ... [varN]
#@  - test default variables..
#@ 
function test_defaultVariables() {

	log_info ">>> test_defaultVariables"

	# print cmd line params
	log_info "how many cmd line params passed? $#"

	# check for memory
	free -m
	_result=$?
	# if $? == 127, means the command 'free' is not available on the OS
	log_info "did last command run OK? $_result"
}
 
#% <doc:test_stringManipulation>
#@ test_stringManipulation
#@  - test common string manipulation commands
#@
#% </doc:test_stringManipulation>
function test_stringManipulation()
{
	log_info ">>> test_stringManipulation"

	# given this file path
	thePath="/opt/someDir/someCoolFile.tar.gz"
 
	# doing this will give you...
	dirPath=${thePath%/*}    # /opt/someDir
	fileName=${thePath##*/}  # someCoolFile.tar.gz
	fileBase=${fileName%%.*} # someCoolFile
	fileExt=${fileName#*.}   # .tar.gz
 
	# So how does this work anyway?
	# ${variable%pattern}      # Trim the shortest match from the end
	# ${variable##pattern}     # Trim the longest match from the beginning
	# ${variable%%pattern}     # Trim the longest match from the end
	# ${variable#pattern}      # Trim the shortest match from the beginning

	log_info "fullPath=$thePath"
	log_info "$dirPath /// $filePath /// $fileBase /// $fileExt"
}

#% <doc:test_forever>
#@ test_forever
#@ - call all function that begins with test_ by inspecting their zenbashdoc comment
#@   note: this will trigger an infite loop because this function also starts with test_ :P
#% </doc:test_forever>
function test_forever()
{
	log_info ">>> test_forever"
	log_info "running all function whose name begin with test_, including this one.."
	# bash does not have reflection. The documentation trick here (using <doc:>
	# allows the use of cat and grep to identify how many functions are out there
	functionList=$(cat zenBashExample.sh | grep "<doc:test_" | grep -v "grep" | cut -d':' -f2 | cut -d'>' -f1)
	# that being said, this will be an infinite loop..
	for testCmd in $functionList; do
		# runs the command
		eval $testCmd;
	done
}

# =============================================================================================================
# MAIN BLOCK
# =============================================================================================================

if [ "" == "$1" ]; then
	cmd="help";
else
	cmd="$1";
fi

"$cmd" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "${10}" "${11}" "${12}"

result=$?
if [ $result == 127 ]; then
	log_error "Command not found: $1"
	help
elif [ $result != 0 ]; then
	help $1
fi
exit $result
