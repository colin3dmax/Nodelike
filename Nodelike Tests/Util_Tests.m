//
//  Util_Tests.m
//  Nodelike
//
//  Created by Sam Rijs on 2/19/14.
//  Copyright (c) 2014 Sam Rijs. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NLContext.h"
#import "NLNatives.h"

@interface Util_Tests : XCTestCase

@end

@implementation Util_Tests

- (void)testAll {
    NSString *prefix = @"test-util";
    [NLNatives.modules enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        if ([obj hasPrefix:prefix]) {
            NSLog(@"running %@", obj);
            NLContext *ctx = [NLContext new];
            ctx.exceptionHandler = ^(JSContext *ctx, JSValue *e) {
                XCTFail(@"Context exception thrown: %@; stack: %@", e, [e valueForProperty:@"stack"]);
            };
            [ctx evaluateScript:@"require_ = require; require = (function (module) { return require_(module === '../common' ? 'test-common' : module); });"];
            [ctx evaluateScript:[NLNatives source:obj]];
            [NLContext runEventLoopSync];
            [ctx evaluateScript:@"process.emit('exit');"];
            [NLContext runEventLoopSync];
        }
    }];
}

@end
