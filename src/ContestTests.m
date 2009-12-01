//
//  ContextTests.m
//  ToodledoAPI
//
//  Created by Michael Petritsch on 01.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ContextTests.h"


@implementation ContextTests

- (void)setUp {
	api = [[TDApi alloc] init];
}

- (void)tearDown {
	[api release];
	api = nil;
}

- (void)testAddContextWithoutParams {
	NSError *error = nil;
	[api addContext:nil error:&error];
	STAssertTrue([error code] == GtdApiMissingParameters, @"Context must not be added without arguments.");
}

- (void)testAddContextWithoutTitle {
	NSError *error = nil;
	context.title = nil;
	NSInteger returnValue = [api addContext:context error:&error];
	STAssertTrue([error code] == GtdApiMissingParameters, @"Context must not be added without context title argument.");
	STAssertTrue(returnValue == -1, @"Return value must be -1.");
}

- (void)testDeleteContextWithoutParams {
	NSError *error = nil;
	STAssertTrue([api deleteContext:nil error:&error] == NO, @"Return value must be NO.");
	STAssertTrue([error code] == GtdApiMissingParameters, @"Context must not be deleted without arguments.");
}

- (void)testDeleteContextWithoutUid {
	NSError *error = nil;
	context.uid = -1;
	STAssertTrue([api deleteContext:context error:&error] == NO, @"Return value must be NO.");
	STAssertTrue([error code] == GtdApiMissingParameters, @"Context must not be deleted without uid argument.");
}

- (void)testEditContextWithoutParams {
	NSError *error = nil;
	STAssertTrue([api editContext:nil error:&error] == NO, @"Return value must be NO.");
	STAssertTrue([error code] == GtdApiMissingParameters, @"Context must not be edited without arguments.");
}

- (void)testEditContextWithoutUid {
	NSError *error = nil;
	context.uid = -1;
	STAssertTrue([api editContext:context error:&error] == NO, @"Return value must be NO.");
	STAssertTrue([error code] == GtdApiMissingParameters, @"Context must not be edited without uid argument.");
}

@end
