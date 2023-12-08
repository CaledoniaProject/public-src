using System;
using System.IO;
using System.Diagnostics;

namespace ConsoleApp1
{
    class Program
    {
        static void Main(string[] args)
        {
            if (Debugger.IsAttached)
            {
                Environment.Exit(1);
            }

            if (File.Exists(Environment.ExpandEnvironmentVariables(@"%appdata%\dnSpy\dnSpy.xml")))
            {
                Environment.Exit(2);
            }
        }
    }
}
