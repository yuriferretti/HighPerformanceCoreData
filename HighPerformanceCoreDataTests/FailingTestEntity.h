//
//  FailingTestEntity.h
//  HighPerformanceCoreData
//
//  Created by Yuri Ferretti on 3/3/15.
//  Copyright (c) 2015 Yuri Ferretti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AbstractImportManagedObject.h"

@interface FailingTestEntity : AbstractImportManagedObject

@property (nonatomic, retain) NSString * identifier;

@end
