from SimpleXMLRPCServer import SimpleXMLRPCServer, SimpleXMLRPCRequestHandler
import SocketServer
import pprint
import subprocess
import logging
import sys
import os
import string
import threading
import time
import signal
import types

# GLOBAL VAR
# ----------

# main server object
SERVER = None

# main service object
DISPLAY_SERVICE = None

# log file
LOG_FILENAME = 'log.out'

# path to this script
FILE_THIS_SCRIPT = os.path.realpath(sys.argv[0])

# path to XRANDR DIFF script
FILE_XRANDR_SCRIPT = "%s/ubuntu_xrandr_diff.sh" % os.path.dirname(FILE_THIS_SCRIPT)


# lOGGING INITIALIZATION
# ----------------------

# create logger with 'spam_application'
logger = logging.getLogger('ubuntu.display.service')
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')

logger.setLevel(logging.INFO)

# create file handler which logs even debug messages
fh = logging.FileHandler('service-display.log')
fh.setLevel(logging.DEBUG)
fh.setFormatter(formatter)

# add the handlers to the logger
logger.addHandler(fh)

def log_info(msg): logger.info(msg)
def log_debug(msg): logger.debug(msg)
def log_warn(msg): logger.warn(msg)
def log_error(msg): logger.error(msg)


# XML RPC CLASS DEF
# -----------------

class XMLRPCServer(SocketServer.ThreadingMixIn, SimpleXMLRPCServer): pass      


"""
@param cmdparam: a list of parameter, the first one being the main command (param0)
"""
def syscall(cmdparam):
    p = subprocess.Popen(cmdparam, stdout=subprocess.PIPE)
    out, err = p.communicate()
    return {'stdout':out, 'stderr':err}



"""

"""
class UbuntuDisplayService:
        
    """
    Inner thread class that scans xrandr for diff. 
    """
    class DisplayScanThread(threading.Thread):
        def __init__(self, UbuntuDisplayServiceObj, path_xrandrDiffScript):
            log_debug("DisplayScanThread: initializing")
            self.UbuntuDisplayService = UbuntuDisplayServiceObj
            self.running = True
            self.path_xrandrDiffScript = path_xrandrDiffScript
            res = syscall([self.path_xrandrDiffScript,'init'])
            threading.Thread.__init__(self)
                    
        def run(self):
            while self.running is True:
                log_debug("DisplayScanThread: <Hearbeat>")
                res = syscall([self.path_xrandrDiffScript,'check'])
                self.UbuntuDisplayService._parseXRandrOutput(res['stdout'])
                time.sleep(3.14)
            log_debug("DisplayScanThread: stopped")
        
        def stop(self):
            log_debug("DisplayScanThread: stopping...")
            self.running = False
    
    """
    Constructor
    """
    def __init__(self, path_xrandrDiffScript):
        self.data = {}
        self.displayScanThread = UbuntuDisplayService.DisplayScanThread(self, path_xrandrDiffScript)
        self._listenDisplayEvent(True);

    # ------------
    # bare command
    # ------------
        
    def hello(self):
        return "XMLRPC UbuntuDisplayService"
    
    def getSystemEnvironment(self):
        return sys.env
    
    def osCommand(self, cmd):
        """
        Run a raw command in the system
        @cmd = a list containing commands to run, cmd[0] = argv[0], cmd[1] = argv[1] and so on
        example: osCommand(['ls','-altrh'] 
        """
        res = syscall(cmd)
        return res['stdout']
    
    
    def getMetaDescription(self):
        """
        Returns a list of function that this component can provide
        """
        dict = {}
        dirself = dir(self)
        print dir(self)
        for cmd in dirself:
            if cmd[0] == '_': continue
            cmdObj = getattr(self, cmd)
            # only return methods, ignore class or non callable object (like variables)
            if isinstance(cmdObj, (type, types.ClassType)) or not hasattr(cmdObj, '__call__'): continue            
            dict[cmd] = cmdObj.__doc__
        return dict
    
    # ------------------
    # Display management
    # ------------------
    
    def _listenDisplayEvent(self, toggle):
        if toggle:  
            if self.displayScanThread is None: self.displayScanThread = DisplayScanThread(self)
            self.displayScanThread.start()
        else:   
            self.displayScanThread.stop()
            self.displayScanThread = None
 
    def _parseXRandrOutput(self, xRandrOutput):
        """
        Parse output from XRandrOutput
        """
        
        currentDisplay = None
        
        for line in xRandrOutput.split('\n'):
            
            if '#NODIFF' in line:
                log_debug('no difference in randr output')
                break
            else:
                log_info(line)
            
            if len(line) <= 0: continue
            
            # display
            if 'connected' in line:
                displayRec = line.strip().split(' ')
                self.data[displayRec[0]] = {
                    'currentRefreshRate':None,
                    'currentMode':None,
                    'name':displayRec[0],
                    'status':displayRec[1],
                    'props':line.split('connected')[1].strip(),
                    'modes':{}
                }
                currentDisplay = displayRec[0]
                
            # resolution
            if line[0] == ' ':
                resolutionList = []
                resolutionDict = {}
                res = []
                
                # remove blanks
                for r in line.split('  '): 
                    if len(r) <= 0: continue
                    res = r.strip()
                    if '*' in res: 
                        self.data[currentDisplay]['currentRefreshRate'] = res.split('*')[0]
                        self.data[currentDisplay]['currentMode'] = resolutionList[0]
                        resolutionList.append(self.data[currentDisplay]['currentRefreshRate'])
                    else:
                        resolutionList.append(r.strip())
                        
                if currentDisplay is not None:
                    self.data[currentDisplay]['modes'][resolutionList[0]] = resolutionList[1:]
                    
        return self.data;
    
    def setDisplayOn(self, displayName, xrandrCmd=None):
        """
        Use XRANDR to turn on a given display
        @displayName - name of the display to turn on
        @xrandrCmd - a list of additional xrandr command to run, default to None
        example: turnOn('HDMI1')
        for list of available display, use getDisplayList()
        """
        self._checkDisplayBeforeChange(displayName);
        res = syscall(['xrandr', '--output', displayName, '--auto'])
    
    def setDisplayOff(self, displayName):
        """
        Use XRANDR to turn OFF a given display
        @displayName - name of the display to turn on
        @xrandrCmd - a list of additional xrandr command to run, default to None
        example: turnOff('HDMI1')
        for list of available display, use getDisplayList()
        """
        self._checkDisplayBeforeChange(displayName);
        res = syscall(['xrandr', '--output', displayName, '--off'])
    
    def setDisplayMode(self, displayName, mode, refresh):
        self._checkDisplayBeforeChange(displayName);
        displayModes = self.data[displayName]['modes']
        if mode not in displayModes: raise Exception('display %s does not have mode %s ' % (displayName, mode))
        if refresh not in displayModes[mode]: raise Exception('display %s, mode %s does not support refresh rate %s' % (displayName, mode, refresh))
        print "displayName:%s, mode:%s, refresh:%s" % (displayName, mode, refresh)
        res = syscall(['xrandr', '--output', displayName, '--mode', mode, '--refresh', refresh])
    
    def _checkDisplayBeforeChange(self, displayName):
        if displayName not in self.data: raise Exception('displayName %s not in display list/ see getDisplayList()' % displayName)
        if self.data[displayName]['status'] == 'disconnected': raise Exception('displayName %s is not connected, unable to change display settings')
    
    def getDisplayList(self): return self.data.keys()
    def getDisplayData(self, displayName): return self.data[displayName]
    
    # ------------------
    # Network management
    # ------------------
    
    def listNetwork(self):
        res=syscall(['nmcli','con'])
        for line in res['stdout'].split('\n'):
            print line.split('  ')
    

def __osCheck__():
    #if string.upper(os.environ['USER']) != 'ROOT' or 'SUDO_UID' not in os.environ:
    #    raise Exception("process not run without root privilege")
    print os.path.realpath(sys.argv[0])
    
def __signalHandler__(signal, frame):
    global DISPLAY_SERVICE
    print "Caught signal %s, frame %s" % (signal, frame)
    DISPLAY_SERVICE._listenDisplayEvent(False)
    sys.exit(0)

def __main__():
    global SERVER, DISPLAY_SERVICE, FILE_XRANDR_SCRIPT
    __osCheck__()
    
    log_info("server starting at port 5789")
    DISPLAY_SERVICE = UbuntuDisplayService(FILE_XRANDR_SCRIPT)
    
    # Instantiate and bind to localhost:8080
    SERVER = XMLRPCServer(('', 5789), SimpleXMLRPCRequestHandler, allow_none=True)
    signal.signal(signal.SIGINT, __signalHandler__)
    
    # Register example object instance
    SERVER.register_instance(DISPLAY_SERVICE)
    # run!
    SERVER.serve_forever()
   
   
__main__() 
