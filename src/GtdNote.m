//
//  GtdNote.m
//  ToodledoAPI
//
//  Created by Alex Leutgöb on 09.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import "GtdNote.h"


@implementation GtdNote

@synthesize noteId;
@synthesize date_created;
@synthesize date_modified;
@synthesize title;
@synthesize text;
@synthesize private;

- (void) dealloc 
{
	// [title release];
	//[note release];
	[super dealloc];
}

- (NSString *)description 
{
	return [NSString stringWithFormat:@"<GtdNote noteId='%i' note='%@'>", noteId, text];
}


@end
