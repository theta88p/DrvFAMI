#include "MMLReader.h"

//�m�[�g�e�[�u���i�m�[�g�����Ɖ��K�̊֌W�j
                      /* a b  c d e f g */
const unsigned char notetbl[] = { 9, 11, 0, 2, 4, 5, 7 };
//�����e�[�u���i�����ԍ���192/n�����̊֌W�j
/* 1 2 3 4 6 8 12 16 24 32 48 64 */
const unsigned char nthnotetbl[] = { 1, 2, 3, 4, 6, 8, 12, 16, 24, 32, 48, 64, 96 };

MMLReader::MMLReader()
{
    totalpos = 0;
    linenum = 1;
    deflen = 4;
    timebase = 96;
    dpcmoffset = 0;
    v_offset = 0;
    f_offset = 0;
    n_offset = 0;
    t_offset = 0;
}

MMLReader::MMLReader(std::wstring& input) : MMLReader()
{
    inputPath = input;
}

MMLReader::~MMLReader()
{

}


void MMLReader::readMML()
{
    char c;
    int n;
    int music = 0;
    std::map<std::string, std::string, cmpByStringLength> macrolist;
    std::vector<unsigned char> head;
    std::vector<unsigned char> body;
    std::ifstream ifs;

    ifs.open(inputPath);

    if (!ifs)
    {
        std::wcerr << "Can not open '" << inputPath << "'" << std::endl;
        exit(1);
    }
    
    ss << ifs.rdbuf();

    readMacro(macrolist);
    linenum = 1;
    
    ss.clear();
    ss.seekg(0);
    std::stringstream ss2;

    replaceMacro(macrolist, ss2);
    /*
    while (!ss2.eof())
    {
        std::string line;
        std::getline(ss2, line);
        std::wcout << line.c_str() << std::endl;
    }
    */
    linenum = 1;
    ss.str("");
    ss.clear();
    ss << ss2.rdbuf();

    while (!ss.eof())      //�ŏ��ɋȐ������擾���Ă����B�w�b�_�T�C�Y�����܂�Ȃ��ƃG���x���[�v�A�h���X���擾�ł��Ȃ����߁B
    {
        if (findStr("music"))
        {
            skipSpace();
            if (getMultiDigit(n))
            {
                musiclist.push_back(n);
                music++;
            }
        }
    }

    if (music < 1)
    {
        std::wcerr << "No Music." << std::endl;
        exit(1);
    }

    linenum = 1;

    //�Ȑ� * �ȃA�h���X2byte
    int musichead = music * 2;
    totalpos = musichead;

    linenum = 1;
    ss.clear();
    ss.seekg(0);    //�ǂݍ��݈ʒu��߂�

    makeLengthTbl(lengthtbl);
    readDifinitions();

    linenum = 1;
    ss.clear();
    ss.seekg(0);    //�ǂݍ��݈ʒu��߂�
    
    int envsize = 0;
    readEnvelope(envsize);
    totalpos += envsize;

    for (const auto& [k, v] : envdata)
    {
        std::copy(v.data.begin(), v.data.end(), std::back_inserter(body));
    }

    linenum = 1;
    ss.clear();
    ss.seekg(0);    //�ǂݍ��݈ʒu��߂�

    int subsize = 0;
    readSubRoutine(subsize);
    totalpos += subsize;

    for (int i = 0; i < subdata.size(); i++)
    {
        std::copy(subdata[i].data.begin(), subdata[i].data.end(), std::back_inserter(body));
    }

    linenum = 1;
    ss.clear();
    ss.seekg(0);    //�ǂݍ��݈ʒu��߂�

    for (int i = 0; i < music; i++)
    {
        std::vector<unsigned char> musdata;
        findStr("music");
        skipSpace();
        if (getMultiDigit(n) && n == musiclist[i])
        {
            if (findStr("{"))
            {
                int seek = ss.tellg();
                int curline = linenum;
                int track = 0;

                while (!ss.eof())                  //�g���b�N�����擾
                {
                    if (findStr("track", "}"))
                    {
                        track++;
                    }
                    else
                    {
                        break;
                    }
                }

                linenum = curline;
                ss.clear();
                ss.seekg(seek);    //�ǂݍ��݈ʒu��߂�

                //�g���b�N�� x 4byte�i�g���b�N�̃A�h���X�ƃg���b�N�ԍ��Ɖ����ԍ��j + �g���b�N�w�b�_�̏I�[�R�[�h + �f�t�H�����f�[�^
                int trheadsize = track * 4 + 1 + 1;

                readBrackets(ss.tellg(), trheadsize, musdata);
                std::copy(musdata.begin(), musdata.end(), std::back_inserter(body));
                head.push_back(totalpos & 0x00ff);
                head.push_back((totalpos & 0xff00) >> 8);
                totalpos += musdata.size();

                linenum = 1;
                ss.clear();
                ss.seekg(0);    //�ǂݍ��݈ʒu��߂�
            }
        }
    }

    std::copy(head.begin(), head.end(), std::back_inserter(seqdata));
    std::copy(body.begin(), body.end(), std::back_inserter(seqdata));

    ifs.close();
}


void MMLReader::readDifinitions()
{
    char c;
    int n;
    bool isTrack = false;
    bool isMusic = false;
    bool isSub = false;

    while (ss.get(c))
    {
        skipSpace();
        skipComment();
        skipSpace();
        if (c == '#')
        {
            if (isMusic || isTrack)
            {
                std::cerr << "Line " << linenum << " : Please write settings starting with '#' at the beginning of the file." << std::endl;
                exit(1);
            }
            else if (isNextStr("timebase"))
            {
                skipSpace();
                if (getMultiDigit(n))
                {
                    timebase = n;
                    lengthtbl.clear();
                    makeLengthTbl(lengthtbl);
                }
            }
            else if (isNextStr("offsetpcm"))
            {
                skipSpace();
                if (getMultiHex(n))
                {
                    dpcmoffset = n - 0xc000;
                }
            }
            else if (isNextStr("offsetv"))
            {
                skipSpace();
                if (getMultiDigit(n))
                {
                    v_offset = n;
                }
            }
            else if (isNextStr("offsetf"))
            {
                skipSpace();
                if (getMultiDigit(n))
                {
                    f_offset = n;
                }
            }
            else if (isNextStr("offsetn"))
            {
                skipSpace();
                if (getMultiDigit(n))
                {
                    n_offset = n;
                }
            }
            else if (isNextStr("offsett"))
            {
                skipSpace();
                if (getMultiDigit(n))
                {
                    t_offset = n;
                }
            }
            else if (isNextStr("title"))
            {
                getStrInQuote(title);
            }
            else if (isNextStr("artist"))
            {
                getStrInQuote(artist);
            }
            else if (isNextStr("copyright"))
            {
                getStrInQuote(copyright);
            }
        }
        else if (c == '@')
        {
            if (isNextStr("dpcm"))   //DPCM���X�g
            {
                int tb;
                skipSpace();
                if (isNextChar('{'))
                {
                    while (!ss.eof())
                    {
                        skipSpace();
                        skipComment();
                        skipSpace();
                        if (getMultiDigit(n))
                        {
                            int dpcmnum = n;
                            skipSpace();
                            if (isNextChar('"'))
                            {
                                std::wstring str;
                                while (ss.get(c))
                                {
                                    if (c != '"')
                                    {
                                        str += c;
                                    }
                                    else
                                    {
                                        break;
                                    }
                                }
                                if (!str.empty())
                                {
                                    if (!Utils::GetFullPath(str))
                                    {
                                        std::cerr << "Line " << linenum << " : Failed to get DPCM path." << std::endl;
                                        exit(1);
                                    }
                                }
                                else
                                {
                                    std::cerr << "Line " << linenum << " : Missing DPCM path." << std::endl;
                                    exit(1);
                                }
                                DpcmInfo d;
                                d.path = str;
                                dpcmlist[dpcmnum] = d;
                                skipSpace();
                                skipComment();
                                skipSpace();
                                if (isNextChar('}'))
                                {
                                    int offset = dpcmoffset;

                                    for (auto& [num, dpcm] : dpcmlist)
                                    {
                                        int size = Utils::GetFileSize(dpcm.path);
                                        if (size > 0)
                                        {
                                            dpcm.offset = offset;
                                            dpcm.size = size;
                                            offset += size;
                                        }
                                        else
                                        {
                                            std::cerr << "Line " << linenum << " : Failed to get DPCM file size." << std::endl;
                                            exit(1);
                                        }
                                    }
                                    break;
                                }
                            }
                            else
                            {
                                std::cerr << "Line " << linenum << " : Missing \"." << std::endl;
                                exit(1);
                            }
                        }
                        else
                        {
                            std::cerr << "Line " << linenum << " : Missing DPCM Number." << std::endl;
                            exit(1);
                        }
                    }
                }
                else
                {
                    std::cerr << "Line " << linenum << " : Missing {." << std::endl;
                    exit(1);
                }
            }
            else if (isNextChar('m'))   //�}�b�v��`
            {
                if (!isTrack && !isSub)  //�O�ɂ��������`
                {
                    skipSpace();
                    if (getMultiDigit(n))
                    {
                        if (mapdiflist.count(n) > 0)
                        {
                            std::cerr << "Line " << linenum << " : Map diffinition #" << n << " is already exists." << std::endl;
                            exit(1);
                        }

                        NoteMapDif mapdif;
                        mapdif.number = n;

                        skipSpace();
                        if (isNextChar('{'))
                        {
                            skipSpace();
                            skipComment();
                            skipSpace();

                            //��������m�[�g�i���o�[�ƒ�`���X�g�̗�
                            while (!ss.eof())
                            {
                                NoteMap map;
                                skipSpaceUntilNextLine();
                                skipComment();
                                skipSpaceUntilNextLine();
                                getNoteNumber(map.target);

                                //�R�}���h�̗�
                                while (!ss.eof())
                                {
                                    int convert = 0;
                                    Command cmd;
                                    CommandArgs args;
                                    skipSpaceUntilNextLine();
                                    skipComment();
                                    skipSpaceUntilNextLine();

                                    if (getNoteNumber(convert))   //�ϊ���m�[�g�i���o�[
                                    {
                                        map.convert = convert;
                                        cmd = map.target;
                                    }
                                    else if (getc(c))
                                    {
                                        if (c == '@')   //�G���x���[�v�����F���f�[�^�Đ�
                                        {
                                            skipSpaceUntilNextLine();
                                            getc(c);
                                            switch (c)
                                            {
                                            case 'v':
                                            case 'V':
                                                if (isNextChar('*'))
                                                {
                                                    cmd = VOLUME_ENV_STOP;
                                                }
                                                else
                                                {
                                                    cmd = VOLUME_ENV;
                                                    getCmdArgs(args);
                                                }
                                                break;
                                            case 'f':
                                            case 'F':
                                                if (isNextChar('*'))
                                                {
                                                    cmd = FREQ_ENV_STOP;
                                                }
                                                else
                                                {
                                                    cmd = FREQ_ENV;
                                                    getCmdArgs(args);
                                                }
                                                break;
                                            case 'n':
                                            case 'N':
                                                if (isNextChar('*'))
                                                {
                                                    cmd = NOTE_ENV_STOP;
                                                }
                                                else
                                                {
                                                    cmd = NOTE_ENV;
                                                    getCmdArgs(args);
                                                }
                                                break;
                                            case 't':
                                            case 'T':
                                                if (isNextChar('*'))
                                                {
                                                    cmd = TONE_ENV_STOP;
                                                }
                                                else
                                                {
                                                    cmd = TONE_ENV;
                                                    getCmdArgs(args);
                                                }
                                                break;
                                            case 'p':
                                            case 'P':
                                                cmd = PLAY_DATA;
                                                getCmdArgs(args);
                                                break;
                                            default:
                                                cmd = TONE;
                                                args.push_back(std::atoi(&c));
                                                break;
                                            }
                                        }
                                        else if (c == 's' || c == 'S')  //�\�t�g�E�F�A�X�C�[�v
                                        {
                                            cmd = SW_SWEEP;
                                            getCmdArgs(args);
                                        }
                                        else if (c == 'q')  //�Q�[�g�^�C��q
                                        {
                                            cmd = GATE_TIME_Q;
                                            getCmdArgs(args);
                                        }
                                        else if (c == 'u')  //�Q�[�g�^�C��u
                                        {
                                            cmd = GATE_TIME_U;
                                            getCmdArgs(args);
                                        }
                                        else if (c == 'Q')  //�Q�[�g�^�C��Q
                                        {
                                            cmd = GATE_TIME_BIGQ;
                                            getCmdArgs(args);
                                        }
                                        else if (c == 'K')  //�L�[�V�t�g��Ύw��
                                        {
                                            cmd = KEYSHIFT_ABS;
                                            getCmdArgs(args);
                                        }
                                        else if (c == 'v' || c == 'V')  //�{�����[��
                                        {
                                            cmd = VOLUME_ABS;
                                            getCmdArgs(args);
                                        }
                                        else if (c == 'r' || c == 'R')  //�x��
                                        {
                                            cmd = REST_DEFLEN;
                                        }
                                        else if (c == '\n')    //���s�ŏI��
                                        {
                                            linenum++;
                                            break;
                                        }
                                        else if (c == '}')   //�����������������`�I��
                                        {
                                            break;
                                        }
                                        else
                                        {
                                            std::cerr << "Line " << linenum << " : Invalid map difinition." << std::endl;
                                            exit(1);
                                        }
                                    }
                                    map.commands[cmd] = args;
                                }

                                mapdif.maplist[map.target] = map;

                                skipSpace();
                                skipComment();
                                skipSpace();

                                if (c == '}' || isNextChar('}'))   //�����������������`�I��
                                {
                                    mapdiflist[mapdif.number] = mapdif;
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }
        else if (c == '\n')
        {
            linenum++;
        }
        else if (c == '\\')
        {
            isSub = true;
        }
        else if (c == '}')
        {
            if (isSub)
            {
                isSub = false;
            }
        }
        else if (c == 't' || c == 'T')
        {
            if (isNextStr("rack"))
            {
                isTrack = true;
            }
        }
        else if (c == 'm' || c == 'M')
        {
            if (isNextStr("usic"))
            {
                isMusic = true;
            }
        }
    }
}


void MMLReader::readMacro(std::map<std::string, std::string, cmpByStringLength>& macrolist)
{
    char c;
    int n;
    bool isTrack = false;
    bool isMusic = false;

    while (ss.get(c))
    {
        skipSpace();
        skipComment();
        skipSpace();
        if (c == '$')
        {
            getc(c);
            if (c != '$')
            {
                if (!isMusic)
                {
                    std::string mname;
                    std::string mbody;

                    while (c != '{' && !ss.eof())
                    {
                        mname += c;
                        skipSpace();
                        skipComment();
                        skipSpace();
                        getc(c);
                    }

                    if (!mname.empty())
                    {
                        if (macrolist.count(mname))
                        {
                            std::cerr << "Line " << linenum << " : Macro $" << mname << " is already exists." << std::endl;
                            exit(1);
                        }
                    }

                    getc(c);
                    while (c != '}' && !ss.eof())
                    {
                        mbody += c;
                        skipSpace();
                        skipComment();
                        skipSpace();
                        getc(c);
                    }

                    if (!mbody.empty())
                    {
                        macrolist[mname] = mbody;
                    }
                }
            }
        }
        else if (c == '\n')
        {
            linenum++;
        }
        else if (c == 't' || c == 'T')
        {
            if (isNextStr("rack"))
            {
                isTrack = true;
            }
        }
        else if (c == 'm' || c == 'M')
        {
            if (isNextStr("usic"))
            {
                isMusic = true;
            }
        }
    }
}


void MMLReader::replaceMacro(std::map<std::string, std::string, cmpByStringLength>& macrolist, std::stringstream& ss2)
{
    bool isMusic = false;
    bool isSub = false;
    std::string buf;

    while (std::getline(ss, buf))
    {
        std::string lower;
        std::transform(buf.begin(), buf.end(), std::back_inserter(lower), tolower);

        if (lower.find("music") != std::string::npos)
        {
            isMusic = true;
        }
        else if (!isMusic && buf.find("\\") != std::string::npos)    //�T�u���[�`����`
        {
            isSub = true;
        }

        if (isMusic || isSub)
        {
            auto bpos = buf.find('}');

            if (isMusic && bpos != std::string::npos)
            {
                isMusic = false;
            }
            else if (isSub && bpos != std::string::npos)
            {
                isSub = false;
            }

            for (const auto& [k, v] : macrolist)
            {
                std::string name = "$" + k;

                while (true && !ss.eof())
                {
                    auto rpos = buf.find(name);
                    if (rpos != std::string::npos && rpos < bpos)
                    {
                        std::string pre = buf.substr(0, rpos);
                        std::string post = buf.substr(rpos + name.length(), buf.length());
                        buf = pre + v + post;
                    }
                    else
                    {
                        break;
                    }
                }
            }
        }

        ss2 << buf << std::endl;
        linenum++;
    }
}


void MMLReader::readSubRoutine(int& subsize)
{
    char c;
    int n;
    bool isTrack = false;
    bool isMusic = false;

    while (ss.get(c))
    {
        skipSpace();
        skipComment();

        if (c == '\\')
        {
            if (!isTrack && !isMusic)
            {
                skipSpace();
                if (getMultiDigit(n))
                {
                    int subnum = n;
                    for (int i = 0; i < subdata.size(); i++)   //���d��`�h�~
                    {
                        if (subdata[i].num == subnum)
                        {
                            std::cerr << "Line " << linenum << " : Subroutine #" << subnum << " is already exists." << std::endl;
                            exit(1);
                        }
                    }

                    skipSpace();
                    if (isNextChar('{'))
                    {
                        int pos = ss.tellg();
                        std::vector<unsigned char> data;
                        readBrackets(pos, 0, data);
                        SubData sd;
                        sd.num = subnum;
                        sd.addr = totalpos + subsize;
                        data.push_back(LOOP_MID_END);    //���[�v�r���I���R�[�h�Ŗ߂�
                        sd.data = data;
                        subdata[subnum] = sd;
                        subsize += data.size();
                    }
                }
            }
        }
        else if (c == '\n')
        {
            linenum++;
        }
        else if (c == 't' || c == 'T')
        {
            if (isNextStr("rack"))
            {
                isTrack = true;
            }
        }
        else if (c == 'm' || c == 'M')
        {
            if (isNextStr("usic"))
            {
                isMusic = true;
            }
        }
    }
}


void MMLReader::readEnvelope(int& envsize)
{
    char c;
    int n;
    bool isTrack = false;
    bool isMusic = false;

    while (ss.get(c))
    {
        skipSpace();
        skipComment();

        if (c == '@')   //���F�w�肩�e���`
        {
            if (!isTrack && !isMusic)
            {
                skipSpace();
                if (isNextChar('e'))
                {
                    if (isTrack)
                    {
                        std::cerr << "Line " << linenum << " : Do not write envelope difinition in the track." << std::endl;
                        exit(1);
                    }

                    if (isMusic)
                    {
                        std::cerr << "Line " << linenum << " : Do not write envelope difinition in the music." << std::endl;
                        exit(1);
                    }
                    skipSpace();
                    if (getMultiDigit(n))
                    {
                        int envnum = n;
                        if (envdata.count(n))   //���d��`�h�~
                        {
                            std::cerr << "Line " << linenum << " : [Envelope difinition] Envelope #" << envnum << " is already exists." << std::endl;
                            exit(1);
                        }

                        skipSpace();
                        if (isNextChar('{'))
                        {
                            EnvData env;
                            std::vector<unsigned char> ehead;
                            std::vector<unsigned char> ebody;

                            while (!ss.eof())
                            {
                                skipSpace();
                                if (getMultiDigit(n))
                                {
                                    ebody.push_back(n);
                                    ebody.push_back(1); //�ȗ����ꂽ��1�t���[��
                                }
                                else if (getc(c))
                                {
                                    if (c == 'f' || c == 'F')
                                    {
                                        if (getMultiDigit(n) && n >= 0)
                                        {
                                            ebody[ebody.size() - 1] = n;
                                        }
                                    }
                                    else if (c == '|')
                                    {
                                        ehead.push_back(ebody.size() / 2 + 1);  //�w�b�_���g���܂߂��+1

                                        if (ehead.size() > 2)
                                        {
                                            std::cerr << "Line " << linenum << " : [Envelope difinition] Too many '|'." << std::endl;
                                            exit(1);
                                        }
                                    }
                                    else if (c == '}')
                                    {

                                        if (ehead.size() == 0)
                                        {
                                            ehead.push_back(0x81);
                                            ehead.push_back(ebody.size() / 2 + 1);
                                            ebody.push_back(0); //�Ō��0��ǉ��ɂ��Ď��̃G���x���[�v�ɗ���Ȃ��悤�ɂ���
                                            ebody.push_back(0);
                                        }
                                        else if (ehead.size() == 1)
                                        {
                                            //�w�b�_1�������烊���[�X���ȗ����ꂽ�Ƃ݂Ȃ�
                                            ehead[0] |= 0x80;
                                            ehead.push_back(ebody.size() / 2 + 1);
                                            ebody.push_back(0); //�Ō��0��ǉ��ɂ��Ď��̃G���x���[�v�ɗ���Ȃ��悤�ɂ���
                                            ebody.push_back(0);
                                        }
                                        else
                                        {
                                            //���J�b�R��������ۑ����Ĕ�����
                                            ebody[ebody.size() - 1] = 0; //�Ō�̒l��0�ɂ��Ď��̃G���x���[�v�ɗ���Ȃ��悤�ɂ���
                                        }

                                        std::copy(ehead.begin(), ehead.end(), std::back_inserter(env.data));
                                        std::copy(ebody.begin(), ebody.end(), std::back_inserter(env.data));
                                        env.num = envnum;
                                        env.addr = totalpos + envsize;
                                        envsize += env.data.size();
                                        envdata[envnum] = env;
                                        break;
                                    }
                                    else
                                    {
                                        std::cerr << "Line " << linenum << " : [Envelope difinition] Invalid character." << std::endl;
                                        exit(1);
                                    }
                                }
                            }
                        }
                        else
                        {
                            std::cerr << "Line " << linenum << " : [Envelope difinition] Missing {." << std::endl;
                            exit(1);
                        }
                    }
                    else
                    {
                        std::cerr << "Line " << linenum << " : [Envelope difinition] No envelope number." << std::endl;
                        exit(1);
                    }
                }
            }
        }
        else if (c == '\n')
        {
            linenum++;
        }
        else if (c == 't' || c == 'T')
        {
            if (isNextStr("rack"))
            {
                isTrack = true;
            }
        }
        else if (c == 'm' || c == 'M')
        {
            if (isNextStr("usic"))
            {
                isMusic = true;
            }
        }
    }
}


void MMLReader::readBrackets(int startpos, int trheadsize, std::vector<unsigned char>& data)
{
    char c;
    int n;
    int volume = 15;
    int octave = 4;
    int fskip;
    int grace = 0;
    bool isTrack = false;
    bool isMusic = false;
    bool usePDelay = false;
    bool isLooped = false;
    int sweepStart = 0;
    int pddist = 4;
    int pdvol = 0;
    int pdlen = 0;
    int shorten = 0;
    int usingNoteMap = -1;
    std::map<Command, CommandArgs> usingCmds;
    std::vector<TrackData> tracks;
    TrackData tr;
    std::queue<unsigned char> prevnotes;

    ss.seekg(startpos);

    while (ss.get(c))
    {
        int nn = 0;        //�R�}���h�̒l
        int num = 0;        //�R�}���h�ɓn�����l��
        int tmp = 0;
        std::string digit;

        switch (c)
        {
        case ' ':
        case '\t':
        case '\r':
            break;
        case '\n':
            linenum++;
            break;
        case '/':
            getc(c);
            if (c == '/')      //1�s�R�����g
            {
                skipUntil("\n");   //�s���܂Ŕ�΂�
                linenum++;
            }
            else if (c == '*')          //�����s�R�����g�̎n�܂�
            {
                skipUntil("*/");   //�R�����g�̏I���܂Ŕ�΂�
            }
            break;
        case 'A':
        case 'B':
        case 'C':
        case 'D':
        case 'E':
        case 'F':
        case 'G':
            tmp = 0x20;
        case 'a':
        case 'b':
        case 'c':
        case 'd':
        case 'e':
        case 'f':
        case 'g':
            nn = notetbl[c - tmp - 0x61] + octave * 12;
            skipSpace();
            while (getc(c))          //����
            {
                if (c == '+')
                {
                    nn += 1;
                }
                else if (c == '-')
                {
                    nn -= 1;
                }
                else
                {
                    ss.seekg((int)ss.tellg() - 1);    //�ǂݍ��݈ʒu��߂�
                    break;
                }
                skipSpace();
            }
            //�m�[�g�}�b�v�̏����B�m�[�g�}�b�v�L���Œ�`�ƕϊ��悪���݂���Ύ��s
            if (usingNoteMap >= 0 && mapdiflist.count(usingNoteMap) && mapdiflist[usingNoteMap].maplist.count(nn))
            {
                int newNN = nn;
                NoteMap map = mapdiflist[usingNoteMap].maplist[nn];

                for (const auto& [cmd, args] : map.commands)
                {
                    if (!isLooped && usingCmds.count(cmd) > 0 && usingCmds[cmd] == args)    //�R�}���h�����Ɏw�肳��Ă���ꍇ�������Ȃ��i���[�v����ȊO�j
                    {
                        continue;
                    }

                    if (cmd == VOLUME_ENV || cmd == FREQ_ENV || cmd == NOTE_ENV || cmd == TONE_ENV)
                    {
                        int offset = 0;

                        switch (cmd)
                        {
                        case VOLUME_ENV:
                            offset = v_offset; break;
                        case FREQ_ENV:
                            offset = f_offset; break;
                        case NOTE_ENV:
                            offset = n_offset; break;
                        case TONE_ENV:
                            offset = t_offset; break;
                        }

                        if (args.size() >= 2)
                        {
                            pushEnvAssign(data, envdata, cmd, args[0], args[1], true, offset);
                        }
                        else if (args.size() == 1)
                        {
                            pushEnvAssign(data, envdata, cmd, args[0], 0, true, offset);
                        }
                        else
                        {
                            std::cerr << "Line " << linenum << " : [Map difinition] Missing args." << std::endl;
                            exit(1);
                        }

                        usingCmds[cmd] = args;
                        if (usingCmds.count(cmd + 1))
                        {
                            usingCmds.erase(cmd + 1);   //��~�R�}���h�������������
                        }
                    }
                    else if (cmd == SW_SWEEP)
                    {
                        data.push_back(cmd);

                        for (int i = 0; i < args.size(); i++)
                        {
                            if (i == 0)
                            {
                                sweepStart = i;
                            }
                            else if (i == 1)
                            {
                                data.push_back(args[i] - sweepStart);
                            }
                            else
                            {
                                data.push_back(args[i]);
                            }
                        }

                        usingCmds[cmd] = args;
                        if (usingCmds.count(cmd + 1))
                        {
                            usingCmds.erase(cmd + 1);   //��~�R�}���h�������������
                        }
                    }
                    else if (cmd == PLAY_DATA)      //������s����̂Ŏg�p���R�}���h�ɂ͒ǉ����Ȃ�
                    {
                        bool hasmusic = false;
                        for (int i = 0; i < musiclist.size(); i++)
                        {
                            if (musiclist[i] == args[0])
                            {
                                data.push_back(PLAY_DATA);
                                data.push_back(musiclist[i]);
                                hasmusic = true;
                            }
                        }

                        if (!hasmusic)
                        {
                            std::cerr << "Line " << linenum << " : Music #" << args[0] << " is not registered." << std::endl;
                            exit(1);
                        }
                    }
                    else if (cmd == VOLUME_ENV_STOP || cmd == FREQ_ENV_STOP || cmd == NOTE_ENV_STOP || cmd == TONE_ENV_STOP || cmd == SW_SWEEP_STOP)
                    {
                        data.push_back(cmd);

                        for (int i = 0; i < args.size(); i++)
                        {
                            data.push_back(args[i]);
                        }

                        usingCmds[cmd] = args;

                        if (usingCmds.count(cmd - 1))
                        {
                            usingCmds.erase(cmd - 1);   //�J�n�R�}���h�������������
                        }
                    }
                    else if (cmd == TONE)
                    {
                        data.push_back(TONE);

                        if (tr.device == 4)     //DPCM�g���b�N�Ȃ�
                        {
                            if (dpcmlist.count(args[0]))
                            {
                                data.push_back(dpcmlist[args[0]].offset / 0x40);
                                data.push_back(dpcmlist[args[0]].size / 0x10);
                            }
                            else
                            {
                                std::cerr << "Line " << linenum << " : [Map difinition] DPCM #" << args[0] << " is not registered." << std::endl;
                                exit(1);
                            }
                        }
                        else
                        {
                            data.push_back(n);
                        }
                        usingCmds[cmd] = args;
                    }
                    else if (cmd > 0x6b && cmd != REST_DEFLEN)  //�m�[�g�Ƌx���ȊO
                    {
                        data.push_back(cmd);

                        for (int i = 0; i < args.size(); i++)
                        {
                            data.push_back(args[i]);
                        }
                        usingCmds[cmd] = args;
                    }
                }

                isLooped = false;

                if (map.convert >= 0)
                {
                    //�m�[�g�̕ϊ��悪���݂����ꍇ�ϊ�����
                    newNN = map.convert;
                }
                
                if (map.commands.count(REST_DEFLEN))   //�x���R�}���h�������Ă����ꍇ
                {
                    skipSpace();
                    calcLength(REST_DEFLEN, data, lengthtbl, grace, 0);
                }
                else
                {
                    if (tr.device == 3 || tr.device == 4)
                    {
                        //newNN = 0x0f - newNN & 0x0f;  //�h���C�o���ł��
                    }
                    else
                    {
                        newNN += sweepStart;
                    }

                    skipSpace();
                    calcLength(newNN, data, lengthtbl, grace, 0);
                }
            }
            else
            {
                if (tr.device == 3 || tr.device == 4)
                {
                    //nn = 0x0f - nn & 0x0f;    //�h���C�o���ł��
                }
                else
                {
                    nn += sweepStart;
                }

                //���܂�傫���Ȃ�߂��Ȃ��悤�ɂ���
                while (prevnotes.size() > 20)
                {
                    prevnotes.pop();
                }

                skipSpace();
                if (usePDelay)
                {
                    while (prevnotes.size() > pddist)
                    {
                        prevnotes.pop();
                    }

                    calcLength(nn, data, lengthtbl, grace, pdlen);

                    if (pdvol < 0)
                    {
                        data.push_back(TAI_SLUR);
                    }
                    else
                    {
                        data.push_back(VOLUME_ABS);
                        data.push_back(pdvol);
                    }

                    if (prevnotes.size() > 0)
                    {
                        if (pdlen == deflen)
                        {
                            data.push_back(prevnotes.front());
                        }
                        else
                        {
                            data.push_back(prevnotes.front() + 0x80);
                            data.push_back(timebase / pdlen);
                        }
                    }
                    else
                    {
                        if (pdlen == deflen)
                        {
                            data.push_back(nn);
                        }
                        else
                        {
                            data.push_back(nn + 0x80);
                            data.push_back(timebase / pdlen);
                        }
                    }

                    if (pdvol > 0)
                    {
                        //�{�����[����߂�
                        data.push_back(VOLUME_ABS);
                        data.push_back(volume);
                    }
                }
                else
                {
                    calcLength(nn, data, lengthtbl, grace, 0);
                }
                prevnotes.push(nn);
            }
            break;
        case 'r':   //�x��
        case 'R':
            skipSpace();
            if (isNextChar('-'))
            {
                data.push_back(ENV_DISABLE);            //�G���x���[�v����
            }

            skipSpace();
            if (usePDelay)
            {
                while (prevnotes.size() > pddist)
                {
                    prevnotes.pop();
                }

                calcLength(REST_DEFLEN, data, lengthtbl, grace, pdlen);

                if (pdvol > 0)
                {
                    data.push_back(VOLUME_ABS);
                    data.push_back(pdvol);
                }

                if (prevnotes.size() > 0)
                {
                    if (pdlen == deflen)
                    {
                        data.push_back(prevnotes.front());
                    }
                    else
                    {
                        data.push_back(prevnotes.front() + 0x80);
                        data.push_back(timebase / pdlen);
                    }
                }
                else
                {
                    if (pdlen == deflen)
                    {
                        data.push_back(REST_DEFLEN);
                    }
                    else
                    {
                        data.push_back(REST_LENGTH);
                        data.push_back(timebase / pdlen);
                    }
                }

                if (pdvol > 0)
                {
                    //�{�����[����߂�
                    data.push_back(VOLUME_ABS);
                    data.push_back(volume);
                }
            }
            else
            {
                calcLength(REST_DEFLEN, data, lengthtbl, grace, 0);
            }
            prevnotes.push(REST_DEFLEN);
            break;
        case '[':   //���[�v�J�n
            skipSpace();
            if (getMultiDigit(n))
            {
                data.push_back(LOOP_START);
                data.push_back(n);
                isLooped = true;
            }
            break;
        case ']':   //���[�v�I��
            data.push_back(LOOP_END);
            isLooped = true;
            break;
        case ':':   //���[�v�r���I��
            data.push_back(LOOP_MID_END);
            isLooped = true;
            break;
        case 'q':   //�Q�[�g�^�C��q
            skipSpace();
            if (getMultiDigit(n))
            {
                data.push_back(GATE_TIME_Q);
                data.push_back(n);
            }
            break;
        case 'u':   //�Q�[�g�^�C��u
            skipSpace();
            if (getMultiDigit(n))
            {
                data.push_back(GATE_TIME_U);
                data.push_back(n);
            }
            break;
        case 'Q':   //�Q�[�g�^�C��Q
            skipSpace();
            if (getMultiDigit(n))
            {
                data.push_back(GATE_TIME_BIGQ);
                data.push_back(n);
            }
            break;
        case 'k':   //���΃L�[�V�t�g
            skipSpace();
            if (getMultiDigit(n))
            {
                data.push_back(KEYSHIFT_REL);
                data.push_back(n);
            }
            break;
        case 'K':   //��΃L�[�V�t�g
            skipSpace();
            if (getMultiDigit(n))
            {
                data.push_back(KEYSHIFT_ABS);
                data.push_back(n);
            }
            break;
        case '&':   //�X���[
            data.push_back(TAI_SLUR);
            break;
        case '@':   //���F�w�肩�e���`
            skipSpace();
            if (getMultiDigit(n))   //���l�Ȃ特�F�w��
            {
                data.push_back(TONE);

                if (tr.device == 4)     //DPCM�g���b�N�Ȃ�
                {
                    if (dpcmlist.count(n))
                    {
                        data.push_back(dpcmlist[n].offset / 0x40);
                        data.push_back(dpcmlist[n].size / 0x10);
                    }
                    else
                    {
                        std::cerr << "Line " << linenum << " : DPCM #" << n << " is not registered." << std::endl;
                        exit(1);
                    }
                }
                else
                {
                    data.push_back(n);
                }
            }
            else if (getc(c))
            {
                if (c == 'p' || c == 'P')       //�w�肵���Ȕԍ��̃f�[�^���Đ�
                {
                    skipSpace();
                    if (getMultiDigit(n))
                    {
                        bool hasmusic = false;
                        for (int i = 0; i < musiclist.size(); i++)
                        {
                            if (musiclist[i] == n)
                            {
                                data.push_back(PLAY_DATA);
                                data.push_back(musiclist[i]);
                                hasmusic = true;
                            }
                        }

                        if (!hasmusic)
                        {
                            std::cerr << "Line " << linenum << " : Music #" << n << " is not registered." << std::endl;
                            exit(1);
                        }
                    }
                }
                if (c == 'm' || c == 'M')       //�m�[�g�}�b�v��`
                {
                    if (isTrack || trheadsize == 0) //�Ȓ����T�u���[�`�����ɂ�������w��
                    {
                        skipSpace();
                        if (getMultiDigit(n))
                        {
                            if (mapdiflist.count(n) > 0)
                            {
                                usingNoteMap = n;
                            }
                            else
                            {
                                std::cerr << "Line " << linenum << " : Map diffinition #" << n << " is not registered." << std::endl;
                                exit(1);
                            }
                        }
                        else if (isNextChar('*'))
                        {
                            usingNoteMap = -1;
                        }
                    }
                    else
                    {
                        //����ȊO�͒�`�H
                        std::cerr << "Line " << linenum << " : Invalid map diffinition." << std::endl;
                        exit(1);
                    }
                }
                else if (c == 'd' || c == 'D')   //�f�`���[��
                {
                    skipSpace();
                    if (getMultiDigit(n))
                    {
                        data.push_back(DETUNE);
                        data.push_back(-n);
                    }
                    else
                    {
                        if (isNextChar('-'))
                        {
                            if (getMultiDigit(n))
                            {
                                data.push_back(DETUNE);
                                data.push_back(n);
                            }
                        }
                    }
                }
                else if (c == 'v' || c == 'V')   //���ʃG���x���[�v
                {
                    skipSpace();
                    getAndPushEnvAssign(data, envdata, VOLUME_ENV, v_offset);
                    break;
                }
                else if (c == 'f' || c == 'F')   //�����G���x���[�v
                {
                    skipSpace();
                    getAndPushEnvAssign(data, envdata, FREQ_ENV, f_offset);
                    break;
                }
                else if (c == 'n' || c == 'N')   //�m�[�g�G���x���[�v
                {
                    skipSpace();
                    getAndPushEnvAssign(data, envdata, NOTE_ENV, n_offset);
                    break;
                }
                else if (c == 't' || c == 'T')   //���F�G���x���[�v
                {
                    skipSpace();
                    getAndPushEnvAssign(data, envdata, TONE_ENV, t_offset);
                    break;
                }
                else
                {
                    ss.seekg((int)ss.tellg() - 1);    //�ǂݍ��݈ʒu��߂�
                }
            }
            break;
        case 'l':   //�f�t�H���g����
            skipSpace();
            if (getMultiDigit(n))
            {
                deflen = n;
                for (int i = 0; i < sizeof(nthnotetbl); i++)
                {
                    if (deflen == nthnotetbl[i])
                    {
                        data.push_back(DEF_LENGTH);
                        data.push_back(lengthtbl[i]);
                        break;
                    }
                }
            }
            else if (isNextChar('%'))
            {
                skipSpace();
                if (getMultiDigit(n))
                {
                    deflen = n;
                    data.push_back(DEF_LENGTH);
                    data.push_back(n);
                }
            }
            break;
        case 'L':   //�������[�v
            data.push_back(INF_LOOP);
            break;
        case 'o':   //�I�N�^�[�u
        case 'O':
            skipSpace();
            if (getMultiDigit(n))
            {
                if (n > 8)
                {
                    n = 8;
                }
                octave = n;
            }
            break;
        case '>':   //�I�N�^�[�u�グ
            octave += (octaveReverse) ? -1 : 1;
            break;
        case '<':   //�I�N�^�[�u����
            octave += (octaveReverse) ? 1 : -1;
            break;
        case 'v':   //�g���b�N�{�����[���w��
        case 'V':
            skipSpace();
            getc(c);
            if (c == '+')           //���Ύw��+
            {
                skipSpace();
                if (getMultiDigit(n))
                {
                    if (n > 15)
                    {
                        n = 15;
                    }
                    data.push_back(VOLUME_REL);
                    data.push_back(n);
                    volume += n;
                }
            }
            else if (c == '-')           //���Ύw��-
            {
                skipSpace();
                if (getMultiDigit(n))
                {
                    if (n > 15)
                    {
                        n = 15;
                    }
                    data.push_back(VOLUME_REL);
                    data.push_back(-n);
                    volume -= n;
                }
            }
            else if (isDigit(c))
            {
                ss.seekg((int)ss.tellg() - 1);    //�ǂݍ��݈ʒu��߂�

                if (getMultiDigit(n))    //��Ύw��
                {
                    if (n > 15)
                    {
                        n = 15;
                    }
                    data.push_back(VOLUME_ABS);
                    data.push_back(n);
                    volume = n;
                }
            }
            break;
        case 't':   //�g���b�N�J�n���e���|
        case 'T':
            if (isNextStr("rack"))   //�g���b�N�J�n
            {
                //�T�u���[�`����
                if (trheadsize == 0)
                {
                    skipSpace();
                    if (getMultiDigit(n))
                    {
                        tr.track = n;
                    }

                    skipSpace();
                    if (isNextChar(','))
                    {
                        skipSpace();
                        if (getMultiDigit(n))
                        {
                            tr.device = n;
                        }
                    }
                }
                else
                {
                    if (!isTrack)
                    {
                        isTrack = true;
                    }
                    else
                    {
                        usingCmds.clear();  //�}�b�v�֌W�̕ϐ��������Ń��Z�b�g����
                        usingNoteMap = -1;

                        usePDelay = false;  //�^���f�B���C�����Z�b�g

                        data.push_back(TRACK_END);    //�I���R�[�h
                        tr.data = data;
                        tracks.push_back(tr);
                        data.clear();
                    }

                    skipSpace();
                    if (getMultiDigit(n))
                    {
                        tr.track = n;
                    }
                    else
                    {
                        std::cerr << "Line " << linenum << " : No track number." << std::endl;
                        exit(1);
                    }

                    skipSpace();
                    if (isNextChar(','))
                    {
                        skipSpace();
                        if (getMultiDigit(n))
                        {
                            tr.device = n;
                        }
                        else
                        {
                            std::cerr << "Line " << linenum << " : No device number." << std::endl;
                        }
                    }
                    else
                    {
                        std::cerr << "Line " << linenum << " : No device number." << std::endl;
                        exit(1);
                    }
                }
            }
            else if (getMultiDigit(n))    //�e���|
            {
                if (!isTrack)
                {
                    std::cerr << "Line " << linenum << " : Prease write the tempo in the track." << std::endl;
                    exit(1);
                }
                int tempo = 14400 / timebase;
                fskip = 256 - 256 * n / tempo;

                if (fskip > 255)
                {
                    fskip = 255;
                }
                else if (fskip < 0)
                {
                    std::cerr << "Line " << linenum << " : Max tempo is " << tempo << std::endl;
                    std::cerr << "Please reduce timebase." << std::endl;
                    exit(1);
                }
                data.push_back(TEMPO);
                data.push_back(fskip);
            }
            break;
        case 's':   //�\�t�g�E�F�A�X�C�[�v
        case 'S':   //�\�t�g�E�F�A�X�C�[�v
        {
                int start, end, delay, speed;
                bool res = false;
                skipSpace();
                getc(c);
                if (c == '*')   //����
                {
                    data.push_back(SW_SWEEP_STOP);
                    sweepStart = 0;
                }
                else if (isDigit(c) || c == '-')
                {
                    ss.seekg((int)ss.tellg() - 1);

                    if (getMultiDigit(start))
                    {
                        skipSpace();
                        getc(c);
                        if (c == ',' && getMultiDigit(end))
                        {
                            skipSpace();
                            getc(c);
                            if (c == ',' && getMultiDigit(delay))
                            {
                                skipSpace();
                                getc(c);
                                if (c == ',' && getMultiDigit(speed))
                                {
                                    data.push_back(SW_SWEEP);
                                    data.push_back(end - start);
                                    data.push_back(delay);
                                    data.push_back(speed);
                                    sweepStart = start;
                                    res = true;
                                }
                            }
                        }
                    }
                    if (!res)
                    {
                        std::cerr << "Line " << linenum << " : Missing softwear sweep arguments." << std::endl;
                        exit(1);
                    }
                }
            }
            break;
        case 'p':   //�^���f�B���C
        case 'P':
            if (isNextChar('d'))
            {
                bool res = false;
                skipSpace();
                if (isNextChar('*'))
                {
                    usePDelay = false;
                    res = true;
                }
                else if (getMultiDigit(n))
                {
                    pddist = n;
                    skipSpace();
                    if (isNextChar(','))
                    {
                        skipSpace();
                        if (getMultiDigit(n))
                        {
                            pdvol = n;
                            skipSpace();
                            if (isNextChar(','))
                            {
                                skipSpace();
                                if (getMultiDigit(n))
                                {
                                    pdlen = n;
                                    usePDelay = true;
                                    res = true;
                                }
                            }
                        }
                    }
                }

                if (!res)
                {
                    std::cerr << "Line " << linenum << " : Missing psuedo delay arguments." << std::endl;
                    exit(1);
                }
            }
            break;
        case 'h':   //�n�[�h�E�F�A����
        case 'H':
            getc(c);
            if (c == 's' || c == 'S')   //�n�[�h�E�F�A�X�C�[�v
            {
                int rate, dir, amount;
                bool res = false;
                skipSpace();
                if (isNextChar('*'))
                {
                    data.push_back(HW_SWEEP);
                    data.push_back(0x08);
                    res = true;
                }
                else if (getMultiDigit(n))
                {
                    rate = n;
                    skipSpace();
                    if (isNextChar(','))
                    {
                        skipSpace();
                        if (getMultiDigit(n))
                        {
                            skipSpace();
                            if (isNextChar(','))
                            {
                                dir = n;
                                skipSpace();
                                if (getMultiDigit(n))
                                {
                                    amount = n;
                                    unsigned char v = 0x80 + (unsigned char)(rate & 0x07 << 4) + (unsigned char)(dir & 0x01 << 3) + ((unsigned char)amount & 0x07);
                                    data.push_back(HW_SWEEP);
                                    data.push_back(v);
                                    res = true;
                                }
                            }
                        }
                    }
                }

                if (!res)
                {
                    std::cerr << "Line " << linenum << " : Missing hardwear sweep arguments." << std::endl;
                    exit(1);
                }
            }
            else if (c == 'e' || c == 'E')  //�n�[�h�E�F�A�G���x���[�v
            {
                int rate, loop;
                bool res = false;
                skipSpace();
                if (isNextChar('*'))
                {
                    data.push_back(HW_ENV);
                    data.push_back(0x10);
                    res = true;
                }
                else if (getMultiDigit(n))
                {
                    loop = n;
                    skipSpace();
                    if (isNextChar(','))
                    {
                        skipSpace();
                        if (getMultiDigit(n))
                        {
                            rate = n;
                            unsigned char v = (unsigned char)(loop & 0x01 << 5) + (unsigned char)(rate & 0x0f);
                            data.push_back(HW_ENV);
                            data.push_back(v);
                            res = true;
                        }
                    }
                }
                
                if (!res)
                {
                    std::cerr << "Line " << linenum << " : Missing hardwear envelope arguments." << std::endl;
                    exit(1);
                }
            }
            break;
        case '\\':   //�T�u���[�`��
            skipSpace();
            if (getMultiDigit(n))
            {
                if (subdata.count(n))
                {
                    data.push_back(SUBROUTINE);
                    data.push_back(subdata[n].addr & 0x00ff);
                    data.push_back((subdata[n].addr & 0xff00) >> 8);
                    isLooped = true;
                }
            }
            break;
        case '}':   //�I��
            if (trheadsize > 0)
            {
                if (isTrack)
                {
                    isTrack = false;
                    data.push_back(TRACK_END);    //�I���R�[�h
                    tr.data = data;
                    tracks.push_back(tr);
                    data.clear();
                }

                std::sort(tracks.begin(), tracks.end());

                //�Ȃ��I�������̂Ńw�b�_�쐬
                //�g���b�N����1�g���b�N�̃A�h���X��1�g���b�N�̃g���b�N�ԍ���1�g���b�N�̉����ԍ���2�g���b�N�̃A�h���X��2�g���b�N�̃g���b�N�ԍ��c
                //�f�t�H�����̏�
                int pos = totalpos + trheadsize;
                std::vector<unsigned char> trhead;

                for (int i = 0; i < tracks.size(); i++)
                {
                    trhead.push_back(tracks[i].track);          //�g���b�N�ԍ�
                    trhead.push_back(tracks[i].device);         //�g���b�N�̉����ԍ�
                    trhead.push_back(pos & 0x00ff);        //�g���b�N�J�n�A�h���X�̉��ʃo�C�g
                    trhead.push_back((pos & 0xff00) >> 8); //�g���b�N�J�n�A�h���X�̏�ʃo�C�g
                    pos += tracks[i].data.size();
                }

                trhead.push_back(0xff);             //�g���b�N�w�b�_�I�[
                trhead.push_back(lengthtbl[3]);     //�f�t�H���g�̃f�t�H���g�����i4�������j

                //�S���������ł�����߂�l�ɃR�s�[���Ĕ�����
                std::copy(trhead.begin(), trhead.end(), std::back_inserter(data));

                for (int i = 0; i < tracks.size(); i++)
                {
                    std::copy(tracks[i].data.begin(), tracks[i].data.end(), std::back_inserter(data));
                }
            }
            return; //1�Ȃ��ǂނ̂ł�����return����
        default:
            std::cerr << "Line " << linenum << " : Unknown command '" << c << "'" << std::endl;
            exit(1);
            break;
        }
    }

    //���J�b�R������Ȃ�
    std::cerr << "Missing }." << std::endl;
    exit(1);
}


bool MMLReader::skipUntil(std::string input)
{
    char c;

    while (ss.get(c))
    {
        for (int i = 0; i < (int)input.size(); i++)
        {
            if (c == input[i])
            {
                if (i == (int)input.size() - 1)     //�S����v����
                {
                    return true;
                }
                else
                {
                    if (!ss.get(c))                //�r���ŏI�[�ɒB����
                    {
                        return false;
                    }
                }
            }
            else
            {
                break;
            }
        }
        
        if (c == '\n')
        {
            linenum++;
        }
    }
    return false;   //��v�����I�[�ɒB����
}


bool MMLReader::isDigit(char c)
{
    return c >= '0' && c <= '9';
}


bool MMLReader::isHex(char c)
{
    return c >= '0' && c <= '9' || c >= 'A' && c <= 'F' || c >= 'a' && c <= 'f';
}


bool MMLReader::skipSpace()
{
    char c;

    while (ss.get(c))
    {
        if (c == '\n')
        {
            linenum++;
        }
        else if (c != ' ' && c != '�@' && c != '\t' && c != '\r')
        {
            ss.seekg((int)ss.tellg() - 1);
            return true;
        }
    }
    return false;   //��v�����I�[�ɒB����
}


bool MMLReader::skipComment()
{
    char c;

    while (ss.get(c))
    {
        if (c == '/')
        {
            getc(c);
            if (c == '/')
            {
                skipUntil("\n");
                ss.seekg((int)ss.tellg() - 1);
                return true;
            }
            else if (c == '*')
            {
                skipUntil("*/");
                return true;
            }
        }
        else
        {
            ss.seekg((int)ss.tellg() - 1);
            return true;
        }

        if (c == '\n')
        {
            linenum++;
        }
    }
    return false;
}


bool MMLReader::skipSpaceUntilNextLine()
{
    char c;

    while (ss.get(c))
    {
        if (c == '\n')
        {
            ss.seekg((int)ss.tellg() - 1);
            return true;
        }
        else if (c != ' ' && c != '�@' && c != '\t' && c != '\r')
        {
            ss.seekg((int)ss.tellg() - 1);
            return true;
        }
    }
    return false;   //��v�����I�[�ɒB����
}


bool MMLReader::findStr(std::string str, std::string exclude)
{
    char c;
    int pos = 0;
    int posex = 0;

    while (ss.get(c))
    {
        if (c == '\n')
        {
            linenum++;
        }

        if (tolower(c) == tolower(exclude[posex]))
        {
            if (posex >= exclude.size() - 1)
            {
                return false;
            }
            posex++;
        }
        else
        {
            posex = 0;
        }

        if (tolower(c) == tolower(str[pos]))
        {
            if (pos >= str.size() - 1)
            {
                return true;
            }
            pos++;
        }
        else
        {
            pos = 0;
        }

        skipSpace();
        skipComment();
        skipSpace();
    }
    return false;
}


bool MMLReader::findStr(std::string str)
{
    char c;
    int pos = 0;
    while (ss.get(c))
    {
        if (c == '\n')
        {
            linenum++;
        }

        if (tolower(c) == tolower(str[pos]))
        {
            if (pos >= str.size() - 1)
            {
                return true;
            }
            pos++;
        }
        else
        {
            if (c == '\n')
            {
                linenum++;
            }
            pos = 0;
        }

        skipSpace();
        skipComment();
        skipSpace();
    }
    return false;
}

//���ɗ��镶�����w�肵�������Ɠ������ǂ������肷��
bool MMLReader::isNextChar(char input)
{
    char c;
    getc(c);
    if (tolower(c) == tolower(input))
    {
        return true;
    }
    else
    {
        ss.seekg((int)ss.tellg() - 1);
        return false;
    }
}

//���ɗ��镶���񂪎w�肵��������Ɠ������ǂ������肷��
bool MMLReader::isNextStr(std::string str)
{
    char c;
    int pos = 0;
    while (ss.get(c))
    {
        if (tolower(c) == tolower(str[pos]))
        {
            if (pos >= str.size() - 1)
            {
                return true;
            }
            pos++;
        }
        else
        {
            ss.seekg((int)ss.tellg() - pos - 1);    //�ǂݍ��݈ʒu��߂�
            return false;
        }
    }
    return false;
}

//�X�g���[�����I��������exit����֐�
bool MMLReader::getc(char& c)
{
    if (ss.get(c))
    {
        return true;
    }
    return false;
}


void MMLReader::syntaxErr()
{
    std::cerr << "Line " << linenum << " : Syntax error." << std::endl;
    exit(1);
}


bool MMLReader::getMultiHex(int& res)
{
    char c;
    bool sign = true;
    std::string d;

    skipSpace();

    while (getc(c))
    {
        if (isHex(c))
        {
            d += c;
        }
        else if (c == '-')
        {
            if (d.empty())
            {
                d += c;
            }
            else
            {
                break;
            }
        }
        else
        {
            ss.seekg((int)ss.tellg() - 1);    //�ǂݍ��݈ʒu��߂�
            break;
        }
    }

    if (!d.empty())
    {
        res = std::stoi(d, nullptr, 16);
        return true;
    }
    else
    {
        return false;
    }
}


bool MMLReader::getMultiDigit(int& res)
{
    char c;
    bool sign = true;
    std::string d;

    skipSpace();

    while (getc(c))
    {
        if (isDigit(c))
        {
            d += c;
        }
        else if (c == '-')
        {
            if (d.empty())
            {
                d += c;
            }
            else
            {
                break;
            }
        }
        else
        {
            ss.seekg((int)ss.tellg() - 1);    //�ǂݍ��݈ʒu��߂�
            break;
        }
    }

    if (!d.empty())
    {
        res = std::stoi(d);
        return true;
    }
    else
    {
        return false;
    }
}

bool MMLReader::getStrInQuote(std::string& str)
{
    char c;
    bool isquote = false;
    skipSpace();
    while (getc(c))
    {
        if (!isquote && c == '"')
        {
            isquote = true;
        }
        else if (isquote && c == '"')
        {
            return true;
        }
        else if (isquote && c == '\n')
        {
            linenum++;
            return true;
        }
        else if (isquote)
        {
            str += c;
        }
    }
    return false;
}

bool MMLReader::getByte(int& res)
{
    char c;
    std::string d;

    for (int i = 0; i < 2; i++)
    {
        getc(c);

        if (isHex(c))
        {
            d += c;
        }
        else
        {
            ss.seekg((int)ss.tellg() - 1);
            break;
        }
    }

    if (!d.empty())
    {
        res = std::stoi(d, nullptr, 16);
        return true;
    }
    else
    {
        return false;
    }
}


void MMLReader::calcLength(char cmd, std::vector<unsigned char>& data, std::vector<unsigned char> lengthtbl, int& prevGrace, int shorten)
{
    char c;
    int n = 0;
    int frames = 0;
    int dottedlen = 0;
    bool dotted = false;
    bool envdis = false;
    bool framelen = false;
    bool grace = false;
    std::string digit;

    while (getc(c))
    {
        if (c == '^' || (cmd == 0x6c && c == 'r'))      //�^�C�A�������͋x�����A���ŗ����Ƃ�
        {
            if (dotted)
            {
                frames += n;
            }
            else if (digit.empty())    //�O�ɐ��l���Ȃ��ꍇ�f�t�H����
            {
                frames += n;
                frames += timebase / deflen;
            }
            else
            {
                frames += n;
                frames += timebase / std::atoi(digit.c_str());
            }
            dottedlen = 0;
            dotted = false;
            digit.clear();
            n = 0;
        }
        else if (c == '.')   //�t�_
        {
            if (dotted)        //���d�t�_
            {
                dottedlen /= 2;
                n += dottedlen;
            }
            else if (digit.empty())    //�O�ɐ��l���Ȃ��ꍇ�f�t�H����
            {
                n = timebase / deflen;
                dottedlen = n / 2;
                n += dottedlen;
            }
            else
            {
                n = timebase / std::atoi(digit.c_str());
                dottedlen = n / 2;
                n += dottedlen;
            }
            dotted = true;
            digit.clear();
        }
        else if (cmd == 0x6c && c == '-' && digit.empty())   //�G���x���[�v�����i�x���̂݁j
        {
            envdis = true;
        }
        else if (c == '%' && digit.empty())   //�t���[������
        {
            framelen = true;
        }
        else if (c == '~' && digit.empty())  //������
        {
            framelen = true;
            grace = true;
        }
        else if (isDigit(c))
        {
            if (c == '0')
            {
                std::cerr << "Line " << linenum << " : Note length is 0." << std::endl;
                exit(1);
            }
            digit += c;
        }
        else
        {
            if (!digit.empty())
            {
                if (framelen)
                {
                    frames = std::atoi(digit.c_str());
                }
                else
                {
                    n += timebase / std::atoi(digit.c_str());
                }
            }
            frames += n;
            ss.seekg((int)ss.tellg() - 1);    //�ǂݍ��݈ʒu��߂�
            break;
        }

        skipSpace();
        skipComment();
        skipSpace();
    }

    if (envdis)            //�G���x���[�v����
    {
        data.push_back(0xf8);
    }

    if (prevGrace > 0)     //�O�̉�����������
    {
        if (!grace)  //���̉������������Ȃ牽�����Ȃ�
        {
            if (frames == 0)
            {
                //�f�t�H�����������t���m�[�g�ɒ���
                frames = timebase / deflen;
            }

            frames -= prevGrace;
            prevGrace = 0;

            if (frames == timebase / deflen)
            {
                //�f�t�H�����Ɠ����ɂȂ�����f�t�H�����ɒ���
                frames = 0;
            }
        }

        if (frames < 0)
        {
            std::cerr << "Line " << linenum << " : Note length has become less than 0." << std::endl;
            exit(1);
        }
    }

    if (shorten > 0)
    {
        if (frames == 0)
        {
            //�f�t�H�����������t���m�[�g�ɒ���
            frames = timebase / deflen;
        }

        frames -= timebase / shorten;

        if (frames == timebase / deflen)
        {
            //�f�t�H�����Ɠ����ɂȂ�����f�t�H�����ɒ���
            frames = 0;
        }
    }

    if (frames > 0)
    {
        if (grace)
        {
            prevGrace += frames;     //���̉�����������l
        }
        //�����t���m�[�g
        while (true)
        {
            data.push_back(cmd + 0x80);
            if (frames > 0xff) // 1�o�C�g�������番��
            {
                data.push_back(0xff);
                data.push_back(TAI_SLUR);
                frames -= 0xff;
            }
            else
            {
                data.push_back(frames);
                break;
            }
        }
    }
    else
    {
        data.push_back(cmd);
    }
}


void MMLReader::pushEnvAssign(std::vector<unsigned char>& data, std::map<int, EnvData>& envdata, int envtype, int envnum, int delay, bool ismap, int offset)
{
    envnum += offset;

    if (envdata.count(envnum))
    {
        data.push_back(envtype);
        data.push_back(envdata[envnum].addr & 0x00ff);           //�G���x���[�v�A�h���X�̉��ʃo�C�g
        data.push_back((envdata[envnum].addr & 0xff00) >> 8);    //�G���x���[�v�A�h���X�̏�ʃo�C�g
        data.push_back(delay);                              //�f�B���C�l
    }
    else
    {
        if (ismap)
        {
            std::cerr << "Line " << linenum << " : [Map difinition] Invalid envelope number " << envnum << "." << std::endl;
        }
        else
        {
            std::cerr << "Line " << linenum << " : Invalid envelope number " << envnum << "." << std::endl;
        }
        exit(1);
    }
}


void MMLReader::getAndPushEnvAssign(std::vector<unsigned char>& data, std::map<int, EnvData>& envdata, int envtype, int offset)
{
    int n;
    char c;
    if (isNextChar('*'))
    {
        data.push_back(envtype + 1);     //��~�R�}���h
    }
    else
    {
        if (getMultiDigit(n))
        {
            int envn = n + offset;
            int delay = 0;
            skipSpace();
            if (isNextChar(','))
            {
                if (getMultiDigit(n))
                {
                    delay = n;
                }
            }

            pushEnvAssign(data, envdata, envtype, envn, delay, false, 0);
        }
    }
}


void MMLReader::getCmdArgs(CommandArgs& args)
{
    char c;
    int n;
    skipSpaceUntilNextLine();
    if (getMultiDigit(n))       //�R�}���h���e��ۑ�
    {
        args.push_back(n);

        skipSpaceUntilNextLine();
        if (isNextChar(','))
        {
            if (getMultiDigit(n))
            {
                args.push_back(n);
            }
        }
    }
}


bool MMLReader::getNoteNumber(int& nn)
{
    char c;
    int n;
    int tmp = 0;
    int pos = ss.tellg();

    getc(c);

    switch (c)
    {
    case 'A':
    case 'B':
    case 'C':
    case 'D':
    case 'E':
    case 'F':
    case 'G':
        tmp = 0x20;
    case 'a':
    case 'b':
    case 'c':
    case 'd':
    case 'e':
    case 'f':
    case 'g':
        nn = notetbl[c - tmp - 0x61];
        break;
    default:
        ss.seekg((int)pos);
        return false;
    }

    skipSpace();
    while (getc(c))          //����
    {
        if (c == '+')
        {
            nn += 1;
        }
        else if (c == '-')
        {
            nn -= 1;
        }
        else
        {
            ss.seekg((int)ss.tellg() - 1);    //�ǂݍ��݈ʒu��߂�
            break;
        }
        skipSpace();
    }

    if (getMultiDigit(n))
    {
        nn += n * 12;
    }
    else
    {
        ss.seekg((int)pos);
        return false;
    }
    return true;
}

//�������t���[���̕ϊ��e�[�u�����쐬����
void MMLReader::makeLengthTbl(std::vector<unsigned char> &lengthtbl)
{
    for (int i = 0; i < sizeof(nthnotetbl); i++)
    {
        unsigned char n = timebase / nthnotetbl[i];
        if (n == 0)
        {
            n = 1;
        }
        lengthtbl.push_back(n);
    }
}
