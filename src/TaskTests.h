//
//  TaskTests.h
//  ToodledoAPI
//
//  Created by Michael Petritsch on 01.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "GtdApi.h"
#import "TDApi.h"

@interface TaskTests :SenTestCase {
	TDApi *api;
	GtdTask *task;
}

/**
 Add a task without params.
 This should not work since there is at least a title param required.
 */
- (void)testAddTaskWithoutParams;

/**
 Try to add a task with params but without a title param.
 This should not work since title is the only param that is actually required.
 */
- (void)testAddTaskWithoutTitle;

/**
 Delete a task without params.
 */
- (void)testDeleteTaskWithoutParams;

/**
 Delete a task without the required param uid.
 */
- (void)testDeleteTaskWithoutUid;

/**
 Edit a task without params.
 */
- (void)testEditTaskWithoutParams;

/**
 Edit a task without uid param.
 */
- (void)testEditTaskWithoutUid;

@end
