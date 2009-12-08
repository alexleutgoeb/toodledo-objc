//
//  TDApiConstants.h
//  ToodledoAPI
//
//  Created by Alex Leutgöb on 26.10.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//



////////////////////////////////////////////////////////////////////////////////
// urls

// main protocol for urls
#define kBasicUrlProtocolFormat @"http://"

// pro user protocol for urls
#define kProUserUrlProtocolFormat @"https://"

// toodledo basic url
#define tdBasicUrl @"api.toodledo.com/api.php?method=";

// authentication url
#define kAuthenticationURLFormat @"api.toodledo.com/api.php?method=getToken;"

// get account info url
#define kUserAccountInfoURLFormat @"api.toodledo.com/api.php?method=getAccountInfo;"

// server info url
#define kServerInfoURLFormat @"api.toodledo.com/api.php?method=getServerInfo;"

// get userid url
#define kUserIdURLFormat @"api.toodledo.com/api.php?method=getUserid;"

// get tasks url
#define kGetTasksURLFormat @"api.toodledo.com/api.php?method=getTasks;"

// get tasks url
#define kGetDeletedTasksURLFormat @"api.toodledo.com/api.php?method=getDeleted;"

// add task url
#define kAddTaskURLFormat @"api.toodledo.com/api.php?method=addTask;"

// edit task url
#define kEditTaskURLFormat @"api.toodledo.com/api.php?method=editTask;"

// delete task url
#define kDeleteTaskURLFormat @"api.toodledo.com/api.php?method=deleteTask;"

// get folders url
#define kGetFoldersURLFormat @"api.toodledo.com/api.php?method=getFolders;"

// add folder url
#define kAddFolderURLFormat @"api.toodledo.com/api.php?method=addFolder;"

// delete folder url
#define kDeleteFolderURLFormat @"api.toodledo.com/api.php?method=deleteFolder;"

// edit folder url
#define kEditFolderURLFormat @"api.toodledo.com/api.php?method=editFolder;"

// add context url
#define kAddContextURLFormat @"api.toodledo.com/api.php?method=addContext;"

// get contexts url
#define kGetContextsURLFormat @"api.toodledo.com/api.php?method=getContexts;"

// delete context url
#define kDeleteContextURLFormat @"api.toodledo.com/api.php?method=deleteContext;"

// edit context url
#define kEditContextURLFormat @"api.toodledo.com/api.php?method=editContext;"

// get notes url
#define kGetNotesURLFormat @"api.toodledo.com/api.php?method=getNotes;"

// delete note url
#define kDeleteNotesURLFormat @"api.toodledo.com/api.php?method=deleteNote;"

// add note url
#define kAddNotesURLFormat @"api.toodledo.com/api.php?method=addNote;"

// edit note url
#define kEditNotesURLFormat @"api.toodledo.com/api.php?method=editNote;"

// TD specific

//tagSeperator
#define tagSeparator @","

////////////////////////////////////////////////////////////////////////////////
// log macros

// DLog is almost a drop-in replacement for NSLog for debug mode
#ifdef DEBUG
#	define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#	define DLog(...)
#endif

// ALog always displays output regardless of the DEBUG setting
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

