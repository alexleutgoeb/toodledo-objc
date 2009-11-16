//
//  GtdFolder.m
//  ToodledoAPI
//
//  Created by Alex Leutgöb on 09.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import "GtdFolder.h"


@implementation GtdFolder

@synthesize id;
@synthesize title;
@synthesize private;
@synthesize archived;
@synthesize order;

- (void) dealloc {
	[title release];
	[super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<GtdFolder folderId='%i' title='%@' private='%i' archived='%i' order='%i'>", folderId, title, private, archived, order];
}


@end
