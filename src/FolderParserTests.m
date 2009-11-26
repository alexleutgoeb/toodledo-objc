//
//  FolderParserTests.m
//  ToodledoAPI
//
//  Created by Alex Leutgöb on 25.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//



#import <SenTestingKit/SenTestingKit.h>
#import "TDApi.h"
#import "GtdFolder.h"
#import "TDSimpleParser.h"
#import "TDFoldersParser.h"


@interface FolderParserTests :SenTestCase {
	TDSimpleParser *simpleParser;
	TDFoldersParser *folderParser;
}

- (void)testAddFolderWithInvalidKey;
- (void)testAddFolderWithMissingTitle;
- (void)testAddFolderSuccess;

@end

@implementation FolderParserTests

- (void)setUp {
	simpleParser = [[TDSimpleParser alloc] init];
	folderParser = [[TDFoldersParser alloc] init];
}

- (void)tearDown {
	[folderParser release];
	folderParser = nil;
	[simpleParser release];
	simpleParser = nil;
}

// Tests xml of adding a folder with an empty title
- (void)testAddFolderWithInvalidKey {
	
	NSData *returnData = [@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><error>key did not validate</error>" dataUsingEncoding:NSUTF8StringEncoding];
	
	simpleParser.tagName = @"added";
	simpleParser.data = returnData;
	
	NSError *error = nil;
	NSArray *results = [simpleParser parseResults:&error];
	
	STAssertTrue(results != nil, @"Parser return value must not be nil.");
	STAssertTrue([results count] == 0, @"Parser return array must be empty.");
}

// Tests xml of adding a folder with an empty title
- (void)testAddFolderWithMissingTitle {
	
	NSData *returnData = [@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><error>You must enter a title</error>" dataUsingEncoding:NSUTF8StringEncoding];
	
	simpleParser.tagName = @"added";
	simpleParser.data = returnData;
	
	NSError *error = nil;
	NSArray *results = [simpleParser parseResults:&error];
	
	STAssertTrue(results != nil, @"Parser return value must not be nil.");
	STAssertTrue([results count] == 0, @"Parser return array must be empty.");
}

// Tests xml of adding a folder
- (void)testAddFolderSuccess {
	
	NSString *newFolderId = @"3283361";
	
	NSData *returnData = [[NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>		<added>%@</added>", newFolderId] dataUsingEncoding:NSUTF8StringEncoding];
	
	simpleParser.tagName = @"added";
	simpleParser.data = returnData;
	
	NSError *error = nil;
	NSArray *results = [simpleParser parseResults:&error];
	
	STAssertTrue(results != nil, @"Parser return value must not be nil.");
	STAssertTrue(error == nil, @"Parser error object must be nil.");
	STAssertTrue([results count] == 1, @"Parser return array count must be 1.");
	STAssertTrue([[results objectAtIndex:0] isEqualToString:newFolderId], @"New folder id must match refernce id.");
}

@end
