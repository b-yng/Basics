//
//  BYCommandInfo.m
//  XcodeBasics
//
//  Created by Young, Braden on 10/30/16.
//  Copyright © 2016 Young, Braden. All rights reserved.
//

#import "BYCommandInfo.h"

static NSString * const BYCommandNameIsEquals = @"isEquals";
static NSString * const BYCommandNameNSCopying = @"NSCopying";
static NSString * const BYCommandNameDeleteLines = @"Delete Lines";
static NSString * const BYCommandNameInterface = @"Interface";

@interface BYCommandInfo ()
@property (class, readonly) NSDictionary<NSString*, NSNumber*> *nameDictionary;
@end

@implementation BYCommandInfo

+ (BYCommand)commandFromName:(NSString *)name {
    BYCommand command = BYCommandUnknown;
    NSNumber *commandWrapped = self.nameDictionary[name];
    if (commandWrapped != nil) {
        command = commandWrapped.unsignedIntegerValue;
    }
    return command;
}

+ (NSString *)nameFromCommand:(BYCommand)command {
    __block NSString *commandName = nil;
    [self.nameDictionary enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSNumber * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.unsignedIntegerValue == command) {
            commandName = key;
            *stop = YES;
        }
    }];
    return commandName;
}

+ (NSDictionary *)nameDictionary {
    static NSDictionary *nameDictionary;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        nameDictionary = @{NSLocalizedString(@"isEquals", @"isEquals") : @(BYCommandIsEquals),
                           NSLocalizedString(@"NSCopying", @"NSCopying") : @(BYCommandNSCopying),
                           NSLocalizedString(@"Delete Lines", @"Delete Lines") : @(BYCommandDeleteLines),
                           NSLocalizedString(@"Interface", @"Interface") : @(BYCommandInterface)};
    });
    return nameDictionary;
}

@end
