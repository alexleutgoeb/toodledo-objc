//
//  FolderTests.m
//  ToodledoAPI
//
//  Created by Alex Leutgöb on 17.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//


#import <SenTestingKit/SenTestingKit.h>
#import "GtdApi.h"
#import "TDApi.h"


@interface FolderTests :SenTestCase {
	TDApi *api;
}

- (void)testAddFolderWithoutParams;

@end

@implementation FolderTests

- (void)setUp {
	api = [[TDApi alloc] init];
}

- (void)tearDown {
	[api release];
	api = nil;
}

- (void)testAddFolderWithoutParams {
	NSError *error = nil;
	[api addFolder:nil error:&error];
	STAssertTrue([error code] == GtdApiMissingParameters, @"Folder must not be added without folder argument.");
}

@end
