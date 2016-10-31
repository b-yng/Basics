//
//  BYObjcParser.m
//  XcodeBasics
//
//  Created by Young, Braden on 10/30/16.
//  Copyright © 2016 Young, Braden. All rights reserved.
//

#import "BYObjcParser.h"

@implementation BYObjcParser

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

// TODO: multiline support
+ (BYMethod *)parseMethodFromLine:(NSString *)line {
    if (line == nil || line.length == 0) return nil;
    
    NSScanner *scanner = [[NSScanner alloc] initWithString:line];
    BOOL isInstanceMethod = [scanner scanString:@"-" intoString:nil];
    BOOL isClassMethod = NO;
    if (!isInstanceMethod) {
        isClassMethod = [scanner scanString:@"+" intoString:nil];
        if (!isClassMethod) return nil;
    }
    
    BOOL isMethodStartSyntax = [scanner scanString:@"(" intoString:nil];
    if (!isMethodStartSyntax) return nil;
    
    // get return type
    NSString *returnTypeText = nil;
    BOOL foundReturnType = [scanner scanUpToString:@")" intoString:&returnTypeText];
    if (!foundReturnType) return nil;
    
    BYType *returnType = [self parseTypeFromScanner:[[NSScanner alloc] initWithString:returnTypeText]];
    if (returnType == nil) return nil;
    
    // get signature
    scanner = [[NSScanner alloc] initWithString:line];
    
    NSString *signature = nil;
    BOOL foundSignature = [scanner scanUpToString:@"{" intoString:&signature];
    if (!foundSignature) {
        foundSignature = [scanner scanUpToString:@";" intoString:&signature];
        if (!foundSignature) return nil;
    }
    
    signature = [signature stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    BYMethod *method = [[BYMethod alloc] init];
    method.signature = signature;
    method.returnType = returnType;
    method.isClassMethod = isClassMethod;
    
    return method;
}

#pragma mark - Helpers

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
    type.primitive = !isPointer;
    
    return type;
}

@end
