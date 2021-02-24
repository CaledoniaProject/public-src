using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace AxControls
{
    [ComVisible(true)]
    [Guid("A3BF45FA-F679-4B3E-AC9B-052F33D064CE")]
    [InterfaceType(ComInterfaceType.InterfaceIsDual)]

    public interface IHelloWorld
    {
        void RunJob();
    }

    public class HelloWorld: IHelloWorld
    {
    	public HelloWorld()
    	{
    		MessageBox.Show("COM called");
    	}

    	public void RunJob()
    	{

    	}
    }
}
