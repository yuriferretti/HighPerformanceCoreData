//
//  PatientImportOperation.h
//  HighPerformanceCoreData
//
//  Created by Yuri Ferretti on 12/1/14.
//  Copyright (c) 2014 iClinic Software. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kImportOperationDidCompleteNotification;
extern NSString *const kImportOperationDidFailNotification;


@class MultiContextCoreDataStack;

@interface HighPerformanceImportOperation : NSOperation


- (instancetype)initWithStack:(MultiContextCoreDataStack *)stack serviceURL:(NSURL *)url serviceGUIDKey:(NSString *)serviceGUIDkey entityClass:(Class)importSubClass;

@property (nonatomic, copy) NSArray * (^dataConversionBlock)(NSData *inputData);
@property (nonatomic, copy) NSComparisonResult (^instanceComparisonBlock)(id obj1, id obj2);
@property (assign, nonatomic) NSInteger importBatchSize;
@property (assign, nonatomic) NSInteger saveSize;


@end
