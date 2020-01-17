//
//  BYCommandInfo.m
//  XcodeBasics
//
//  Created by Young, Braden on 10/30/16.
//  Copyright © 2016 Young, Braden. All rights reserved.
//

#import "BYCommandInfo.h"

@interface BYCommandInfo ()
@property (class, readonly) NSDictionary<NSString*, NSNumber*> *nameDictionary;
@property (class, readonly) NSDictionary<NSString*, NSNumber*> *identifierDictionary;
@end

@implementation BYCommandInfo

+ (BYCommand)commandFromIdentifier:(NSString *)identifier {
    BYCommand command = BYCommandNone;
    NSNumber *commandWrapped = self.identifierDictionary[identifier];
    if (commandWrapped != nil) {
        command = commandWrapped.unsignedIntegerValue;
    }
    return command;
}

+ (NSString *)identifierFromCommand:(BYCommand)command {
    __block NSString *commandName = nil;
    [self.identifierDictionary enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSNumber * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.unsignedIntegerValue == command) {
            commandName = key;
            *stop = YES;
        }
    }];
    return commandName;
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

#pragma mark - Private overrides

+ (NSDictionary *)nameDictionary {
    static NSDictionary *nameDictionary;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        nameDictionary = @{NSLocalizedString(@"isEqual", @"isEqual") : @(BYCommandIsEqual),
                           NSLocalizedString(@"NSCopying", @"NSCopying") : @(BYCommandNSCopying),
                           NSLocalizedString(@"Method", @"Method") : @(BYCommandMethod),
                           NSLocalizedString(@"Delete Lines", @"Delete Lines") : @(BYCommandDeleteLines),
                           NSLocalizedString(@"Duplicate Lines", @"Duplicate Lines") : @(BYCommandDuplicateLines)
                           };
    });
    return nameDictionary;
}

+ (NSDictionary *)identifierDictionary {
    static NSMutableDictionary *identifierDictionary;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        identifierDictionary = [[NSMutableDictionary alloc] init];
        [[self nameDictionary] enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSNumber * _Nonnull obj, BOOL * _Nonnull stop) {
            NSString *identifier = [self identifierFromName:key];
            [identifierDictionary setObject:obj forKey:identifier];
        }];
    });
    
    return identifierDictionary;
}

#pragma mark - Helpers

+ (NSString *)identifierFromName:(NSString *)name {
    static NSString * const idPrefix = @"com.young.XcodeBasics";
    
    // If any command keys have spaces, Xcode throws an exception like:
    // Command identifier 'com.young.XcodeBasics.Delete Lines' is not a legal RFC1034 identifier
    NSString *identifier = [name stringByReplacingOccurrencesOfString:@" " withString:@""];
    return [NSString stringWithFormat:@"%@.%@", idPrefix, identifier];
}

@end
