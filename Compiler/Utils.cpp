#include "Utils.h"

long long int Utils::GetFileSize(std::wstring& filename)
{
    HANDLE handle = CreateFileW(
        filename.c_str(),
        GENERIC_READ,
        0,
        NULL,
        OPEN_EXISTING,
        FILE_ATTRIBUTE_NORMAL,
        NULL
    );
    if (handle == INVALID_HANDLE_VALUE)
    {
        return -1LL;
    }

    LARGE_INTEGER fsize;
    if (!GetFileSizeEx(handle, &fsize))
    {
        CloseHandle(handle);
        return -1LL;
    }
    else
    {
        CloseHandle(handle);
        return fsize.QuadPart;
    }
}


bool Utils::GetModuleDir(std::wstring& res)
{
    wchar_t buf[MAX_PATH * 2];

    if (FALSE != GetModuleFileName(NULL, buf, MAX_PATH * 2))
    {
        std::wstring in(buf);
        if (Utils::GetDir(in, res))
        {
            return true;
        }
    }
    return false;
}


bool Utils::GetDir(std::wstring& in, std::wstring& out)
{
    if (!in.empty())
    {
        wchar_t drive[MAX_PATH * 2]
            , dir[MAX_PATH * 2]
            , fname[MAX_PATH * 2]
            , ext[MAX_PATH * 2];
        _wsplitpath_s(in.c_str(), drive, dir, fname, ext);
        out = std::wstring(drive) + std::wstring(dir);
        return true;
    }
    return false;
}


bool Utils::GetFullPath(std::wstring& res)
{
    wchar_t buf[MAX_PATH * 2];

    if (FALSE != GetFullPathName(res.c_str(), MAX_PATH * 2, buf, NULL))
    {
        res = std::wstring(buf);
        return true;
    }
    return false;
}