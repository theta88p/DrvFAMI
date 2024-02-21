#include <iostream>
#include "MMLReader.h"
#include "FileWriter.h"

void outputUsage()
{
    std::cout << "DrvFAMI MML Compiler Input -Options\n\n";
    std::cout << "  -o\tOutput filename\n";
    std::cout << "  -r\tOutput raw data\n";
}

int wmain(int argc, wchar_t* argv[])
{
    std::wstring input;
    std::wstring output;
    std::wstring dir;
    std::wstring ext;
    bool raw = false;

    std::wcout.imbue(std::locale("Japanese"));
    std::wcout << "DrvFAMI MML Compiler v0.1.0  (c) theta 2024" << std::endl;
    std::wcout << std::endl;

    if (argc < 2)
    {
        outputUsage();
        exit(1);
    }

    if (argv[1] == L"")
    {
        std::wcerr << "Enter filename." << std::endl;
        exit(1);
    }
    else
    {
        bool res = false;
        input = argv[1];
        if (Utils::GetFullPath(input))
        {
            if (Utils::GetDir(input, dir))
            {
                if (SetCurrentDirectory(dir.c_str()))
                {
                    res = true;
                }
            }
        }

        if (!res)
        {
            std::wcerr << "Faild to set current directory." << std::endl;
            exit(1);
        }
    }

    for (int i = 0; i < argc; i++)
    {
        if (argv[i][0] == '-')
        {
            switch (argv[i][1])
            {
            case 'o':
            case 'O'://Output
                if (i + 1 < argc)
                {
                    if (argv[i + 1] != L"")
                    {
                        output = argv[i + 1];
                    }
                    else
                    {
                        std::wcerr << "Missing output filename." << std::endl;
                        exit(1);
                    }
                }
                break;
            case 'r':
            case 'R'://Raw
                raw = true;
                break;
            default:
                std::wcerr << "Unknown option '-" << argv[i][1] << "'" << std::endl;
                exit(1);
            }
        }
    }

    if (raw)
    {
        ext = L"bin";
    }
    else
    {
        ext = L"nsf";
    }

    if (output.empty())
    {
        output = input;

        while (true)
        {
            if (output[output.size() - 1] == '.')
            {
                break;
            }
            output.pop_back();
        }

        output += ext;
    }

    std::wcout << "Input: " << input << std::endl << "Output: " << output << std::endl << std::endl;
    MMLReader reader(input);
    reader.readMML();

    FileWriter writer(output, reader);

    if (raw)
    {
        writer.createBin();
    }
    else
    {
        writer.createNsf();
    }

    std::wcout << "Finished!" << std::endl;
    exit(0);
}
