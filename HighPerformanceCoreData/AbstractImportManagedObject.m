//
//  AbstractImportManagedObject.m
//  HighPerformanceCoreData
//
//  Created by Yuri Ferretti on 2/26/15.
//  Copyright (c) 2015 Yuri Ferretti. All rights reserved.
//

#import "AbstractImportManagedObject.h"

@implementation AbstractImportManagedObject

- (BOOL)hasSameID:(id)anID {
    
    [NSException raise:NSInternalInconsistencyException format:@"%@ %s must be implemented by a subclass", NSStringFromClass([AbstractImportManagedObject class]), __PRETTY_FUNCTION__];
    
    return NO;
}

- (void)setAttributesFromDictionary:(NSDictionary *)dict {
    
    [NSException raise:NSInternalInconsistencyException format:@"%@ %s must be implemented by a subclass", NSStringFromClass([AbstractImportManagedObject class]), __PRETTY_FUNCTION__];
}

- (void)setGUID:(id)guid {
    
    [NSException raise:NSInternalInconsistencyException format:@"%@ %s must be implemented by a subclass", NSStringFromClass([AbstractImportManagedObject class]), __PRETTY_FUNCTION__];
}

#pragma mark - Class methods

+ (AbstractImportManagedObject *)insertNewObjectIntoContext:(NSManagedObjectContext *)context {
    
    [NSException raise:NSInternalInconsistencyException format:@"%@ %s must be implemented by a subclass", NSStringFromClass([AbstractImportManagedObject class]), __PRETTY_FUNCTION__];
    
    return nil;
}

+ (NSString *)entityName {
    
    [NSException raise:NSInternalInconsistencyException format:@"%@ %s must be implemented by a subclass", NSStringFromClass([AbstractImportManagedObject class]), __PRETTY_FUNCTION__];
    
    return nil;
}

+ (NSString *)entityGUID {
    
    [NSException raise:NSInternalInconsistencyException format:@"%@ %s must be implemented by a subclass", NSStringFromClass([AbstractImportManagedObject class]), __PRETTY_FUNCTION__];
    
    return nil;
}

@end
