//
//  AbstractImportManagedObject.h
//  HighPerformanceCoreData
//
//  Created by Yuri Ferretti on 2/26/15.
//  Copyright (c) 2015 Yuri Ferretti. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface AbstractImportManagedObject : NSManagedObject



- (void)setGUID:(id)guid;
- (void)setAttributesFromDictionary:(NSDictionary *)dict;
- (BOOL)hasSameID:(id)anID;

+ (NSString *)entityName;
+ (NSString *)entityGUID;
+ (AbstractImportManagedObject *)insertNewObjectIntoContext:(NSManagedObjectContext *)context;


@end
