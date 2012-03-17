//
//  SenAsyncTestCase.m
//  AsyncSenTestingKit
//
//  Created by 小野 将司 on 12/03/17.
//  Copyright (c) 2012年 AppBankGames Inc. All rights reserved.
//

#import "SenAsyncTestCase.h"


@interface SenAsyncTestCase ()
@property (nonatomic, retain) NSDate *loopUntil;
@property (nonatomic, assign) BOOL notified;
@end


@implementation SenAsyncTestCase


@synthesize loopUntil = _loopUntil;
@synthesize notified = _notified;


- (void)dealloc
{
    self.loopUntil = nil;
    [super dealloc];
}

- (void)waitUntilTimeout:(NSTimeInterval)timeout
{
    self.notified = NO;
    self.loopUntil = [NSDate dateWithTimeIntervalSinceNow:timeout];
    while (!self.notified && [self.loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:self.loopUntil];
    }
}

- (void)notify
{
    self.notified = YES;
}

@end
