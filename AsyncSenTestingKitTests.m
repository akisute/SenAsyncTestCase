//
//  AsyncSenTestingKitTests.m
//  AsyncSenTestingKitTests
//
//  Created by 小野 将司 on 12/03/17.
//  Copyright (c) 2012年 AppBankGames Inc. All rights reserved.
//

#import "AsyncSenTestingKitTests.h"

@implementation AsyncSenTestingKitTests

- (void)setUp
{
    [super setUp];
    NSLog(@"%s", __func__);
}

- (void)tearDown
{
    NSLog(@"%s", __func__);
    [super tearDown];
}


#pragma mark -


- (void)testAsyncTimeoutsProperly
{
    [self waitForTimeout:3.0];
}

- (void)testAsyncTimeoutsProperly_EXPECT_FAIL
{
    [self waitForStatus:SenAsyncTestCaseStatusSucceeded timeout:3.0];
}


#pragma mark -


- (void)testAsyncWithDelegate
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]];
    [NSURLConnection connectionWithRequest:request delegate:self];
    [self waitForStatus:SenAsyncTestCaseStatusSucceeded timeout:10.0];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Request Finished!");
    [self notify:SenAsyncTestCaseStatusSucceeded];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Request failed with error: %@", error);
    [self notify:SenAsyncTestCaseStatusFailed];
}


#pragma mark -


- (void)testAsyncWithBlocks200
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (error) {
                                   NSLog(@"Request failed with error: %@", error);
                                   [self notify:SenAsyncTestCaseStatusFailed];
                                   return;
                               }
                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                               STAssertEquals([httpResponse statusCode], 200, @"");
                               NSLog(@"Request Finished!");
                               [self notify:SenAsyncTestCaseStatusSucceeded];
                           }];
    [self waitForStatus:SenAsyncTestCaseStatusSucceeded timeout:10.0];
    NSLog(@"Test Finished!");
}

- (void)testAsyncWithBlocks200_EXPECT_FAIL
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (error) {
                                   NSLog(@"Request failed with error: %@", error);
                                   [self notify:SenAsyncTestCaseStatusFailed];
                                   return;
                               }
                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                               STAssertEquals([httpResponse statusCode], 404, @"Expected Fail");
                               NSLog(@"Request Finished!");
                               [self notify:SenAsyncTestCaseStatusSucceeded];
                           }];
    [self waitForStatus:SenAsyncTestCaseStatusSucceeded timeout:10.0];
    NSLog(@"Test Finished!");
}

- (void)testAsyncWithBlocksStatusDoesntMatch_EXPECT_FAIL
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (error) {
                                   NSLog(@"Request failed with error: %@", error);
                                   [self notify:SenAsyncTestCaseStatusFailed];
                                   return;
                               }
                               NSLog(@"Request Finished!");
                               [self notify:SenAsyncTestCaseStatusCancelled];
                           }];
    [self waitForStatus:SenAsyncTestCaseStatusSucceeded timeout:10.0];
    NSLog(@"Test Finished!");
}

- (void)testAsyncWithBlocksError
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.there_should_be_no_such_domain_in_the_world.org"]];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (error) {
                                   NSLog(@"Request failed with error: %@", error);
                                   [self notify:SenAsyncTestCaseStatusFailed];
                                   return;
                               }
                               STFail(@"Must fail before this statement");
                           }];
    [self waitForStatus:SenAsyncTestCaseStatusFailed timeout:10.0];
}

- (void)testAsyncWithBlocksError_EXPECT_FAIL
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.there_should_be_no_such_domain_in_the_world.org"]];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               // DOES fail on events while not notifying
                               // This results in waiting until timeout
                               STFail(@"Must fail before this statement");
                           }];
    [self waitForStatus:SenAsyncTestCaseStatusFailed timeout:5.0];
}


#pragma mark -


- (void)testAsyncMainQueue
{
    /*
     
     This is the preferred way if you're using iOS SDK 4 or above.
     
     Test Case '-[AsyncSenTestingKitTests testAsyncMainQueue]' started.
     2012-03-17 16:27:49.974 otest[939:7b03] -[AsyncSenTestingKitTests setUp]
     2012-03-17 16:27:49.975 otest[939:7b03] Wait loop start
     2012-03-17 16:27:51.976 otest[939:7b03] Notified
     2012-03-17 16:27:51.977 otest[939:7b03] Wait loop finished
     2012-03-17 16:27:51.979 otest[939:7b03] -[AsyncSenTestingKitTests tearDown]
     Test Case '-[AsyncSenTestingKitTests testAsyncMainQueue]' passed (2.007 seconds).
     
     */
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        [self notify:SenAsyncTestCaseStatusSucceeded];
    });
    [self waitForStatus:SenAsyncTestCaseStatusSucceeded timeout:5.0];
}

- (void)testAsyncPerformSelector
{
    /*
     
     Using -performSelector:withObject:afterDelay is no longer recommended as the test has to wait until timeout, like below:
     
     Test Case '-[AsyncSenTestingKitTests testAsyncPerformSelector]' started.
     2012-03-17 16:27:51.980 otest[939:7b03] -[AsyncSenTestingKitTests setUp]
     2012-03-17 16:27:51.981 otest[939:7b03] Wait loop start
     2012-03-17 16:27:53.982 otest[939:7b03] Notified
     2012-03-17 16:27:56.983 otest[939:7b03] Wait loop finished
     2012-03-17 16:27:56.984 otest[939:7b03] -[AsyncSenTestingKitTests tearDown]
     Test Case '-[AsyncSenTestingKitTests testAsyncPerformSelector]' passed (5.004 seconds).
     
     This is because the -performSelector:withObject:afterDelay method internally uses timer. Timers are not considered to be
     the input sources thus -runMode:beforeDate: doesn't return.
     
     */
    [self performSelector:@selector(___internal___testAsyncPerformSelector) withObject:nil afterDelay:2.0];
    [self waitForStatus:SenAsyncTestCaseStatusSucceeded timeout:5.0];
}

- (void)___internal___testAsyncPerformSelector
{
    [self notify:SenAsyncTestCaseStatusSucceeded];
}


@end
