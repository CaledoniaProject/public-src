/*
编译
clang print-serial-number.m -framework Foundation -framework IOKit
*/

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <IOKit/IOKitLib.h>

void printSerialNumber()
{
    CFStringRef serial;
    char buffer[32] = {0};

    io_service_t service = IOServiceGetMatchingService(
        kIOMasterPortDefault, 
        IOServiceMatching("IOPlatformExpertDevice"));

    if (service)
    {
        CFTypeRef cfprop = IORegistryEntryCreateCFProperty(
            service,
            CFSTR(kIOPlatformSerialNumberKey),
            kCFAllocatorDefault, 0);

        if (cfprop)
        {
            serial = (CFStringRef)cfprop;

            NSString *string = (__bridge NSString *) serial;
            NSLog(@"serial = %@", string);
        }
    }

    IOObjectRelease(service);
}

int main(int argc, char **argv)
{
    printSerialNumber();
    return 0;
}
