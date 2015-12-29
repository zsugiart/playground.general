import sys
from optparse import OptionParser
from SimpleXMLRPCServer import SimpleXMLRPCServer
 
class DynamicXMLRPCServer(SimpleXMLRPCServer):
    """
    An XMLRPC server that will register all function whose name are prefixed with PREFIX via xml-rpc
    Zen Sugiarto - 2011
    """
 
    # this is the prefix used by this sever to decide whether a given method should be published over xml-rpc or not.
    PREFIX="xmlrpc_"
 
    # constructor
    def __init__(self, params):
        self.params=params
        self.host=params['host']
        self.port=params['port']
        SimpleXMLRPCServer.__init__(self,(self.host, self.port))
        # register all xmlrpc_ functions over xml-rpc
        for name in dir(self):
            if name[:len(DynamicXMLRPCServer.PREFIX)] == DynamicXMLRPCServer.PREFIX:
                function=getattr(self,name)
                print "registering function: %s as %s " % ( name, name[len(DynamicXMLRPCServer.PREFIX):] )
                self.register_function(function, name[len(DynamicXMLRPCServer.PREFIX):])
 
    # note: xmlrpc_ prefix is used by this server to mark that this function will be published
    def xmlrpc_hello(self,msg):
        """
        A simple hello function used for simple ping check. 
        @param msg - msg to pass to hello
        @return dictionary {"hello":msg}
        """
        return {"hello":msg}
 
    def xmlrpc_describe(self):
        """
        Retrieves the description/documentation of available functions within this service.
        by the grace of python's .__doc__ object.
        @return dictionary of the following format
        { 
            'function_name' : 'documentation/description of that function '} 
        } 
        """
        metaDescription={}
        for name in dir(self):
            if name[:len(DynamicXMLRPCServer.PREFIX)] == DynamicXMLRPCServer.PREFIX:
                function=getattr(self,name)
                metaDescription[name[len(DynamicXMLRPCServer.PREFIX):]]=function.__doc__
        return metaDescription;
 
    def xmlrpc_yourFunction(self):
        """
        Put in more function here!~
        """
        print "IMPLEMENT ME"
 
def main():
    """ main method """
    parser = OptionParser(""" 
        Template service object - please put your comment in here
        """)
    parser.add_option("--host", dest="host", help="hostname to publish the service against")
    parser.add_option("--port", dest="port", help="port number to use")
    (options, args) = parser.parse_args()
 
    if( options.host == None or options.port == None ):
        print "insufficient options provided. try --help"
        sys.exit(1);
 
    server = DynamicXMLRPCServer({'host':options.host,'port':int(options.port)})
    server.serve_forever()
 
if __name__ == "__main__":
    main()

