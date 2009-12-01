//
//  NoteParserTest.h
//  ToodledoAPI
//
//  Created by Michael Petritsch on 01.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "TDApi.h"
#import "GtdNote.h"
#import "TDSimpleParser.h"
#import "TDNotesParser.h"


@interface NoteParserTest :SenTestCase {
	TDSimpleParser *simpleParser;
	TDNotesParser *nParser;
}

- (void)testAddNoteWithInvalidKey;
- (void)testAddNoteWithMissingTitle;
- (void)testAddNoteSuccess;

@end


@implementation NoteParserTest

- (void)setUp {
	simpleParser = [[TDSimpleParser alloc] init];
	nParser = [[TDNotesParser alloc] init];
}

- (void)tearDown {
	[nParser release];
	nParser = nil;
	[simpleParser release];
	simpleParser = nil;
}

- (void)testAddNoteWithInvalidKey {
	
	NSData *returnData = [@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><error>key did not validate</error>" dataUsingEncoding:NSUTF8StringEncoding];
	
	simpleParser.tagName = @"added";
	simpleParser.data = returnData;
	
	NSError *error = nil;
	NSArray *results = [simpleParser parseResults:&error];
	
	STAssertTrue(results != nil, @"Parser return value must not be nil.");
	STAssertTrue([results count] == 0, @"Parser return array must be empty.");
}

- (void)testAddNoteWithMissingTitle {
	
	NSData *returnData = [@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><error>You must enter a title</error>" dataUsingEncoding:NSUTF8StringEncoding];
	
	simpleParser.tagName = @"added";
	simpleParser.data = returnData;
	
	NSError *error = nil;
	NSArray *results = [simpleParser parseResults:&error];
	
	STAssertTrue(results != nil, @"Parser return value must not be nil.");
	STAssertTrue([results count] == 0, @"Parser return array must be empty.");
}

- (void)testAddNoteSuccess {
	
	NSString *newNoteId = @"3283361";
	
	NSData *returnData = [[NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>		<added>%@</added>", newNoteId] dataUsingEncoding:NSUTF8StringEncoding];
	
	simpleParser.tagName = @"added";
	simpleParser.data = returnData;
	
	NSError *error = nil;
	NSArray *results = [simpleParser parseResults:&error];
	
	STAssertTrue(results != nil, @"Parser return value must not be nil.");
	STAssertTrue(error == nil, @"Parser error object must be nil.");
	STAssertTrue([results count] == 1, @"Parser return array count must be 1.");
	STAssertTrue([[results objectAtIndex:0] isEqualToString:newNoteId], @"New Note id must match refernce id.");
}

@end
