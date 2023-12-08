setImmediate(function() { //prevent timeout
    console.log("[*] Starting script");

    Java.perform(function() {
      boolean = Java.use("java.lang.Boolean")
      
      bClass  = Java.use("com.netspi.egruber.test.e");
      bClass.a.overload('[Ljava.lang.Void;').implementation = function(v) {
         console.log("[*] com.netspi.egruber.test.e.a() called:", this.b.value)
         return boolean.$new("True")
      }
      console.log("[*] com.netspi.egruber.test.e modified")

    })
})

