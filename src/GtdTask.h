//
//  GtdTask.h
//  ToodledoAPI
//
//  Created by Alex Leutgöb on 07.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GtdTask : NSObject {

@private
	NSInteger uid;
	NSString *title;
	NSDate *date_created;
	NSDate *date_modified;
	NSDate *date_start;
	NSDate *date_due;
	NSDate *date_deleted;
	NSArray *tags;
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

@property (nonatomic) NSInteger uid;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, retain) NSDate *date_created;
@property (nonatomic, retain) NSDate *date_modified;
@property (nonatomic, retain) NSDate *date_start;
@property (nonatomic, retain) NSDate *date_due;
@property (nonatomic, retain) NSDate *date_deleted;
@property (nonatomic, copy) NSArray *tags;
@property (nonatomic) NSInteger folder;
@property (nonatomic) NSInteger context;
@property (nonatomic) NSInteger priority;
@property (nonatomic, retain) NSDate *completed;
@property (nonatomic) NSInteger length;
@property (nonatomic, copy) NSString *note;
@property BOOL star;
@property NSInteger repeat;
@property NSInteger status;
@property NSInteger reminder;
@property NSInteger parentId;

@end
