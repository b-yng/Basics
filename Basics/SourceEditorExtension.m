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
             [self definitionForCommand:BYCommandDeleteLines],
             [self definitionForCommand:BYCommandMethodSignature]];
}

#pragma mark - Helpers

- (NSDictionary<XCSourceEditorCommandDefinitionKey, id> *)definitionForCommand:(BYCommand)command {
    NSString *name = [BYCommandInfo nameFromCommand:command];
    return @{ XCSourceEditorCommandClassNameKey : @"SourceEditorCommand",
              XCSourceEditorCommandIdentifierKey : [NSString stringWithFormat:@"%@.%@", BYCommandIdPrefix, name],
              XCSourceEditorCommandNameKey : name };
}

@end

