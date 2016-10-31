//
//  SourceEditorCommand.m
//  Basics
//
//  Created by Young, Braden on 10/26/16.
//  Copyright © 2016 Young, Braden. All rights reserved.
//

#import "SourceEditorCommand.h"

#import <AppKit/AppKit.h>
#import "BYCommandInfo.h"
#import "BYGenerator.h"
#import "BYProperty.h"
#import "BYObjcGenerator.h"
#import "BYSourceInfo.h"
#import "NSString+Tools.h"
#import "SourceEditorExtension.h"

static NSString *const GenErrorDomain = @"com.young.XcodeBasics";

@interface SourceEditorCommand ()
@end

@implementation SourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler {
    XCSourceTextBuffer *buffer = invocation.buffer;
    if (buffer.lines.count == 0) {
        completionHandler(nil);
        return;
    }
    
    if (buffer.selections.count == 0) {
        completionHandler([self errorNoSelection]);
        return;
    }
    
    // get command
    NSString *commandName = [invocation.commandIdentifier pathExtension];
    BYCommand command = [BYCommandInfo commandFromName:commandName];
    
    switch (command) {
        case BYCommandDeleteLines:
            [self handleDeleteCommand:buffer completion:completionHandler];
            break;
        case BYCommandIsEquals:
            [self handleIsEqualsCommand:buffer completion:completionHandler];
            break;
        case BYCommandNSCopying:
            [self handleNSCopyingCommand:buffer completion:completionHandler];
            break;
        case BYCommandInterface:
            break;
    }
}

#pragma mark - Command Handlers

- (void)handleDeleteCommand:(XCSourceTextBuffer *)buffer completion:(void (^)(NSError *nilOrError))completionHandler {
    // delete selection
    for (XCSourceTextRange *selection in buffer.selections) {
        NSInteger startLine = selection.start.line;
        NSRange deleteRange = NSMakeRange(startLine, MIN(selection.end.line + 1 - startLine, buffer.lines.count - startLine));
        [buffer.lines removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:deleteRange]];
    }
    
    // clear selection
    XCSourceTextRange *firstSelection = buffer.selections.firstObject;
    firstSelection.start = XCSourceTextPositionMake(firstSelection.start.line, 0);
    firstSelection.end = firstSelection.start;
    [buffer.selections removeAllObjects];
    [buffer.selections addObject:firstSelection];
    
    completionHandler(nil);
}

- (void)handleIsEqualsCommand:(XCSourceTextBuffer *)buffer completion:(void (^)(NSError *nilOrError))completionHandler {
    // get source info
    BYSourceInfo *sourceInfo = [[BYSourceInfo alloc] initWithContentUTI:buffer.contentUTI];
    if (sourceInfo.sourceLanguage == BYSourceLanguageUnsupported) {
        completionHandler([self errorUnsupportedLanguage]);
        return;
    }
    
    // get content from pasteboard
    NSString *copiedContent = [self contentFromPasteboard];
    
    // parse properties
    NSArray<BYProperty*> *properties = [self propertiesFromText:copiedContent];
    
    // generate text from properties
    id<BYGenerator> textGenerator = [self textGeneratorForSourceLanguage:sourceInfo.sourceLanguage tabWidth:buffer.tabWidth];
    
    NSMutableArray<NSString*> *lines = [textGenerator generateIsEquals:properties];
    [lines addObject:@"\n"];
    [lines addObjectsFromArray:[textGenerator generateHash:properties]];
    
    // insert lines into buffer
    [self insertLinesIntoBuffer:buffer lines:lines];
    
    completionHandler(nil);
}

- (void)handleNSCopyingCommand:(XCSourceTextBuffer *)buffer completion:(void (^)(NSError *nilOrError))completionHandler {
    // get source info
    BYSourceInfo *sourceInfo = [[BYSourceInfo alloc] initWithContentUTI:buffer.contentUTI];
    if (sourceInfo.sourceLanguage == BYSourceLanguageUnsupported) {
        completionHandler([self errorUnsupportedLanguage]);
        return;
    }
    
    // get content from pasteboard
    NSString *copiedContent = [self contentFromPasteboard];
    
    // parse properties
    NSArray<BYProperty*> *properties = [self propertiesFromText:copiedContent];
    
    // generate text from properties
    id<BYGenerator> textGenerator = [self textGeneratorForSourceLanguage:sourceInfo.sourceLanguage tabWidth:buffer.tabWidth];
    
    // get class name
    NSString *className = [self classNameFromText:buffer.completeBuffer sourceLanguage:sourceInfo.sourceLanguage];
    if (className == nil) {
        completionHandler([self errorClassNameNotFound]);
        return;
    }
    
    // generate text from properties and class name
    NSMutableArray<NSString*> *lines = [textGenerator generateCopyWithZone:properties className:className];
    
    // insert lines into buffer
    [self insertLinesIntoBuffer:buffer lines:lines];
    
    completionHandler(nil);
}

#pragma mark - Helpers

- (NSArray<BYProperty*> *)propertiesFromText:(NSString *)text {
    NSMutableArray<BYProperty*> *properties = [[NSMutableArray alloc] init];
    
    if (text == nil || text.length == 0) {
        return properties;
    }
    
    [text enumerateLinesUsingBlock:^(NSString * _Nonnull line, BOOL * _Nonnull stop) {
        BYProperty *property = [BYProperty propertyFromObjcLine:line];
        if (property != nil) {
            [properties addObject:property];
        }
    }];
    
    return properties;
}

- (NSString *)classNameFromText:(NSString *)text sourceLanguage:(BYSourceLanguage)sourceLanguage {
    if (text == nil || text.length == 0) {
        return nil;
    }
    
    NSString *className = nil;
    
    if (sourceLanguage == BYSourceLanguageObjc) {
        NSScanner *scanner = [NSScanner scannerWithString:text];
        BOOL foundImplementation = [scanner scanUpToString:@"@implementation" intoString:nil];
        if (!foundImplementation) {
            return nil;
        }
        
        [scanner scanString:@"@implementation" intoString:nil];
        
        BOOL foundClassName = [scanner scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet] intoString:&className];
        if (!foundClassName) {
            return nil;
        }
    }
    else if (sourceLanguage == BYSourceLanguageSwift) {
        
    }
    
    return className;
}

- (NSString *)contentFromPasteboard {
    return [[NSPasteboard generalPasteboard] stringForType:NSPasteboardTypeString];
}

- (id<BYGenerator>)textGeneratorForSourceLanguage:(BYSourceLanguage)sourceLanguage tabWidth:(NSInteger)tabWidth {
    id<BYGenerator> textGenerator = nil;
    if (sourceLanguage == BYSourceLanguageObjc) {
        textGenerator = [[BYObjcGenerator alloc] initWithTabWidth:tabWidth];
    }
    else if (sourceLanguage == BYSourceLanguageSwift) {
        
    }
    return textGenerator;
}

- (void)insertLinesIntoBuffer:(XCSourceTextBuffer *)buffer lines:(NSArray<NSString*> *)lines {
    NSInteger offset = buffer.selections.firstObject.end.line;
    for (NSInteger i = 0; i < lines.count; i++) {
        [buffer.lines insertObject:[lines objectAtIndex:i] atIndex:offset + i];
    }
}

#pragma mark - Errors

- (NSError *)errorUnsupportedLanguage {
    return [self errorWithCode:1 message:NSLocalizedString(@"Unsupported destination language", @"Unsupported destination language")];
}

- (NSError *)errorNoSelection {
    return [self errorWithCode:2 message:NSLocalizedString(@"No selection", @"No selection")];
}

- (NSError *)errorCommandFailed {
    return [self errorWithCode:3 message:NSLocalizedString(@"Command failed", @"Command failed")];
}

- (NSError *)errorClassNameNotFound {
    return [self errorWithCode:4 message:NSLocalizedString(@"Class name not found", @"Class name not found")];
}

- (NSError *)errorWithCode:(NSInteger)code message:(NSString *)message {
    return [[NSError alloc] initWithDomain:GenErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey : message}];
}

@end
