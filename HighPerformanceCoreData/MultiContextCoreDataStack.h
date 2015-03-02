//
//  MultiContextCoreDataStack.h
//  HighPerformanceCoreData
//
//  Created by Yuri Ferretti on 12/1/14.
//  Copyright (c) 2014 iClinic Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString * const kHighPerformanceCoreDataStackDidInitialize;


@interface MultiContextCoreDataStack : NSObject

@property (strong, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSString *storeName;
@property (assign, nonatomic) BOOL disableMergeNotifications;

- (NSManagedObjectContext *)newPrivateManagedObjectContext;

- (void)saveContext;

+ (id)sharedStack;

- (void)removeCoreDataStore;

@end
