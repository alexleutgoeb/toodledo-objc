//
//  TDUserInfoParser.m
//  ToodledoAPI
//
//  Created by Alex Leutgöb on 24.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import "TDUserInfoParser.h"


@implementation TDUserInfoParser

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:@"account"]) {
		userInfos = [[NSMutableDictionary alloc] init];
		[results addObject:userInfos];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([elementName isEqualToString:@"account"]) {
		[results addObject:userInfos];
		[userInfos release];
		userInfos = nil;
	}
	else if ([elementName isEqualToString:@"userid"] || [elementName isEqualToString:@"alias"] || 
			 [elementName isEqualToString:@"pro"] || [elementName isEqualToString:@"dateformat"] || 
			 [elementName isEqualToString:@"timezone"] || [elementName isEqualToString:@"hidemonths"] || 
			 [elementName isEqualToString:@"hotlistpriority"] || [elementName isEqualToString:@"hotlistduedate"] || 
			 [elementName isEqualToString:@"lastaddedit"] || [elementName isEqualToString:@"lastdelete"] || 
			 [elementName isEqualToString:@"lastfolderedit"] || [elementName isEqualToString:@"lastcontextedit"] || 
			 [elementName isEqualToString:@"lastgoaledit"]) {
		[userInfos setValue:currentString forKey:elementName];
	}
	[currentString release];
	currentString = nil;
}

@end
