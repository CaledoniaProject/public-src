import java.io.*;
import java.net.*;

public class safe_redir {

    public static boolean inWhiteList (String url)
    {
        return false;
    }

    public static void main (String[] args)
    {
        try {
            URL url = new URL ("http://www.test.com/aa?a=22");
            String host = url.getHost ();

            if (host == "test.com"
                || host.endsWith (".test.com")
                || inWhiteList (host))
            {
                System.out.println ("允许访问: " + host);
            }
            else
            {
                System.out.println ("不允许的跳转: " + host);
            }
        } catch (Exception e) {

        }
    }
}
