//
//  TDFoldersParser.h
//  ToodledoAPI
//
//  Created by Alex Leutgöb on 09.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TDParser.h"
#import "GtdFolder.h"


@interface TDFoldersParser : TDParser {
@private
	GtdFolder *currentFolder;
}

@end
