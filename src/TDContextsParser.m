//
//  TDContextsParser.m
//  ToodledoAPI
//
//  Created by Alex Leutgöb on 09.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import "TDContextsParser.h"


@implementation TDContextsParser
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:@"context"]) {
		currentContext = [[GtdContext alloc] init];
		currentContext.uid = [[attributeDict valueForKey:@"id"] intValue];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([elementName isEqualToString:@"context"]) {
		currentContext.title = currentString;
		[results addObject:currentContext];
		[currentContext release];
		currentContext = nil;
	}
	
	[currentString release];
	currentString = nil;
}
@end
