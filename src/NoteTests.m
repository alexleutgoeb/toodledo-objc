//
//  NoteTests.m
//  ToodledoAPI
//
//  Created by Michael Petritsch on 01.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NoteTests.h"


@implementation NoteTests

- (void)setUp {
	api = [[TDApi alloc] init];
}

- (void)tearDown {
	[api release];
	api = nil;
}

- (void)testAddNoteWithoutParams {
	NSError *error = nil;
	[api addNote:nil error:&error];
	STAssertTrue([error code] == GtdApiMissingParameters, @"Note must not be added without arguments.");
}

- (void)testAddNoteWithoutTitle {
	NSError *error = nil;
	note.title = nil;
	NSInteger returnValue = [api addNote:note error:&error];
	STAssertTrue([error code] == GtdApiMissingParameters, @"Note must not be added without note title argument.");
	STAssertTrue(returnValue == -1, @"Return value must be -1.");
}

- (void)testDeleteNoteWithoutParams {
	NSError *error = nil;
	STAssertTrue([api deleteNote:nil error:&error] == NO, @"Return value must be NO.");
	STAssertTrue([error code] == GtdApiMissingParameters, @"Note must not be deleted without arguments.");
}

- (void)testDeleteNoteWithoutUid {
	NSError *error = nil;
	note.uid = -1;
	STAssertTrue([api deleteNote:note error:&error] == NO, @"Return value must be NO.");
	STAssertTrue([error code] == GtdApiMissingParameters, @"Note must not be deleted without uid argument.");
}

- (void)testEditNoteWithoutParams {
	NSError *error = nil;
	STAssertTrue([api editNote:nil error:&error] == NO, @"Return value must be NO.");
	STAssertTrue([error code] == GtdApiMissingParameters, @"Note must not be edited without arguments.");
}

- (void)testEditNoteWithoutUid {
	NSError *error = nil;
	note.uid = -1;
	STAssertTrue([api editNote:note error:&error] == NO, @"Return value must be NO.");
	STAssertTrue([error code] == GtdApiMissingParameters, @"Note must not be edited without uid argument.");
}


@end
