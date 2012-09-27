//
//  GithubAuthController.h
//  Github-Auth-iOS
//
//  Created by buza on 9/26/12.
//  Copyright (c) 2012 buza. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GitAuthDelegate
-(void) didAuth:(NSString*)token;
@end

@protocol FrameChangeDelegate
-(void) frameChanged:(CGRect)frame;
@end

@interface GithubAuthController : UIViewController <FrameChangeDelegate, GitAuthDelegate>

@property(nonatomic, copy) BMBlockVoid completionBlock;
@property(nonatomic, weak) id<GitAuthDelegate> authDelegate;

@end
