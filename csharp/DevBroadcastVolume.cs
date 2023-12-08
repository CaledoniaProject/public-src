using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Runtime.InteropServices;

namespace Forms1
{
    [StructLayout(LayoutKind.Sequential)]
    public class DevBroadcastVolume
    {
        public int dbcv_size;
        public int dbcv_devicetype;
        public int dbcv_reserved;
        public int dbcv_unitmask;
        public short dbcv_flags;
    }

    public partial class Form1 : Form
    {
        private const int WM_DEVICECHANGE = 0x219;
        private const int DBT_DEVICEARRIVAL = 0x8000;
        private const int DBT_DEVICEREMOVECOMPLETE = 0x8004;
        private const int DBT_DEVTYP_VOLUME = 0x00000002;

        public Form1()
        {
            InitializeComponent();
            Console.WriteLine("INIT forms");
        }

        protected string decodeDriveLetter(int unitMask)
        {
            char driveLetter;
            for (driveLetter = 'A'; driveLetter <= 'Z'; ++driveLetter)
            {
                if ((unitMask & 0x1) == 0x1)
                    break;
                unitMask = unitMask >> 1;

            }

            if (driveLetter > 'Z') // Catch any unitMask failure
                driveLetter = '0';

            return driveLetter.ToString();
        }

        protected override void WndProc(ref Message m)
        {
            base.WndProc(ref m);

            switch (m.Msg)
            {
                case WM_DEVICECHANGE:
                    switch ((int)m.WParam)
                    {
                        case DBT_DEVICEARRIVAL:
                            Console.WriteLine("New Device Arrived");

                            int devType = Marshal.ReadInt32(m.LParam, 4);
                            if (devType == DBT_DEVTYP_VOLUME)
                            {
                                DevBroadcastVolume vol;
                                vol = (DevBroadcastVolume)
                                   Marshal.PtrToStructure(m.LParam,
                                   typeof(DevBroadcastVolume));
                                Console.WriteLine("Attached {0}:\\", decodeDriveLetter(vol.dbcv_unitmask));
                            }

                            break;

                        case DBT_DEVICEREMOVECOMPLETE:
                            Console.WriteLine("Device Removed");
                            break;

                    }
                    break;
            }

        }
    }
}

