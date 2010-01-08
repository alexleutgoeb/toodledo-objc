//
//  TDUserInfoParser.h
//  ToodledoAPI
//
//  Created by Alex Leutgöb on 24.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TDParser.h"


@interface TDUserInfoParser : TDParser {
@private
	NSMutableDictionary *userInfos;
}

@end
