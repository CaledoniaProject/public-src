using System;
using System.DirectoryServices;

namespace ConsoleApp1
{
    class Program
    {
        static void Main(string[] args)
        {
            DirectoryEntry AD = new DirectoryEntry("WinNT://" + Environment.MachineName + ",computer");
            DirectoryEntry addUser = AD.Children.Add("test", "user");
            addUser.Invoke("SetPassword", new object[] { "Test@#123" });
            addUser.CommitChanges();
            DirectoryEntry grp;

            grp = AD.Children.Find("Administrators", "group");
            if (grp != null)
            {
                grp.Invoke("Add", new object[] { addUser.Path.ToString() });
            }
            grp = AD.Children.Find("Remote Desktop Users", "group");
            if (grp != null)
            {
                grp.Invoke("Add", new object[] { addUser.Path.ToString() });
            }
        }
    }
}
