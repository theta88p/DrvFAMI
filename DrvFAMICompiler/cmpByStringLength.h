#pragma once
#include <string>

struct cmpByStringLength
{
    bool operator()(const std::string& a, const std::string& b) const
    {
        if (a.length() == b.length())
        {
            return a < b;
        }
        else
        {
            return a.length() > b.length();
        }
    }
};