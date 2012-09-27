//
//  GithubAuthController.m
//  Github-Auth-iOS
//
//  Created by buza on 9/26/12.
//  Copyright (c) 2012 buza. All rights reserved.
//

#import "GithubAuthController.h"

#import "GithubAuthenticatorView.h"

#import "SizerView.h"

@interface GithubAuthController ()

@end

@implementation GithubAuthController

@synthesize completionBlock;
@synthesize authDelegate;

- (id)init
{
    self = [super init];
    if (self)
    {
        //We use a special view that will tell us what the proper frame size is so we can
        //make sure the login view is centered in the modal view controller.
        self.view = [[SizerView alloc] initWithFrame:CGRectZero frameChangeDelegate:self];
        self.authDelegate = nil;
    }
    return self;
}

-(void) dealloc
{
}

-(void) didAuth:(NSString*)token
{
    [self.authDelegate didAuth:token];
    self.completionBlock();
}

-(void) frameChanged:(CGRect)frame
{
    GithubAuthenticatorView *gha = [[GithubAuthenticatorView alloc] initWithFrame:frame];
    gha.authDelegate = self;
    [self.view addSubview:gha];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


@end
