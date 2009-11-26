//
//  GtdContext.m
//  ToodledoAPI
//
//  Created by Alex Leutgöb on 09.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import "GtdContext.h"


@implementation GtdContext

@synthesize uid;
@synthesize title;

- (id)init {
	if (self = [super init]) {
		title = nil;
		uid = -1;
	}
	return self;
}

- (void) dealloc {
	[title release];
	[super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<GtdContext contextId='%i' title='%@'>", uid, title];
}

@end
