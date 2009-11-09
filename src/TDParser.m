//
//  TDParser.m
//  ToodledoAPI
//
//  Created by Alex Leutgöb on 03.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import "TDParser.h"


@implementation TDParser

@synthesize data;

- (id)initWithTarget:(id)theTarget andSelector:(SEL)theSelector {
	[super init];
	target = theTarget;
	selector = theSelector;
	return self;
}

- (id)initWithData:(NSData *)aData {
	if (self = [super init]) {
		self.data = aData;
	}
	return self;
}

- (void)dealloc {
	[data release];
	[error release];
	[results release];
	[currentString release];
    [super dealloc];
}

- (NSMutableArray *)parseResults:(NSError **)parseError {
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];	
	[parser setDelegate:self];
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	[parser parse];
	[parser release];
	
	if (error) {
		*parseError = error;
		return nil;
	}
	else {
		return results;
	}
}

#pragma mark -
#pragma mark NSXMLParser delegation methods

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	if (results != nil) {
		[results release];
		results = nil;
	}
	results = [[NSMutableArray alloc] init];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {	
	string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if (!currentString) {
		currentString = [[NSMutableString alloc] initWithString:string];
	} else {
		[currentString appendString:string];
	}
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	error = [parseError retain];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	// id result = error ? (id)error : (id)results;
	// [target performSelectorOnMainThread:selector withObject:result waitUntilDone:YES];
}

@end
