//
//  GtdContext.m
//  ToodledoAPI
//
//  Created by Alex Leutgöb on 09.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import "GtdContext.h"


@implementation GtdContext

@synthesize contextId;
@synthesize title;

- (void) dealloc {
	[title release];
	[super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<GtdContext contextId='%i' title='%@'>", contextId, title];
}

@end
