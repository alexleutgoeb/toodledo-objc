//
//  GtdFolder.h
//  ToodledoAPI
//
//  Created by Alex Leutgöb on 09.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GtdFolder : NSObject {
@private
	NSInteger uid;
	NSString *title;
	BOOL private;
	BOOL archived;
	NSInteger order;
}

@property NSInteger uid;
@property (nonatomic, copy) NSString *title;
@property (getter=isPrivate) BOOL private;
@property (getter=isArchived) BOOL archived;
@property NSInteger order;

@end
