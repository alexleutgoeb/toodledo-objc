//
//  TDApi.m
//  ToodledoAPI
//
//  Created by Alex Leutgöb on 08.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "TDApi.h"
#import "TDApiConstants.h"
#import "TDSimpleParser.h"
#import "TDFoldersParser.h"
#import "TDContextsParser.h"
#import "TDTasksParser.h"
#import "TDDeletedTasksParser.h"
#import "TDNotesParser.h"
#import "TDUserInfoParser.h"

@interface TDApi ()

- (BOOL)loadServerInfos;
- (BOOL)loadAccountInfo;
- (NSString *)getUserIdForUsername:(NSString *)aUsername andPassword:(NSString *)aPassword;
- (NSURLRequest *)requestForURLString:(NSString *)anUrlString additionalParameters:(NSDictionary *)additionalParameters;
- (NSURLRequest *)authenticatedRequestForURLString:(NSString *)anUrlString additionalParameters:(NSDictionary *)additionalParameters;
- (void)setPasswordHashWithPassword:(NSString *)password;

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *passwordHash;
@property (nonatomic, retain) NSDate *keyValidity;
@property (nonatomic, retain) NSDictionary *accountInfo;

@end


// workaround for error domain initialization
NSString *const GtdApiErrorDomain = @"GtdApiErrorDomain";


@implementation TDApi

@synthesize userId, key, keyValidity, passwordHash, accountInfo;

- (void) dealloc {
	[passwordHash release];
	[keyValidity release];
	[key release];
	[userId release];
	[super dealloc];
}

#pragma mark -
#pragma mark GtdApi protocol implementation

- (id)initWithUsername:(NSString *)username password:(NSString *)password error:(NSError **)error {
	*error = nil;
	if (self = [super init]) {
		
		// Check if username and password is set
		if (username == nil || password == nil || [username length] == 0 || [password length] == 0) {
			// error: empty arguments
			*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiMissingCredentialsError userInfo:nil];
			[self release];
			return nil;
		}
		else {
			self.userId = [self getUserIdForUsername:username andPassword:password];
			
			//Check userId
			if (self.userId == nil) {
				// UserId unknown error (connection ? )
				*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:nil];
				[self release];
				return nil;
			}
			else if ([userId isEqualToString:@"0"]) {
				// error: empty arguments, redundant
				*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiMissingCredentialsError userInfo:nil];
				[self release];
				return nil;
			}
			else if ([userId isEqualToString:@"1"]) {
				// error: wrong credentials
				*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiWrongCredentialsError userInfo:nil];
				[self release];
				return nil;
			}
			else {
				[self setPasswordHashWithPassword:password];
				// auth
				[self key];
				[self loadServerInfos];
			}
		}
	}
	return self;
}

- (BOOL)isAuthenticated {
	if (key == nil || keyValidity == nil | [keyValidity compare:[NSDate date]] == NSOrderedDescending)
		return NO;
	else
		return YES;
}

+ (NSString *)identifier {
	return @"syncservice.toodledo-objc";
}

- (NSString *)identifier {
	return [TDApi identifier];
}

- (NSMutableDictionary *)getLastModificationsDates:(NSError **)error {
	NSMutableDictionary *returnResult = nil;
	
	if ([self loadAccountInfo] != NO) {
		returnResult = [NSMutableDictionary dictionary];
		
		if ([accountInfo valueForKey:@"lastaddedit"] != nil) {
			[returnResult setValue:[accountInfo valueForKey:@"lastaddedit"] forKey:@"lastTaskAddEdit"];
		}
		if ([accountInfo valueForKey:@"lastdelete"] != nil) {
			[returnResult setValue:[accountInfo valueForKey:@"lastdelete"] forKey:@"lastTaskDelete"];
		}
		if ([accountInfo valueForKey:@"lastfolderedit"] != nil) {
			[returnResult setValue:[accountInfo valueForKey:@"lastfolderedit"] forKey:@"lastFolderEdit"];
		}
		if ([accountInfo valueForKey:@"lastcontextedit"] != nil) {
			[returnResult setValue:[accountInfo valueForKey:@"lastcontextedit"] forKey:@"lastContextEdit"];
		}
	}
	else {
		*error = [NSError errorWithDomain:GtdApiErrorDomain code:-1 userInfo:nil];
	}
	
	return returnResult;
}


#pragma mark folder actions

- (NSArray *)getFolders:(NSError **)error {

	id returnResult = nil;
	
	if (self.key != nil) {
		NSError *requestError = nil, *parseError = nil;
		NSURLRequest *request = [self authenticatedRequestForURLString:kGetFoldersURLFormat additionalParameters:nil];
		NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&requestError];
		
		if (requestError == nil) {
			// all ok
			TDFoldersParser *parser = [[TDFoldersParser alloc] initWithData:responseData];
			NSArray *result = [[[parser parseResults:&parseError] retain] autorelease];

			if (parseError != nil) {
				// error in response xml
				*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:nil];
			}
			else {
				// all ok, save result
				returnResult = result;
			}
			[parser release];
		}
		else {
			// error while loading request
			*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiNotReachableError userInfo:nil];
		}
	}
	else {
		// error: no key, api error?
		*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:nil];
	}
	
	return returnResult;
}

- (NSInteger)addFolder:(GtdFolder *)aFolder error:(NSError **)error {
	
	NSInteger returnResult = -1;

	// Check parameters
	if (aFolder == nil || aFolder.title == nil) {
		*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiMissingParameters userInfo:nil];
	}
	// Check if valid key
	else if (self.key != nil) {
		NSError *requestError = nil, *parseError = nil;
		NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:aFolder.title, @"title", (aFolder.private == NO ? @"0" : @"1"), @"private", nil];
		NSURLRequest *request = [self authenticatedRequestForURLString:kAddFolderURLFormat additionalParameters:params];
		NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&requestError];
		[params release];
		
		if (requestError == nil) {
			// all ok
			TDSimpleParser *parser = [[TDSimpleParser alloc] initWithData:responseData];
			parser.tagName = @"added";
			NSArray *result = [[[parser parseResults:&parseError] retain] autorelease];
			
			if ([result count] == 1 && parseError == nil) {
				// all ok, save return value
				returnResult = [[result objectAtIndex:0] intValue];
			}
			else {
				// error in response xml
				*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiFolderNotAddedError userInfo:nil];
			}
			[parser release];
		}
		else {
			// error while loading request
			*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:nil];
		}
	}
	else {
		// error: no key, api error?
		*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:nil];
	}
	
	return returnResult;
}

- (BOOL)deleteFolder:(GtdFolder *)aFolder error:(NSError **)error {
	
	BOOL returnResult = NO;
	
	// Check parameters
	if (aFolder == nil || aFolder.uid == -1) {
		*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiMissingParameters userInfo:nil];
	}
	// Check if valid key
	else if (self.key != nil) {
		NSError *requestError = nil, *parseError = nil;
		NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d", aFolder.uid], @"id", nil];
		NSURLRequest *request = [self authenticatedRequestForURLString:kDeleteFolderURLFormat additionalParameters:params];
		NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&requestError];
		
		if (requestError == nil) {
			// all ok
			TDSimpleParser *parser = [[TDSimpleParser alloc] initWithData:responseData];
			parser.tagName = @"success";
			NSArray *result = [[[parser parseResults:&parseError] retain] autorelease];
			
			if ([result count] == 1 && parseError == nil) {
				// all ok, set return result
				returnResult = YES;
			}
			else {
				// error in response xml
				*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiFolderNotDeletedError userInfo:nil];
			}
			[parser release];
		}
		else {
			// error while loading request
			*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:nil];
		}
	}
	else {
		// error: no key, api error?
		*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:nil];
	}
	
	return returnResult;
}

- (BOOL)editFolder:(GtdFolder *)aFolder error:(NSError **)error {

	BOOL returnResult = NO;
	
	// Check parameters
	if (aFolder == nil || aFolder.uid == -1 || aFolder.title == nil) {
		*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiMissingParameters userInfo:nil];
	}
	// Check if valid key
	else if (self.key != nil) {
		NSError *requestError = nil, *parseError = nil;
		NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d", aFolder.uid], @"id",
																			aFolder.title, @"title",
																			(aFolder.private == NO ? @"0" : @"1"), @"private",
																			(aFolder.private == NO ? @"0" : @"1"), @"archived",
																			nil];
		
		NSURLRequest *request = [self authenticatedRequestForURLString:kEditFolderURLFormat additionalParameters:params];
		[params release];
		
		NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&requestError];
		
		if (requestError == nil) {
			// all ok
			TDSimpleParser *parser = [[TDSimpleParser alloc] initWithData:responseData];
			parser.tagName = @"success";
			NSArray *result = [[[parser parseResults:&parseError] retain] autorelease];
			
			if ([result count] == 1 && parseError == nil) {
				// all ok, set return result
				returnResult = YES;
			}
			else {
				// error in response xml
				*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiFolderNotEditedError userInfo:nil];
			}
			[parser release];
		}
		else {
			// error while loading request
			*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:nil];
		}
	}
	else {
		// error: no key, api error?
		*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:nil];
	}
	
	return returnResult;
}


#pragma mark task actions

- (NSArray *)getTasks:(NSError **)error {
	
	id returnResult = nil;
	
	if (self.key != nil) {
		NSError *requestError = nil, *parseError = nil;
		NSURLRequest *request = [self authenticatedRequestForURLString:kGetTasksURLFormat additionalParameters:nil];
		NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&requestError];
		
		if (requestError == nil) {
			// all ok
			TDTasksParser *parser = [[TDTasksParser alloc] initWithData:responseData];
			NSArray *result = [[[parser parseResults:&parseError] retain] autorelease];
			
			if(parseError != nil)
				*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:nil];
			else {
				//all ok, save result, if no pro account set parentIds of tasks to -1 and change dates
				for (GtdTask *task in result) {
					if (![[self.accountInfo valueForKey:@"pro"] isEqualToString:@"1"])
						task.parentId = -1;
					
					//whitespace von tags trimmen
					if ([task.tags count] > 0) {
						NSMutableArray *trimmedTags = [NSMutableArray arrayWithCapacity:[task.tags count]];
						for (NSString *tag in task.tags)
							[trimmedTags addObject:[tag stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
						task.tags = trimmedTags;
					}
					
					//serverTimeDifference adden
					task.date_modified = [task.date_modified addTimeInterval:-servertimeDifference];
					task.date_created = [task.date_created addTimeInterval:-servertimeDifference];
				}
				returnResult = result;
			}
			[parser release];
		}
		else
			*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiNotReachableError userInfo:nil];
	}
	else
		*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:nil];
	return returnResult;
}

- (NSArray *)getDeleted:(NSError **)error {
	
	id returnResult = nil;
	
	if (self.key != nil) {
		NSError *requestError = nil, *parseError = nil;
		NSURLRequest *request = [self authenticatedRequestForURLString:kGetDeletedTasksURLFormat additionalParameters:nil];
		NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&requestError];
		
		if (requestError == nil) {
			// all ok
			TDDeletedTasksParser *parser = [[TDDeletedTasksParser alloc] initWithData:responseData];
			NSArray *result = [[[parser parseResults:&parseError] retain] autorelease];
			
			if(parseError != nil)
				*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:nil];
			else //all ok, save result
			{
				for (GtdTask *task in result) {
					//serverTimeDifference adden
					task.date_deleted = [task.date_deleted addTimeInterval:-servertimeDifference];
				}
				returnResult = result;
			}
			
			[parser release];
		}
		else
			*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiNotReachableError userInfo:nil];
	}
	else
		*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:nil];
	return returnResult;
}


- (NSInteger)addTask:(GtdTask *)aTask error:(NSError **)error {
	
	NSInteger returnResult = -1;
	
	// Check parameters
	if (aTask == nil || aTask.title == nil)
		*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiMissingParameters userInfo:nil];
	//check if valid key
	else if (self.key != nil) {
		NSError *requestError = nil, *parseError = nil;
		
		NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
		[dateFormatter setDateFormat:@"yyyy-MM-dd"];
		NSDateFormatter *timeFormatter = [[[NSDateFormatter alloc] init] autorelease];
		[timeFormatter setDateFormat:@"hh:mm a"];
		[timeFormatter setAMSymbol:@"am"];
		[timeFormatter setPMSymbol:@"pm"];
		
		//pro account check
		if([[accountInfo objectForKey:@"pro"] intValue] != 1)
			aTask.parentId = 0;
		
		//whitespace von tags trimmen
		for (NSString *tag in aTask.tags)
			tag = [tag stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		
		NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
		[params setObject:aTask.title forKey:@"title"];
		if (aTask.tags != nil)
			[params setObject:[aTask.tags componentsJoinedByString:kTagSeparator] forKey:@"tag"];
		[params setObject:[NSString stringWithFormat:@"%d", aTask.folder] forKey:@"folder"];
		[params setObject:[NSString stringWithFormat:@"%d", aTask.context] forKey:@"context"];
		[params setObject:[NSString stringWithFormat:@"%d", aTask.parentId] forKey:@"parent"];
		if (aTask.date_due != nil) {
			[params setObject:[dateFormatter stringFromDate:aTask.date_due] forKey:@"duedate"];
			if(aTask.hasDueTime)
				[params setObject:[timeFormatter stringFromDate:aTask.date_due] forKey:@"duetime"];
			else
				[params setObject:@"0" forKey:@"duetime"]; // unset the time
		}
		else
			[params setObject:@"0000-00-00" forKey:@"duedate"]; // unset the date
		if (aTask.date_start != nil) {
			[params setObject:[dateFormatter stringFromDate:aTask.date_start] forKey:@"startdate"];
			[params setObject:[timeFormatter stringFromDate:aTask.date_start] forKey:@"starttime"];
		}
		if(aTask.completed != nil) {
			[params setObject:[NSString stringWithFormat:@"%d", (NSInteger)1] forKey:@"completed"];
		}
		else {
			[params setObject:[NSString stringWithFormat:@"%d", (NSInteger)0] forKey:@"completed"];
		}

		[params setObject:[NSString stringWithFormat:@"%d", aTask.reminder] forKey:@"reminder"];
		[params setObject:[NSString stringWithFormat:@"%d", aTask.repeat] forKey:@"repeat"];
		[params setObject:[NSString stringWithFormat:@"%d", aTask.status] forKey:@"status"];
		[params setObject:[NSString stringWithFormat:@"%d", aTask.length] forKey:@"length"];
		[params setObject:[NSString stringWithFormat:@"%d", aTask.priority] forKey:@"priority"];
		[params setObject:[NSString stringWithFormat:@"%d", aTask.star] forKey:@"star"];
		if (aTask.note != nil && [aTask.note length] > 0)
			[params setObject:aTask.note forKey:@"note"];
		
		NSURLRequest *request = [self authenticatedRequestForURLString:kAddTaskURLFormat additionalParameters:params];
		NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&requestError];
		[params release];
		
		if (requestError == nil) {
			// all ok
			TDSimpleParser *parser = [[TDSimpleParser alloc] initWithData:responseData];
			parser.tagName = @"added";
			NSArray *result = [[[parser parseResults:&parseError] retain] autorelease];
			
			if ([result count] == 1 && parseError == nil) {
				// all ok, save return value
				returnResult = [[result objectAtIndex:0] intValue];
			}
			else
				*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:nil];
			[parser release];
		}
		else
			*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiNotReachableError userInfo:nil];
	}
	else
		*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:nil];
	return returnResult;
}

- (BOOL)editTask:(GtdTask *)aTask error:(NSError **)error {
	
	BOOL returnResult = NO;
	
	// Check parameters
	if (aTask == nil || aTask.uid == -1 || aTask.title == nil)
		*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiMissingParameters userInfo:nil];
	// Check if valid key
	else if (self.key != nil) {
		NSError *requestError = nil, *parseError = nil;
		
		NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
		[dateFormatter setDateFormat:@"yyyy-MM-dd"];
		NSDateFormatter *timeFormatter = [[[NSDateFormatter alloc] init] autorelease];
		[timeFormatter setDateFormat:@"hh:mm a"];
		[timeFormatter setAMSymbol:@"am"];
		[timeFormatter setPMSymbol:@"pm"];
		
		//pro account check
		if([[accountInfo objectForKey:@"pro"] intValue] != 1)
			aTask.parentId = 0;
		
		//whitespace von tags trimmen
		for (NSString *tag in aTask.tags)
			tag = [tag stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		
		NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
		[params setObject:[NSString stringWithFormat:@"%d", aTask.uid] forKey:@"id"];
		[params setObject:aTask.title forKey:@"title"];
		if (aTask.tags != nil)
			[params setObject:[aTask.tags componentsJoinedByString:kTagSeparator] forKey:@"tag"];
		else
			[params setObject:@"" forKey:@"tag"];
		[params setObject:[NSString stringWithFormat:@"%d", aTask.folder] forKey:@"folder"];
		[params setObject:[NSString stringWithFormat:@"%d", aTask.context] forKey:@"context"];
		[params setObject:[NSString stringWithFormat:@"%d", aTask.parentId] forKey:@"parent"];
		if (aTask.date_due != nil) {
			[params setObject:[dateFormatter stringFromDate:aTask.date_due] forKey:@"duedate"];
			if(aTask.hasDueTime)
				[params setObject:[timeFormatter stringFromDate:aTask.date_due] forKey:@"duetime"];
			else
				[params setObject:@"0" forKey:@"duetime"]; // unset the time
		}
		else
			[params setObject:@"0000-00-00" forKey:@"duedate"]; // unset the date
		if (aTask.date_start != nil) {
			[params setObject:[dateFormatter stringFromDate:aTask.date_start] forKey:@"startdate"];
			[params setObject:[timeFormatter stringFromDate:aTask.date_start] forKey:@"starttime"];
		}
		if(aTask.completed != nil) {
			[params setObject:[NSString stringWithFormat:@"%d", (NSInteger)1] forKey:@"completed"];
		}
		else {
			[params setObject:[NSString stringWithFormat:@"%d", (NSInteger)0] forKey:@"completed"];
		}
		[params setObject:[NSString stringWithFormat:@"%d", aTask.reminder] forKey:@"reminder"];
		[params setObject:[NSString stringWithFormat:@"%d", aTask.repeat] forKey:@"repeat"];
		[params setObject:[NSString stringWithFormat:@"%d", aTask.status] forKey:@"status"];
		[params setObject:[NSString stringWithFormat:@"%d", aTask.length] forKey:@"length"];
		[params setObject:[NSString stringWithFormat:@"%d", aTask.priority] forKey:@"priority"];
		[params setObject:[NSString stringWithFormat:@"%d", aTask.star] forKey:@"star"];
		if (aTask.note != nil)
			[params setObject:aTask.note forKey:@"note"];
		else
			[params setObject:@"" forKey:@"note"];
		
		NSURLRequest *request = [self authenticatedRequestForURLString:kEditTaskURLFormat additionalParameters:params];
		NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&requestError];
		
		[params release];
		
		if (requestError == nil) {
			// all ok
			TDSimpleParser *parser = [[TDSimpleParser alloc] initWithData:responseData];
			parser.tagName = @"success";
			NSArray *result = [[[parser parseResults:&parseError] retain] autorelease];
			
			if ([result count] == 1 && parseError == nil) {
				// all ok, set return result
				returnResult = YES;
			}
			else
				*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:nil];
			[parser release];
		}
		else
			*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiNotReachableError userInfo:nil];
	}
	else
		*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:nil];
	return returnResult;
}

- (BOOL)deleteTask:(GtdTask *)aTask error:(NSError **)error {
	
	BOOL returnResult = NO;
	
	// Check parameters
	if (aTask == nil || aTask.uid == -1)
		*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiMissingParameters userInfo:nil];
	// Check if valid key
	else if (self.key != nil) {
		// TODO: parse error handling
		NSError *requestError = nil, *parseError = nil;
		NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d", aTask.uid], @"id", nil];
		NSURLRequest *request = [self authenticatedRequestForURLString:kDeleteTaskURLFormat additionalParameters:params];
		NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&requestError];
		
		if (requestError == nil) {
			// all ok
			TDSimpleParser *parser = [[TDSimpleParser alloc] initWithData:responseData];
			parser.tagName = @"success";
			NSArray *result = [[[parser parseResults:&parseError] retain] autorelease];
			
			if ([result count] == 1 && parseError == nil) {
				// all ok, set return result
				returnResult = YES;
			}
			else
				*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:nil];
		}
		else
			*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiNotReachableError userInfo:nil];
	}
	else
		*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:nil];
	return returnResult;
}


#pragma mark context actions

- (NSInteger)addContext:(GtdContext *)aContext error:(NSError **)error {
	
	NSInteger returnResult = -1;
	
	// check parameters
	if(aContext == nil || aContext.title == nil) {
		*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiMissingParameters userInfo:nil];
	}
	
	// check if valid key
	else if(self.key != nil) {
		NSError *requestError = nil, *parseError = nil;
		NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:aContext.title, @"title", nil];
		NSURLRequest *request = [self authenticatedRequestForURLString:kAddContextURLFormat additionalParameters:params];
		NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&requestError];
		[params release];
		
		if (requestError == nil) {
			// all ok
			TDSimpleParser *parser = [[TDSimpleParser alloc] initWithData:responseData];
			parser.tagName = @"added";
			NSArray *result = [[[parser parseResults:&parseError] retain] autorelease];
			[parser release];
			
			if ([result count] == 1 && parseError == nil) {
				// all ok, save return value
				return [[result objectAtIndex:0] intValue];
			}
			else {
				// error in response xml
				*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiContextNotAddedError userInfo:nil];
			}
			[parser release];
		}
		else {
			// error while loading request
			*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:nil];
		}
	}
	else {
		// error: no key, api error?
		*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:nil];
	}
	
	return returnResult;
}

- (NSArray *)getContexts:(NSError **)error {
	
	id returnResult = nil;
	
	if (self.key != nil) {
		NSError *requestError = nil, *parseError = nil;
		NSURLRequest *request = [self authenticatedRequestForURLString:kGetContextsURLFormat additionalParameters:nil];
		NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&requestError];
		
		if (requestError == nil) {
			// all ok
			TDContextsParser *parser = [[TDContextsParser alloc] initWithData:responseData];
			NSArray *result = [[[parser parseResults:&parseError] retain] autorelease];
			
			if(parseError != nil) {
				// error in response xml
				*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:nil];
			}
			else {
				// all ok, save result
				returnResult = result;
			}
			[parser release];
		}
		else {
			// error while loading request
			*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiNotReachableError userInfo:nil];
		}
	}
	else {
		// error: no key, api error?
		*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:nil];
	}
	
	return returnResult;
}

- (BOOL)deleteContext:(GtdContext *)aContext error:(NSError **)error {
	
	bool returnResult = NO;
	
	// check parameters
	if(aContext == nil || aContext.uid == -1) {
		*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiMissingParameters userInfo:nil];
	}
	// check if valid key
	else if (self.key != nil) {
		NSError *requestError = nil, *parseError = nil;
		NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d", aContext.uid], @"id", nil];
		NSURLRequest *request = [self authenticatedRequestForURLString:kDeleteContextURLFormat additionalParameters:params];
		NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&requestError];
		
		if (requestError == nil) {
			// all ok
			TDSimpleParser *parser = [[TDSimpleParser alloc] initWithData:responseData];
			parser.tagName = @"success";
			NSArray *result = [[[parser parseResults:&parseError] retain] autorelease];
			
			if ([result count] == 1 && parseError == nil) {
				// all ok, set return result
				returnResult = YES;
			}
			else {
				// error in response xml
				*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiContextNotDeletedError userInfo:nil];
			}
			[parser release];
		}
		else {
			// error while loading request
			*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:nil];
		}
	}
	else {
		// error: no key, api error?
		*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:nil];
	}
	
	return returnResult;
}

- (BOOL)editContext:(GtdContext *)aContext error:(NSError **)error {
	
	BOOL returnResult = NO;
	
	// check parameters
	if (aContext == nil || aContext.uid == -1 || aContext.title == nil) {
		*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiMissingParameters userInfo:nil];
	}
	// check if valid key
	else if(self.key != nil) {
		NSError *requestError = nil, *parseError = nil;
		NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d", aContext.uid], @"id",aContext.title, @"title", nil];
		
		NSURLRequest *request = [self authenticatedRequestForURLString:kEditContextURLFormat additionalParameters:params];
		[params release];
		NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&requestError];
		
		if(requestError == nil) {
			// all ok
			TDSimpleParser *parser = [[TDSimpleParser alloc] initWithData:responseData];
			parser.tagName = @"success";
			NSArray *result = [[[parser parseResults:&parseError] retain] autorelease];
			
			if([result count] == 1 && parseError == nil) {
				// all ok, set return result
				returnResult = YES;
			}
			else // error in response xml
				*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiContextNotEditedError userInfo:nil];
			
			[parser autorelease];
		}
		else // error while loading request
			*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:nil];
	}
	else // error: no key, api error?
		*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:nil];

	return returnResult;
}


#pragma mark notes actions

- (NSArray *)getNotes:(NSError **)error 
{
	
	id returnResult = nil;
	
	// Check if valid key
	if (self.key != nil) 
	{

		NSError *requestError = nil, *parseError = nil;
		NSURLRequest *request = [self authenticatedRequestForURLString:kGetNotesURLFormat additionalParameters:nil];
		NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&requestError];
		
		if (requestError == nil) 
		{
			// all ok
			
			TDNotesParser *parser = [[TDNotesParser alloc] initWithData:responseData];
			NSArray *result = [[[parser parseResults:&parseError] retain] autorelease];
			
			//add servertimeDifference to date_modified
			for(GtdNote *note in result)
				note.date_modified = [note.date_modified addTimeInterval:servertimeDifference];
			
			if (parseError != nil) 
			{
				*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:nil];
			}
			else 
			{
				// all ok, save result
				returnResult = result;
			}
			[parser release]; 
		}
		else 
		{			
			*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiNotReachableError userInfo:nil];
		}
	}
	else 
	{
		*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:nil];
	}
	
	return returnResult;
}


//Delete a given Note
- (BOOL)deleteNote:(GtdNote *)aNote error:(NSError **)error
{
	BOOL returnResult = NO;
	
	// Check parameters
	if (aNote.uid == -1 || aNote.text == nil || aNote.title == nil || aNote.folder == -1)
	{
		*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiMissingParameters userInfo:nil];
	}
	else 
	{
		if (self.key != nil) 
		{
			// TODO: parse error handling
			NSError *requestError = nil, *parseError = nil;
			NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d", aNote.uid], @"id", nil];
			NSURLRequest *request = [self authenticatedRequestForURLString:kDeleteNotesURLFormat additionalParameters:params];
			NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&requestError];
		
			if (requestError == nil) 
			{
				// all ok
				TDSimpleParser *parser = [[TDSimpleParser alloc] initWithData:responseData];
				parser.tagName = @"success";
				NSArray *result = [[[parser parseResults:&parseError] retain] autorelease];
				
				if ([result count] == 1 && parseError == nil) 
				{
					returnResult = YES;
				}
				else
				{
					*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:nil];
				}
			}
			else
			{
				*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiNotReachableError userInfo:nil];
			}
		}
		else
		{
			*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:nil];
		}
	}
		
	return returnResult;
	
}


//Adds given Note
- (NSInteger)addNote:(GtdNote *)aNote error:(NSError **)error
{
	NSInteger returnResult = -1;
	// Check parameters
	if (aNote.uid == -1 || aNote.text == nil || aNote.title == nil || aNote.folder == -1)
	{
		*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiMissingParameters userInfo:nil];
	}	
	else 
	{
		if ([self isAuthenticated]) 
		{
			NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
			[dateFormatter setDateFormat:@"yyyy-MM-dd"];
			
			NSError *requestError = nil, *parseError = nil;
			NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
								aNote.title, @"title",
								aNote.text, @"text",
								[NSString stringWithFormat:@"%d", aNote.folder], @"folder",
								[NSString stringWithFormat:@"%d", aNote.private], @"private",
								// [dateFormater stringFromDate:aNote.addedon], @"addedon",
									nil ];								
			// TODO: addedon ?
		
		
			NSURLRequest *request = [self authenticatedRequestForURLString:kAddNotesURLFormat additionalParameters:params];
			NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&requestError];
		
			if (requestError == nil) 
			{
				// all ok
				TDSimpleParser *parser = [[TDSimpleParser alloc] initWithData:responseData];
				parser.tagName = @"added";
				NSArray *result = [[[parser parseResults:&parseError] retain] autorelease];
			
				[parser release];
			
				if ([result count] == 1 && parseError == nil) 
				{
					return [[result objectAtIndex:0] intValue];
				}
				else 
				{
					*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:nil];
				}
			}
			else 
			{
				*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiNotReachableError userInfo:nil];
			}
		}
		else 
		{		
			*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:nil];
		}
	}
	return returnResult;
}

//Edits given Note
- (BOOL)editNote:(GtdNote *)aNote error:(NSError **)error
{
	BOOL returnResult = NO;
	
	if (aNote.uid == -1 || aNote.text == nil || aNote.title == nil || aNote.folder == -1)
	{
		*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiMissingParameters userInfo:nil];
	}	
	else 
	{
		if ([self isAuthenticated]) 
		{
			NSError *requestError = nil, *parseError = nil;
			NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
								[NSString stringWithFormat:@"%d", aNote.uid], @"id",
								aNote.title, @"title",
								aNote.text, @"text",
								[NSString stringWithFormat:@"%d", aNote.folder], @"folder",
								[NSString stringWithFormat:@"%d", aNote.private], @"private", nil ];								
		
		
		
			NSURLRequest *request = [self authenticatedRequestForURLString:kAddNotesURLFormat additionalParameters:params];
			NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&requestError];
		
			if (requestError == nil) 
			{
				// all ok
				TDSimpleParser *parser = [[TDSimpleParser alloc] initWithData:responseData];
				parser.tagName = @"success";
				NSArray *result = [[[parser parseResults:&parseError] retain] autorelease];
				[parser release];
			
				if ([result count] == 1 && parseError == nil) 
				{
					// all ok, set return result
					return YES;
				}
				else 
				{
					*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:nil];
				}
			}
			else 
			{
				*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiNotReachableError userInfo:nil];
			}
		}
		else 
		{
			*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:nil];
		}
	}
	return returnResult;
}


#pragma mark -
#pragma mark helper methods

// Get server infos for api
- (BOOL)loadServerInfos {
	
	if ([self isAuthenticated]) {
		NSError *parseError = nil;
		NSURLRequest *request = [self authenticatedRequestForURLString:kServerInfoURLFormat additionalParameters:nil];
		NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
		
		TDSimpleParser *parser = [[TDSimpleParser alloc] initWithData:responseData];
		parser.tagName = @"date";
		NSArray *result = [[[parser parseResults:&parseError] retain] autorelease];
		[parser release];
		
		if ([result count] == 1) {
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			NSLocale *enUS = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
			[formatter setLocale:enUS];
			[enUS release];
			[formatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss"];
			
			NSDate *serverDate = [formatter dateFromString:[result objectAtIndex:0]];
			servertimeDifference = [serverDate timeIntervalSinceNow];
			
			[formatter release];
			DLog(@"Server infos retrieved, servertime difference: %f.", servertimeDifference);
			return YES;
		}
		else {
			DLog(@"Could not fetch server infos.");
			return NO;
		}	
	}
	else {
		return NO;
	}
}

- (BOOL)loadAccountInfo {
	
	BOOL returnResult = NO;
	
	if (self.key != nil) {
		NSError *requestError = nil, *parseError = nil;
		NSURLRequest *request = [self authenticatedRequestForURLString:kUserAccountInfoURLFormat additionalParameters:nil];
		NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&requestError];
		
		if (requestError == nil) {
			// all ok
			TDUserInfoParser *parser = [[TDUserInfoParser alloc] initWithData:responseData];
			NSArray *result = [[[parser parseResults:&parseError] retain] autorelease];
			
			if (parseError == nil) {
				self.accountInfo = [result objectAtIndex:0];
				returnResult = YES;
			}
			[parser release];
		}
	}
	return returnResult;
}

// Used for userid lookup. Warning: the pwd is sent unencrypted.
- (NSString *)getUserIdForUsername:(NSString *)aUsername andPassword:(NSString *)aPassword {

	NSString * returnResult = nil;
	NSError *requestError = nil, *parseError = nil;

	NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:aUsername, @"email", aPassword, @"pass", nil];
	NSURLRequest *request = [self requestForURLString:kUserIdURLFormat additionalParameters:params];
	[params release];
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&requestError];
	
	if (requestError == nil) {
		// all ok
		TDSimpleParser *parser = [[TDSimpleParser alloc] initWithData:responseData];
		parser.tagName = @"userid";
		NSArray *result = [[[parser parseResults:&parseError] retain] autorelease];
		
		if (parseError != nil) {
			// error in response xml
			DLog(@"Error while parsing userId.");
		}
		else {
			// all ok, save result
			if ([result count] == 1) {
				DLog(@"Got user id: %@", [result objectAtIndex:0]);
				returnResult = [result objectAtIndex:0];
			}
			else {
				DLog(@"Could not fetch user id.");
			}
		}
		[parser release];
	}
	else {
		// error while loading request
		DLog(@"Error while loading request for userId.");
	}
	return returnResult;
}

// Custom getter for key; if key is not set or invalid, the getter loads a new one.
- (NSString *)key {
	if (key == nil || keyValidity == nil | [keyValidity compare:[NSDate date]] == NSOrderedDescending) {
		
		NSError *requestError = nil, *parseError = nil;
		
		// If no key exists or key is invalid
		NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:userId, @"userid", @"welldone", @"appid", nil];
		NSURLRequest *request = [self requestForURLString:kAuthenticationURLFormat additionalParameters:params];
		[params release];
		
		NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&requestError];
		
		if (requestError == nil) {
			// all ok
			TDSimpleParser *parser = [[TDSimpleParser alloc] initWithData:responseData];
			parser.tagName = @"token";
			NSArray *result = [[[parser parseResults:&parseError] retain] autorelease];
			[parser release];
			
			if ([result count] == 1) {
				NSString *token = [result objectAtIndex:0];
				DLog(@"New token: %@", token);
				
				const char *cStr = [[NSString stringWithFormat:@"%@%@%@", passwordHash, token, userId] UTF8String];
				unsigned char result[CC_MD5_DIGEST_LENGTH];
				
				CC_MD5(cStr, strlen(cStr), result);
				
				self.key = [[NSString stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
							 result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7], result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]] lowercaseString];
				self.keyValidity = [NSDate date];
				DLog(@"Loaded new key: %@", key);
			}
			else {
				self.key = nil;
			}
		}
		else {
			// error while loading request
			self.key = nil;
		}
	}
	return key;
}

// Custom setter, sets the password hash for a given password.
- (void)setPasswordHashWithPassword:(NSString *)password {
	const char *cStr = [password UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	
	CC_MD5(cStr, strlen(cStr), result);
	
	self.passwordHash = [[NSString stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7], result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]] lowercaseString];
}

// Creates a request and append the api key
- (NSURLRequest *)authenticatedRequestForURLString:(NSString *)anUrlString additionalParameters:(NSDictionary *)additionalParameters {
	
	// Determine protocol
	NSString *urlProtocol = kBasicUrlProtocolFormat;
	if ([[self.accountInfo valueForKey:@"pro"] isEqualToString:@"1"]) {
		// pro user
		urlProtocol = kProUserUrlProtocolFormat;
	}
	
	// Create parameter string
	NSMutableString *params = [[NSMutableString alloc] initWithFormat:@"%@%@key=%@;", urlProtocol, anUrlString, self.key];
	for (NSString *paramKey in additionalParameters)
		[params appendFormat:@"%@=%@;", paramKey, (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)[additionalParameters objectForKey:paramKey], NULL, CFSTR("￼=,!$&'()*+;@?\n\"<>#\t :/"),kCFStringEncodingUTF8)];
	
	// Create rest url
	NSURL *url = [[NSURL alloc] initWithString:params];
	[params release];
	
	NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:url] autorelease];
	[url release];
	
	DLog(@"Created request with url: %@", [[request URL] absoluteString]);
	
    return request;
}

// Creates a request without the api key and the standard url protocol.
- (NSURLRequest *)requestForURLString:(NSString *)anUrlString additionalParameters:(NSDictionary *)additionalParameters {

	// Create parameter string
	NSMutableString *params = [[NSMutableString alloc] initWithFormat:@"%@%@", kBasicUrlProtocolFormat, anUrlString];
	for (NSString *paramKey in additionalParameters)
		[params appendFormat:@"%@=%@;", paramKey, (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)[additionalParameters objectForKey:paramKey], NULL, CFSTR("￼=,!$&'()*+;@?\n\"<>#\t :/"),kCFStringEncodingUTF8)];
		
	// Create rest url
	NSURL *url = [[NSURL alloc] initWithString:params];
	[params release];
	NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:url] autorelease];
	[url release];
	
	DLog(@"Created request with url: %@", [[request URL] absoluteString]);
	
    return request;
}

@end
