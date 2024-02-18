#pragma once
#include <string>
#include "Windows.h"

class Utils
{
public:
    static long long int GetFileSize(std::wstring& filename);
    static bool GetModuleDir(std::wstring& res);
    static bool GetDir(std::wstring& input, std::wstring& output);
    static bool GetFullPath(std::wstring& res);
};

