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
#import "BYObjcGenerator.h"
#import "BYObjcParser.h"
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
    BYCommand command = [BYCommandInfo commandFromIdentifier:invocation.commandIdentifier];
    
    switch (command) {
        case BYCommandDeleteLines:
            [self handleDeleteLinesCommand:buffer completion:completionHandler];
            break;
        case BYCommandIsEqual:
            [self handleIsEqualsCommand:buffer completion:completionHandler];
            break;
        case BYCommandNSCopying:
            [self handleNSCopyingCommand:buffer completion:completionHandler];
            break;
        case BYCommandMethod:
            [self handleMethodSignatureCommand:buffer completion:completionHandler];
            break;
        case BYCommandNone:
            completionHandler(nil);
            break;
    }
}

#pragma mark - Command Handlers

- (void)handleDeleteLinesCommand:(XCSourceTextBuffer *)buffer completion:(void (^)(NSError *nilOrError))completionHandler {
    XCSourceTextPosition finalSelection = XCSourceTextPositionMake(buffer.selections.firstObject.start.line, 0);
    
    // delete selection
    for (XCSourceTextRange *selection in buffer.selections) {
        NSInteger startLine = selection.start.line;
        NSInteger length = selection.end.line - startLine;
        if (selection.end.column > 0) { // if selection is the entire line, end.line is the next line & column is 0. Handle this case
            length++;
        }
        length = MAX(length, 1);    // if selection is just the cursor at the begininning of the line, selection.start == selection.end. We still want length=1
        length = MIN(length, buffer.lines.count - startLine);
        NSRange deleteRange = NSMakeRange(startLine, length);
        [buffer.lines removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:deleteRange]];
    }
    
    // clear selection
    XCSourceTextRange *textRange = [[XCSourceTextRange alloc] initWithStart:finalSelection end:finalSelection];
    [buffer.selections removeAllObjects];
    [buffer.selections addObject:textRange];
    
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
    NSArray<BYProperty*> *properties = [BYObjcParser parsePropertiesFromText:copiedContent];
    
    // get class name
    NSString *className = [self classNameFromText:buffer.completeBuffer sourceLanguage:sourceInfo.sourceLanguage];
    if (className == nil) {
        completionHandler([self errorClassNameNotFound]);
        return;
    }
    
    // generate text from properties
    id<BYGenerator> textGenerator = [self textGeneratorForSourceLanguage:sourceInfo.sourceLanguage tabWidth:buffer.tabWidth];
    
    NSMutableArray<NSString*> *lines = [textGenerator generateIsEqual:properties className:className];
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
    NSArray<BYProperty*> *properties = [BYObjcParser parsePropertiesFromText:copiedContent];
    
    // get class name
    NSString *className = [self classNameFromText:buffer.completeBuffer sourceLanguage:sourceInfo.sourceLanguage];
    if (className == nil) {
        completionHandler([self errorClassNameNotFound]);
        return;
    }
    
    // generate text from properties and class name
    id<BYGenerator> textGenerator = [self textGeneratorForSourceLanguage:sourceInfo.sourceLanguage tabWidth:buffer.tabWidth];
    NSArray<NSString*> *lines = [textGenerator generateCopyWithZone:properties className:className];
    
    // insert lines into buffer
    [self insertLinesIntoBuffer:buffer lines:lines];
    
    completionHandler(nil);
}

- (void)handleMethodSignatureCommand:(XCSourceTextBuffer *)buffer completion:(void (^)(NSError *nilOrError))completionHandler {
    // get source info
    BYSourceInfo *sourceInfo = [[BYSourceInfo alloc] initWithContentUTI:buffer.contentUTI];
    if (sourceInfo.sourceLanguage == BYSourceLanguageUnsupported ||
        sourceInfo.sourceLanguage == BYSourceLanguageSwift) {
        completionHandler([self errorUnsupportedLanguage]);
        return;
    }
    
    // get content from pasteboard
    NSString *copiedContent = [self contentFromPasteboard];
    
    // parse methods
    NSArray<BYMethod*> *methods = [BYObjcParser parseMethodsFromText:copiedContent];
    
    // generate text from methods
    BYObjcGenerator *textGenerator = [self textGeneratorForSourceLanguage:sourceInfo.sourceLanguage tabWidth:buffer.tabWidth];
    NSArray<NSString*> *lines;
    
    if (sourceInfo.fileType == BYSourceFileTypeHeader) {
        lines = [textGenerator generateMethodSignatures:methods];
    }
    else {
        lines = [textGenerator generateMethodBoilerplate:methods];
    }
    
    // insert lines into buffer
    [self insertLinesIntoBuffer:buffer lines:lines];
    
    completionHandler(nil);
}

#pragma mark - Helpers

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
