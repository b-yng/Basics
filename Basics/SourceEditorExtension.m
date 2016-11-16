//
//  SourceEditorExtension.m
//  Basics
//
//  Created by Young, Braden on 10/26/16.
//  Copyright © 2016 Young, Braden. All rights reserved.
//

#import "SourceEditorExtension.h"
@import AppKit;
#import "BYCommandInfo.h"

static NSString * const BYCommandIdPrefix = @"com.young.XcodeBasics";

@implementation SourceEditorExtension

#pragma mark - XCSourceEditorExtension

- (NSArray <NSDictionary <XCSourceEditorCommandDefinitionKey, id> *> *)commandDefinitions {
    return @[[self definitionForCommand:BYCommandIsEquals],
             [self definitionForCommand:BYCommandNSCopying],
             [self definitionForCommand:BYCommandMethodSignature],
             [self definitionForCommand:BYCommandDeleteLines]];
}

#pragma mark - Helpers

- (NSDictionary<XCSourceEditorCommandDefinitionKey, id> *)definitionForCommand:(BYCommand)command {
    NSString *name = [BYCommandInfo nameFromCommand:command];
    return [self definitionWithName:name key:name];
}

- (NSDictionary<XCSourceEditorCommandDefinitionKey, id> *)definitionWithName:(NSString *)name key:(NSString *)key {
    return @{ XCSourceEditorCommandClassNameKey : @"SourceEditorCommand",
              XCSourceEditorCommandIdentifierKey : [NSString stringWithFormat:@"%@.%@", BYCommandIdPrefix, key],
              XCSourceEditorCommandNameKey : name };
}

@end

