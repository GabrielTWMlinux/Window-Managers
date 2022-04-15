//Modify this file to change what commands output to your statusbar, and recompile using the make command.
static const Block blocks[] = {
	/*Icon*/	/*Command*/		/*Update Interval*/	/*Update Signal*/
	{"  ", "~/Scripts/Void-Updates",		3600,		10},

	{"  ", "~/Scripts/volumedwm",			1,		0},

	{"  ", "~/Scripts/ram-dwm",			5,		0},
	
	{"  ", "~/Scripts/cpu-dwm",			5,		0},

	{"  ", "date '+%d %b %Y, %a %H:%M '",		30,		0},
};

//sets delimeter between status commands. NULL character ('\0') means no delimeter.
static char delim[] = " | ";
static unsigned int delimLen = 5;
