//
//  APITests.m
//  ToodledoAPI
//
//  Created by Alex Leutgöb on 09.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//


#import <SenTestingKit/SenTestingKit.h>
#import "TDApi.h"

@interface APITests :SenTestCase

- (void)testStaticIdentifier;

@end

@implementation APITests

// Tests if the class method identifier is implemented
-(void)testStaticIdentifier {	
	STAssertTrue([[TDApi identifier] isEqualToString:@"syncservice.toodledo-objc"], @"Class identifier should be syncservice.toodledo-objc.");
}

@end
