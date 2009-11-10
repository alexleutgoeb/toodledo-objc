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


@interface TDApi : NSObject <GtdApi> {
@private
	NSString *userId;
	NSString *key;
	NSDate *keyValidity;
	NSString *passwordHash;

}


// Main initializer, performs authentication.
- (id)initWithUsername:(NSString *)username password:(NSString *)password error:(NSError **)error;

// Loads and returns an array with GtdFolder objects.
- (NSArray *)getFoldersWithError:(NSError **)error;

// Adds a remote folder
- (NSInteger)addFolder:(GtdFolder *)aFolder error:(NSError **)error;

@end
