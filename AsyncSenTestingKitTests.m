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
    [self waitUntilTimeout:3.0];
}


#pragma mark -


- (void)testAsyncWithDelegate
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]];
    [NSURLConnection connectionWithRequest:request delegate:self];
    [self waitUntilTimeout:10.0];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Request Finished!");
    [self notify];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    STFail(@"Request failed with error: %@", error);
    [self notify];
}


#pragma mark -


- (void)testAsyncWithBlocks200
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (error) {
                                   STFail(@"Request failed with error: %@", error);
                                   return;
                               }
                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                               STAssertEquals([httpResponse statusCode], 200, @"");
                               [self notify];
                               NSLog(@"Request Finished!");
                           }];
    [self waitUntilTimeout:10.0];
    NSLog(@"Test Finished!");
}

- (void)testAsyncWithBlocks200_EXPECT_FAIL
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (error) {
                                   STFail(@"Request failed with error: %@", error);
                                   return;
                               }
                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                               STAssertEquals([httpResponse statusCode], 404, @"Expected Fail");
                               [self notify];
                           }];
    [self waitUntilTimeout:10.0];
}

- (void)testAsyncWithBlocksError
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.there_should_be_no_such_domain_in_the_world.org"]];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (error) {
                                   NSLog(@"Request failed with error: %@", error);
                                   [self notify];
                                   return;
                               }
                               STFail(@"Must fail before this statement");
                           }];
    [self waitUntilTimeout:10.0];
}

@end
