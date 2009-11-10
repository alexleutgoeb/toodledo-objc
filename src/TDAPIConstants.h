//
//  TDApiConstants.h
//  ToodledoAPI
//
//  Created by Alex Leutgöb on 26.10.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

////////////////////////////////////////////////////////////////////////////////
// urls

// authentication url
#define kAuthenticationURLFormat @"http://api.toodledo.com/api.php?method=getToken;"

// get userid url
#define kUserIdURLFormat @"http://api.toodledo.com/api.php?method=getUserid;"

// get tasks url
#define kGetTasksURLFormat @"http://api.toodledo.com/api.php?method=getTasks;"

// get folders url
#define kGetFoldersURLFormat @"http://api.toodledo.com/api.php?method=getFolders;"

// add folder url
#define kAddFolderURLFormat @"http://api.toodledo.com/api.php?method=addFolder;"


// log macros

// DLog is almost a drop-in replacement for NSLog for debug mode
#ifdef DEBUG
#	define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#	define DLog(...)
#endif

// ALog always displays output regardless of the DEBUG setting
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
