#include "NoteMap.h"

bool operator<(const NoteMap& t1, const NoteMap& t2)
{
	return t1.target < t2.target;
}
