//
//  TDSimpleParser.h
//  ToodledoAPI
//
//  Created by Alex Leutgöb on 10.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TDParser.h"


@interface TDSimpleParser : TDParser {
@private
	NSString *tagName;
}

@property (nonatomic, copy) NSString *tagName;

@end
