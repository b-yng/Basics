//
//  SourceEditorCommand.m
//  Basics
//
//  Created by Young, Braden on 10/26/16.
//  Copyright © 2016 Young, Braden. All rights reserved.
//

#import "SourceEditorCommand.h"

#import <AppKit/AppKit.h>
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
    
    // get command
    NSString *commandName = [invocation.commandIdentifier pathExtension];
    
    if (buffer.selections.count == 0) {
        completionHandler([self errorNoSelection]);
        return;
    }
    
    // TODO: cleanup for scale
    if ([commandName isEqualToString:BYCommandDeleteLines]) {
        
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
        return;
    }
    
    // get selection
    XCSourceTextRange *selection = buffer.selections.firstObject;

    
    BYSourceInfo *sourceInfo = [[BYSourceInfo alloc] init];
    sourceInfo.contentUTI = buffer.contentUTI;
    
    // check destination language
    if (sourceInfo.sourceLanguage == BYSourceLanguageUnsupported) {
        completionHandler(nil);
        return;
    }
    
    // get content from pasteboard
    NSString *copiedContent = [[NSPasteboard generalPasteboard] stringForType:NSPasteboardTypeString];
    if (copiedContent == nil || copiedContent.length == 0) {
        completionHandler([self errorNoCopiedContent]);
        return;
    }
    
    // parse properties
    NSMutableArray<BYProperty*> *properties = [[NSMutableArray alloc] init];
    
    [copiedContent enumerateLinesUsingBlock:^(NSString * _Nonnull line, BOOL * _Nonnull stop) {
        BYProperty *property;
        
        if (sourceInfo.sourceLanguage == BYSourceLanguageObjc) {
            property = [BYProperty propertyFromObjcLine:line];
        }
        else if (sourceInfo.sourceLanguage == BYSourceLanguageSwift) {
            // TODO: swift
        }
        
        if (property != nil) {
            [properties addObject:property];
        }
    }];
    
    id<BYGenerator> textGenerator;
    
    if (sourceInfo.sourceLanguage == BYSourceLanguageObjc) {
        BYObjcGenerator *objcGenerator = [[BYObjcGenerator alloc] init];
        objcGenerator.tabWidth = buffer.tabWidth;
        textGenerator = objcGenerator;
    }
    else if (sourceInfo.sourceLanguage == BYSourceLanguageSwift) {
        // TODO: swift
    }
    
    NSMutableArray<NSString*> *lines = nil;
    
    
    if ([commandName isEqualToString:BYCommandIsEquals]) {
        lines = [textGenerator generateIsEquals:properties];
        [lines addObject:@"\n"];
        [lines addObjectsFromArray:[textGenerator generateHash:properties]];
    }
    else if ([commandName isEqualToString:BYCommandNSCopying]) {
        
        // get class name
        NSScanner *scanner = [NSScanner scannerWithString:buffer.completeBuffer];
        BOOL foundImplementation = [scanner scanUpToString:@"@implementation" intoString:nil];
        if (!foundImplementation) {
            completionHandler([self errorClassNameNotFound]);
            return;
        }
        
        [scanner scanString:@"@implementation" intoString:nil];
        
        NSString *className;
        BOOL foundClassName = [scanner scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet] intoString:&className];
        if (!foundClassName) {
            completionHandler([self errorClassNameNotFound]);
            return;
        }
        
        lines = [textGenerator generateCopyWithZone:properties className:className];
    }
    
    if (lines == nil) {
        completionHandler([self errorCommandFailed]);
        return;
    }
    
    // insert lines into buffer
    NSInteger offset = selection.end.line;
    for (NSInteger i = 0; i < lines.count; i++) {
        [buffer.lines insertObject:[lines objectAtIndex:i] atIndex:offset + i];
    }
    
    completionHandler(nil);
}

#pragma mark - Errors

- (NSError *)errorUnsupportedLanguage {
    return [self errorWithCode:1 message:NSLocalizedString(@"Unsupported destination language", @"Unsupported destination language")];
}

- (NSError *)errorNoSelection {
    return [self errorWithCode:1 message:NSLocalizedString(@"No selection", @"No selection")];
}

- (NSError *)errorNoCopiedContent {
    return [self errorWithCode:2 message:NSLocalizedString(@"No copied content", @"No copied content")];
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

- (NSString *)indentWithWidth:(NSUInteger)width {
    return [@"" stringByPaddingToLength:width withString:@" " startingAtIndex:0];
}

@end
