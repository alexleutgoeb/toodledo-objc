//
//  TDTasksParser.m
//  ToodledoAPI
//
//  Created by Michael Petritsch on 17.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TDTasksParser.h"


@implementation TDTasksParser

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
	[inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
	if ([elementName isEqualToString:@"task"]) {
		currentTask = [[GtdTask alloc] init];
		currentTask.uid = [[attributeDict valueForKey:@"id"] intValue];
		currentTask.title = [[attributeDict valueForKey:@"title"] stringValue];
		currentTask.date_created = [inputFormatter dateFromString:[attributeDict valueForKey:@"added"]];
		currentTask.date_modified = [inputFormatter dateFromString:[attributeDict valueForKey:@"modified"]];
		currentTask.date_start = [inputFormatter dateFromString:[attributeDict valueForKey:@"startdate"]];
		currentTask.date_due = [inputFormatter dateFromString:[attributeDict valueForKey:@"duedate"]];
		currentTask.tag = [[attributeDict valueForKey:@"tag"] stringValue];
		currentTask.folder = [[attributeDict valueForKey:@"folder"] intValue];
		currentTask.context = [[attributeDict valueForKey:@"context"] intValue];
		currentTask.priority = [[attributeDict valueForKey:@"priority"] intValue];
		currentTask.completed = [inputFormatter dateFromString:[attributeDict valueForKey:@"completed"]];
		currentTask.length = [[attributeDict valueForKey:@"length"] intValue];
		currentTask.note = [[attributeDict valueForKey:@"note"] stringValue];
		currentTask.star = [[attributeDict valueForKey:@"star"] isEqualToString:@"1"] ? YES : NO ;
		currentTask.repeat = [[attributeDict valueForKey:@"repeat"] intValue];
		//currentTask.rep_advanced = 
		currentTask.status = [[attributeDict valueForKey:@"status"] intValue];
		currentTask.reminder = [[attributeDict valueForKey:@"reminder"] intValue];
		currentTask.parentId = [[attributeDict valueForKey:@"parent"] intValue];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([elementName isEqualToString:@"task"]) {
		currentTask.title = currentString;
		[results addObject:currentTask];
		[currentTask release];
		currentTask = nil;
	}
	
	[currentString release];
	currentString = nil;
}

@end
