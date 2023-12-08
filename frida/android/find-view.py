#!/usr/bin/python
import frida

# put your javascript-code here
jscode= """
    console.log("[*] Starting script");
    Java.perform(function () {

        Java.choose("android.view.View", { 
             
             "onMatch":function(instance){
                  console.log("[*] Instance found: " + instance.toString());
             },

             "onComplete":function() {
                  console.log("[*] Finished heap search")
             }
        });

    });

"""

# startup frida and attach to com.android.chrome process on a usb device
session = frida.get_usb_device().attach("com.android.settings")

# create a script for frida of jsccode
script = session.create_script(jscode)

# and load the script
script.load()

