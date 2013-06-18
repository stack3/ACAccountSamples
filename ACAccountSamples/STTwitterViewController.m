//
//  STTwitterViewController.m
//  ACAccountSamples
//
//  Created by EIMEI on 2013/06/17.
//  Copyright (c) 2013 stack3.net. All rights reserved.
//

#import "STTwitterViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@implementation STTwitterViewController {
    IBOutlet __weak UITextView *_textView;
    IBOutlet __weak UIButton *_timelineButton;
    IBOutlet __weak UIButton *_updateStatusButton;
    IBOutlet __weak UIButton *_composeViewControllerButton;

    __strong ACAccountStore *_accountStore;
    __strong NSArray *_twitterAccounts;
}

- (id)init
{
    self = [super initWithNibName:@"STTwitterViewController" bundle:nil];
    if (self) {
        self.title = @"Twitter";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_timelineButton addTarget:self action:@selector(didTapTimelineButton) forControlEvents:UIControlEventTouchUpInside];
    [_updateStatusButton addTarget:self action:@selector(didTapUpdateStatusButton) forControlEvents:UIControlEventTouchUpInside];
    [_composeViewControllerButton addTarget:self action:@selector(didTapCompseViewControllerButton) forControlEvents:UIControlEventTouchUpInside];
    
    _accountStore = [[ACAccountStore alloc] init];
    
    ACAccountType *accountType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    NSArray *accounts = [_accountStore accountsWithAccountType:accountType];
    if (accounts.count == 0) {
        _textView.text = @"Please add twitter account on Settings.";
        return;
    }
    
    [_accountStore requestAccessToAccountsWithType:accountType
                                           options:nil
                                        completion:^(BOOL granted, NSError *error) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                if (granted) {
                                                    //
                                                    // Get twitter accounts.
                                                    //
                                                    _twitterAccounts = [_accountStore accountsWithAccountType:accountType];
                                                    //
                                                    // Display accounts.
                                                    //
                                                    NSMutableString *text = [[NSMutableString alloc] initWithCapacity:200];
                                                    [text appendString:@"Twitter Accounts:\n"];
                                                    for (ACAccount *account in _twitterAccounts) {
                                                        [text appendString:@" > "];
                                                        [text appendString:account.username];
                                                        [text appendString:@"\n"];
                                                    }
                                                    _textView.text = text;
                                                } else {
                                                    _textView.text = @"User denied to access twitter account.";
                                                }
                                            });
                                        }];
}

- (void)didTapTimelineButton
{
    if (_twitterAccounts.count == 0) return;
    
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json"];
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                            requestMethod:SLRequestMethodGET
                                                      URL:url
                                               parameters:nil];
    // Use first twitter account.
    [request setAccount:[_twitterAccounts objectAtIndex:0]];
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSUInteger statusCode = urlResponse.statusCode;
            if (200 <= statusCode && statusCode < 300) {
                NSArray *tweets = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
                NSMutableString *text = [[NSMutableString alloc] initWithCapacity:200];
                for (NSDictionary *tweet in tweets) {
                    NSString *tweetUsername = [[tweet objectForKey:@"user"] objectForKey:@"screen_name"];
                    NSString *tweetText = [tweet objectForKey:@"text"];
                    
                    [text appendString:tweetUsername];
                    [text appendString:@":"];
                    [text appendString:tweetText];
                    [text appendString:@"\n\n"];
                }
                _textView.text = text;
            } else {
                NSDictionary *twitterErrorRoot = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
                NSArray *twitterErrors = [twitterErrorRoot objectForKey:@"errors"];
                if (twitterErrors.count > 0) {
                    _textView.text = [[twitterErrors objectAtIndex:0] objectForKey:@"message"];
                } else {
                    _textView.text = @"Failed to get tweets.";
                }
            }
        });
    }];
}

- (void)didTapUpdateStatusButton
{
    if (_twitterAccounts.count == 0) return;
    
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
    NSDictionary *parameters = @{@"status": [NSString stringWithFormat:@"test %llu", (uint64_t)[[NSDate date] timeIntervalSince1970]]};
    SLRequest * request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                             requestMethod:SLRequestMethodPOST
                                                       URL:url
                                                parameters:parameters];
    // Use first twitter account.
    [request setAccount:[_twitterAccounts objectAtIndex:0]];
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSUInteger statusCode = urlResponse.statusCode;
            if (200 <= statusCode && statusCode < 300) {
                NSDictionary *tweet = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
                NSMutableString *text = [[NSMutableString alloc] initWithCapacity:200];
                NSString *tweetUsername = [[tweet objectForKey:@"user"] objectForKey:@"screen_name"];
                NSString *tweetText = [tweet objectForKey:@"text"];
                
                [text appendString:tweetUsername];
                [text appendString:@":"];
                [text appendString:tweetText];
                [text appendString:@"\n\n"];
                _textView.text = text;
            } else {
                NSDictionary *twitterErrorRoot = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
                NSArray *twitterErrors = [twitterErrorRoot objectForKey:@"errors"];
                if (twitterErrors.count > 0) {
                    _textView.text = [[twitterErrors objectAtIndex:0] objectForKey:@"message"];
                } else {
                    _textView.text = @"Failed to get tweets.";
                }
            }
        });
    }];    
}

- (void)didTapCompseViewControllerButton
{
    if (![SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) return;
    
    SLComposeViewController *con =
    [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [con setCompletionHandler:^(SLComposeViewControllerResult result) {
        if (result == SLComposeViewControllerResultDone) {
            // Dismiss automatically.
        } else if (result == SLComposeViewControllerResultCancelled) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    [self presentViewController:con animated:YES completion:nil];
}

@end
