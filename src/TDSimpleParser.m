//
//  TDSimpleParser.m
//  ToodledoAPI
//
//  Created by Alex Leutgöb on 10.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import "TDSimpleParser.h"


@implementation TDSimpleParser

@synthesize tagName;

- (void)dealloc {
	[tagName release];
    [super dealloc];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if (tagName != nil && [elementName isEqualToString:tagName]) {
		[results addObject:currentString];
	}
	
	[currentString release];
	currentString = nil;
}

@end
