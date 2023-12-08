/*  用法
    RemoteDexLoader job = new RemoteDexLoader();
    ContextWrapper c = new ContextWrapper(this);
    job.execute(c.getFilesDir().getPath(), "http://127.0.0.1/demoapk.apk", "demoapk.apk");
*/

package com.loader;

import java.lang.reflect.*;
import java.io.*;
import java.net.*;
import android.os.*;
import android.util.Log;
import dalvik.system.DexClassLoader;

public class RemoteDexLoader extends AsyncTask<String, Void, String>
{
    protected String doInBackground(String[] params)
    {
        String dataDir = params[0];
        String url     = params[1];
        String name    = params[2];

        String localName = dataDir + File.separator + name;

        try {
            URLDownloadToFile(url, localName);
        } catch (Exception e) {
            Log.e("URLDownloadToFile", e.toString());
            return "fail";
        }

        final File optimizedDexFile = new File(localName);
        DexClassLoader cl = new DexClassLoader(localName, dataDir, null, this.getClass().getClassLoader());
        try {
            Class<?> demoDexClass   = cl.loadClass("com.example.demo");
            Constructor constructor = demoDexClass.getConstructor();
            Object obj = constructor.newInstance();

            // 方案1
            Method method = demoDexClass.getMethod("Run", null);
            method.setAccessible(true);
            method.invoke(obj);

            // 方案2
            DexDemoInterface demoInterface = (DexDemoInterface)demoDexClass.newInstance();
            demoInterface.test();
        } catch (Exception e) {
            Log.e("DexClassLoader", e.toString());
        }

        return "some message";
    }

    protected void onPostExecute(String message) 
    {
        //process message
    }

    public void URLDownloadToFile(final String urlString, final String filename) throws Exception 
    {
        BufferedInputStream in = null;
        FileOutputStream fout  = null;

        try
        {
            in   = new BufferedInputStream(new URL(urlString).openStream());
            fout = new FileOutputStream(filename);

            int count = 0;
            final byte data[] = new byte[1024];
            while ((count = in.read(data, 0, 1024)) != -1) 
            {
                fout.write(data, 0, count);
            }
        } 
        finally 
        {
            if (in != null) 
            {
                in.close();
            }

            if (fout != null) 
            {
                fout.close();
            }
        }
    }
}
