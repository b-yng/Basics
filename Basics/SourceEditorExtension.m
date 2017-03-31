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
    return @[[self definitionForCommand:BYCommandIsEqual],
             [self definitionForCommand:BYCommandNSCopying],
             [self definitionForCommand:BYCommandMethod],
             [self definitionForCommand:BYCommandDeleteLines]];
}

#pragma mark - Helpers

- (NSDictionary<XCSourceEditorCommandDefinitionKey, id> *)definitionForCommand:(BYCommand)command {
    return @{ XCSourceEditorCommandClassNameKey : @"SourceEditorCommand",
              XCSourceEditorCommandIdentifierKey : [BYCommandInfo identifierFromCommand:command],
              XCSourceEditorCommandNameKey : [BYCommandInfo nameFromCommand:command] };
}

@end

