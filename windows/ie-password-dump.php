/**
 *  The MIT License:
 *
 *  Copyright (c) 2012 Kevin Devine
 *
 *  Permission is hereby granted,  free of charge,  to any person obtaining a
 *  copy of this software and associated documentation files (the "Software"),
 *  to deal in the Software without restriction,  including without limitation
 *  the rights to use,  copy,  modify,  merge,  publish,  distribute,
 *  sublicense,  and/or sell copies of the Software,  and to permit persons to
 *  whom the Software is furnished to do so,  subject to the following
 *  conditions:
 *
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS",  WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED,  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,  DAMAGES OR OTHER
 *  LIABILITY,  WHETHER IN AN ACTION OF CONTRACT,  TORT OR OTHERWISE,
 *  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 *  OTHER DEALINGS IN THE SOFTWARE.
 */

#define UNICODE
#define _WIN32_IE 0x0500

#include <windows.h>

#include <string>
#include <cstdio>
#include <vector>
#include <algorithm>

#include <UrlHist.h>
#include <shlguid.h>
#include <Shlobj.h>
#include <wincrypt.h>
#include <Wininet.h>
#include <atlbase.h>

#pragma comment(lib, "Advapi32.lib")
#pragma comment(lib, "user32.lib")
#pragma comment(lib, "Ole32.lib")
#pragma comment(lib, "wininet.lib")
#pragma comment(lib, "crypt32.lib")

#define MAX_URL_NAME 255
#define MAX_URL_VALUE 4096*4

typedef struct _IE_STORAGE_ENTRY {
  std::wstring UrlHash;
  DWORD cbData;
  BYTE pbData[MAX_URL_VALUE];
} IE_STORAGE_ENTRY, *PIE_STORAGE_ENTRY;

std::vector <IE_STORAGE_ENTRY> entries;
std::vector <std::wstring> url_list;

#pragma pack(push, 1)
struct AutoCompleteBlob {
  DWORD   cbHdrSize;
  DWORD   cbStringSize1;
  DWORD   cbStringSize2;

  DWORD   dwSignature;
  DWORD   cbStringSize;
  DWORD   dwNumStrings;
  DWORD   dwReserved;
  INT64   iData;

  struct tagStringEntry {
    union {
      DWORD_PTR   dwStringPtr;
      LPWSTR      pwszString;
    };
    FILETIME    ftLastSubmitted;
    DWORD       dwStringLen;
  }
  StringEntry[];
};
#pragma pack(pop)


/**
 *
 *  enumerate auto complete entries for Internet Explorer
 *  return the number of entries found
 *
 */
size_t GetEntries(void) {
  HKEY hKey;
  DWORD dwResult;

  dwResult = RegOpenKeyEx(HKEY_CURRENT_USER,
      L"Software\\Microsoft\\Internet Explorer\\IntelliForms\\Storage2",
      0, KEY_QUERY_VALUE, &hKey);

  if (dwResult == ERROR_SUCCESS) {
    DWORD dwIndex = 0;

    do {
      IE_STORAGE_ENTRY entry;

      DWORD cbUrl = MAX_URL_NAME;
      wchar_t UrlHash[MAX_URL_NAME];

      entry.cbData = MAX_URL_VALUE;

      dwResult = RegEnumValue(hKey, dwIndex, UrlHash, &cbUrl,
          NULL, 0, entry.pbData, &entry.cbData);

      if (dwResult == ERROR_SUCCESS) {
        entry.UrlHash = UrlHash;
        entries.push_back(entry);
      }
      dwIndex++;
    } while (dwResult != ERROR_NO_MORE_ITEMS);
    RegCloseKey(hKey);
  }
  return entries.size();
}

/**
 *
 *  Generate SHA1 string from str parameter
 *  return string of hash
 */
BOOL GetUrlHash(std::wstring str, std::wstring &result) {
  HCRYPTPROV hProv;
  HCRYPTHASH hHash;
  BOOL bResult = FALSE;

  if (CryptAcquireContext(&hProv, NULL, NULL, PROV_RSA_FULL,
      CRYPT_VERIFYCONTEXT)) {

    if (CryptCreateHash(hProv, CALG_SHA1, 0, 0, &hHash)) {
      if (CryptHashData(hHash, (PBYTE)str.c_str(),
          str.length() * sizeof(wchar_t) + 2, 0)) {

        BYTE bHash[20];
        DWORD dwHashLen = sizeof(bHash);

        bResult = CryptGetHashParam(hHash, HP_HASHVAL, bHash, &dwHashLen, 0);
        if (bResult) {
          wchar_t wcsSha1[64] = {0};
          dwHashLen = sizeof(wcsSha1) / sizeof(wchar_t);
          bResult = CryptBinaryToString(bHash, sizeof(bHash),
              CRYPT_STRING_HEXRAW | CRYPT_STRING_NOCRLF, wcsSha1, &dwHashLen);
          BYTE sum = 0;
          for (int i = 0; i < 20; i++) {
            sum += bHash[i];
          }
          _snwprintf(&wcsSha1[40], sizeof(wchar_t), L"%02X", sum);
          CharUpper(wcsSha1);
          result = wcsSha1;
        }
      }
      CryptDestroyHash(hHash);
    }
    CryptReleaseContext(hProv, 0);
  }
  return bResult;
}

void AddUrl(wchar_t url[]) {
  wchar_t *p1 = url, *p2;

  if (NULL != (p2 = wcschr(url, L'\n'))) *p2 = L'\0';
  if (NULL != (p2 = wcschr(url, L'\r'))) *p2 = L'\0';
  if (NULL != (p2 = wcschr(url, L'?' ))) *p2 = L'\0';
  if (NULL != (p2 = wcschr(url, L'@' ))) p1 = (p2 + 1);

  CharLower(url);
  url_list.push_back(p1);
}

void EnumTypedUrls(void) {
  HKEY hKey;
  DWORD dwResult;

  dwResult = RegOpenKeyEx(HKEY_CURRENT_USER,
      L"Software\\Microsoft\\Internet Explorer\\TypedURLs",
      0, KEY_QUERY_VALUE, &hKey);

  if (dwResult == ERROR_SUCCESS) {
    DWORD dwIndex = 0;
    do {
      DWORD cbUrl, cbUrlName;
      wchar_t Url[255], UrlName[255];

      cbUrl = cbUrlName = 255;
      dwResult = RegEnumValue(hKey, dwIndex, UrlName, &cbUrlName,
          NULL, 0, (PBYTE)Url, &cbUrl);

      if (dwResult == ERROR_SUCCESS) {
        AddUrl(Url);
      }
      dwIndex++;
    } while (dwResult != ERROR_NO_MORE_ITEMS);
    RegCloseKey(hKey);
  }
}

/**
 *
 * enumerate urls from cache
 *
 */
void EnumUrlCache1(void) {
  HRESULT hr = CoInitialize(NULL);

  if (SUCCEEDED(hr)) {
    CComPtr<IUrlHistoryStg2> pHistory;
    hr = CoCreateInstance(CLSID_CUrlHistory, NULL, CLSCTX_INPROC_SERVER,
        IID_IUrlHistoryStg2,(void**)(&pHistory));

    if (SUCCEEDED(hr)) {
      CComPtr<IEnumSTATURL> pUrls;
      hr = pHistory->EnumUrls(&pUrls);

      if (SUCCEEDED(hr)) {
        for (;;) {
          STATURL st;
          ULONG result;
          hr = pUrls->Next(1, &st, &result);
          if (FAILED(hr) || result != 1) {
            break;
          }
          AddUrl(st.pwcsUrl);
        }
        pUrls = NULL;
      }
      pHistory = NULL;
    }
    CoUninitialize();
  }
}

/**
 *
 *  Another method of enumerating cache
 *
 */
void EnumUrlCache2(void) {
  HANDLE hEntry;
  DWORD dwSize;
  BYTE buffer[8192];
  LPINTERNET_CACHE_ENTRY_INFO info = (LPINTERNET_CACHE_ENTRY_INFO)buffer;

  dwSize = 8192;
  hEntry = FindFirstUrlCacheEntry(NULL, info, &dwSize);

  if (hEntry != NULL) {
    do {
      if (info->CacheEntryType != COOKIE_CACHE_ENTRY) {
        AddUrl(info->lpszSourceUrlName);
      }
      dwSize = 8192;
    } while (FindNextUrlCacheEntry(hEntry, info, &dwSize));
    FindCloseUrlCache(hEntry);
  }
}

/**
 *
 *  Read and save a list of URLs from file
 *
 */
void LoadUrlFromFile(void) {
  FILE *fd = _wfopen(L"urls.txt", L"rb");

  if (fd != NULL) {
    BYTE buffer[8];
    size_t readSize = fread(buffer, 1, 8, fd);
    fseek(fd, 0, SEEK_SET);

    BOOL bUnicode = IsTextUnicode(buffer, readSize, NULL);

    while (!feof(fd)) {
      wchar_t s[MAX_URL_NAME + 1];

      if (bUnicode) {
        fgetws(s, MAX_URL_NAME, fd);
      } else {
        char ansi_word[MAX_URL_NAME + 1];
        fgets(ansi_word, MAX_URL_NAME, fd);
        MultiByteToWideChar(CP_ACP, 0, ansi_word, 1, s, MAX_URL_NAME);
      }
      AddUrl(s);
    }
    fclose(fd);
  }
}

/**
 *
 *  Generate list of URLs from local machine by reading:
 *
 *   Cache
 *   Registry
 *   File
 *
 */
size_t EnumUrls(void) {
  EnumUrlCache1();
  EnumUrlCache2();

  LoadUrlFromFile();
  EnumTypedUrls();

  // sort and weed out duplicates
  if (url_list.size() != 0) {
    std::sort(url_list.begin(), url_list.end());
    url_list.erase( std::unique(url_list.begin(),
        url_list.end()), url_list.end());
  }
  return url_list.size();
}

/**
 *
 *  Dump a single autocomplete entry
 *
 */
void DumpEntry(PBYTE pInfo, const wchar_t url[]) {

  AutoCompleteBlob *blob = (AutoCompleteBlob*)pInfo;
  PBYTE pse = (PBYTE)&pInfo[blob->cbHdrSize + blob->cbStringSize1];

  // process 2 entries for each login
  for (DWORD i = 0; i < blob->dwNumStrings; i += 2) {
    PWCHAR username = (PWCHAR)&pse[blob->StringEntry[i + 0].dwStringPtr];
    PWCHAR password = (PWCHAR)&pse[blob->StringEntry[i + 1].dwStringPtr];

    bool bTime = false;
    wchar_t updated[MAX_PATH];

    if (lstrlen(password) > 0) {
      FILETIME ft, lt;
      SYSTEMTIME st;

      FileTimeToLocalFileTime(&blob->StringEntry[i].ftLastSubmitted, &lt);
      FileTimeToSystemTime(&lt, &st);

      bTime = (GetDateFormatW(LOCALE_SYSTEM_DEFAULT, 0,
          &st, L"MM/dd/yyyy", updated, MAX_PATH) > 0);
          
      wprintf(L"\n  %-32s  %-32s  %-15s  %-48s",
        username, password, bTime ? updated : L"NEVER", url);
    }
  }
}

void DecodeEntries(void) {
  wprintf(L"\n  %-32s  %-32s  %-15s  %-48s",
      std::wstring(32, L'-').c_str(),
      std::wstring(32, L'-').c_str(),
      std::wstring(15, L'-').c_str(),
      std::wstring(48, L'-').c_str());

  wprintf(L"\n  %-32s  %-32s  %-15s  %-48s",
      L"Username", L"Password", L"Last Update", L"URL address");

  wprintf(L"\n  %-32s  %-32s  %-15s  %-48s",
      std::wstring(32, L'-').c_str(),
      std::wstring(32, L'-').c_str(),
      std::wstring(15, L'-').c_str(),
      std::wstring(48, L'-').c_str());

  // hash each url found in cache
  for (size_t i = 0;i < url_list.size();i++) {
    std::wstring sha1_hash;
    if (GetUrlHash(url_list[i], sha1_hash)) {
      // search through auto complete entries for a match
      for (size_t j = 0;j < entries.size();j++) {
        if (entries[j].UrlHash == sha1_hash) {

          DATA_BLOB in, out, entropy;

          in.pbData = entries[j].pbData;
          in.cbData = entries[j].cbData;

          entropy.pbData = (PBYTE) url_list[i].c_str();
          entropy.cbData = url_list[i].length() * 2 + 2;

          if (CryptUnprotectData(&in, NULL, &entropy, NULL, NULL, 0, &out)) {
            DumpEntry(out.pbData, url_list[i].c_str());
            LocalFree(out.pbData);
          }
        }
      }
    }
  }
}

/**
 *
 *  Set the buffer width of console
 *  if X is less than current width, do nothing.
 *
 */
VOID ConsoleSetBufferWidth(SHORT X) {
  CONSOLE_SCREEN_BUFFER_INFO csbi;
  GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &csbi);

  if (X <= csbi.dwSize.X) return;
  csbi.dwSize.X = X;
  SetConsoleScreenBufferSize(GetStdHandle(STD_OUTPUT_HANDLE), csbi.dwSize);
}

int wmain(void) {
  ConsoleSetBufferWidth(300);

  puts("\n  Internet Explorer 7/8/9 Password Dumper v1.0"
       "\n  Copyright (c) 2012 Kevin Devine");

  DWORD nEntries = GetEntries();
  wprintf(L"\n  %i auto complete entries found.", nEntries);

  if (nEntries > 0) {
    DWORD nUrls = EnumUrls();
    wprintf(L"\n  %i URL entries loaded.\n", nUrls);
    DecodeEntries();
  }
  //wprintf(L"\n\n  Press any key to continue . . .");
  //fgetc(stdin);
  return 0;
}
