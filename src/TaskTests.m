//
//  TaskTests.m
//  ToodledoAPI
//
//  Created by Michael Petritsch on 22.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "GtdApi.h"
#import "TDApi.h"

@interface TaskTests :SenTestCase {
	TDApi *api;
}

- (void)testAddTaskWithoutParams;

@end

@implementation TaskTests

- (void)setUp {
	api = [[TDApi alloc] init];
}

- (void)tearDown {
	[api release];
	api = nil;
}

- (void)testAddTaskWithoutParams {
	NSError *error = nil;
	[api addTask:nil error:&error];
	STAssertTrue([error code] == GtdApiMissingParameters, @"Task must not be added without arguments.");
}

@end
