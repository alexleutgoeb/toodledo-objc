//
//  TaskTests.m
//  ToodledoAPI
//
//  Created by Michael Petritsch on 22.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


#import "TaskTests.h"


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

- (void)testAddTaskWithoutTitle {
	NSError *error = nil;
	task.title = nil;
	NSInteger returnValue = [api addTask:task error:&error];
	STAssertTrue([error code] == GtdApiMissingParameters, @"Task must not be added without task title argument.");
	STAssertTrue(returnValue == -1, @"Return value must be -1.");
}

- (void)testDeleteTaskWithoutParams {
	NSError *error = nil;
	STAssertTrue([api deleteTask:nil error:&error] == NO, @"Return value must be NO.");
	STAssertTrue([error code] == GtdApiMissingParameters, @"Task must not be deleted without arguments.");
}

- (void)testDeleteTaskWithoutUid {
	NSError *error = nil;
	task.uid = -1;
	STAssertTrue([api deleteTask:task error:&error] == NO, @"Return value must be NO.");
	STAssertTrue([error code] == GtdApiMissingParameters, @"Task must not be deleted without uid argument.");
}

- (void)testEditTaskWithoutParams {
	NSError *error = nil;
	STAssertTrue([api editTask:nil error:&error] == NO, @"Return value must be NO.");
	STAssertTrue([error code] == GtdApiMissingParameters, @"Task must not be edited without arguments.");
}

- (void)testEditTaskWithoutUid {
	NSError *error = nil;
	task.uid = -1;
	STAssertTrue([api editTask:task error:&error] == NO, @"Return value must be NO.");
	STAssertTrue([error code] == GtdApiMissingParameters, @"Task must not be edited without uid argument.");
}

@end
