// 获取 netstat -ano 里面的 TCP 结果

#include <winsock2.h>
#include <iphlpapi.h>
#include <iostream>
#include <vector>
using namespace std;

#pragma comment(lib, "iphlpapi.lib")
#pragma comment(lib, "ws2_32.lib")

int main()
{
	//	ulAf value		TableClass value					pTcpTable structure 
	//	AF_INET			TCP_TABLE_OWNER_PID_ALL		->		MIB_TCPTABLE_OWNER_PID
	//	AF_INET6		TCP_TABLE_OWNER_PID_ALL		->		MIB_TCP6TABLE_OWNER_PID

	//	--> only AF_INET(IPv4)!! <--

	vector<unsigned char> buffer;
	DWORD dwSize = sizeof(MIB_TCPTABLE_OWNER_PID);
	DWORD dwRetValue = 0;

	// repeat till buffer is big enough
	do
	{
		buffer.resize(dwSize, 0);
		dwRetValue = GetExtendedTcpTable(buffer.data(), &dwSize, TRUE, AF_INET, TCP_TABLE_OWNER_PID_ALL, 0);
	} while (dwRetValue == ERROR_INSUFFICIENT_BUFFER);

	if (dwRetValue == ERROR_SUCCESS)
	{
		// cast to access element values
		PMIB_TCPTABLE_OWNER_PID ptTable = reinterpret_cast<PMIB_TCPTABLE_OWNER_PID>(buffer.data());

		cout << "Number of Entries: " << ptTable->dwNumEntries << endl << endl;

		for (DWORD i = 0; i < ptTable->dwNumEntries; i++)
		{
			cout << "PID: " << ptTable->table[i].dwOwningPid << endl;
			cout << "State: " << ptTable->table[i].dwState << endl;
			
			cout << "Local: "
				<< (ptTable->table[i].dwLocalAddr & 0xFF)
				<< "." 
				<< ((ptTable->table[i].dwLocalAddr >> 8) & 0xFF)
				<< "."
				<< ((ptTable->table[i].dwLocalAddr >> 16) & 0xFF)
				<< "."
				<< ((ptTable->table[i].dwLocalAddr >> 24) & 0xFF)
				<< ":"
				<< htons((unsigned short)ptTable->table[i].dwLocalPort)
				<< endl;

			cout << "Remote: "
				<< (ptTable->table[i].dwRemoteAddr & 0xFF)
				<< "." 
				<< ((ptTable->table[i].dwRemoteAddr >> 8) & 0xFF)
				<< "."
				<< ((ptTable->table[i].dwRemoteAddr >> 16) & 0xFF)
				<< "."
				<< ((ptTable->table[i].dwRemoteAddr >> 24) & 0xFF)
				<< ":"
				<<  htons((unsigned short)ptTable->table[i].dwRemotePort)
				<< endl;

			cout << endl;
		}

	} 
	else
	{
		cerr << "Error code" << GetLastError() << endl;
	}

	return 0;	
}
