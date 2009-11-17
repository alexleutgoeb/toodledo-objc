//
//  GtdTask.h
//  ToodledoAPI
//
//  Created by Alex Leutgöb on 07.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GtdTask : NSObject {

@private
	NSInteger taskId;
	NSString *title;
	NSDate *date_created;
	NSDate *date_modified;
	NSDate *date_start;
	NSDate *date_due;
	NSString *tag;
	NSInteger folder;
	NSInteger context;
	NSInteger priority;
	NSDate *completed;
	NSInteger length;
	NSString *note;
	BOOL star;
	NSInteger repeat;
	NSInteger status;
	NSInteger reminder;
	NSInteger parentId;
}

@property (nonatomic) NSInteger taskId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, retain) NSDate *date_created;
@property (nonatomic, retain) NSDate *date_modified;
@property (nonatomic, retain) NSDate *date_start;
@property (nonatomic, retain) NSDate *date_due;
@property (nonatomic, copy) NSString *tag;
@property (nonatomic) NSInteger folder;
@property (nonatomic) NSInteger context;
@property (nonatomic) NSInteger priority;
@property (nonatomic, retain) NSDate *completed;
@property (nonatomic) NSInteger length;
@property (nonatomic, copy) NSString *note;
@property BOOL star;
@property (nonatomic) NSInteger repeat;
@property (nonatomic) NSInteger status;
@property (nonatomic) NSInteger reminder;
@property (nonatomic) NSInteger parentId;

@end
