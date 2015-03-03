//
//  PassingTestEntity.m
//  HighPerformanceCoreData
//
//  Created by Yuri Ferretti on 3/3/15.
//  Copyright (c) 2015 Yuri Ferretti. All rights reserved.
//

#import "PassingTestEntity.h"
#import "MultiContextCoreDataStack.h"


@implementation PassingTestEntity

@dynamic identifier;


- (void) setGUID:(id)guid {
    
    self.identifier = (NSString *)guid;
}

- (void)setAttributesFromDictionary:(NSDictionary *)dict {
    
    self.identifier = dict[@"id"];
    
}

- (BOOL)hasSameID:(id)anID {
    
    NSString *str = (NSString *)anID;
    
    return [str isEqualToString:self.identifier];
}

+ (NSString *)entityGUID {
    
    return @"identifier";
}

+ (AbstractImportManagedObject *)insertNewObjectIntoContext:(NSManagedObjectContext *)context {
    
    MultiContextCoreDataStack *stack = [MultiContextCoreDataStack sharedStack];
    
    PassingTestEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:stack.managedObjectContext];
    return entity;
}



@end
