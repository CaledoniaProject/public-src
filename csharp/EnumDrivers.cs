using System;
using System.Runtime.InteropServices;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace EnumDriversTest
{
    class Program
    {
        [DllImport("psapi")]
        private static extern bool EnumDeviceDrivers(
            IntPtr Addresses,
            int arraySizeBytes,
            out int bytesNeeded
        );

        [DllImport("psapi")]
        private static extern int GetDeviceDriverBaseName(
            IntPtr ddAddress,
            StringBuilder ddBaseName,
            int baseNameStringSizeChars
        );

        [DllImport("psapi")]
        private static extern int GetDeviceDriverFileName(
            IntPtr ddAddress,
            StringBuilder ddBaseName,
            int baseNameStringSizeChars
        );

        static void Main(string[] args)
        {
            IntPtr drivers = IntPtr.Zero;
            int bytesNeeded;
            bool success;

            // Figure out how large an array we need to hold the device driver 'load addresses'
            success = EnumDeviceDrivers(IntPtr.Zero, 0, out bytesNeeded);

            Console.WriteLine("Success? " + success);
            Console.WriteLine("Array bytes needed? " + bytesNeeded);

            if (!success)
            {
                Console.WriteLine("Call to EnumDeviceDrivers failed!  To get extended error information, call GetLastError.");
                return;
            }
            if (bytesNeeded == 0)
            {
                Console.WriteLine("Apparently, there were NO device drivers to enumerate.  Strange.");
                return;
            }

            drivers = Marshal.AllocHGlobal(bytesNeeded);

            // Now fill it
            success = EnumDeviceDrivers(drivers, bytesNeeded, out bytesNeeded);

            if (!success)
            {
                Console.WriteLine("Call to EnumDeviceDrivers failed!  To get extended error information, call GetLastError.");
                return;
            }

            for (int i = 0; i < bytesNeeded / IntPtr.Size; i++)
            {
                // If the length of the device driver base name is over 1000 characters, good luck to it.  :-)
                StringBuilder sb = new StringBuilder(1000);
                IntPtr address = new IntPtr(drivers.ToInt64() + i * IntPtr.Size);
                IntPtr pp = Marshal.ReadIntPtr(address);

                int result = GetDeviceDriverBaseName(pp, sb, sb.Capacity);

                Console.WriteLine("Device driver LoadAddress: " + pp + ", BaseName: " + sb.ToString());
            }
        }
    }
}