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
- (void)testDeleteFolderWithoutParams;
- (void)testDeleteFolderWithoutFolderUid;
- (void)testEditFolderWithoutParams;
- (void)testEditFolderWithoutFolderUid;
- (void)testEditFolderWithoutFolderTitle;

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

// Tests adding a folder without a folder parameter
- (void)testAddFolderWithoutParams {
	NSError *error = nil;
	NSInteger returnValue = [api addFolder:nil error:&error];
	STAssertTrue([error code] == GtdApiMissingParameters, @"Folder must not be added without folder argument.");
	STAssertTrue(returnValue == -1, @"Return value must be -1.");
}

// Tests adding a folder with an empty title in the folder object
- (void)testAddFolderWithoutFolderTitle {
	NSError *error = nil;
	folder.title = nil;
	NSInteger returnValue = [api addFolder:folder error:&error];
	STAssertTrue([error code] == GtdApiMissingParameters, @"Folder must not be added without folder title argument.");
	STAssertTrue(returnValue == -1, @"Return value must be -1.");
}

// Tests deleting a folder without a folder parameter
- (void)testDeleteFolderWithoutParams {
	NSError *error = nil;
	STAssertTrue([api deleteFolder:nil error:&error] == NO, @"Return value must be NO.");
	STAssertTrue([error code] == GtdApiMissingParameters, @"Folder must not be added without folder argument.");
}

// Tests deleting a folder with an empty uid in the folder object
- (void)testDeleteFolderWithoutFolderUid {
	NSError *error = nil;
	folder.uid = -1;
	STAssertTrue([api deleteFolder:folder error:&error] == NO, @"Return value must be NO.");
	STAssertTrue([error code] == GtdApiMissingParameters, @"Folder must not be added without folder uid argument.");
}

// Tests editing a folder without a folder parameter
- (void)testEditFolderWithoutParams {
	NSError *error = nil;
	STAssertTrue([api editFolder:nil error:&error] == NO, @"Return value must be NO.");
	STAssertTrue([error code] == GtdApiMissingParameters, @"Folder must not be edited without folder argument.");
}

// Tests editing a folder with an empty uid in the folder object
- (void)testEditFolderWithoutFolderUid {
	NSError *error = nil;
	folder.uid = -1;
	STAssertTrue([api editFolder:folder error:&error] == NO, @"Return value must be NO.");
	STAssertTrue([error code] == GtdApiMissingParameters, @"Folder must not be edited without folder uid argument.");
}

// Tests editing a folder with an empty uid in the folder object
- (void)testEditFolderWithoutFolderTitle {
	NSError *error = nil;
	folder.title = nil;
	STAssertTrue([api editFolder:folder error:&error] == NO, @"Return value must be NO.");
	STAssertTrue([error code] == GtdApiMissingParameters, @"Folder must not be edited without folder title argument.");
}

@end
