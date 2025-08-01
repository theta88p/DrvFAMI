#pragma once
#include <vector>
#include <map>

using Command = int;
using CommandArgs = std::vector<int>;

struct NoteMap
{
	int target;
	int convert;
	std::map<Command, CommandArgs> commands;

	NoteMap()
	{
		target = 0;
		convert = -1;
	}

	NoteMap operator=(const NoteMap& nm)
	{
		this->target = nm.target;
		this->convert = nm.convert;
		this->commands = nm.commands;
		return nm;
	}
};

bool operator<(const NoteMap& t1, const NoteMap& t2);