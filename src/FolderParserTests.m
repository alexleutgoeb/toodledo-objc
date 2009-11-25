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

- (void)testAddFolderWithMissingTitle;

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
- (void)testAddFolderWithMissingTitle {
	simpleParser.tagName = @"added";
	simpleParser.data = [NSData data];
	// TODO: set data, test return value
}

@end
