#include "FileWriter.h"

FileWriter::FileWriter()
{

}

FileWriter::FileWriter(std::wstring& path, MMLReader& reader)
{
    outputPath = path;
    title = reader.title;
    artist = reader.artist;
    copyright = reader.copyright;
    musicnum = reader.musiclist.size();
    dpcmoffset = reader.dpcmoffset;
    dpcmlist = reader.dpcmlist;
    seqdata = reader.seqdata;
}

void FileWriter::createBin()
{
    std::ofstream ofs;
    ofs.open(outputPath, std::ofstream::out | std::ofstream::binary);
    if (!ofs)
    {
        std::cerr << "Faild to write file." << std::endl;
        exit(1);
    }

    for (auto it = seqdata.begin(); it != seqdata.end(); it++)
    {
        ofs.write((const char*)&*it, sizeof(char));
        if (!ofs)
        {
            std::cerr << "Faild to write file." << std::endl;
            exit(1);
        }
    }

    ofs.close();
}


void FileWriter::createNes()
{
    std::ifstream ifs;
    std::wstring dir;
    Utils::GetModuleDir(dir);

    ifs.open(dir + L"drv.bin", std::ifstream::in | std::ifstream::binary);
    if (!ifs)
    {
        std::cerr << "Faild to open drv.bin." << std::endl;
        exit(1);
    }

    std::ofstream ofs;
    ofs.open(outputPath, std::ofstream::out | std::ofstream::binary);
    if (!ofs)
    {
        std::cerr << "Faild to write file." << std::endl;
        exit(1);
    }

    char c;
    int offset = 0x10;
    int dpcmaddr = 0x4000;

    for (int i = 0; i < offset; i++)
    {
        if (ifs && ofs)
        {
            ifs.read(&c, sizeof(char));
            ofs.write(&c, sizeof(char));
        }
        else
        {
            std::cerr << "Faild to write file." << std::endl;
            exit(1);
        }
    }

    for (int i = 0; i < seqdata.size(); i++)
    {
        if (ofs)
        {
            ofs.write((const char*)&seqdata[i], sizeof(char));
        }
        else
        {
            std::cerr << "Faild to write file." << std::endl;
            exit(1);
        }
    }

    ifs.seekg(seqdata.size() + offset);

    for (int i = seqdata.size() + offset; i < dpcmaddr + offset; i++)
    {
        if (ifs && ofs)
        {
            ifs.read(&c, sizeof(char));
            ofs.write(&c, sizeof(char));
        }
        else
        {
            std::cerr << "Faild to write file." << std::endl;
            exit(1);
        }
    }

    int totalsize = 0;
    std::ifstream ifsd;

    for (const auto& [n, file] : dpcmlist)
    {
        ifsd.open(std::filesystem::path(file.path), std::ifstream::binary);

        for (int i = 0; i < file.size; i++)
        {
            if (ifsd && ofs)
            {
                ifsd.read(&c, sizeof(char));
                ofs.write(&c, sizeof(char));
            }
            else
            {
                std::cerr << "Faild to write file." << std::endl;
                exit(1);
            }
        }

        totalsize += file.size;
        ifsd.close();
    }

    ifs.seekg((int)ifs.tellg() + totalsize);

    while (true)
    {
        if (ifs && ofs)
        {
            ifs.read(&c, sizeof(char));
            if (!ifs.eof())
            {
                ofs.write(&c, sizeof(char));
            }
            else
            {
                break;
            }
        }
        else
        {
            std::cerr << "Faild to write file." << std::endl;
            exit(1);
        }
    }

    ofs.close();
}


void FileWriter::createNsf()
{
    std::ifstream ifs;
    std::wstring dir;
    Utils::GetModuleDir(dir);
    std::wstring drv = dir + L"drv.bin";
    auto drvsize = Utils::GetFileSize(drv);
    int maxfilesize = 0x10080;

    ifs.open(drv, std::ifstream::in | std::ifstream::binary);
    if (!ifs)
    {
        std::cerr << "Faild file open drv.bin." << std::endl;
        exit(1);
    }

    std::ofstream ofs;
    ofs.open(outputPath, std::ofstream::out | std::ofstream::binary);
    if (!ofs)
    {
        std::cerr << "Faild to write file." << std::endl;
        exit(1);
    }

    char c;
    int nesheadsize = 0x10;
    int nsfheadsize = 0x80;
    int dpcmaddr = 0x4000 + nsfheadsize;

    unsigned char nsfhead[]{
        0x4e, 0x45, 0x53, 0x4d, 0x1a, 0x01, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x41, 0x1a,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x4e, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    };

    nsfhead[0x06] = musicnum;//曲数
    nsfhead[0x08] = 0x00;   //シーケンスデータの開始アドレス
    nsfhead[0x09] = 0x80;
    nsfhead[0x0a] = 0xcd;   //初期化アドレス
    nsfhead[0x0b] = 0x80;
    nsfhead[0x0c] = 0xe5;   //再生アドレス
    nsfhead[0x0d] = 0x80;

    for (int i = 0; i < 31; i++)
    {
        if (i < title.length())
        {
            nsfhead[i + 0x0e] = title[i];
        }
        else
        {
            break;
        }
    }

    for (int i = 0; i < 31; i++)
    {
        if (i < artist.length())
        {
            nsfhead[i + 0x2e] = artist[i];
        }
        else
        {
            break;
        }
    }

    for (int i = 0; i < 31; i++)
    {
        if (i < copyright.length())
        {
            nsfhead[i + 0x4e] = copyright[i];
        }
        else
        {
            break;
        }
    }

    for (int i = 0; i < nsfheadsize; i++)
    {
        if (ofs)
        {
            ofs.write((const char*)&nsfhead[i], sizeof(char));
        }
        else
        {
            std::cerr << "Faild to write file." << std::endl;
            exit(1);
        }
    }

    ifs.seekg(nsfheadsize);

    while (true)
    {
        if (ifs && ofs)
        {
            ifs.read(&c, sizeof(char));
            if (!ifs.eof())
            {
                ofs.write(&c, sizeof(char));
            }
            else
            {
                break;
            }
        }
        else
        {
            std::cerr << "Faild to write file." << std::endl;
            exit(1);
        }
    }

    if (drvsize + seqdata.size() > dpcmaddr + dpcmoffset)
    {
        std::cerr << "Sequence data size has reached maximum." << std::endl;
        std::cerr << "Seq data : " << seqdata.size() << " bytes, Max : " << dpcmaddr + dpcmoffset - drvsize << " bytes" << std::endl;
        exit(1);
    }

    for (int i = 0; i < seqdata.size(); i++)
    {
        if (ofs)
        {
            ofs.write((const char*)&seqdata[i], sizeof(char));
        }
        else
        {
            std::cerr << "Faild to write file." << std::endl;
            exit(1);
        }
    }

    if (dpcmlist.size() > 0)
    {
        for (int i = drvsize + seqdata.size(); i < dpcmaddr + dpcmoffset; i++)
        {
            if (ofs)
            {
                c = 0;
                ofs.write(&c, sizeof(char));
            }
            else
            {
                std::cerr << "Faild to write file." << std::endl;
                exit(1);
            }
        }
    }

    std::ifstream ifsd;
    int dpcmsize = 0;

    for (const auto& [n, file] : dpcmlist)
    {
        dpcmsize += file.size;
    }

    if (dpcmaddr + dpcmsize + dpcmoffset > maxfilesize)
    {
        std::cerr << "DPCM data size has reached maximum." << std::endl;
        std::cerr << "DPCM data : " << dpcmsize << " bytes, Max : " << maxfilesize - dpcmoffset - dpcmaddr << " bytes" << std::endl;
        exit(1);
    }

    for (const auto& [n, file] : dpcmlist)
    {
        ifsd.open(std::filesystem::path(file.path), std::ifstream::binary);

        for (int i = 0; i < file.size; i++)
        {
            if (ifsd && ofs)
            {
                ifsd.read(&c, sizeof(char));
                ofs.write(&c, sizeof(char));
            }
            else
            {
                std::cerr << "Faild to write file." << std::endl;
                exit(1);
            }
        }

        ifsd.close();
    }

    ofs.close();
}
