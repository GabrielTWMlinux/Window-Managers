//Modify this file to change what commands output to your statusbar, and recompile using the make command.
static const Block blocks[] = {
	/*Icon*/	/*Command*/			/*Update Interval*/	/*Update Signal*/
	{"  ", "~/.config/Scripts/Void-Updates",		3600,		10},

	{"  ", "~/.config/Scripts/weather",			3600,		0},

	{"  ", "~/.config/Scripts/volumedwm",			1,		0},

	{"  ", "~/.config/Scripts/ram-dwm",			5,		0},
	
	{"  ", "~/.config/Scripts/cpu-dwm",			5,		0},

	{"  ", "date '+%d %b %Y, %a %H:%M '",			30,		0},
};

//sets delimeter between status commands. NULL character ('\0') means no delimeter.
static char delim[] = " | ";
static unsigned int delimLen = 5;
