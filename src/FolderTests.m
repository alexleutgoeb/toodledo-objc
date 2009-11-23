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
#import "GtdFolder.h"


@interface FolderTests :SenTestCase {
	TDApi *api;
	GtdFolder *folder;
}

- (void)testAddFolderWithoutParams;
- (void)testAddFolderWithoutFolderTitle;

@end

@implementation FolderTests

- (void)setUp {
	api = [[TDApi alloc] init];
	folder = [[GtdFolder alloc] init];
}

- (void)tearDown {
	[folder release];
	folder = nil;
	[api release];
	api = nil;
}

- (void)testAddFolderWithoutParams {
	NSError *error = nil;
	[api addFolder:nil error:&error];
	STAssertTrue([error code] == GtdApiMissingParameters, @"Folder must not be added without folder argument.");
}

- (void)testAddFolderWithoutFolderTitle {
	NSError *error = nil;
	folder.title = nil;
	[api addFolder:folder error:&error];
	STAssertTrue([error code] == GtdApiMissingParameters, @"Folder must not be added without folder title argument.");
}

@end
