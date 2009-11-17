//
//  TDApi.h
//  ToodledoAPI
//
//  Created by Alex Leutgöb on 08.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GtdApi.h"

@class GtdFolder;
@class GtdTask;


@interface TDApi : NSObject <GtdApi> {
@private
	NSString *userId;
	NSString *key;
	NSDate *keyValidity;
	NSString *passwordHash;
	NSTimeInterval servertimeDifference;

}


// Main initializer, performs authentication.
- (id)initWithUsername:(NSString *)username password:(NSString *)password error:(NSError **)error;

// Returns the last modifications dates in a dictionary, see doc for details.
- (NSDictionary *)getLastModificationsDates:(NSError **)error;

// Loads and returns an array with GtdFolder objects.
- (NSArray *)getFolders:(NSError **)error;

// Adds a remote folder
- (NSInteger)addFolder:(GtdFolder *)aFolder error:(NSError **)error;

// Deletes a remote folder
- (BOOL)deleteFolder:(GtdFolder *)aFolder error:(NSError **)error;

// Edits a remote folder
- (BOOL)editFolder:(GtdFolder *)aFolder error:(NSError **)error;

//Loads and returns an array with GtdTask objects.
- (NSArray *)getTasks:(NSError **)error;

//Adds a remote task
- (NSInteger)addTask:(GtdTask *)aTask error:(NSError **)error;

//Edits a remote task
- (NSInteger)editTask:(GtdTask *)aTask error:(NSError **)error;

//Deletes a remote task
- (BOOL)deleteTask:(GtdTask *)aTask error:(NSError **)error;

//Loads and returns an array with deleted task objects.
- (NSArray *)getDeleted:(NSError **)error;

@end
