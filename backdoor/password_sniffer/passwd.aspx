public void WriteEntry(String usr, String pwd)
{
    using (StreamWriter sw = new StreamWriter(@"c:\log.txt", true))
    {
        sw.WriteLine(String.Format("Logon: {0} | {1}, Date: {2}\n", usr, pwd, DateTime.Now));
    }
}
