//
//  ContextTests.h
//  ToodledoAPI
//
//  Created by Michael Petritsch on 01.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "GtdApi.h"
#import "TDApi.h"


@interface ContextTests : SenTestCase {
	TDApi *api;
	GtdContext *context;
}

/**
 Add a context without params.
 This should not work since there is at least a title param required.
 */
- (void)testAddContextWithoutParams;

/**
 Try to add a context with params but without a title param.
 This should not work since title is the only param that is actually required.
 */
- (void)testAddContextWithoutTitle;

/**
 Delete a context without params.
 */
- (void)testDeleteContextWithoutParams;

/**
 Delete a context without the required param uid.
 */
- (void)testDeleteContextWithoutUid;

/**
 Edit a context without params.
 */
- (void)testEditContextWithoutParams;

/**
 Edit a context without uid param.
 */
- (void)testEditContextWithoutUid;

@end
