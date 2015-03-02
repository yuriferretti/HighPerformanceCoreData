//
//  MultiContextCoreDataStackTestCase.m
//  HighPerformanceCoreData
//
//  Created by Yuri Ferretti on 3/1/15.
//  Copyright (c) 2015 Yuri Ferretti. All rights reserved.
//

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <XCTest/XCTest.h>

#import "MultiContextCoreDataStack.h"

SpecBegin(MultiContextCoreDataStack)

describe(@"MultiContextCoreDataStack Tests", ^{
    
   __block  MultiContextCoreDataStack *stack;
    
    beforeAll(^{
        
        stack = [MultiContextCoreDataStack sharedStack];
    });
    
    it(@"Stack can be created", ^{
        
        expect(stack).toNot.beNil();
        
    });
    
    it(@"Stack is the same as shared stack", ^{
        
        expect(stack).to.equal([MultiContextCoreDataStack sharedStack]);
        
    });
    
    afterAll(^{
        
        stack = nil;
    });
    
});

SpecEnd
