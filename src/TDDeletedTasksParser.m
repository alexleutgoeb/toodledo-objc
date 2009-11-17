//
//  TDDeletedTasksParser.m
//  ToodledoAPI
//
//  Created by Michael Petritsch on 17.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TDDeletedTasksParser.h"


@implementation TDDeletedTasksParser

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:@"task"]) {
		currentTask = [[GtdTask alloc] init];
		currentTask.taskId = [[attributeDict valueForKey:@"id"] intValue];
		currentTask.date_modified = [[attributeDict valueForKey:@"stamp"] dateValue];

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
