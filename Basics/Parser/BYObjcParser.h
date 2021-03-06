//
//  BYObjcParser.h
//  XcodeBasics
//
//  Created by Young, Braden on 10/30/16.
//  Copyright © 2016 Young, Braden. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BYMethod.h"
#import "BYProperty.h"

@interface BYObjcParser : NSObject

+ (NSArray<BYProperty*> *)parsePropertiesFromText:(NSString *)text;

+ (NSArray<BYMethod*> *)parseMethodsFromText:(NSString *)text;

@end
