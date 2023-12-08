#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <IOKit/IOKitLib.h>
#import <sys/types.h>
#import <sys/sysctl.h>
#import <mach/machine.h>

NSString *getCPUType()
{
    NSMutableString *cpu = [[NSMutableString alloc] init];
    size_t size;
    cpu_type_t type;
    cpu_subtype_t subtype;

    size = sizeof(type);
    sysctlbyname("hw.cputype", &type, &size, NULL, 0);

    size = sizeof(subtype);
    sysctlbyname("hw.cpusubtype", &subtype, &size, NULL, 0);

    if (type == CPU_TYPE_X86)
    {
        [cpu appendString:@"x86"];
    }
    else if (type == CPU_TYPE_ARM)
    {
        [cpu appendString:@"ARM"];
        switch(subtype)
        {
            case CPU_SUBTYPE_ARM_V8:
                [cpu appendString:@"-V8"];
                break;
            case CPU_SUBTYPE_ARM_V7:
                [cpu appendString:@"-V7"];
                break;
            default:
                [cpu appendString: [NSString stringWithFormat:@"-subtype.%d", subtype]];
                break;
        }
    }

    return [cpu autorelease];
}

NSString *getSerialNumber()
{
    CFStringRef serial;
    NSString *result = nil;
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
            result = (__bridge NSString *) serial;
        }
    }

    IOObjectRelease(service);
    return result;
}

NSString *getUUID()
{
    io_service_t platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"));
    if (!platformExpert) return nil;

    CFTypeRef uuidAsCFString = IORegistryEntryCreateCFProperty(platformExpert, CFSTR(kIOPlatformUUIDKey), kCFAllocatorDefault, 0);
    if (!uuidAsCFString) return nil;

    IOObjectRelease(platformExpert);
    return (__bridge NSString *)(uuidAsCFString);
}

int main(int argc, char **argv)
{
    NSString *serialNumber = getSerialNumber();
    if (serialNumber != nil)
    {
        NSLog(@"serial = %@", serialNumber);
    }
    else
    {
        NSLog(@"Failed to acquire serial number\n");
    }

    NSString *uuid = getUUID();
    if (uuid != nil)
    {
        NSLog(@"UUID = %@", uuid);
    }
    else
    {
        NSLog(@"Failed to acquire uuid\n");
    }    

    NSString *cpuType = getCPUType();
    NSLog(@"cpu type = %@", cpuType);

    return 0;
}
