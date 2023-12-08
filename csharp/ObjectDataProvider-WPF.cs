// 需要增加WPF引用，相关DLL在.NET目录下:
// WindowsBase、PresentationCore、PresentationFramework

using System;
using System.Windows.Data;

namespace ConsoleApp1
{
    class Program
    {
        static void Main(string[] args)
        {
            ObjectDataProvider obj = new ObjectDataProvider();
            obj.MethodParameters.Add("calc");
            obj.MethodName = "Start";
            obj.ObjectInstance = new System.Diagnostics.Process();
        }
    }
}
