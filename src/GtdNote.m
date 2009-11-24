//
//  GtdNote.m
//  ToodledoAPI
//
//  Created by Alex Leutgöb on 09.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import "GtdNote.h"


@implementation GtdNote

@synthesize uid;
@synthesize date_created;
@synthesize date_modified;
@synthesize title;
@synthesize text;
@synthesize private;
@synthesize folder;

- (void) dealloc 
{
	[super dealloc];
}

- (NSString *)description 
{
	return [NSString stringWithFormat:@"<GtdNote uid='%i' note='%@'>", uid, text];
}


@end
