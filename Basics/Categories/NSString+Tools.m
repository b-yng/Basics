//
//  NSString+Tools.m
//  gen
//
//  Created by Young, Braden on 10/6/16.
//  Copyright © 2016 Young, Braden. All rights reserved.
//

#import "NSString+Tools.h"

@implementation NSString (Tools)

- (NSString *)repeat:(NSUInteger)times {
    return [@"" stringByPaddingToLength:times * self.length withString:self startingAtIndex:0];
}

@end
