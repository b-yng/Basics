//
//  NSScanner+Tools.h
//  XcodeBasics
//
//  Created by Young, Braden on 11/6/16.
//  Copyright © 2016 Young, Braden. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSScanner (Tools)

- (void)scanLine;
- (void)scanLine:(NSString **)intoString;

@end
