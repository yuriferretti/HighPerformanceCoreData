//
//  MultiContextCoreDataStack.m
//  HighPerformanceCoreData
//
//  Created by Yuri Ferretti on 12/1/14.
//  Copyright (c) 2014 iClinic Software. All rights reserved.
//

#import "MultiContextCoreDataStack.h"

NSString * const kHighPerformanceCoreDataStackDidInitialize = @"NOTIFICATION_COREDATA_STACK_INITIALIZED";


@interface MultiContextCoreDataStack ()

@property (nonatomic, strong, readwrite) NSManagedObjectContext *managedObjectContext;

/*!
 *  managed object model
 */
@property (nonatomic) NSManagedObjectModel *managedObjectModel;

/*!
 *  store coordinator
 */
@property (nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end


@implementation MultiContextCoreDataStack


#pragma mark - singleton

+ (id)sharedStack
{
    static MultiContextCoreDataStack *sharedStack = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStack = [[self alloc]init];
    });
    return sharedStack;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager]URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]lastObject];
}

#pragma mark - Core Data Methods

- (void)saveContext {

    NSError *error;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext) {
        
        //saves only if context has changes
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
        
    }
}

#pragma mark - Private NSManagedObjectContext

- (void)managedObjectContextDidSaveNotification:(NSNotification *)notification {
    
    if (_disableMergeNotifications == NO) {
        NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
        NSManagedObjectContext *savedManagedObjectContext = notification.object;
        if (savedManagedObjectContext != managedObjectContext) {
            [managedObjectContext performBlock:^(){
                [managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
            }];
        }
    }
}

- (NSManagedObjectContext *)newPrivateManagedObjectContext {
    NSManagedObjectContext *privateContext = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    privateContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    privateContext.persistentStoreCoordinator = self.managedObjectContext.persistentStoreCoordinator;
    return privateContext;
}

#pragma mark - core data stack

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return  _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc]initWithConcurrencyType: NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        _managedObjectContext.mergePolicy =  NSMergeByPropertyObjectTrumpMergePolicy;
        
        [self setupSaveNotification];
        
        [self persistenceStackInitialized];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:self.storeName withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    //avoid concurrent access
    @synchronized(self){
        
        if (_persistentStoreCoordinator != nil) {
            return _persistentStoreCoordinator;
        }
        
        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@".sqlite"];
        
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        
        if (_persistentStoreCoordinator == nil) {
            NSLog(@"ERROR: Cannot add persistent store as no persistent store coordinator exist");
            NSAssert(NO, @"ASSERT: NSPersistentStoreCoordinator is nil");
        }
        
        NSDictionary *options = @{
                                  NSInferMappingModelAutomaticallyOption: @(YES),
                                  NSMigratePersistentStoresAutomaticallyOption:@(YES)
                                  };
        
        NSError *error;
        
        NSPersistentStore *persistentStore = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                                       configuration:nil
                                                                                                 URL:storeURL
                                                                                             options:options
                                                                                               error:&error];
        
        if (persistentStore == nil) {
            
            NSError *deleteError = nil;
            
            if ([[NSFileManager defaultManager] removeItemAtURL:storeURL error:&deleteError]) {
                error = nil;
                [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                          configuration:nil
                                                                    URL:storeURL
                                                                options:options
                                                                  error:&error];
            }
            
            if (persistentStore == nil) {
                NSLog(@"ERROR: Cannot create managed object context because a persistent store does not exist\n%@", [error localizedDescription]);
                NSLog(@"DELETE ERROR: %@", [deleteError localizedDescription]);
                NSAssert(NO, @"ASSERT: NSPersistentStore is nil");
                abort();
            }

        }
        
        return _persistentStoreCoordinator;
    }
}

- (void)persistenceStackInitialized {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kHighPerformanceCoreDataStackDidInitialize
                                                        object:self];
}

- (void)setupSaveNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(managedObjectContextDidSaveNotification:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:nil];
}


- (void)removeCoreDataStore {
    
    NSArray *stores = self.persistentStoreCoordinator.persistentStores;
    
    if (stores.count == 1) {
        
        NSPersistentStore *store = stores[0];
        NSURL *storeURL = store.URL;
        NSError *error = nil;
        [self.persistentStoreCoordinator removePersistentStore:store error:&error];
        [[NSFileManager defaultManager]removeItemAtPath:storeURL.path error:&error];
        
        if (error) {
            NSLog(@"Error deleting cache %@", [error localizedDescription]);
        }
    }
    self.persistentStoreCoordinator = nil;
    self.managedObjectContext = nil;
    self.managedObjectModel = nil;
}

@end
