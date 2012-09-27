//
//  GistCreator.h
//  ScriptKit
//
//  Created by buza on 9/26/12.
//
//

#import <Foundation/Foundation.h>

#import "GithubAuthController.h"

@interface GistCreator : NSObject <GitAuthDelegate>


-(void) createGist:(NSString*)script description:(NSString*)description title:(NSString*)title anonymous:(BOOL)anonymous;

@end
