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
	NSString *title;
	NSArray *tags;
	NSInteger folder;
	NSInteger context;
	NSInteger priority;
	NSInteger parentId;
	NSString *note;
}

@property (nonatomic, copy) NSString *title;
@property (retain) NSArray *tags;
@property (nonatomic) NSInteger folder;
@property (nonatomic) NSInteger context;
@property (nonatomic) NSInteger priority;
@property (nonatomic) NSInteger parentId;
@property (nonatomic, copy) NSString *note;

@end
