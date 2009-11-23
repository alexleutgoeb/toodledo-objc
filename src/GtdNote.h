//
//  GtdNote.h
//  ToodledoAPI
//
//  Created by Alex Leutgöb on 09.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GtdNote : NSObject 
{

@private
	NSInteger uid;
	NSDate *date_created;
	NSDate *date_modified;
	NSString *title;
	NSString *text;
	NSInteger folder;
	BOOL private;
	
}

@property (nonatomic) NSInteger uid;
@property (nonatomic) NSInteger folder;
@property (nonatomic, retain) NSDate *date_created;
@property (nonatomic, retain) NSDate *date_modified;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *text;
@property (nonatomic) BOOL private;

@end
