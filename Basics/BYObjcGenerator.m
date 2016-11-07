//
//  BYTextGenerator.m
//  gen
//
//  Created by Young, Braden on 10/7/16.
//  Copyright © 2016 Young, Braden. All rights reserved.
//

#import "BYObjcGenerator.h"
#import "NSString+Tools.h"

#define IND(_text, _indent) [self indent:(_text) by:(_indent)]

@interface BYObjcGenerator ()
@property (nonatomic) NSString *indent;
@end

@implementation BYObjcGenerator

- (instancetype)initWithTabWidth:(NSInteger)tabWidth {
    self = [super init];
    if (!self) return nil;
    
    self.tabWidth = tabWidth;
    
    return self;
}

#pragma mark - Public

- (NSMutableArray<NSString*> *)generateIsEquals:(NSArray<BYProperty*> *)properties {
    __block NSMutableArray *lines = [[NSMutableArray alloc] init];
    
    [lines addObject:@"- (BOOL)isEqual:(id)object {"];
    [lines addObject:IND(@"if (object == nil)", 1)];
    [lines addObject:IND(@"return NO;", 2)];
    [lines addObject:IND(@"if (self == object)", 1)];
    [lines addObject:IND(@"return YES;", 2)];
    [lines addObject:IND(@"if (![object isKindOfClass:[self class]])", 1)];
    [lines addObject:IND(@"return NO;", 2)];
    [lines addObject:@"\n"];
    
    [properties enumerateObjectsUsingBlock:^(BYProperty * _Nonnull property, NSUInteger idx, BOOL * _Nonnull stop) {
        // ignore readonly properties
        if (property.readonly) {
            return;
        }
        
        NSMutableString *lineText = [[NSMutableString alloc] init];
        if (idx == 0) {
            [lineText appendString:IND(@"return ", 1)];
        }
        else {
            [lineText appendString:[self.indent repeat:2]];
        }
        
        NSString *name = property.name;
        if (property.type.primitive) {
            [lineText appendString:[NSString stringWithFormat:@"_%@ == [object %@]", name, name]];
        }
        else {
            [lineText appendString:[NSString stringWithFormat:@"(_%@ == [object %@] || [_%@ isEqual:[object %@]])", name, name, name, name]];
        }
        
        if (idx == properties.count - 1) {
            [lineText appendString:@";"];
        }
        else {
            [lineText appendString:@" &&"];
        }
        
        [lines addObject:lineText];
    }];
    
    [lines addObject:@"}"];
    
    return lines;
}

- (NSMutableArray<NSString*> *)generateHash:(NSArray<BYProperty*> *)properties {
    NSMutableArray *lines = [[NSMutableArray alloc] init];
    
    [lines addObject:@"- (NSUInteger)hash {"];
    
    [properties enumerateObjectsUsingBlock:^(BYProperty * _Nonnull property, NSUInteger idx, BOOL * _Nonnull stop) {
        // ignore readonly properties
        if (property.readonly) {
            return;
        }
        
        NSMutableString *lineText = [[NSMutableString alloc] init];
        if (idx == 0) {
            [lineText appendString:IND(@"return ", 1)];
        }
        else {
            [lineText appendString:[self.indent repeat:2]];
        }
        
        NSString *name = property.name;
        if (property.type.primitive) {
            // wrap primitives in NSNumber for hash method
            [lineText appendString:[NSString stringWithFormat:@"@(_%@).hash", name]];
        }
        else {
            [lineText appendString:[NSString stringWithFormat:@"_%@.hash", name]];
        }
        
        if (idx == properties.count - 1) {
            [lineText appendString:@";"];
        }
        else {
            [lineText appendString:@" ^"];
        }
        
        [lines addObject:lineText];
    }];
    
    [lines addObject:@"}"];
    
    return lines;
}

- (NSMutableArray<NSString*> *)generateCopyWithZone:(NSArray<BYProperty*> *)properties className:(NSString *)className {
    __block NSMutableArray *lines = [[NSMutableArray alloc] init];
    
    [lines addObject:@"#pragma mark - NSCopying"];
    [lines addObject:@"\n"];
    [lines addObject:@"- (id)copyWithZone:(NSZone *)zone {"];
    
    NSString *initLine = [NSString stringWithFormat:@"%@ *clone = [[%@ alloc] init];", className, className];
    [lines addObject:IND(initLine, 1)];
    
    [properties enumerateObjectsUsingBlock:^(BYProperty * _Nonnull property, NSUInteger idx, BOOL * _Nonnull stop) {
        // ignore readonly properties
        // TODO: don't do this
        if (property.readonly) {
            return;
        }
        
        NSString *name = property.name;
        
        if (property.type.primitive) {
            NSString *copyLine = [NSString stringWithFormat:@"clone.%@ = _%@;", name, name];
            [lines addObject:IND(copyLine, 1)];
        }
        else {
            Class typeClass = property.type.typeClass;
            
            // deep copy collections
            if (typeClass != nil && typeClass == [NSArray class]) {
                [lines addObject:[self indent:[NSString stringWithFormat:@"if (_%@ != nil)", name] by:1]];
                
                NSString *copyLine = [NSString stringWithFormat:@"clone.%@ = [[NSArray alloc] initWithArray:_%@ copyItems:YES];", name, name];
                [lines addObject:IND(copyLine, 2)];
            }
            else if (typeClass != nil && typeClass == [NSSet class]) {
                [lines addObject:[self indent:[NSString stringWithFormat:@"if (_%@ != nil)", name] by:1]];
                
                NSString *copyLine = [NSString stringWithFormat:@"clone.%@ = [[NSSet alloc] initWithSet:_%@ copyItems:YES];", name, name];
                [lines addObject:IND(copyLine, 2)];
            }
            else if (typeClass != nil && typeClass == [NSDictionary class]) {
                [lines addObject:[self indent:[NSString stringWithFormat:@"if (_%@ != nil)", name] by:1]];
                
                NSString *copyLine = [NSString stringWithFormat:@"clone.%@ = [[NSDictionary alloc] initWithDictionary:_%@ copyItems:YES];", name, name];
                [lines addObject:IND(copyLine, 2)];
            }
            else {
                NSString *copyLine = [NSString stringWithFormat:@"clone.%@ = _%@.copy;", name, name];
                [lines addObject:IND(copyLine, 1)];
            }
        }
    }];
    
    [lines addObject:IND(@"return clone;", 1)];
    [lines addObject:@"}"];
    
    return lines;
}

- (NSMutableArray<NSString*> *)generateMethodSignatures:(NSArray<BYMethod*> *)methods {
    __block NSMutableArray *lines = [[NSMutableArray alloc] init];
    
    [methods enumerateObjectsUsingBlock:^(BYMethod * _Nonnull method, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *closedSignature = [NSString stringWithFormat:@"%@;", method.signature];
        [lines addObject:closedSignature];
        
        if (idx < methods.count - 1) {
            [lines addObject:@"\n"];
        }
    }];

    return lines;
}

#pragma mark - Public setters

- (void)setTabWidth:(NSInteger)tabWidth {
    _tabWidth = tabWidth;
    self.indent = [@" " repeat:tabWidth];
}

#pragma mark - Helpers

- (NSString *)indent:(NSString *)text by:(NSInteger)tabs {
    return [NSString stringWithFormat:@"%@%@", [self.indent repeat:tabs], text];
}

@end
