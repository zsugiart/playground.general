<%@ LANGUAGE=VBScript %>
<%
'# ==========================================================================================================
'#
'# JSON-RPC Proxy ASP [classic asp]
'#
'# This asp page/component will forward the json-rpc request to an existing json-rpc service 
'# and transparently forward the result back to the caller via the HTTP response. 
'#
'# ==========================================================================================================

'# configuration
'# -------------

'# This URl points to the json-rpc service point. 
'# if your system uses a different configuration mechanism, please adjust it accordingly
'#
Dim servicePointUrl
servicePointUrl = "http://url-to-json-rpc/point"

'# main body of execution
'# ----------------------

'# this function allows for msg to be logged into a log file so we can trace / analyze the traffic.
Sub logInfo (message)
	logFile = Server.MapPath("event.log")
    Const ForWriting   = 2
    Const ForAppending = 8
    Set fs = CreateObject("Scripting.FileSystemObject")
    If fs.FileExists(logFile) Then
        Set logFile = fs.OpenTextFile(logFile, ForAppending)
    Else
        Set logFile = fs.CreateTextFile(logFile, True)
    End If    
    logFile.WriteLine(Now() & vbTab & message)
    logFile.Close
    Set logFile = nothing
    Set fs = nothing
End Sub

' we read all of the POST data, json-rpc supports get, but this component only does POST for now.
' the safe array read from .BinaryRead is then converted into string, which is then sent into the 
' forwarding HTTP request object to the bus.
dim safeArray, totalBytes
totalBytes=Request.TotalBytes
safeArray=Request.BinaryRead(totalBytes)
jsonBody = ""
For n = 1 To LenB(safeArray)
  jsonBody = jsonBody & Chr(AscB(MidB(safeArray,n,1)))
Next

' create the HTTP request object to be forwarded into destination service point 
' inject the json body in.
Dim httpreq
Set httpreq = Server.CreateObject("MSXML2.XMLHTTP")
httpreq.open "POST",servicePointUrl, False
httpreq.setRequestHeader "Content-Type","application/json-rpc"
'httpreq.setRequestHeader "Cookie",Request.Cookies

' Send out the request
On Error Resume Next
httpreq.send jsonBody
logInfo("REQUEST={ queryString=" & Request.QueryString & ", cookies="& Request.Cookies &", totalBytes=" & Request.TotalBytes & ", jsonBody="&jsonBody)

' get response text, set mime type to application/json-rpc and write the service response to the response stream
Response.ContentType="application/json-rpc"
Response.Write(httpreq.responseText)
%>
