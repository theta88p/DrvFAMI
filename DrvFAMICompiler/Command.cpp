/*
#include "Command.h"

bool operator==(const Command& t1, const Command& t2)
{
	if (t1.argssize != t2.argssize)
	{
		return false;
	}
	else
	{
		for (int i = 0; i < t1.argssize; i++)
		{
			if (t1.args[i] != t2.args[i])
			{
				return false;
			}
		}
		return true;
	}
}

bool operator!=(const Command& t1, const Command& t2)
{
	if (t1.argssize != t2.argssize)
	{
		return true;
	}
	else
	{
		for (int i = 0; i < t1.argssize; i++)
		{
			if (t1.args[i] != t2.args[i])
			{
				return true;
			}
		}
		return false;
	}
}
*/