//
//  PatientImportOperation.m
//  HighPerformanceCoreData
//
//  Created by Yuri Ferretti on 12/1/14.
//  Copyright (c) 2014 iClinic Software. All rights reserved.
//

#import "HighPerformanceImportOperation.h"
#import "MultiContextCoreDataStack.h"
#import "AbstractImportManagedObject.h"


NSString *const kImportOperationDidCompleteNotification = @"NOTIFICATION_IMPORT_OPERATION_COMPLETE";
NSString *const kImportOperationDidFailNotification = @"NOTIFICATION_IMPORT_OPERATION_FAIL";

@interface HighPerformanceImportOperation ()

@property (assign, nonatomic) Class                     importObjectClass;
@property (nonatomic, strong) NSURL                     *serviceURL;
@property (strong, nonatomic) NSString                  *serviceGUIDKey;
@property (nonatomic, strong) MultiContextCoreDataStack *persistenceStack;
@property (nonatomic, strong) NSManagedObjectContext    *managedObjectContext;



@end

@implementation HighPerformanceImportOperation

- (instancetype)initWithStack:(MultiContextCoreDataStack *)stack
                   serviceURL:(NSURL *)url
               serviceGUIDKey:(NSString *)serviceGUIDkey entityClass:(__unsafe_unretained Class)importSubClass{

    if (self = [super init]) {
        
        if (importSubClass == [AbstractImportManagedObject class] ||
            ![importSubClass isSubclassOfClass:[AbstractImportManagedObject class]]) {

            [NSException raise:NSInternalInconsistencyException format:@"The %@ class argument must be a %@ subclass",NSStringFromClass(importSubClass), NSStringFromClass([AbstractImportManagedObject class])];
        }
        
        _persistenceStack = stack;
        _serviceURL = url;
        _serviceGUIDKey = serviceGUIDkey;
        _importObjectClass = importSubClass;
        _importBatchSize = 100;
        _saveSize = 100;
    }
    
    return self;
}


- (void)main {
    
    _managedObjectContext = [_persistenceStack newPrivateManagedObjectContext];
    _managedObjectContext.undoManager = nil;
    [_managedObjectContext performBlockAndWait:^{
        
        _persistenceStack.disableMergeNotifications = YES;
        [self importData];
        _persistenceStack.disableMergeNotifications = NO;
        
    }];
}

- (void)cancel {
    [super cancel];
}

- (void)saveManagedObjectContext {
    
    NSError *saveError;
    if ([_managedObjectContext save:&saveError] == NO) {
        NSLog(@"ERROR: Could not save managed object context\n%@", [saveError localizedDescription]);
        NSLog(@"%@", [saveError localizedRecoveryOptions]);
        NSAssert(NO, @"ASSERT: NSManagedObjectContext Save Error");
    }
}

- (void)importData {
    
    NSError *error = nil;
    NSData *data = [self JSONObjectWithURL:_serviceURL error:&error];


    if (error) {
        return;
    }
    
    
    
    NSArray *instancesArray = _dataConversionBlock(data);
    
    NSInteger totalPatients = instancesArray.count;
    NSInteger totalBatches = totalPatients / _importBatchSize;
    
    NSArray *sortedInstancesArray = [instancesArray sortedArrayUsingComparator:_instanceComparisonBlock];
    
    NSArray *instanceIDArray = [sortedInstancesArray valueForKey:_serviceGUIDKey];
    
    for (NSInteger batchCounter = 0; batchCounter <= totalBatches; batchCounter++) {
        
        NSRange range = NSMakeRange(batchCounter * _importBatchSize, _importBatchSize);
        
        if (batchCounter == totalBatches) {
            range.length = totalPatients - (batchCounter * _importBatchSize);
        }
        
        NSArray *batchArray = [instanceIDArray subarrayWithRange:range];
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[_importObjectClass entityName]];
        
        NSString *entityGUID = [_importObjectClass entityGUID];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K IN %@", entityGUID, batchArray];
        request.predicate = predicate;
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:entityGUID ascending:YES];
        request.sortDescriptors = @[sortDescriptor];
        NSError *fetchError = nil;
        NSArray *fetchResults = [_managedObjectContext executeFetchRequest:request error:&fetchError];
        
        if (fetchResults == nil) {
            NSLog(@"ERROR: Could not execute fetch request\n%@", [fetchError localizedDescription]);
            NSAssert(NO, @"ASSERT: Fetch request failed");
            return;
        }
        
        NSEnumerator *instanceEnumerator = [[sortedInstancesArray subarrayWithRange:range]objectEnumerator];
        NSEnumerator *fetchResultsEnumerator = [fetchResults objectEnumerator];
        NSDictionary *instanceDictionary = [instanceEnumerator nextObject];
        AbstractImportManagedObject  *fetchedObject = [fetchResultsEnumerator nextObject];
        
        NSInteger count = 0;
        
        while (instanceDictionary) {
            
            count++;
            
            if (self.isCancelled) {
                return;
            }
        
            BOOL isUpdate = NO;
            
            if (fetchedObject != nil && [fetchedObject hasSameID:[instanceDictionary objectForKey:_serviceGUIDKey]]) {

                isUpdate = YES;
            }
            
            
            if (!isUpdate) {
                
                Class fetchedClass = [fetchedObject class];
                
                fetchedObject = [fetchedClass insertNewObjectIntoContext:_managedObjectContext];
                [fetchedObject setGUID: [instanceDictionary objectForKey:_serviceGUIDKey]];
            }
            
            [fetchedObject setAttributesFromDictionary:instanceDictionary];
            
            if (isUpdate) {
                instanceDictionary = [instanceEnumerator nextObject];
                fetchedObject = [fetchResultsEnumerator nextObject];
            
            } else {
                instanceDictionary = [instanceEnumerator nextObject];
            }
            
            if (count % _saveSize == 0) {
                [self saveManagedObjectContext];
            }
            
        }// while patientDict
    }//for batchCounter
    
    [self saveManagedObjectContext];
}

- (NSData *)JSONObjectWithURL:(NSURL *)url error:(NSError **)error {
    
    NSURLRequest *request = [self requestWithURL:_serviceURL];
    NSHTTPURLResponse *response = nil;
    NSError *localError = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&localError];
    
    if (localError) {
        *error = localError;
        return nil;
    }
    
    return data;
}

- (NSURLRequest *)requestWithURL:(NSURL *)url {

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20.0];
    request.HTTPMethod = @"GET";
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    return request;
}

@end
