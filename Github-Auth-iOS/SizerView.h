//
//  SizerView.h
//  Github-Auth-iOS
//
//  Created by buza on 9/27/12.
//  Copyright (c) 2012 buza. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GithubAuthController.h"

@interface SizerView : UIView

- (id)initWithFrame:(CGRect)frame frameChangeDelegate:(id<FrameChangeDelegate>)_delegate;

@end
