//
//  TDApiConstants.h
//  ToodledoAPI
//
//  Created by Alex Leutgöb on 26.10.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

////////////////////////////////////////////////////////////////////////////////
// urls

// toodledo basic url
#define tdBasicUrl @"http://api.toodledo.com/api.php?method=";

// authentication url
#define kAuthenticationURLFormat @"http://api.toodledo.com/api.php?method=getToken;"

// get account info url
#define kUserAccountInfoURLFormat @"http://api.toodledo.com/api.php?method=getAccountInfo;"

// server info url
#define kServerInfoURLFormat @"http://api.toodledo.com/api.php?method=getServerInfo;"

// get userid url
#define kUserIdURLFormat @"http://api.toodledo.com/api.php?method=getUserid;"

// get tasks url
#define kGetTasksURLFormat @"http://api.toodledo.com/api.php?method=getTasks;"

// add task url
#define kAddTaskURLFormat @"http://api.toodledo.com/api.php?method=addTask;"

// edit task url
#define kEditTaskURLFormat @"http://api.toodledo.com/api.php?method=editTask;"

// delete task url
#define kDeleteTaskURLFormat @"http://api.toodledo.com/api.php?method=deleteTask;"

// get folders url
#define kGetFoldersURLFormat @"http://api.toodledo.com/api.php?method=getFolders;"

// add folder url
#define kAddFolderURLFormat @"http://api.toodledo.com/api.php?method=addFolder;"

// delete folder url
#define kDeleteFolderURLFormat @"http://api.toodledo.com/api.php?method=deleteFolder;"

// add context url
#define kAddContextURLFormat @"http://api.toodledo.com/api.php?method=addContext;"

// get contexts url
#define kGetContextsURLFormat @"http://api.toodledo.com/api.php?method=getContexts;"

// delete context url
#define kDeleteContextURLFormat @"http://api.toodledo.com/api.php?method=deleteContext;"


// log macros

// DLog is almost a drop-in replacement for NSLog for debug mode
#ifdef DEBUG
#	define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#	define DLog(...)
#endif

// ALog always displays output regardless of the DEBUG setting
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
