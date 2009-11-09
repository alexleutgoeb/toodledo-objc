//
//  TDAuthenticationParser.m
//  ToodledoAPI
//
//  Created by Alex Leutgöb on 08.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import "TDAuthenticationParser.h"


@implementation TDAuthenticationParser

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([elementName isEqualToString:@"token"]) {
		[results addObject:currentString];
	}
	
	[currentString release];
	currentString = nil;
}

@end
