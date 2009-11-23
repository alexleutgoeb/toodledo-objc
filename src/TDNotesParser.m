//
//  TDNotesParser.m
//  ToodledoAPI
//
//  Created by BlackandCold on 19.11.09.
//  Copyright 2009 TU Wien. All rights reserved.
//

#import "TDNotesParser.h"
/*
<note>
<id>1234</id>
<folder>123</folder>
<added seconds="1249925490">2009-08-10 12:32:00</added>
<modified seconds="1249955490">2009-08-09 20:51:00</modified>
<title>My Notebook Entry</title>
<text>This is my note</text>
<private>1</private>
</note>
 
 NSInteger uid;
 NSDate *date_created;
 NSDate *date_modified;
 NSString *title;
 NSString *text;
 NSInteger folder;
 BOOL private;
*/

@implementation TDNotesParser
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:@"note"]) {
		currentNote = [[GtdNote alloc] init];
		currentNote.uid = [[attributeDict valueForKey:@"id"] intValue];
		currentNote.private = [[attributeDict valueForKey:@"private"] isEqualToString:@"1"] ? YES : NO ;
		currentNote.folder = [[attributeDict valueForKey:@"folder"] intValue];
		currentNote.date_created = [[attributeDict valueForKey:@"added"] dateValue];
		currentNote.date_modified = [[attributeDict valueForKey:@"modified"] dateValue];
		currentNote.text = [[attributeDict valueForKey:@"text"] stringValue];
		currentNote.title = [[attributeDict valueForKey:@"title"] stringValue];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([elementName isEqualToString:@"note"]) {
		currentNote.title = currentString;
		[results addObject:currentNote];
		[currentNote release];
		currentNote = nil;
	}
	
	[currentString release];
	currentString = nil;
}
@end
