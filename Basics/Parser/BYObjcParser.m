//
//  BYObjcParser.m
//  XcodeBasics
//
//  Created by Young, Braden on 10/30/16.
//  Copyright © 2016 Young, Braden. All rights reserved.
//

#import "BYObjcParser.h"
#import "NSScanner+Tools.h"

@implementation BYObjcParser

+ (NSArray<BYProperty*> *)parsePropertiesFromText:(NSString *)text {
    NSMutableArray<BYProperty*> *properties = [[NSMutableArray alloc] init];
    if (text == nil || text.length == 0) {
        return properties;
    }
    
    [text enumerateLinesUsingBlock:^(NSString * _Nonnull line, BOOL * _Nonnull stop) {
        BYProperty *property = [self parsePropertyFromLine:line];
        if (property != nil) {
            [properties addObject:property];
        }
    }];
    
    return properties;
}

+ (NSArray<BYMethod*> *)parseMethodsFromText:(NSString *)text {
    NSMutableArray<BYMethod*> *methods = [[NSMutableArray alloc] init];
    
    NSScanner *scanner = [[NSScanner alloc] initWithString:text];
    NSScanner *signatureScanner = [[NSScanner alloc] initWithString:text];
    
    if (scanner == nil || scanner.isAtEnd) return methods;
    
    while (!scanner.isAtEnd) {
        
        BOOL isInstanceMethod = [scanner scanString:@"-" intoString:nil];
        BOOL isClassMethod = NO;
        if (!isInstanceMethod) {
            isClassMethod = [scanner scanString:@"+" intoString:nil];
            if (!isClassMethod) {
                [scanner scanLine];
                signatureScanner.scanLocation = scanner.scanLocation;
                continue;
            }
        }
        
        BOOL isMethodStartSyntax = [scanner scanString:@"(" intoString:nil];
        if (!isMethodStartSyntax) {
            [scanner scanLine];
            signatureScanner.scanLocation = scanner.scanLocation;
            continue;
        }
        
        // get return type
        NSString *returnTypeText = nil;
        BOOL foundReturnType = [scanner scanUpToString:@")" intoString:&returnTypeText];
        if (!foundReturnType) {
            [scanner scanLine];
            signatureScanner.scanLocation = scanner.scanLocation;
            continue;
        }
        
        BYType *returnType = [self parseTypeFromScanner:[[NSScanner alloc] initWithString:returnTypeText]];
        if (returnType == nil) {
            [scanner scanLine];
            signatureScanner.scanLocation = scanner.scanLocation;
            continue;
        };
        
        // get signature
        static NSCharacterSet *signatureCloseSet = nil;
        if (signatureCloseSet == nil) {
            signatureCloseSet = [NSCharacterSet characterSetWithCharactersInString:@"{;"];
        }
        
        NSString *signature = nil;
        
        BOOL foundSignature = [signatureScanner scanUpToCharactersFromSet:signatureCloseSet intoString:&signature];
        if (!foundSignature) {
            [scanner scanLine];
            signatureScanner.scanLocation = scanner.scanLocation;
            continue;
        }
        
        // cleanup signature
        signature = [signature stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        BYMethod *method = [[BYMethod alloc] init];
        method.signature = signature;
        method.returnType = returnType;
        method.isClassMethod = isClassMethod;
        [methods addObject:method];
        
        // flush remaining line & keep signature scanner location in sync with scanner location
        [scanner scanLine];
        signatureScanner.scanLocation = scanner.scanLocation;
    }
    
    return methods;
}

#pragma mark - Helpers


+ (BYProperty *)parsePropertyFromLine:(NSString *)line {
    if (line == nil || line.length == 0) return nil;
    
    NSScanner *scanner = [[NSScanner alloc] initWithString:line];
    BOOL isProperty = [scanner scanString:@"@property" intoString:nil];
    if (!isProperty) return nil;
    
    // parse attributes
    BOOL readonly = NO;
    BOOL hasAttributes = [scanner scanString:@"(" intoString:nil];
    if (hasAttributes) {
        NSString *attributes = nil;
        BOOL foundAttributes = [scanner scanUpToString:@")" intoString:&attributes];
        if (!foundAttributes) return nil;
        
        readonly = [attributes containsString:@"readonly"];
        
        [scanner scanString:@")" intoString:nil];
    }
    
    // parse property type
    BYType *type = [self parseTypeFromScanner:scanner];
    if (type == nil) return nil;
    
    // parse property name
    NSString *propertyName = nil;
    BOOL foundName = [scanner scanUpToString:@";" intoString:&propertyName];
    if (!foundName) return nil;
    
    BYProperty *property = [[BYProperty alloc] init];
    property.name = propertyName;
    property.readonly = readonly;
    property.type = type;
    
    return property;
}

+ (BYType *)parseTypeFromScanner:(NSScanner *)scanner {
    // get type name
    NSString *typeName = nil;
    BOOL foundType = [scanner scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet] intoString:&typeName];
    if (!foundType) return nil;
    
    // get class for foundation classes
    Class typeClass = NSClassFromString(typeName);
    
    BYType *type = [[BYType alloc] init];
    type.name = typeName;
    type.typeClass = typeClass;
    
    // parse generics
    BOOL hasGeneric = [scanner scanString:@"<" intoString:nil];
    if (hasGeneric) {
        NSString *generics = nil;
        BOOL foundGenerics = [scanner scanUpToString:@">" intoString:&generics];
        if (!foundGenerics) return nil;
        
        [scanner scanString:@">" intoString:nil];
        
        // recursively get type
        type.generic = [self parseTypeFromScanner:[[NSScanner alloc] initWithString:generics]];
    }
    
    BOOL isPointer = [scanner scanString:@"*" intoString:nil];
    type.pointer = isPointer;
    
    return type;
}

@end
