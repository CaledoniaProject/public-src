#include <Windows.h>
#include <Ntsecapi.h>

#include <stdio.h>
#pragma comment(lib, "advapi32")

wchar_t keyname_string[] = L"harrytest";

LSA_UNICODE_STRING keyname;

LSA_OBJECT_ATTRIBUTES lsa_object_attributes;

int set(void)
{
    LSA_HANDLE ph;
    LSA_UNICODE_STRING secretdata;
    wchar_t secretdata_buffer[2];

    DWORD status;

    status = LsaOpenPolicy(NULL, &lsa_object_attributes, POLICY_ALL_ACCESS, &ph);
    if (status != 0)
    {
        printf("LsaOpenPolicy: %X\n", status);
        return status;
    }

    secretdata.Length = 2;
    secretdata.MaximumLength = sizeof(secretdata_buffer);
    secretdata.Buffer = secretdata_buffer;
    secretdata_buffer[0] = L'x';
    secretdata_buffer[1] = L'\0';

    status = LsaStorePrivateData(ph, &keyname, &secretdata);
    if (status != 0)
    {
        printf("LsaStorePrivateData: %X\n", status);
        return status;
    }

    printf("Success!\n");
    return 0;
}

int get(wchar_t * target_string)
{
    LSA_HANDLE ph;
    LSA_UNICODE_STRING * secretdata;
    LSA_UNICODE_STRING target;

    DWORD status;

    if (target_string != NULL)
    {
        target.Length = wcslen(target_string) * 2;
        target.MaximumLength = target.Length + 2;
        target.Buffer = target_string;
    }

    status = LsaOpenPolicy(target_string ? &target : NULL, &lsa_object_attributes, MAXIMUM_ALLOWED, &ph);
    if (status != 0)
    {
        printf("LsaOpenPolicy: %X\n", status);
        return status;
    }

    status = LsaRetrievePrivateData(ph, &keyname, &secretdata);
    if (status != 0)
    {
        printf("LsaRetrievePrivateData: %X\n", status);
        return status;
    }

    if (secretdata == NULL)
    {
        printf("NULL pointer retrieved\n");
        return 1;
    }

    printf("%u bytes retrieved\n", secretdata->Length);
    return 0;
}

int delete_data(void)
{
    LSA_HANDLE ph;

    DWORD status;

    status = LsaOpenPolicy(NULL, &lsa_object_attributes, POLICY_ALL_ACCESS, &ph);
    if (status != 0)
    {
        printf("LsaOpenPolicy: %X\n", status);
        return status;
    }

    status = LsaStorePrivateData(ph, &keyname, NULL);
    if (status != 0)
    {
        printf("LsaStorePrivateData: %X\n", status);
        return status;
    }

    printf("Success!\n");
    return 0;
}

int wmain(int argc, wchar_t ** argv)
{
    keyname.Length = wcslen(keyname_string) * 2;
    keyname.MaximumLength = keyname.Length + 2;
    keyname.Buffer = keyname_string;

    lsa_object_attributes.Length = sizeof(lsa_object_attributes);
    lsa_object_attributes.RootDirectory = NULL;
    lsa_object_attributes.ObjectName = NULL;
    lsa_object_attributes.Attributes = 0;
    lsa_object_attributes.SecurityDescriptor = NULL;
    lsa_object_attributes.SecurityQualityOfService = NULL;

    if (argc > 1)
    {
        if (_wcsicmp(argv[1], L"set") == 0)
        {
            return set();
        }
        if (_wcsicmp(argv[1], L"delete") == 0)
        {
            return delete_data();
        }
        else if (_wcsicmp(argv[1], L"get") == 0)
        {
            if (argc == 2)
            {
                return get(NULL);
            }
            else if (argc == 3)
            {
                return get(argv[2]);
            }
        }
    }
    printf("Syntax:\n"
            "testprivatedata set\n"
            "testprivatedata get\n"
            "testprivatedata get \\\\target\n"
            "testprivatedata delete\n");
    return 1;
}
