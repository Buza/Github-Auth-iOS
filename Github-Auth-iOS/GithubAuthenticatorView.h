//
//  GithubAuthenticator.h
//  Github-Auth-iOS
//
//  Created by buza on 9/25/12.
//  Copyright (c) 2012 buza. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GithubAuthController.h"

@interface GithubAuthenticatorView : UIWebView <UIWebViewDelegate>

@property(nonatomic, weak) id<GitAuthDelegate> authDelegate;

@end
