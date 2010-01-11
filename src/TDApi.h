//
//  TDApi.h
//  ToodledoAPI
//
//  Created by Alex Leutgöb on 08.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GtdApi.h"


@interface TDApi : NSObject <GtdApi> {
@private
	NSString *userId;
	NSString *key;
	NSDate *keyValidity;
	NSString *passwordHash;
	NSTimeInterval servertimeDifference;
	NSMutableDictionary *accountInfo;
}

@end
