//
//  TDDeletedTasksParser.m
//  ToodledoAPI
//
//  Created by Michael Petritsch on 17.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TDDeletedTasksParser.h"


@implementation TDDeletedTasksParser

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	[super parserDidStartDocument:parser];
	dateTime24Formatter = [[NSDateFormatter alloc] init];
	[dateTime24Formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
	[inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
	if ([elementName isEqualToString:@"task"]) {
		currentTask = [[GtdTask alloc] init];
	}
	
	
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([elementName isEqualToString:@"task"]) {
		[results addObject:currentTask];
		[currentTask release];
		currentTask = nil;
	}
	else if ([elementName isEqualToString:@"id"]) {
		currentTask.uid = [currentString intValue];
	}
	else if ([elementName isEqualToString:@"stamp"]) {
		currentTask.date_deleted = [dateTime24Formatter dateFromString:currentString];
	}
	
	[currentString release];
	currentString = nil;
}


@end
