using System;
using System.Web;
using System.IO;
using System.Diagnostics;

public class TestClass 
{
	public TestClass()
	{
        HttpContext.Current.Response.Write("Hello From DLL");
    } 
}