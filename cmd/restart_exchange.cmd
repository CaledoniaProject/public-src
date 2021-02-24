@Echo Off
Echo 'Stopping Microsoft Exchange Services'
net stop MSExchangeAB
net stop MSExchangeADTopology
net stop MSExchangeAntispamUpdate
net stop MSExchangeEdgeSync
net stop MSExchangeFBA
net stop MSExchangeFDS
net stop MSExchangeIS
net stop MSExchangeMailboxAssistants
net stop MSExchangeMailboxReplication
net stop MSExchangeMailSubmission
net stop MSExchangeProtectedServiceHost
net stop MSExchangeRepl
net stop MSExchangeRPC
net stop MSExchangeSA
net stop MSExchangeSearch
net stop MSExchangeServiceHost
net stop MSExchangeThrottling
net stop MSExchangeTransport
net stop MSExchangeTransportLogSearch
Echo 'Starting Microsoft Exchange Services'
net start MSExchangeAB
net start MSExchangeADTopology
net start MSExchangeAntispamUpdate
net start MSExchangeEdgeSync
net start MSExchangeFBA
net start MSExchangeFDS
net start MSExchangeIS
net start MSExchangeMailboxAssistants
net start MSExchangeMailboxReplication
net start MSExchangeMailSubmission
net start MSExchangeProtectedServiceHost
net start MSExchangeRepl
net start MSExchangeRPC
net start MSExchangeSA
net start MSExchangeSearch
net start MSExchangeServiceHost
net start MSExchangeThrottling
net start MSExchangeTransport
net start MSExchangeTransportLogSearch
End

