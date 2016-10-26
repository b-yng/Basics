//
//  Property.h
//  gen
//
//  Created by Young, Braden on 10/6/16.
//  Copyright © 2016 Young, Braden. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BYProperty : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *typeName;
@property (nonatomic) Class typeClass;
@property (nonatomic) BOOL primitive;
@property (nonatomic) BOOL readonly;

+ (BYProperty *)propertyFromObjcLine:(NSString *)text;

@end
