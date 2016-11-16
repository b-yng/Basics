//
//  BYTextGenerator.h
//  gen
//
//  Created by Young, Braden on 10/7/16.
//  Copyright © 2016 Young, Braden. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BYGenerator.h"
#import "BYProperty.h"
#import "BYMethod.h"

@interface BYObjcGenerator : NSObject <BYGenerator>

@property (nonatomic) NSInteger tabWidth;

- (instancetype)initWithTabWidth:(NSInteger)tabWidth;

- (NSMutableArray<NSString*> *)generateMethodBoilerplate:(NSArray<BYMethod*> *)methods;

@end
