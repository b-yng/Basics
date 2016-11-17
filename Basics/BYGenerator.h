//
//  BYGenerator.h
//  gen
//
//  Created by Young, Braden on 10/9/16.
//  Copyright © 2016 Young, Braden. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BYProperty;
@class BYMethod;

@protocol BYGenerator <NSObject>

- (NSMutableArray<NSString*> *)generateIsEqual:(NSArray<BYProperty*> *)properties className:(NSString *)className;

- (NSMutableArray<NSString*> *)generateHash:(NSArray<BYProperty*> *)properties;

- (NSMutableArray<NSString*> *)generateCopyWithZone:(NSArray<BYProperty*> *)properties className:(NSString *)className;

- (NSMutableArray<NSString*> *)generateMethodSignatures:(NSArray<BYMethod*> *)methods;

@end
