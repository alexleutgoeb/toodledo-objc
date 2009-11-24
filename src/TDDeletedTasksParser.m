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
	
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
	[inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
	if ([elementName isEqualToString:@"task"]) {
		currentTask = [[GtdTask alloc] init];
		currentTask.uid = [[attributeDict valueForKey:@"id"] intValue];
		[inputFormatter dateFromString:[attributeDict valueForKey:@"stamp"]];

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
