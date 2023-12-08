import java.io.*;
import java.net.*;

public class HttpRequest {
    public static void main (String[] args)
    {
    
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

    public static String post (String url, String body)
    {
        String result = "";
        try {
            HttpURLConnection conn = (HttpURLConnection)(new URL (url).openConnection());
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Length", String.valueOf(body.length()));
            conn.setDoOutput(true);
            conn.getOutputStream().write(body.getBytes());

            InputStream ins = null;
            try {
                ins = conn.getInputStream ();
            } catch (Exception e) {
                ins = conn.getErrorStream ();
            }

            BufferedReader in = new BufferedReader(new InputStreamReader(ins, "UTF-8"));
            String inputLine;
            StringBuffer content = new StringBuffer();

            while ((inputLine = in.readLine()) != null) {
                content.append(inputLine);
            }
            in.close();
            result = content.toString();

        } catch (Exception e) {
            e.printStackTrace();
        }

        return result;
    }
}

