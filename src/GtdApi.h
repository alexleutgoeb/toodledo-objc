//
//  GtdApi.h
//  ToodledoAPI
//
//  Created by Alex Leutgöb on 05.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GtdFolder.h"
#import "GtdTask.h"
#import "GtdNote.h"
#import "GtdContext.h"


// This constant defines the GtdApi error domain.
extern NSString *const GtdApiErrorDomain;

/**
 The GtdApi Protocol.
 */
@protocol GtdApi

@property (readonly) BOOL isAuthenticated;

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

/**
 Loads and returns an array with GtdTask objects.
 @param error
*/
 - (NSArray *)getTasks:(NSError **)error;

/**
 Adds a remote task
 @param aTask
 @param error
*/
 - (NSInteger)addTask:(GtdTask *)aTask error:(NSError **)error;

/**
 Edits a remote task
 @param aTask
 @param error
*/
 - (BOOL)editTask:(GtdTask *)aTask error:(NSError **)error;

/**
 Deletes a remote task
 @param aTask
 @param error
*/
- (BOOL)deleteTask:(GtdTask *)aTask error:(NSError **)error;

/**
 Loads and returns an array with deleted task objects.
 @param error
*/
 - (NSArray *)getDeleted:(NSError **)error;

//Get remote Notes
- (NSArray *)getNotes:(NSError **)error;

//Delete a given Note
- (BOOL)deleteNote:(GtdNote *)aNote error:(NSError **)error;

//Adds given Note
- (NSInteger)addNote:(GtdNote *)aNote error:(NSError **)error;

//Edits given Note
- (BOOL)editNote:(GtdNote *)aNote error:(NSError **)error;

// Adds a given context
- (NSInteger)addContext:(GtdContext *)aContext error:(NSError **)error;

// Gets a list of contexts
- (NSArray *)getContexts:(NSError **)error;

// Deletes a given context
- (BOOL)deleteContext:(GtdContext *)aContext error:(NSError **)error;

// Edit given context
- (BOOL)editContext:(GtdContext *)aContext error:(NSError **)error;

@end


typedef enum {
	GtdApiNoConnectionError = 10,
	GtdApiNotReachableError = 20,
	GtdApiDataError = 30,
	GtdApiMissingParameters = 40,
	GtdApiMissingCredentialsError = 110,
	GtdApiWrongCredentialsError = 120,
	GtdApiFolderNotAddedError = 210,
	GtdApiFolderNotDeletedError = 310,
	GtdApiFolderNotEditedError = 410,
	GtdApiContextNotAddedError = 510,
	GtdApiContextNotDeletedError = 520,
	GtdApiContextNotEditedError = 530
} GtdApiError;
