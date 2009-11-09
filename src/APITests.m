//
//  APITests.m
//  ToodledoAPI
//
//  Created by Alex Leutgöb on 09.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//


#import <SenTestingKit/SenTestingKit.h>

@interface APITests :SenTestCase

- (void)testTemplate;

@end

@implementation APITests

-(void)testTemplate {	
	int value1 = 1;
	int value2 = 1; //change this value to see what happens when the 
	STAssertTrue(value1 == value2, @"Value1 != Value2. Expected %i, got %i", value1, value2);
}

@end
