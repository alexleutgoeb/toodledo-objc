//
//  GtdContext.h
//  ToodledoAPI
//
//  Created by Alex Leutgöb on 09.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GtdContext : NSObject {
	
@private
	NSInteger id;
	NSString *title;
}

@property (nonatomic) NSInteger id;
@property (nonatomic, copy) NSString *title;

@end
