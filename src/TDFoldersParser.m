//
//  TDFoldersParser.m
//  ToodledoAPI
//
//  Created by Alex Leutgöb on 09.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import "TDFoldersParser.h"


@implementation TDFoldersParser

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:@"folder"]) {
		currentFolder = [[GtdFolder alloc] init];
		currentFolder.uid = [[attributeDict valueForKey:@"id"] intValue];
		currentFolder.private = [[attributeDict valueForKey:@"private"] isEqualToString:@"1"] ? YES : NO ;
		currentFolder.archived = [[attributeDict valueForKey:@"archived"] isEqualToString:@"1"] ? YES : NO ;
		currentFolder.order = [[attributeDict valueForKey:@"order"] intValue];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([elementName isEqualToString:@"folder"]) {
		currentFolder.title = currentString;
		[results addObject:currentFolder];
		[currentFolder release];
		currentFolder = nil;
	}
	
	[currentString release];
	currentString = nil;
}

@end
