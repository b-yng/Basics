//
//  BYTextGenerator.h
//  gen
//
//  Created by Young, Braden on 10/7/16.
//  Copyright © 2016 Young, Braden. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BYGenerator.h"
@class BYProperty;

@interface BYObjcGenerator : NSObject <BYGenerator>

@property (nonatomic) NSUInteger tabWidth;

@end
