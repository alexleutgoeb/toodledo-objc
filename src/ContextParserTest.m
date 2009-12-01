//
//  ContextParserTest.h
//  ToodledoAPI
//
//  Created by Michael Petritsch on 01.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "TDApi.h"
#import "GtdContext.h"
#import "TDSimpleParser.h"
#import "TDContextsParser.h"


@interface ContextParserTest :SenTestCase {
	TDSimpleParser *simpleParser;
	TDContextsParser *cParser;
}

- (void)testAddContextWithInvalidKey;
- (void)testAddContextWithMissingTitle;
- (void)testAddContextSuccess;

@end


@implementation ContextParserTest

- (void)setUp {
	simpleParser = [[TDSimpleParser alloc] init];
	cParser = [[TDContextsParser alloc] init];
}

- (void)tearDown {
	[cParser release];
	cParser = nil;
	[simpleParser release];
	simpleParser = nil;
}

- (void)testAddContextWithInvalidKey {
	
	NSData *returnData = [@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><error>key did not validate</error>" dataUsingEncoding:NSUTF8StringEncoding];
	
	simpleParser.tagName = @"added";
	simpleParser.data = returnData;
	
	NSError *error = nil;
	NSArray *results = [simpleParser parseResults:&error];
	
	STAssertTrue(results != nil, @"Parser return value must not be nil.");
	STAssertTrue([results count] == 0, @"Parser return array must be empty.");
}

- (void)testAddContextWithMissingTitle {
	
	NSData *returnData = [@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><error>You must enter a title</error>" dataUsingEncoding:NSUTF8StringEncoding];
	
	simpleParser.tagName = @"added";
	simpleParser.data = returnData;
	
	NSError *error = nil;
	NSArray *results = [simpleParser parseResults:&error];
	
	STAssertTrue(results != nil, @"Parser return value must not be nil.");
	STAssertTrue([results count] == 0, @"Parser return array must be empty.");
}

- (void)testAddContextSuccess {
	
	NSString *newContextId = @"3283361";
	
	NSData *returnData = [[NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>		<added>%@</added>", newContextId] dataUsingEncoding:NSUTF8StringEncoding];
	
	simpleParser.tagName = @"added";
	simpleParser.data = returnData;
	
	NSError *error = nil;
	NSArray *results = [simpleParser parseResults:&error];
	
	STAssertTrue(results != nil, @"Parser return value must not be nil.");
	STAssertTrue(error == nil, @"Parser error object must be nil.");
	STAssertTrue([results count] == 1, @"Parser return array count must be 1.");
	STAssertTrue([[results objectAtIndex:0] isEqualToString:newContextId], @"New Context id must match refernce id.");
}

@end