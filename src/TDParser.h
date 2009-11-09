//
//  TDParser.h
//  ToodledoAPI
//
//  Created by Alex Leutgöb on 03.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TDParser : NSObject <NSXMLParserDelegate> {
	NSMutableArray *results;
	NSMutableString *currentString;
@private
	id target;
	SEL selector;
	NSError *error;
	NSData *data;
}

- (id)initWithTarget:(id)theTarget andSelector:(SEL)theSelector;
- (id)initWithData:(NSData *)aData;
- (NSMutableArray *)parseResults:(NSError **)parseError;


@property (nonatomic, retain) NSData *data;

@end
