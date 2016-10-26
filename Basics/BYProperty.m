//
//  Property.m
//  gen
//
//  Created by Young, Braden on 10/6/16.
//  Copyright © 2016 Young, Braden. All rights reserved.
//

#import "BYProperty.h"

@implementation BYProperty

+ (BYProperty *)propertyFromObjcLine:(NSString *)text {
    if (text == nil || text.length == 0) return nil;
    
    NSScanner *scanner = [[NSScanner alloc] initWithString:text];
    BOOL isProperty = [scanner scanString:@"@property" intoString:nil];
    if (!isProperty) return nil;
    
    // parse attributes
    BOOL readonly = NO;
    BOOL hasAttributes = [scanner scanString:@"(" intoString:nil];
    if (hasAttributes) {
        NSString *attributes;
        BOOL foundAttributes = [scanner scanUpToString:@")" intoString:&attributes];
        if (!foundAttributes) return nil;
        
        readonly = [attributes containsString:@"readonly"];
        
        [scanner scanString:@")" intoString:nil];
    }
    
    // parse property type
    NSString *typeName;
    BOOL foundType = [scanner scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet] intoString:&typeName];
    if (!foundType) return nil;
    
    Class typeClass = NSClassFromString(typeName);
    
    // parse generics
    BOOL hasGeneric = [scanner scanString:@"<" intoString:nil];
    if (hasGeneric) {
        NSString *generics;
        BOOL foundGenerics = [scanner scanUpToString:@">" intoString:&generics];
        if (!foundGenerics) return nil;
        
        // TODO: use generic type info
        [scanner scanString:@">" intoString:nil];
    }
    
    // skip *
    BOOL isPointer = [scanner scanString:@"*" intoString:nil];
    
    // parse property name
    NSString *propertyName;
    BOOL foundName = [scanner scanUpToString:@";" intoString:&propertyName];
    if (!foundName) return nil;
    
    BYProperty *property = [[BYProperty alloc] init];
    property.typeName = typeName;
    property.typeClass = typeClass;
    property.name = propertyName;
    property.primitive = !isPointer;
    property.readonly = readonly;
    
    return property;
}

+ (NSCharacterSet *)whitespaceAndAsterickSet {
    static NSMutableCharacterSet *whitespaceAndAsterickSet = nil;
    if (whitespaceAndAsterickSet == nil) {
        whitespaceAndAsterickSet = [NSMutableCharacterSet whitespaceCharacterSet];
        [whitespaceAndAsterickSet addCharactersInString:@"*"];
    }
    return whitespaceAndAsterickSet;
}

@end
