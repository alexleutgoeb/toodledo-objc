//
//  GtdContext.h
//  ToodledoAPI
//
//  Created by Alex Leutgöb on 09.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GtdContext : NSObject {
	
@private
	NSInteger contextId;
	NSString *title;
}

@property (nonatomic) NSInteger contextId;
@property (nonatomic, copy) NSString *title;

@end
