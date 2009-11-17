//
//  TDTasksParser.h
//  ToodledoAPI
//
//  Created by Michael Petritsch on 17.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TDParser.h"
#import "GtdTask.h"


@interface TDTasksParser : TDParser {
@private
	GtdTask *currentTask;
}

@end
