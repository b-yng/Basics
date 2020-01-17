//
//  BYCommandInfo.h
//  XcodeBasics
//
//  Created by Young, Braden on 10/30/16.
//  Copyright © 2016 Young, Braden. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, BYCommand) {
    BYCommandNone,
    BYCommandIsEqual,
    BYCommandNSCopying,
    BYCommandDeleteLines,
    BYCommandDuplicateLines,
    BYCommandMethod
};

@interface BYCommandInfo : NSObject

+ (BYCommand)commandFromIdentifier:(NSString *)identifier;

+ (NSString *)identifierFromCommand:(BYCommand)command;

+ (NSString *)nameFromCommand:(BYCommand)command;

@end
