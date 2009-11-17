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
#import "GtdFolder.h"
#import "GtdTask.h"
#import "GtdContext.h"
#import "TDSimpleParser.h"
#import "TDFoldersParser.h"
#import "TDContextsParser.h"


@interface TDApi ()

- (BOOL)loadServerInfos;
- (NSString *)getUserIdForUsername:(NSString *)aUsername andPassword:(NSString *)aPassword;
- (NSURLRequest *)requestForURLString:(NSString *)anUrlString additionalParameters:(NSDictionary *)additionalParameters;
- (NSURLRequest *)authenticatedRequestForURLString:(NSString *)anUrlString additionalParameters:(NSDictionary *)additionalParameters;
- (void)setPasswordHashWithPassword:(NSString *)password;

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *passwordHash;
@property (nonatomic, retain) NSDate *keyValidity;

@end


// workaround for error domain initialization
NSString *const GtdApiErrorDomain = @"GtdApiErrorDomain";


@implementation TDApi

@synthesize userId, key, keyValidity, passwordHash;

#pragma mark -
#pragma mark GtdApi protocol implementation

- (id)initWithUsername:(NSString *)username password:(NSString *)password error:(NSError **)error {
	if (self = [super init]) {
		self.userId = [self getUserIdForUsername:username andPassword:password];
		
		//Check userId
		if (self.userId == nil) {
			// UserId unknown error (connection ? )
			NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
			[errorDetail setValue:@"Unknown error." forKey:NSLocalizedDescriptionKey];
			*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:errorDetail];
			[self release];
			return nil;
		}
		else if ([userId isEqualToString:@"0"]) {
			// error: empty arguments
			NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
			[errorDetail setValue:@"Missing input parameters." forKey:NSLocalizedDescriptionKey];
			*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiMissingCredentialsError userInfo:errorDetail];
			[self release];
			return nil;
		}
		else if ([userId isEqualToString:@"1"]) {
			// error: wrong credentials
			NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
			[errorDetail setValue:@"User could not be found, probably wrong credentials" forKey:NSLocalizedDescriptionKey];
			*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiWrongCredentialsError userInfo:errorDetail];
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
	return self;
}

- (NSDictionary *)getLastModificationsDates:(NSError **)error {
	
	if ([self isAuthenticated]) {
		
		NSDictionary *datesDict = [NSDictionary dictionary];
		
		// NSError *requestError = nil, *parseError = nil;
		// NSURLRequest *request = [self authenticatedRequestForURLString:kGetFoldersURLFormat additionalParameters:nil];
		// NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&requestError];
		
		// TODO: implementieren
		
		return datesDict;
	}
	else {
		return nil;
	}
	
}

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
				NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
				[errorDetail setValue:@"Api data error." forKey:NSLocalizedDescriptionKey];
				*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:errorDetail];
			}
			else {
				// all ok, save result
				returnResult = result;
			}
			[parser release];
		}
		else {
			// error while loading request
			NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
			[errorDetail setValue:[requestError localizedDescription] forKey:NSLocalizedDescriptionKey];
			*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiNotReachableError userInfo:errorDetail];
		}
	}
	else {
		// error: no key, api error?
		NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
		[errorDetail setValue:@"Api Error, no valid key." forKey:NSLocalizedDescriptionKey];
		*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:errorDetail];
	}
	
	return returnResult;
}

- (NSInteger)addFolder:(GtdFolder *)aFolder error:(NSError **)error {
	
	NSInteger returnResult = -1;
	
	// Check parameters
	if (aFolder == nil || aFolder.uid == -1 || aFolder.title == nil) {
		NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
		[errorDetail setValue:@"Missing parameters in folder object." forKey:NSLocalizedDescriptionKey];
		*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiMissingParameters userInfo:errorDetail];
	}
	// Check if valid key
	else if (self.key != nil) {
		NSError *requestError = nil, *parseError = nil;
		NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:aFolder.title, @"title", (aFolder.private == NO ? 0 : 1), @"private", nil];
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
				NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
				[errorDetail setValue:@"Remote folder not added." forKey:NSLocalizedDescriptionKey];
				*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiFolderNotAddedError userInfo:errorDetail];
			}
			[parser release];
		}
		else {
			// error while loading request
			NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
			[errorDetail setValue:[requestError localizedDescription] forKey:NSLocalizedDescriptionKey];
			*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:errorDetail];
		}
	}
	else {
		// error: no key, api error?
		NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
		[errorDetail setValue:@"Api Error, no valid key." forKey:NSLocalizedDescriptionKey];
		*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:errorDetail];
	}
	
	return returnResult;
}

- (BOOL)deleteFolder:(GtdFolder *)aFolder error:(NSError **)error {
	
	BOOL returnResult = NO;
	
	// Check parameters
	if (aFolder == nil || aFolder.uid == -1 || aFolder.title == nil) {
		NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
		[errorDetail setValue:@"Missing parameters in folder object." forKey:NSLocalizedDescriptionKey];
		*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiMissingParameters userInfo:errorDetail];
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
				NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
				[errorDetail setValue:@"Remote folder not deleted." forKey:NSLocalizedDescriptionKey];
				*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiFolderNotDeletedError userInfo:errorDetail];
			}
			[parser release];
		}
		else {
			// error while loading request
			NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
			[errorDetail setValue:[requestError localizedDescription] forKey:NSLocalizedDescriptionKey];
			*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:errorDetail];
		}
	}
	else {
		// error: no key, api error?
		NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
		[errorDetail setValue:@"Api Error, no valid key." forKey:NSLocalizedDescriptionKey];
		*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:errorDetail];
	}
	
	return returnResult;
}

- (BOOL)editFolder:(GtdFolder *)aFolder error:(NSError **)error {

	BOOL returnResult = NO;
	
	// Check parameters
	if (aFolder == nil || aFolder.uid == -1 || aFolder.title == nil) {
		NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
		[errorDetail setValue:@"Missing parameters in folder object." forKey:NSLocalizedDescriptionKey];
		*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiMissingParameters userInfo:errorDetail];
	}
	// Check if valid key
	else if (self.key != nil) {
		NSError *requestError = nil, *parseError = nil;
		NSDictionary *params = [[NSDictionary alloc] init];
		
		if (aFolder.uid == -1) {
			// TODO: error: uid not set
			return NO;
		}
		[params setValue:aFolder.title forKey:@"key"];
		[params setValue:[NSString stringWithFormat:@"%d", aFolder.private] forKey:@"private"];
		[params setValue:[NSString stringWithFormat:@"%d", aFolder.archived] forKey:@"archived"];
		
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
				NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
				[errorDetail setValue:@"Remote folder not edited." forKey:NSLocalizedDescriptionKey];
				*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiFolderNotEditedError userInfo:errorDetail];
			}
			[parser release];
		}
		else {
			// error while loading request
			NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
			[errorDetail setValue:[requestError localizedDescription] forKey:NSLocalizedDescriptionKey];
			*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:errorDetail];
		}
	}
	else {
		// error: no key, api error?
		NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
		[errorDetail setValue:@"Api Error, no valid key." forKey:NSLocalizedDescriptionKey];
		*error = [NSError errorWithDomain:GtdApiErrorDomain code:GtdApiDataError userInfo:errorDetail];
	}
	
	return returnResult;
}

- (NSArray *)getTasks:(NSError **)error {
	/*
	if ([self isAuthenticated]) {
		// TODO: parse error handling
		NSError *requestError = nil, *parseError = nil;
		NSURLRequest *request = [self authenticatedRequestForURLString:kGetTasksURLFormat additionalParameters:nil];
		NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&requestError];
		
		if (requestError == nil) {
			// all ok
			TDTasksParser *parser = [[TDTasksParser alloc] initWithData:responseData];
			NSArray *result = [[[parser parseResults:&parseError] retain] autorelease];
			[parser release];
			return result;
		}
		else {
			// error while loading request
			NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
			[errorDetail setValue:[requestError localizedDescription] forKey:NSLocalizedDescriptionKey];
			*error = [NSError errorWithDomain:GtdApiErrorDomain code:-2 userInfo:errorDetail];
			return nil;
		}
	}
	else {
		// TODO: error
		return nil;
	}
	 */
	return nil;
}

- (NSInteger)addTask:(GtdTask *)aTask error:(NSError **)error {
	
	// TODO: check parameters (if set)
	
	if ([self isAuthenticated]) {
		// TODO: parse error handling
		NSError *requestError = nil, *parseError = nil;
		NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
								aTask.title, @"title",
								aTask.tag, @"tag",
								aTask.folder, @"folder",
								aTask.context, @"context",
								//aTask.goal, @"goal",
								//aTask.parent, @"parent",
								aTask.date_due, @"dueDate",
								aTask.date_start, @"startDate",
								//aTask.time_due, @"dueTime",
								//aTask.time_start, @"startTime",
								aTask.reminder, @"reminder",
								aTask.repeat, @"repeat",
								//aTask.rep_advanced, @"rep_advanced",
								aTask.status, @"status",
								aTask.length, @"length",
								aTask.priority, @"priority",
								aTask.star, @"star",
								aTask.note, @"note",
								nil
								];
		NSURLRequest *request = [self authenticatedRequestForURLString:kAddTaskURLFormat additionalParameters:params];
		NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&requestError];
		
		if (requestError == nil) {
			// all ok
			TDSimpleParser *parser = [[TDSimpleParser alloc] initWithData:responseData];
			parser.tagName = @"added";
			NSArray *result = [[[parser parseResults:&parseError] retain] autorelease];
			[parser release];
			
			if ([result count] == 1) {
				return [[result objectAtIndex:0] intValue];
			}
			else {
				return -1;
			}
		}
		else {
			// error while loading request
			NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
			[errorDetail setValue:[requestError localizedDescription] forKey:NSLocalizedDescriptionKey];
			*error = [NSError errorWithDomain:GtdApiErrorDomain code:-2 userInfo:errorDetail];
			return -1;
		}
	}
	else {
		// TODO: error
		return -1;
	}
}

- (NSInteger)editTask:(GtdTask *)aTask error:(NSError **)error {
	/*
	if([self isAuthenticated]) {
		NSError *requestError = nil, *parseError = nil;
		NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
								aTask.id, @"id",
								aTask.title, @"title",
								aTask.tag, @"tag",
								aTask.folder, @"folder",
								aTask.context, @"context",
								//aTask.goal, @"goal",
								//aTask.timer, @"timer", 
								//aTask.timerval, @"timerval",
								//aTask.parent, @"parent",
								aTask.completed, @"completed",
								//aTask.completed_on, @"completed_on",
								//aTask.reschedule, @"reschedule",
								aTask.date_due, @"dueDate",
								aTask.date_start, @"startDate",
								//aTask.time_due, @"dueTime",
								//aTask.time_start, @"startTime",
								aTask.reminder, @"reminder",
								aTask.repeat, @"repeat",
								//aTask.rep_advanced, @"rep_advanced",
								aTask.status, @"status",
								aTask.length, @"length",
								aTask.priority, @"priority",
								aTask.star, @"star",
								aTask.note, @"note",
								nil
								];
		NSURLRequest *request = [self authenticatedRequestForURLString:kEditTaskURLFormat additionalParameters:params];
		NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&requestError];
		
		if (requestError == nil) {
			// all ok
			TDSimpleParser *parser = [[TDSimpleParser alloc] initWithData:responseData];
			parser.tagName = @"success";
			NSArray *result = [[[parser parseResults:&parseError] retain] autorelease];
			[parser release];
			
			if ([result count] == 1) {
				return [[result objectAtIndex:0] intValue];
			}
			else {
				return -1;
			}
		}
		else {
			// error while loading request
			NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
			[errorDetail setValue:[requestError localizedDescription] forKey:NSLocalizedDescriptionKey];
			*error = [NSError errorWithDomain:GtdApiErrorDomain code:-2 userInfo:errorDetail];
			return -1;
		}
	}
	else {
		// TODO: error
		return -1;
	}
	 */
	return -1;
}

- (BOOL)deleteTask:(GtdTask *)aTask error:(NSError **)error {
	
	// TODO: check parameters (if set)
	
	if ([self isAuthenticated]) {
		// TODO: parse error handling
		NSError *requestError = nil, *parseError = nil;
		NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d", aTask.id], @"id", nil];
		NSURLRequest *request = [self authenticatedRequestForURLString:kDeleteTaskURLFormat additionalParameters:params];
		NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&requestError];
		
		if (requestError == nil) {
			// all ok
			TDSimpleParser *parser = [[TDSimpleParser alloc] initWithData:responseData];
			parser.tagName = @"success";
			NSArray *result = [[[parser parseResults:&parseError] retain] autorelease];
			[parser release];
			if ([result count] == 1) {
				if ([[result objectAtIndex:0] intValue] == 1)
					return YES;
				else
					return NO;
				// TODO: error handling, task not deleted
			}
			else {
				return NO;
				// TODO: error handling, task not deleted
			}
		}
		else {
			// error while loading request
			NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
			[errorDetail setValue:[requestError localizedDescription] forKey:NSLocalizedDescriptionKey];
			*error = [NSError errorWithDomain:GtdApiErrorDomain code:-2 userInfo:errorDetail];
			return -1;
		}
	}
	else {
		// TODO: error
		return -1;
	}
}


- (void) dealloc {
	[passwordHash release];
	[keyValidity release];
	[key release];
	[userId release];
	[super dealloc];
}


- (BOOL)isAuthenticated {
	if (key == nil || keyValidity == nil | [keyValidity compare:[NSDate date]] == NSOrderedDescending)
		return NO;
	else
		return YES;
}

#pragma mark -
#pragma mark helper methods

// Gets server infos for api
- (BOOL)loadServerInfos {
	
	if ([self isAuthenticated]) {
		NSError *parseError = nil;
		NSURLRequest *request = [self authenticatedRequestForURLString:kServerInfoURLFormat additionalParameters:nil];
		NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
		
		TDSimpleParser *parser = [[TDSimpleParser alloc] initWithData:responseData];
		parser.tagName = @"unixtime";
		NSArray *result = [[[parser parseResults:&parseError] retain] autorelease];
		[parser release];
		
		if ([result count] == 1) {
			NSDate *serverDate = [[NSDate alloc] initWithTimeIntervalSince1970:[[result objectAtIndex:0] doubleValue]];
			servertimeDifference = [serverDate timeIntervalSinceNow];
			[serverDate release];
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

// Used for userid lookup. Warning: the pwd is sent unencrypted.
- (NSString *)getUserIdForUsername:(NSString *)aUsername andPassword:(NSString *)aPassword {

	// TODO: parse error handling
	NSError *parseError = nil;
	NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:aUsername, @"email", aPassword, @"pass", nil];
	NSURLRequest *request = [self requestForURLString:kUserIdURLFormat additionalParameters:params];
	[params release];
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	
	TDSimpleParser *parser = [[TDSimpleParser alloc] initWithData:responseData];
	parser.tagName = @"userid";
	NSArray *result = [[[parser parseResults:&parseError] retain] autorelease];
	[parser release];
	
	if ([result count] == 1) {
		DLog(@"Got user id: %@", [result objectAtIndex:0]);
		return [result objectAtIndex:0];
	}
	else {
		DLog(@"Could not fetch user id.");
		return nil;
	}
	
}

// Custom getter for key; if key is not set or invalid, the getter loads a new one.
- (NSString *)key {
	if (key == nil || keyValidity == nil | [keyValidity compare:[NSDate date]] == NSOrderedDescending) {
		// TODO: parse error handling
		NSError *parseError = nil;
		
		// If no key exists or key is invalid
		NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:userId, @"userid", @"welldone", @"appid", nil];
		NSURLRequest *request = [self requestForURLString:kAuthenticationURLFormat additionalParameters:params];
		[params release];
		
		NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
		
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

// Create a request and append the api key
- (NSURLRequest *)authenticatedRequestForURLString:(NSString *)anUrlString additionalParameters:(NSDictionary *)additionalParameters {
	
	// Create parameter string
	NSMutableString *params = [[NSMutableString alloc] initWithFormat:@"%@key=%@;", anUrlString, self.key];
	for (NSString *paramKey in additionalParameters)
		[params appendFormat:@"%@=%@;", paramKey, [additionalParameters objectForKey:paramKey]];
	
	
	// Create rest url
	NSURL *url = [[NSURL alloc] initWithString:params];
	[params release];
	
	NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:url] autorelease];
	[url release];
	
	DLog(@"Created request with url: %@", [[request URL] absoluteString]);
	
    return request;
}

// Create a request without the api key.
- (NSURLRequest *)requestForURLString:(NSString *)anUrlString additionalParameters:(NSDictionary *)additionalParameters {

	// Create parameter string
	NSMutableString *params = [[NSMutableString alloc] initWithString:anUrlString];
	for (NSString *paramKey in additionalParameters)
		[params appendFormat:@"%@=%@;", paramKey, [additionalParameters valueForKey:paramKey]];
	
	
	// Create rest url
	NSURL *url = [[NSURL alloc] initWithString:params];
	[params release];
	NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:url] autorelease];
	[url release];
	
	DLog(@"Created request with url: %@", [[request URL] absoluteString]);
	
    return request;
}

- (NSInteger)addContext:(GtdContext *)aContext error:(NSError **)error {
	
	// TODO: check parameters (if set)
	
	if ([self isAuthenticated]) {
		// TODO: parse error handling
		NSError *requestError = nil, *parseError = nil;
		NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:aContext.title, @"title", nil];
		NSURLRequest *request = [self authenticatedRequestForURLString:kAddContextURLFormat additionalParameters:params];
		NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&requestError];
		
		if (requestError == nil) {
			// all ok
			TDSimpleParser *parser = [[TDSimpleParser alloc] initWithData:responseData];
			parser.tagName = @"added";
			NSArray *result = [[[parser parseResults:&parseError] retain] autorelease];
			[parser release];
			
			if ([result count] == 1) {
				return [[result objectAtIndex:0] intValue];
			}
			else {
				return -1;
			}
		}
		else {
			// error while loading request
			NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
			[errorDetail setValue:[requestError localizedDescription] forKey:NSLocalizedDescriptionKey];
			*error = [NSError errorWithDomain:GtdApiErrorDomain code:-2 userInfo:errorDetail];
			return -1;
		}
	}
	else {
		// TODO: error
		return -1;
	}
}

- (NSArray *)getContexts:(NSError **)error {
	
	if ([self isAuthenticated]) {
		// TODO: parse error handling
		NSError *requestError = nil, *parseError = nil;
		NSURLRequest *request = [self authenticatedRequestForURLString:kGetContextsURLFormat additionalParameters:nil];
		NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&requestError];
		
		if (requestError == nil) {
			// all ok
			TDContextsParser *parser = [[TDContextsParser alloc] initWithData:responseData];
			NSArray *result = [[[parser parseResults:&parseError] retain] autorelease];
			[parser release];
			return result;
		}
		else {
			// error while loading request
			NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
			[errorDetail setValue:[requestError localizedDescription] forKey:NSLocalizedDescriptionKey];
			*error = [NSError errorWithDomain:GtdApiErrorDomain code:-2 userInfo:errorDetail];
			return nil;
		}
	}
	else {
		// TODO: error
		return nil;
	}
}

- (BOOL)deleteContext:(GtdContext *)aContext error:(NSError **)error {
	
	// TODO: check parameters (if set)
	
	if ([self isAuthenticated]) {
		// TODO: parse error handling
		NSError *requestError = nil, *parseError = nil;
		NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d", aContext.contextId], @"id", nil];
		NSURLRequest *request = [self authenticatedRequestForURLString:kDeleteContextURLFormat additionalParameters:params];
		NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&requestError];
		
		if (requestError == nil) {
			// all ok
			TDSimpleParser *parser = [[TDSimpleParser alloc] initWithData:responseData];
			parser.tagName = @"success";
			NSArray *result = [[[parser parseResults:&parseError] retain] autorelease];
			[parser release];
			if ([result count] == 1) {
				if ([[result objectAtIndex:0] intValue] == 1)
					return YES;
				else
					return NO;
				// TODO: error handling, folder not deleted
			}
			else {
				return NO;
				// TODO: error handling, folder not deleted
			}
		}
		else {
			// error while loading request
			NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
			[errorDetail setValue:[requestError localizedDescription] forKey:NSLocalizedDescriptionKey];
			*error = [NSError errorWithDomain:GtdApiErrorDomain code:-2 userInfo:errorDetail];
			return -1;
		}
	}
	else {
		// TODO: error
		return -1;
	}
}

@end
