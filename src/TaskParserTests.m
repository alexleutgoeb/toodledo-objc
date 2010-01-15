//
//  TaskParserTest.h
//  ToodledoAPI
//
//  Created by Michael Petritsch on 01.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "TDApi.h"
#import "GtdTask.h"
#import "TDSimpleParser.h"
#import "TDTasksParser.h"


@interface TaskParserTests :SenTestCase {
	TDSimpleParser *simpleParser;
	TDTasksParser *tParser;
}

- (void)testAddTaskWithInvalidKey;
- (void)testAddTaskWithMissingTitle;
- (void)testAddTaskSuccess;

@end


@implementation TaskParserTests

- (void)setUp {
	simpleParser = [[TDSimpleParser alloc] init];
	tParser = [[TDTasksParser alloc] init];
}

- (void)tearDown {
	[tParser release];
	tParser = nil;
	[simpleParser release];
	simpleParser = nil;
}

- (void)testAddTaskWithInvalidKey {
	
	NSData *returnData = [@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><error>key did not validate</error>" dataUsingEncoding:NSUTF8StringEncoding];
	
	simpleParser.tagName = @"added";
	simpleParser.data = returnData;
	
	NSError *error = nil;
	NSArray *results = [simpleParser parseResults:&error];
	
	STAssertTrue(results != nil, @"Parser return value must not be nil.");
	STAssertTrue([results count] == 0, @"Parser return array must be empty.");
}

- (void)testAddTaskWithMissingTitle {
	
	NSData *returnData = [@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><error>You must enter a title</error>" dataUsingEncoding:NSUTF8StringEncoding];
	
	simpleParser.tagName = @"added";
	simpleParser.data = returnData;
	
	NSError *error = nil;
	NSArray *results = [simpleParser parseResults:&error];
	
	STAssertTrue(results != nil, @"Parser return value must not be nil.");
	STAssertTrue([results count] == 0, @"Parser return array must be empty.");
}

- (void)testAddTaskSuccess {
	
	NSString *newTaskId = @"3283361";
	
	NSData *returnData = [[NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>		<added>%@</added>", newTaskId] dataUsingEncoding:NSUTF8StringEncoding];
	
	simpleParser.tagName = @"added";
	simpleParser.data = returnData;
	
	NSError *error = nil;
	NSArray *results = [simpleParser parseResults:&error];
	
	STAssertTrue(results != nil, @"Parser return value must not be nil.");
	STAssertTrue(error == nil, @"Parser error object must be nil.");
	STAssertTrue([results count] == 1, @"Parser return array count must be 1.");
	STAssertTrue([[results objectAtIndex:0] isEqualToString:newTaskId], @"New task id must match refernce id.");
}

- (void)testGetTasks {
	NSData *returnData = [@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><tasks num=\"7\" total=\"7\" start=\"0\" end=\"1000\">	<task>	<id>62577521</id>		<children>0</children>	<title>Add some items to your todo list</title>	<tag></tag>	<folder>0</folder>	<context id=\"0\"></context>	<goal id=\"0\"></goal>	<added>2010-01-12</added>	<modified>2010-01-14 12:02:00</modified>	<startdate></startdate>	<duetime>1:33pm</duetime><duedate modifier=\"\">2010-01-12</duedate>		<starttime></starttime>	<reminder>0</reminder>	<completed>2010-01-14</completed>	<repeat>0</repeat>	<rep_advanced></rep_advanced>	<status>0</status>	<star>0</star>	<priority>1</priority>	<length>10</length>	<timer onfor=\"0\">0</timer>	<note></note>	</task>		<task>	<id>62577523</id>		<children>0</children>	<title>Visit your Account Settings section and configure your account.</title>	<tag></tag>	<folder>0</folder>	<context id=\"0\"></context>	<goal id=\"0\"></goal>	<added>2010-01-12</added>	<modified>2010-01-14 12:01:59</modified>	<startdate></startdate>	<duedate modifier=\"\">2010-01-12</duedate>	<duetime></duetime>	<starttime></starttime>	<reminder>0</reminder>	<completed>2010-01-14</completed>	<repeat>0</repeat>	<rep_advanced></rep_advanced>	<status>0</status>	<star>0</star>	<priority>2</priority>	<length>5</length>	<timer onfor=\"0\">0</timer>	<note></note>	</task>		<task>	<id>63644545</id>		<children>0</children>	<title>testtask</title>	<tag></tag>	<folder>0</folder>	<context id=\"0\"></context>	<goal id=\"0\"></goal>	<added>2010-01-15</added>	<modified>2010-01-15 11:15:00</modified>	<startdate></startdate>	<duedate modifier=\"\"></duedate>	<duetime></duetime>	<starttime></starttime>	<reminder>0</reminder>	<completed></completed>	<repeat>0</repeat>	<rep_advanced></rep_advanced>	<status>0</status>	<star>0</star>	<priority>0</priority>	<length>0</length>	<timer onfor=\"0\">0</timer>	<note></note>	</task>		<task>	<id>63644627</id>		<children>0</children>	<title>test2</title>	<tag></tag>	<folder>0</folder>	<context id=\"0\"></context>	<goal id=\"0\"></goal>	<added>2010-01-15</added>	<modified>2010-01-15 11:15:26</modified>	<startdate></startdate>	<duedate modifier=\"\"></duedate>	<duetime></duetime>	<starttime></starttime>	<reminder>0</reminder>	<completed></completed>	<repeat>0</repeat>	<rep_advanced></rep_advanced>	<status>0</status>	<star>0</star>	<priority>0</priority>	<length>0</length>	<timer onfor=\"0\">0</timer>	<note></note>	</task>		<task>	<id>63644629</id>		<children>0</children>	<title>test</title>	<tag></tag>	<folder>0</folder>	<context id=\"0\"></context>	<goal id=\"0\"></goal>	<added>2010-01-15</added>	<modified>2010-01-15 11:15:26</modified>	<startdate></startdate>	<duedate modifier=\"\"></duedate>	<duetime></duetime>	<starttime></starttime>	<reminder>0</reminder>	<completed></completed>	<repeat>0</repeat>	<rep_advanced></rep_advanced>	<status>0</status>	<star>0</star>	<priority>0</priority>	<length>0</length>	<timer onfor=\"0\">0</timer>	<note></note>	</task>		<task>	<id>63644631</id>		<children>0</children>	<title>dada</title>	<tag></tag>	<folder>0</folder>	<context id=\"0\"></context>	<goal id=\"0\"></goal>	<added>2010-01-15</added>	<modified>2010-01-15 11:15:26</modified>	<startdate></startdate>	<duedate modifier=\"\"></duedate>	<duetime></duetime>	<starttime></starttime>	<reminder>0</reminder>	<completed></completed>	<repeat>0</repeat>	<rep_advanced></rep_advanced>	<status>0</status>	<star>0</star>	<priority>0</priority>	<length>0</length>	<timer onfor=\"0\">0</timer>	<note></note>	</task>		<task>	<id>63645093</id>		<children>0</children>	<title>test1</title>	<tag></tag>	<folder>3712555</folder>	<context id=\"0\"></context>	<goal id=\"0\"></goal>	<added>2010-01-15</added>	<modified>2010-01-15 11:17:16</modified>	<startdate></startdate>	<duedate modifier=\"\">2010-01-21</duedate>	<duetime></duetime>	<starttime></starttime>	<reminder>0</reminder>	<completed></completed>	<repeat>0</repeat>	<rep_advanced></rep_advanced>	<status>0</status>	<star>0</star>	<priority>1</priority>	<length>0</length>	<timer onfor=\"0\">0</timer>	<note>dsdsds</note>	</task>	</tasks>" dataUsingEncoding:NSUTF8StringEncoding];
	
	tParser.data = returnData;
	
	NSError *error = nil;
	NSArray *results = [tParser parseResults:&error];
	
	STAssertTrue(results != nil, @"Parser return value must not be nil.");
	STAssertTrue(error == nil, @"Parser error object must be nil.");
	STAssertTrue([results count] == 7, @"Parser return array count must be 7.");
	STAssertTrue([@"2010-01-12 13:33:00 +0100" isEqualToString:[[[results objectAtIndex:0] date_due] description]], @"Wrong date: %@", [[[results objectAtIndex:0] date_due] description]);

}

@end
