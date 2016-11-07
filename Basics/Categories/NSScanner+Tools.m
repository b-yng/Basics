//
//  NSScanner+Tools.m
//  XcodeBasics
//
//  Created by Young, Braden on 11/6/16.
//  Copyright © 2016 Young, Braden. All rights reserved.
//

#import "NSScanner+Tools.h"

@implementation NSScanner (Tools)

- (void)scanLine {
    [self scanLine:nil];
}

- (void)scanLine:(NSString **)intoString {
    static NSString *const newLineString = @"\n";
    [self scanUpToString:newLineString intoString:intoString];
    [self scanString:newLineString intoString:nil];
}

@end
