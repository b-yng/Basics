//
//  BYCommandInfo.h
//  XcodeBasics
//
//  Created by Young, Braden on 10/30/16.
//  Copyright © 2016 Young, Braden. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, BYCommand) {
    BYCommandUnknown,
    BYCommandIsEquals,
    BYCommandNSCopying,
    BYCommandDeleteLines,
    BYCommandMethodSignature
};

@interface BYCommandInfo : NSObject

+ (BYCommand)commandFromName:(NSString *)name;

+ (NSString *)nameFromCommand:(BYCommand)command;

@end
