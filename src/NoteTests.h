//
//  NoteTests.h
//  ToodledoAPI
//
//  Created by Michael Petritsch on 01.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "GtdApi.h"
#import "TDApi.h"

@interface NoteTests :SenTestCase {
	TDApi *api;
	GtdNote *note;
}

/**
 Add a note without params.
 This should not work since there is at least a title param required.
 */
- (void)testAddNoteWithoutParams;

/**
 Try to add a note with params but without a title param.
 This should not work since title is the only param that is actually required.
 */
- (void)testAddNoteWithoutTitle;

/**
 Delete a note without params.
 */
- (void)testDeleteNoteWithoutParams;

/**
 Delete a note without the required param uid.
 */
- (void)testDeleteNoteWithoutUid;

/**
 Edit a note without params.
 */
- (void)testEditNoteWithoutParams;

/**
 Edit a note without uid param.
 */
- (void)testEditNoteWithoutUid;


@end
