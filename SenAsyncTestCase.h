//
//  SenAsyncTestCase.h
//  AsyncSenTestingKit
//
//  Created by 小野 将司 on 12/03/17.
//  Copyright (c) 2012年 AppBankGames Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>


@interface SenAsyncTestCase : SenTestCase

- (void)waitUntilTimeout:(NSTimeInterval)timeout;
- (void)notify;

@end
