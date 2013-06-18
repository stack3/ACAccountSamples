//
//  STFacebookViewController.m
//  ACAccountSamples
//
//  Created by EIMEI on 2013/06/17.
//  Copyright (c) 2013 stack3.net. All rights reserved.
//

#import "STFacebookViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>

#define _STFacebookAppID @"Your App ID"

@implementation STFacebookViewController {
    IBOutlet __weak UITextView *_textView;
    IBOutlet __weak UIButton *_updateStatusButton;
    IBOutlet __weak UIButton *_composeViewControllerButton;
    
    __strong ACAccountStore *_accountStore;
    __strong ACAccount *_facebookAccount;
}

- (id)init
{
    self = [super initWithNibName:@"STFacebookViewController" bundle:nil];
    if (self) {
        self.title = @"Facebook";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [_updateStatusButton addTarget:self action:@selector(didTapUpdateStatusButton) forControlEvents:UIControlEventTouchUpInside];
    [_composeViewControllerButton addTarget:self action:@selector(didTapCompseViewControllerButton) forControlEvents:UIControlEventTouchUpInside];
    
    _accountStore = [[ACAccountStore alloc] init];
    
    ACAccountType *accountType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    NSArray *accounts = [_accountStore accountsWithAccountType:accountType];
    if (accounts.count == 0) {
        _textView.text = @"Please add facebook account on Settings.";
        return;
    }

    NSDictionary *options = @{ ACFacebookAppIdKey : _STFacebookAppID,
                               ACFacebookAudienceKey : ACFacebookAudienceOnlyMe,
                               ACFacebookPermissionsKey : @[@"email"] };
    [_accountStore requestAccessToAccountsWithType:accountType
                                           options:options
                                        completion:^(BOOL granted, NSError *error) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                if (granted) {
                                                    [self authenticatePermissions];
                                                } else {
                                                    _textView.text = @"User denied to access facebook account.";
                                                }
                                            });
                                        }];    
}

- (void)authenticatePermissions
{
    NSDictionary *options = @{ ACFacebookAppIdKey : _STFacebookAppID,
                               ACFacebookAudienceKey : ACFacebookAudienceOnlyMe,
                               ACFacebookPermissionsKey : @[@"friends_birthday"] };
    ACAccountType *accountType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    [_accountStore requestAccessToAccountsWithType:accountType
                                           options:options
                                        completion:^(BOOL granted, NSError *error) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                if (granted) {
                                                    //
                                                    // Get facebook account.
                                                    //
                                                    NSArray *accounts = [_accountStore accountsWithAccountType:accountType];
                                                    if (accounts.count > 0) {
                                                        // Use can add only one facebook account.
                                                        _facebookAccount = [accounts objectAtIndex:0];
                                                        NSString *fullname = [[_facebookAccount valueForKey:@"properties"] objectForKey:@"fullname"];
                                                        
                                                        NSMutableString *text = [[NSMutableString alloc] initWithCapacity:200];
                                                        //
                                                        // Display accounts.
                                                        //
                                                        [text appendString:@"Granted Users:\n"];
                                                        [text appendString:@" > "];
                                                        [text appendString:fullname];
                                                        [text appendString:@" "];
                                                        [text appendString:_facebookAccount.username]; // e-mail
                                                        [text appendString:@"\n"];
                                                        _textView.text = text;
                                                    } else {
                                                        _textView.text = @"Not found user.";
                                                    }
                                                } else {
                                                    _textView.text = @"User denied to access facebook account.";
                                                }
                                            });
                                        }];
}

- (void)didTapUpdateStatusButton
{
    NSString *uid = [[_facebookAccount valueForKey:@"properties"] objectForKey:@"uid"];
    NSString *urlString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/feed", uid];
    NSURL *url = [NSURL URLWithString:urlString];
    NSDictionary *parameters = @{@"message" : [NSString stringWithFormat:@"test %llu", (uint64_t)[[NSDate date] timeIntervalSince1970]]};
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                            requestMethod:SLRequestMethodPOST
                                                      URL:url
                                               parameters:parameters];
    [request setAccount:_facebookAccount];
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSUInteger statusCode = urlResponse.statusCode;
            if (200 <= statusCode && statusCode < 300) {
                NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
                _textView.text = [NSString stringWithFormat:@"id:%@", [response objectForKey:@"id"]];
            } else {
                NSDictionary *fbErrorRoot = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
                NSString *fbErrorMessage = [[fbErrorRoot objectForKey:@"error"] objectForKey:@"message"];
                _textView.text = fbErrorMessage;
            }
        });
    }];
}

- (void)didTapCompseViewControllerButton
{
    if (![SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) return;
    
    SLComposeViewController *con =
    [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [con setCompletionHandler:^(SLComposeViewControllerResult result) {
        if (result == SLComposeViewControllerResultDone) {
            // Do something if needed.
        } else if (result == SLComposeViewControllerResultCancelled) {
            // Do something if needed.
        }
    }];
    [self presentViewController:con animated:YES completion:nil];
}


@end
