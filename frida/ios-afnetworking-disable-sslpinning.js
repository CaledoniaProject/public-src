/*
	Source
	https://kov4l3nko.github.io/blog/2018-06-17-afnetwork-disable-ssl-pinning/

	**********************************************
	 disable_ssl_pinning_in_loops.js Frida script
	 by Dima Kovalenko
	**********************************************
	
	Usage:
		
		1. Run Loops on the device
		
		2. Inject the script to the process:
			$ frida -U -n LOOPS  -l disable_ssl_pinning_in_loops.js
		
		3. SSL pinning in Loops HTTPs is
		   disabled. Now you can intercept
		   Loops HTTPs requests, e.g. with
		   mitmproxy.
		   
		IMPORTANT NOTE: Use an HTTP(s) sniffer with HTTP 2.0 support!

*/

function main() {
	var resolver = new ApiResolver('objc');
	var matches = resolver.enumerateMatchesSync("-[AFSecurityPolicy evaluateServerTrust:forDomain:]");
	if (matches.lenght == 0) {
		console.log("\n[E] -[AFSecurityPolicy evaluateServerTrust:forDomain:] is not found!\n");
		return;
	}
	Interceptor.attach(
		ptr(matches[0]["address"]),
		{
			onLeave: function(retval) {
				console.log("[I] -[AFSecurityPolicy evaluateServerTrust:forDomain:] hits!");
				retval.replace(1);
			}
		}
	);
	console.log("[I] -[AFSecurityPolicy evaluateServerTrust:forDomain:] is hooked!\n")
}

main();
