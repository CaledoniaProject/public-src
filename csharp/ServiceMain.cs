// 编写最简单的服务
// https://3gstudent.github.io/3gstudent.github.io/Use-powershell-to-find-a-writable-windows-service/
// 
// sc create Test type= own binpath= c:\test\test.exe
// sc start Test
// sc stop Test
// sc delete Test

using System.ServiceProcess;
namespace Demo
{
    public class Service : ServiceBase
    {
        protected override void OnStart(string[] args)
        {
            System.Diagnostics.Process.Start(@"c:\psexec.exe", @"-accepteula -d -i 1 cmd.exe");
        }
    }
    
    static class Program { 
    	static void Main() { 
    		ServiceBase.Run(new ServiceBase[] {
    			new Service() 
    		}); 
    	} 
    }
}
