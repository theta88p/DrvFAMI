#pragma once
#include "NoteMap.h"

using NoteMapTgt = int;

struct NoteMapDif
{
	int number;
	std::map<NoteMapTgt, NoteMap> maplist;

	NoteMapDif()
	{
		int number = 0;
	}

	NoteMapDif operator=(const NoteMapDif& nmd)
	{
		this->number = nmd.number;
		this->maplist = nmd.maplist;
		return nmd;
	}
};

bool operator<(const NoteMapDif& t1, const NoteMapDif& t2);