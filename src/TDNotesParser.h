//
//  TDNotesParser.h
//  ToodledoAPI
//
//  Created by BlackandCold on 19.11.09.
//  Copyright 2009 TU Wien. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TDParser.h"
#import "GtdNote.h"



@interface TDNotesParser : TDParser {
	GtdNote *currentNote;
}

@end
