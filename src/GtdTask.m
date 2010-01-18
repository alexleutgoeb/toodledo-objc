//
//  GtdTask.m
//  ToodledoAPI
//
//  Created by Alex Leutgöb on 07.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GtdTask.h"


@implementation GtdTask

@synthesize uid;
@synthesize title;
@synthesize date_created;
@synthesize date_modified;
@synthesize date_start;
@synthesize date_due;
@synthesize date_deleted;
@synthesize tags;
@synthesize folder;
@synthesize context;
@synthesize priority;
@synthesize completed;
@synthesize length;
@synthesize note;
@synthesize star;
@synthesize repeat;
@synthesize status;
@synthesize reminder;
@synthesize parentId;

- (id)init {
	if (self = [super init]) {
		title = nil;
		tags = nil;
		uid = -1;
		parentId = -1;
	}
	return self;
}

- (void) dealloc {
	[title release];
	[date_created release];
	[date_due release];
	[date_start release];
	[date_modified release];
	[date_deleted release];
	[tags release];
	[completed release];
	[note release];
	[super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<GtdTask uid='%i' title='%@' modified='%@' date_due='%@' date_start='%@'>", uid, title, date_modified, date_due, date_start];
}


@end
