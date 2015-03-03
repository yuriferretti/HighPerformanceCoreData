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
#import "PassingTestEntity.h"

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

describe(@"Class method tests for AbstractImportManagedObject subclass implementing 'abstract' methods", ^{
    
    __block MultiContextCoreDataStack *stack;
    
    
    beforeAll(^{
        
        stack = [MultiContextCoreDataStack sharedStack];
        stack.storeName = kTestStoreName;
        
    });
    
    
    
    it(@"PassingTestEntity entityName should be equal class name", ^{
        
        expect([PassingTestEntity entityName]).to.equal(NSStringFromClass([PassingTestEntity class]));
    });
    
    it(@"PassingTestEntity entityGUID should not raise exception", ^{
        
        
        expect(^{
        
            [PassingTestEntity entityGUID];
            
        }).toNot.raise(NSInternalInconsistencyException);
    });
    
    it(@"PassintTestEntity insertNewObjectIntoContext should not raise exception", ^{
        
        expect(^{
          
            [PassingTestEntity insertNewObjectIntoContext:stack.managedObjectContext];
            
        }).toNot.raise(NSInternalInconsistencyException);
    });
    
    it(@"PassingTestEntity entityGUID should be equals to 'identifier'", ^{
        
        expect([PassingTestEntity entityGUID]).to.equal(@"identifier");
        
    });
    
    it(@"PassingTestEntity insertNewObjectIntoContext: class method should create a new PassingTestEntity instace", ^{
        
        PassingTestEntity *entity = (PassingTestEntity *)[PassingTestEntity insertNewObjectIntoContext:stack.managedObjectContext];
        expect(entity).toNot.beNil();
        
    });
});

describe(@"Instance method tests for AbstractImportManagedObject subclass implementing 'abstract' methods", ^{
    
    
    __block MultiContextCoreDataStack *stack;
    __block PassingTestEntity *entity;
    
    beforeAll(^{
        
        stack = [MultiContextCoreDataStack sharedStack];
        stack.storeName = kTestStoreName;
        entity = (PassingTestEntity *)[PassingTestEntity insertNewObjectIntoContext:stack.managedObjectContext];
        
    });
    
    it(@"PassinTestEntity instance should implement setGUID: method", ^{
        
        expect(^{
            
            [entity setGUID:@"aGUID"];
            
        }).toNot.raise(NSInternalInconsistencyException);
        
    });
    
    it(@"PassinTestEntity instance should implement setAttributesFromDictionary: method", ^{
        
        expect(^{
            
            [entity setAttributesFromDictionary:@{}];
            
        }).toNot.raise(NSInternalInconsistencyException);
        
    });
    
    it(@"PassinTestEntity instance should implement hasSameID: method", ^{
        
        expect(^{
            
            [entity hasSameID:@"anID"];
            
        }).toNot.raise(NSInternalInconsistencyException);
        
    });
    
    it(@"PassinTestEntity instance should identifier equals to 'aGUID' after setting its GUID", ^{
        
        [entity setGUID:@"aGUID"];
        
        expect(entity.identifier).to.equal(@"aGUID");
        
    });
    
    it(@"PassinTestEntity instance should identifier equals to 'aGUID' after setting its attributes", ^{
        
        [entity setAttributesFromDictionary:@{@"id": @"aGUID"}];
        
        expect(entity.identifier).to.equal(@"aGUID");
        
    });
    
    it(@"PassinTestEntity instance should have same ID", ^{

        [entity setGUID:@"aGUID"];
        
        expect([entity hasSameID:@"aGUID"]).to.beTruthy();
        
    });
    
});

SpecEnd

