//
//  ViewController.m
//  Github-Auth-iOS
//
//  Created by buza on 9/27/12.
//  Copyright (c) 2012 buza. All rights reserved.
//

#import "ViewController.h"

#import "GithubAuthController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    if([GITHUB_CLIENT_ID isEqualToString:@"YOUR CLIENT ID"])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"You must specify your Github API credentials in Defines.h."] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    } else
    {
        [self performSelector:@selector(checkGitAuth) withObject:nil afterDelay:2];   
    }
    
    self.view.backgroundColor = [UIColor blackColor];
    [super viewDidLoad];
}

//This is our authentication delegate. When the user logs in, and Github sends us our auth token, we receive that here.
-(void) didAuth:(NSString*)token
{
    if(!token)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Failed to request token."] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    //As a test, we'll request the authenticated user data.
    NSString *gistCreateURLString = [NSString stringWithFormat:@"https://api.github.com/user?access_token=%@", token];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:gistCreateURLString]];
    
    NSOperationQueue *theQ = [NSOperationQueue new];
    [NSURLConnection sendAsynchronousRequest:request queue:theQ
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               NSError *err;
                               id val = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
                               if(!err && !error && val && [NSJSONSerialization isValidJSONObject:val])
                               {
                                   dispatch_sync(dispatch_get_main_queue(), ^{
                                       NSString *username = [val objectForKey:@"name"];
                                       
                                       UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"User request complete" message:[NSString stringWithFormat:@"User info retrieved for: %@", username] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                       [alertView show];
                                   });
                               }
                           }];

}

-(void) checkGitAuth
{
    GithubAuthController *githubAuthController = [[GithubAuthController alloc] init];
    githubAuthController.authDelegate = self;
    
    githubAuthController.modalPresentationStyle = UIModalPresentationFormSheet;
    githubAuthController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self presentViewController:githubAuthController animated:YES completion:^{ } ];
    
    __weak __block GithubAuthController *weakAuthController = githubAuthController;
    
    githubAuthController.completionBlock = ^(void) {
        [weakAuthController dismissViewControllerAnimated:YES completion:nil];
    };
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
