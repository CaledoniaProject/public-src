// frida -l main.js PID

function StalkerExeample() {
    var threadIds = []

    Process.enumerateThreads({
        onMatch: function(thread) {
            threadIds.push(thread.id)
            console.log("stalking thread ID: " + thread.id.toString())
        },
        onComplete: function() {
            threadIds.forEach(function(threadId) {
                Stalker.follow(threadId, {
                    events: {
                        call: false,
                        ret: false,
                        exec: false,
                        block: false,
                        compile: true,
                    },
                    onReceive: (events) => {
                        let tmp = Stalker.parse(events, {stringify: false, annotate: false})
                        console.log("[onReceive]", tmp)
                    },
                    onCallSummary: (summary) => {
                        console.log("[onCallSummary]", summary)
                    }
                })
            })
        }
    })
}

StalkerExeample()
