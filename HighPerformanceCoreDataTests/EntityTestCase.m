//
//  EntityTestCase.m
//  HighPerformanceCoreData
//
//  Created by Yuri Ferretti on 3/3/15.
//  Copyright (c) 2015 Yuri Ferretti. All rights reserved.
//

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <XCTest/XCTest.h>
#import "MultiContextCoreDataStack.h"
#import "FailingTestEntity.h"

NSString * const kTestStoreName = @"Test-store";

SpecBegin(EntityTest)

describe(@"Class methods tests for AbstractImporManagedObject subclass not implementing 'abstract' methods", ^{
    
    __block MultiContextCoreDataStack *stack;
    
    beforeAll(^{
        
        stack = [MultiContextCoreDataStack sharedStack];
        stack.storeName = kTestStoreName;
        
    });
    
    it(@"Entity should have its store name equals to its class name", ^{
        
        NSString *entityName = [FailingTestEntity entityName];
        
        expect(entityName).to.equal(NSStringFromClass([FailingTestEntity class]));
        
    });
    
    it(@"Abstract 'entityGUID' class method should raise exception", ^{
        
        expect(^{
            
            [FailingTestEntity entityGUID];
            
        }).to.raise(NSInternalInconsistencyException);
        
    });
    
    it(@"Abstract 'insertNewObjectIntoContext:' class method should raise exception", ^{
        
        expect(^{
            
            [FailingTestEntity insertNewObjectIntoContext:stack.managedObjectContext];
            
        }).to.raise(NSInternalInconsistencyException);
        
    });
});

describe(@"Instance methods tests for AbstractImportManagedObject subclass not implementing 'abstract' methods", ^{
    
    
    __block MultiContextCoreDataStack *stack;
    __block FailingTestEntity *entity;
    
    beforeAll(^{
        
        stack = [MultiContextCoreDataStack sharedStack];
        stack.storeName = kTestStoreName;
        
        entity = [NSEntityDescription insertNewObjectForEntityForName:[FailingTestEntity entityName]
                                                                  inManagedObjectContext:stack.managedObjectContext];
        
    });
    
    it(@"FailingTestEntity should be created", ^{
    
        
        
        expect(entity).toNot.beNil();
    });
    
    it(@"Abstract setGUID: instance method should raise exception", ^{
        
        expect(^{
            
            [entity setGUID:@"aGUID"];
            
        }).to.raise(NSInternalInconsistencyException);
        
    });
    
    it(@"Abstract setAttributesFromDictionary: instance method should raise exception", ^{
        
        expect(^{
            
            [entity setGUID:[NSDictionary new]];
            
        }).to.raise(NSInternalInconsistencyException);
        
    });
    
    it(@"Abstract hasSameID: instance method should raise exception", ^{
        
        expect(^{
            
            [entity hasSameID:nil];
            
        }).to.raise(NSInternalInconsistencyException);
        
    });
    
});

SpecEnd

