#include "NoteMapDif.h"

bool operator<(const NoteMapDif& t1, const NoteMapDif& t2)
{
	return t1.number < t2.number;
}
