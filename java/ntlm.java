import java.io.*;
import java.net.*;

public class ntlm {
    public static void main (String[] args)
    {
        for (String arg : args)
        {
            System.out.println(arg);
            System.out.println(get(arg));
        }
    }

    public static String get (String url)
    {
        String result = "";

        try {
            HttpURLConnection conn = (HttpURLConnection) (new URL (url).openConnection ());
            conn.setRequestMethod("GET");
            conn.connect ();

            BufferedReader br = new BufferedReader (new InputStreamReader (conn.getInputStream()));
            StringBuilder  sb = new StringBuilder ();
            String line;

            while ((line = br.readLine()) != null)
            {
                sb.append (line);
            }

            result = sb.toString();

        } catch (Exception e) {
            e.printStackTrace ();
        }

        return result;
    }
}

