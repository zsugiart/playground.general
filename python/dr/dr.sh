#!/bin/bash

#@
#@ ==============================================================================
#@ * DR. King Schultz *
#@ The good doctor. Django's helper script that works with virtualenv,
#@ git, mysql install, and whatnot
#@ assumes: python2.7, compatible virtualenv, and mysql installed.
#@ ==============================================================================
#@

# =============================================================================================================
# CONFIG
# =============================================================================================================

__SCRIPT_NAME="Dr.K"

# support for PYTHON3 ™

export CMD_PIP='pip3'
export CMD_PYTHON='python3'
export CMD_VENV='virtualenv'

# VENV_DIR = set as env variable, points to the directory of virtualenv

# =============================================================================================================
# HELPER METHOD
# =============================================================================================================

function log_info()
{
	echo "`date +'%Y.%m.%d %H:%M:%S'` | $__SCRIPT_NAME | INFO  | $1"
}

function log_header()
{
	echo -e "\033[94m`date +'%Y.%m.%d %H:%M:%S'` | $__SCRIPT_NAME | # $1\033[0m"
}

function log_warn()
{
  echo -e "\033[33m`date +'%Y.%m.%d %H:%M:%S'` | $__SCRIPT_NAME | WARN  | $1\033[0m"
}

function log_error()
{
	echo -e "\033[91m`date +'%Y.%m.%d %H:%M:%S'` | $__SCRIPT_NAME | ERROR | $1\033[0m"
}

#% <doc:help>
#@ help
#@   shows this msg
#@
#% </doc:help>
function cmd_help() {
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


function __venvcheck() {

	log_header "Base cmd check"

	which $CMD_PYTHON
	__iferrmsg "$CMD_PYTHON is not properly configured"

	which $CMD_PIP
	__iferrmsg "$CMD_PIP is not properly configured"

	which $CMD_VENV
	__iferrmsg "$CMD_PYTHON is not properly configured"

	if [ -z ${VENV_DIR} ]; then
	   log_error "Env variable VENV_DIR is not set. Please set it to the location of virtual env folder"
	   exit -1
	else
	   log_info "VENV_DIR is set to $VENV_DIR"
	fi

	if [ -d "$VENV_DIR" ]; then
	   log_info "VENV_DIR exist"
	else
	   log_error "directory does not exist: $VENV_DIR "
	   exit -1
	fi

	log_header "VirtualEnv check"

    if [ ! -e $VENV_DIR/bin/activate ]; then
      log_info "$VENV_DIR/bin/activate not found - virtualenv not yet initiated"
    else
      log_info "$VENV_DIR/bin/activate found - virtualenv is initiated"
    fi

    if [ "True" != $($CMD_PYTHON -c "import sys; print(hasattr(sys,'real_prefix'))") ]; then
        log_error "virtual env environment is NOT activated, you need to activate it first. try:"
        log_error "source $VENV_DIR/bin/activate"
        exit -1
    else
        log_info "virtual environment is activated!"
    fi

	if [[ $1 == "-d" ]]; then
	  log_info "django project system check"
	  $CMD_PYTHON manage.py check
	  if [ $? != 0 ]; then
	    log_error "Something is screwed up with your Django code, can you check above?"
	    exit -1;
	  fi
	fi
}

function __iferrmsg() {
  if [ $? != 0 ]; then
    log_error "$1"
    exit $?
  fi
}


#% <doc:>
#@ init
#@   initialize the djzen project. downloads requirement.txt file
#@
#% </doc:>
function cmd_init() {
	exit 1
}


#% <doc:>
#@ package <1:appName>
#@   app must have a pkg directory with MANIFEST, README, etc file in there
#@
#% </doc:>
function cmd_pkg() {
	log_header "================================ PKG(app:$1) ====================================="

	if [ "$1" == "" ]; then
		log_error "please specify an appname"
		return -1
	else
		# if directory found, check pkg structure
		if [ -d "$appName/pkg" ]; then
			log_error "appName $1 does not have a pkg directory";
			return -1;
		else
			log_info "appName $1 pkg dir found"
			ls -altrh $appName/pkg
		fi
		if [ ! -e "$appName/pkg/setup.py" ]; then
			log_error "appName $1 does not have a setup.py in the pkg dir";
			return -1;
		fi
	fi
	appName=$1

	log_info "preparing directory _dist/django-$appName.."
	rm -rf "_dist/django-$appName"
	mkdir -p "_dist/django-$appName"
	log_info "assembling file structure..."
	cp -rf "$appName" "_dist/django-$appName"
	mv _dist/django-$appName/$appName/pkg/* _dist/django-$appName/
	log_info "building package"
	#rm -rf "_dist/django-$appName/$appName/pkg/"
	$CMD_PYTHON "_dist/django-$appName/setup.py" sdist
	find "_dist/django-$appName" -name "*.pyc"
	log_info "distribution package creation completed. check _dist/django-$appName"
}


#% <doc:>
#@ env [rebuild]
#@   builds the environment for development:
#@    1. prepares the virtual environment in $VENV_DIR if not yet prepared,
#@    2. find mysql_config if not in path, and adds dir location to $path
#@    3. install python package requirement into virtual env
#@   this command can be called repeatedly.
#@   call this after a fresh git pull to setup env.
#@   if "rebuild" is passed, will delete and rebuild the entire environment
#@
#% </doc:>
function cmd_env() {

  log_header "================================ ENV ====================================="

  log_header "$1"
  if [ "$1" == "rebuild" ]; then			# if rebuild is passed
		if [ -d $VENV_DIR ]; then		    # and $VENV_DIR existed, then
			log_warn "REBUILD flag passed, deleting $VENV_DIR in 5 second unless cancelled"
			sleep 5
			rm -rf $VENV_DIR
		fi
	fi

  if [ ! -e $VENV_DIR/bin/activate ]; then
    log_info "preparing virtual env environment in $VENV_DIR"
    $CMD_VENV -p $CMD_PYTHON --no-site-packages --distribute $VENV_DIR;
  else
    log_info "virtual env environment is prepared."
  fi

  source $VENV_DIR/bin/activate

  # check if virtualenv is activated properly
  __venvcheck

  which mysql_config &> /dev/null
  if [ $? != 0 ]; then
    log_warn "unable to find mysql_config in your PATH. locating in OS..."
    mysql_config_path=$(locate -l1 mysql_config | grep mysql_config )
    PATH=$PATH:${mysql_config_path%/*}
    which mysql_config &> /dev/null
    if [ $? != 0 ]; then
      log_error "unable to resolve mysql_config in path. Please ensure that MYSQL is installed and set $PATH manually."
      return -1
    fi
    log_info "... found at: $(which mysql_config). configured into PATH"
  fi
  log_info "Syncing pip package requirement from $PWD/requirements.txt"
  $CMD_PIP install --upgrade -r requirements.txt;

  log_info "creating log directory to keep log files..."
  mkdir -p log

  log_info "environment preparation is complete. to activate in your own shell, use:"
  log_info "source $VENV_DIR/bin/activate"
}

#% <doc:>
#@ mamp-innodbrecover
#@   helps to recover from an innodb crash.
#@   specific for MAMP user :) assumes that MAMP is insatlled in
#@   /Applications/MAMP. execute with sudo privilege.
#@
#% </doc:>
function cmd_mamp-innodbrecover() {
	log_warn "this command is only intended for runtime in macOSX, where MAMP is installed in standard directory: /Applications/MAMP. If you are not sure, terminate now (Ctrl+c). Otherwise, this will continue on in a few seconds."
	sleep 15

	if [ ! -e "/Applications/MAMP/conf/my.cnf" ]; then
		log_error "my.cnf not found - create one first or initialize an empty file in /Applications/MAMP/conf/my.cnf"
		exit 1
	fi

	log_header "backing up my.cnf & stopping MAMP MYSQL"
	cat /Applications/MAMP/conf/my.cnf
	cp /Applications/MAMP/conf/my.cnf /Applications/MAMP/conf/my.cnf.backup
	log_info "stopping MAMP MYSQL"
	/Applications/MAMP/bin/stopMysql.sh
	sleep 10

	log_header "replacing innoDBRecover=1 config file and starting MAMP MySQL"
	echo "[mysqld]" > /Applications/MAMP/conf/my.cnf
	echo "innodb_force_recovery=1" >> /Applications/MAMP/conf/my.cnf
	cat /Applications/MAMP/conf/my.cnf
	/Applications/MAMP/bin/startMysql.sh
	sleep 10;

	tail /Applications/MAMP/logs/mysql_error_log.err


	log_header "stopping mysql & swapping back original configuration"
	/Applications/MAMP/bin/stopMysql.sh
	sleep 12

	log_info "copying configuration file back"
	cp /Applications/MAMP/conf/my.cnf.backup /Applications/MAMP/conf/my.cnf
	sleep
	/Applications/MAMP/bin/startMysql.sh

	sleep 5
	log_header "end of attempted recovery, MySQL should be up and running. may the force be with you."
}

#% <doc:>
#@ run <1:hostport>
#@   checks if env is activated, if so:
#@   runs $CMD_PYTHON manage.py, check its result,
#@   if OK, do django migration commands, git status,
#@   and runserver so we can work on our apps.
#@   [params]
#@     <1:hostport> if specified, will use the specified hostname eg. hostname:6666
#@   //-> need virtualenv activation
#@   //-> need a working DB config and settings.py updated
#@
#% </doc:>
function cmd_run() {

	log_header "================================ RUN ====================================="

  __venvcheck -d  # we check if virtualenv is setup

  cmd_qmigrate
	cmd_qtest

  log_header "git status"
  git status

	cmd_qrun "$1"
}

#% <doc:>
#@ qstatic
#@  shorthand for python manage.py collectstatic
#@
#% </doc:>
function cmd_qstatic() {

	log_header "================================ QSTATIC ====================================="
  __venvcheck -d  # we check if virtualenv is setup

	$CMD_PYTHON manage.py collectstatic
}


#% <doc:>
#@ dbshell
#@  shorthand for python manage.py cmd_dbshell
#@  and all of the environment setup sorted.
#@
#% </doc:>
function cmd_dbshell() {

	log_header "================================ RUN ====================================="
  alias mysql=$(locate bin/mysql | grep "bin/mysql$")
  __venvcheck -d  # we check if virtualenv is setup

	$CMD_PYTHON manage.py dbshell
}


#% <doc:>
#@ clean
#@  cleans the running environment. deletes all *.pyc to ensure fresh runtime
#@
#% </doc:>
function cmd_clean() {
	log_header "================================ CLEAN ====================================="
	find . -name "*.pyc" | grep -vE "$VENV_DIR" > pyc.list
	if (( $( cat pyc.list | wc -l ) <= 0 )); then
		log_info "there are no .pyc file to remove"
		rm pyc.list
		return 0
	else
		log_warn "found $( cat pyc.list | wc -l ) .pyc files, removing in 5 second unless interrupted (ctrl+c)"
		sleep 5
	fi

	while read file; do
		rm $file
		if [ $? == 0 ]; then
			log_info "removed $file"
		fi
	done < pyc.list
	rm pyc.list

	log_warn "removing _dist directory"
	sleep 2
	rm -rf _dist
}

#% <doc:>
#@ qrun <1:hostport> <2:profile>
#@   quick run ! don't check for safety. Just! run!
#@   [params]
#@     <1:hostport> if specified, will use the specified hostname eg. hostname:6666
#@     <2:profile>  if specified, will use specific settings_local.py, otherwise will try
#@        to find
#@
#% </doc:>
function cmd_qrun()
{
		log_header "run"
		hostname="127.0.0.1:8000"
		if [ "$1" != "" ]; then
			log_warn "hostport override provided [ $1 ]"
			hostname="$1";
			if [ "$1" == "lucky" ]; then
				log_warn "TRYINA GET LUCKY!!! auto-resolve hostname using ifconfig & sed"
				hostname=$( ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' | head -n1 )
				hostname="$hostname:8000"
				log_warn "RESOLVED... $hostname"
			fi
		else
			log_info "using standard hostport [ $hostname ]"
	  fi

		mkdir -p .runtime/log;    # for runtime logs
		mkdir -p .runtime/static; # for static files
		mkdir -p .runtime/data;   # for data files

		if [ "$2" == "ssl" ]; then
			log_warn "RUNNING IN SSL MODE!! ***"
			# see https://github.com/teddziuba/django-sslserver and settings.py
			$CMD_PYTHON manage.py runsslserver $hostname
		else
	  	$CMD_PYTHON manage.py runserver $hostname
		fi
}

#% <doc:>
#@ qmigrate
#@   quick makemigrations & migrate
#@
#% </doc:>
function cmd_qmigrate()
{
		log_header "migration"
		__venvcheck -d  # we check if virtualenv is setup

	  $CMD_PYTHON manage.py makemigrations
		__iferrmsg "Unable to make migrations - please check above errors"
		$CMD_PYTHON manage.py migrate
		__iferrmsg "Unable to complete migration - please check above errors"
}

#% <doc:>
#@ qtest
#@   quick test !! --noinput
#@
#% </doc:>
function cmd_qtest()
{
		log_header "test --noinput"
		__venvcheck -d  # we check if virtualenv is setup

	  $CMD_PYTHON manage.py test --noinput
		__iferrmsg "Test run detected errors, please fix above. Aborting run."
}


function cmd_qshell()
{
	log_header "=============================== SHELL ===================================="

	__venvcheck -d  # we check if virtualenv is setup

	$CMD_PYTHON manage.py shell
}

#% <doc:>
#@ qrpc <1:rpcurl >
#@   establish XMLRPC session to localhost:8000, unless <1:rpcurl> is
#@   provided. In which case it'll attempt provided rpcurl instead.
#@
#% </doc:>
function cmd_qrpc()
{
	log_header "=============================== QRPC ===================================="
	rpcurl="http://localhost:8000/api/rpc/"
	if [ "$1" != "" ]; then
		log_warn "rpcurl override provided [ $1 ]"
		rpcurl="$1";
	else
		log_info "using standard rpcurl [ $rpcurl ]"
	fi
	$CMD_PYTHON xmlrpc-client.py --url="$rpcurl"
}


#% <doc:>
#@ pip <1:flag [-u] >
#@   compare current pip packages against requirements.txt.
#@   [params]
#@      <1:flag> if -u is specified, will update requirements.txt if diff is found
#@   //-> need virtualenv activation
#@
#% </doc:>
function cmd_pip() {

	alias pip='pip3'
	alias python='python3'

	log_header "================================ PIP ====================================="
	$CMD_PIP --version

  __venvcheck   # we check if virtualenv is setup
  $CMD_PIP freeze > .requirements.now

	log_header "comparing current packages with [requirements.txt]"
	diff -y -w .requirements.now requirements.txt > .diff.tmp
	if [ $? == 0 ]; then
		log_info "requirements.txt up to date."
		cat requirements.txt
	elif [ "$1" == "-u" ]; then # if -u specified, update requirements.txt
		log_info "[-u] flag specified & diff detected - updating [requirements.txt]:"
		mv .requirements.now requirements.txt
		cat requirements.txt
		log_header "git status"
		git status | grep requirements.txt
	else # else, discard tmp file, back to 0
		cat .diff.tmp
	fi
	rm .requirements.now &> /dev/null
	rm .diff.tmp &> /dev/null
}





#% <doc:>
#@ secret <1:update/extract] >
#@   manage secret files within _local/* folder
#@   [params]
#@      <1:flag>
#@         if 'update' - updates secret.zip with managed files
#@         if 'extract' - extract secret.zip managed files into file system
#@      note: make sure to add managed files into .gitignore !!
#@            and, do remember how to unlock the password.
#@
#% </doc:>
function cmd_secret() 
{

	log_header "================================ SECRET ====================================="

	if [ "$1" == "update" ]; then
		log_info "updating _local/secret.zip with sensitive files listed in _local/secret.txt:"
		log_warn "PLEASE REMEMBER YOUR PASSWORD!"
		pushd _local
		cat secret.txt
		cat secret.txt | zip -e secret.zip -@
		popd
	elif [ "$1" == "extract" ]; then
		log_info "extracting _local/secret.zip:"
		log_warn "after password provided sensitive files will be OVERWRITTEN"
		pushd _local
		unzip secret.zip
		popd
	else # else, discard tmp file, back to 0
		log_info "nothing to do. check help?"
	fi
	rm .requirements.now &> /dev/null
	rm .diff.tmp &> /dev/null
	
}

# =============================================================================================================
# MAIN BLOCK
# =============================================================================================================

# if no command passed, exit
if [ "" == "$1" ]; then cmd="help"; else cmd="$1"; fi

# if cmd is passed, call it passing in all parameter (up to 12th..)
"cmd_$cmd" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "${10}" "${11}" "${12}"

# check result, if cmd not found exit & print help
result=$?
if [ $result == 127 ]; then
	log_error "Command not found: $1"
	help
elif [ $result != 0 ]; then
	# if cmd is found, but exit is still nonzero, print help for that command
	cmd_help $1
fi
# whatever the result, return the exit code from the command
exit $result
