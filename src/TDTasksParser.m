//
//  TDTasksParser.m
//  ToodledoAPI
//
//  Created by Michael Petritsch on 17.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TDTasksParser.h"
#import "TDApiConstants.h"


@interface TDTasksParser ()

@property (nonatomic, copy) NSString *startTime;
@property (nonatomic, copy) NSString *startDate;
@property (nonatomic, copy) NSString *dueTime;
@property (nonatomic, copy) NSString *dueDate;

@end


@implementation TDTasksParser

@synthesize startTime, startDate, dueDate, dueTime;

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	[super parserDidStartDocument:parser];
	dateTime24Formatter = [[NSDateFormatter alloc] init];
	[dateTime24Formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd"];
	dateTime12Formatter = [[NSDateFormatter alloc] init];
	[dateTime12Formatter setDateFormat:@"yyyy-MM-dd hh:mma"];
	[dateTime12Formatter setAMSymbol:@"am"];
	[dateTime12Formatter setPMSymbol:@"pm"];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
	qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	
	if ([elementName isEqualToString:@"task"]) {		
		currentTask = [[GtdTask alloc] init];
		currentTask.hasDueDate = NO;
		currentTask.hasDueTime = NO;
	}
	
	else if ([elementName isEqualToString:@"context"]) {
		currentTask.context = [[attributeDict valueForKey:@"id"] intValue];
	}

}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI 
	qualifiedName:(NSString *)qName {
	if ([elementName isEqualToString:@"task"]) {
		[results addObject:currentTask];
		[currentTask release];
		currentTask = nil;
		self.startDate = nil;
		self.startTime = nil;
		self.dueDate = nil;
		self.dueTime = nil;
	}
	
	else if ([elementName isEqualToString:@"id"]) {
		currentTask.uid = [currentString intValue];
	}
	else if ([elementName isEqualToString:@"parent"]) {
		currentTask.parentId = [currentString intValue];
	}
	else if ([elementName isEqualToString:@"title"]) {
		currentTask.title = currentString;
	}
	else if ([elementName isEqualToString:@"tag"]) {
		currentTask.tags = [currentString componentsSeparatedByString:kTagSeparator];
	}
	else if ([elementName isEqualToString:@"folder"]) {
		currentTask.folder = [currentString intValue];
	}
	else if ([elementName isEqualToString:@"added"]) {
		currentTask.date_created = [dateFormatter dateFromString:currentString];
	}
	else if ([elementName isEqualToString:@"modified"]) {
		currentTask.date_modified = [dateTime24Formatter dateFromString:currentString];
	}
	else if ([elementName isEqualToString:@"reminder"]) {
		currentTask.reminder = [currentString intValue];
	}
	else if ([elementName isEqualToString:@"completed"]) {
		if ([currentString length] > 1) {
			currentTask.completed = [dateFormatter dateFromString:currentString];
		}
	}
	else if ([elementName isEqualToString:@"repeat"]) {
		currentTask.repeat = [currentString intValue];
	}
	else if ([elementName isEqualToString:@"status"]) {
		currentTask.status = [currentString intValue];
	}
	else if ([elementName isEqualToString:@"star"]) {
		currentTask.star = [currentString boolValue];
	}
	else if ([elementName isEqualToString:@"priority"]) {
		currentTask.priority = [currentString intValue];
	}
	else if ([elementName isEqualToString:@"length"]) {
		currentTask.length = [currentString intValue];
	}
	else if ([elementName isEqualToString:@"note"]) {
		currentTask.note = currentString;
	}
	
	else if ([elementName isEqualToString:@"startdate"]) {		
		self.startDate = (currentString == nil) ? @"" : currentString;
		if (startTime != nil && [startDate length] > 0) {
			if ([startTime length] == 0)
				currentTask.date_start = [dateFormatter dateFromString:startDate];
			else
				currentTask.date_start = [dateTime12Formatter dateFromString:[NSString stringWithFormat:@"%@ %@", startDate, startTime]];
		}
	}
	else if ([elementName isEqualToString:@"starttime"]) {
		self.startTime = (currentString == nil) ? @"" : currentString;
		if (startDate != nil && [startTime length] > 0) {
			currentTask.date_start = [dateTime12Formatter dateFromString:[NSString stringWithFormat:@"%@ %@", startDate, startTime]];
		}
		else if (startDate != nil) {
			currentTask.date_start = [dateFormatter dateFromString:startDate];
		}
	}
	else if ([elementName isEqualToString:@"duedate"]) {		
		self.dueDate = (currentString == nil) ? @"" : currentString;
		if (dueTime != nil && [dueDate length] > 0) {
			currentTask.hasDueDate = YES;
			if ([dueTime length] == 0)
			{	
				currentTask.hasDueTime = NO;
				currentTask.date_due = [dateFormatter dateFromString:dueDate];
			}
			else
			{
				currentTask.hasDueTime = YES;
				currentTask.date_due = [dateTime12Formatter dateFromString:[NSString stringWithFormat:@"%@ %@", dueDate, dueTime]];
			}
		}
		else
			currentTask.hasDueDate = NO;
	}
	else if ([elementName isEqualToString:@"duetime"]) {
		self.dueTime = (currentString == nil) ? @"" : currentString;
		if (dueDate != nil && [dueTime length] > 0) {
			currentTask.hasDueTime = YES;
			currentTask.hasDueDate = YES;
			currentTask.date_due = [dateTime12Formatter dateFromString:[NSString stringWithFormat:@"%@ %@", dueDate, dueTime]];
		}
		else if (dueDate != nil) {
			currentTask.hasDueTime = NO;
			currentTask.hasDueDate = YES;
			currentTask.date_due = [dateFormatter dateFromString:dueDate];
		}
	}
	
	[currentString release];
	currentString = nil;
}

- (void)dealloc {
	[startTime release];
	[startDate release];
	[dueTime release];
	[dueDate release];
	[dateTime24Formatter release];
	[dateFormatter release];
	[dateTime12Formatter release];
	[super dealloc];
}

@end
