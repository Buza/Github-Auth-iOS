//
//  GistCreator.m
//  ScriptKit
//
//  Created by buza on 9/26/12.
//
//

#import "GistCreator.h"

#import "NSDictionary+UrlEncoding.h"

#import "Screen.h"
#import "GithubAuthController.h"

#import "SFHFKeychainUtils.h"

@interface GistCreator()
@property(nonatomic, copy) NSString *script;
@property(nonatomic, copy) NSString *description;
@property(nonatomic, copy) NSString *title;

@property(nonatomic, strong) NSMutableData *data;
@property(nonatomic, strong) NSURLConnection *gistConnection;
@property(nonatomic, strong) NSURLConnection *shortenConnection;
@end

@implementation GistCreator

@synthesize data;
@synthesize script;
@synthesize description;
@synthesize title;
@synthesize gistConnection;
@synthesize shortenConnection;

-(id) init
{
    self = [super init];
    if(self)
    {
        self.description = nil;
        self.title = nil;
        self.script = nil;
        self.data = [NSMutableData data];
        self.gistConnection = nil;
        self.shortenConnection = nil;
    }
    return self;
}

-(void) dealloc
{
    [gistConnection cancel];
    [shortenConnection cancel];
}

-(void) didAuth:(NSString*)token
{
    Screen *s = [Screen screen];
    [s.mEditorController dismissModalViewControllerAnimated:YES];
    
    if(token)
    {
        NSError *error;
        [SFHFKeychainUtils storeUsername:kGithubAuthTokenID andPassword:token forServiceName:kGithubAuthTokenID updateExisting:YES error:&error];
        //[SFHFKeychainUtils storeUsername:kGithubUserID andPassword:token forServiceName:kGithubUserID updateExisting:YES error:&error];
        
        
        [self createGist:self.script description:self.description title:self.title anonymous:NO];
    }
}


-(void) dismissController
{
    Screen *s = [Screen screen];
    [s.mEditorController dismissModalViewControllerAnimated:YES];
}

-(void) createGist:(NSString*)_script description:(NSString*)_description title:(NSString*)_title anonymous:(BOOL)anonymous
{
    NSError *error;
    NSString *authToken = [SFHFKeychainUtils getPasswordForUsername:kGithubAuthTokenID andServiceName:kGithubAuthTokenID error:&error];
    
    if(!anonymous)
    {
        if(!authToken)
        {
            self.description = _description;
            self.title = _title;
            self.script = _script;
            
            GithubAuthController *sbc = [[GithubAuthController alloc] init];
            sbc.authDelegate = self;
            
            UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:sbc];
            NSDictionary *dikk = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithWhite:0.25 alpha:1.0], UITextAttributeTextColor, [UIColor whiteColor], UITextAttributeTextShadowColor, [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset, [UIFont fontWithName:@"GoodMobiPro-Bold" size:22.0], UITextAttributeFont, nil];
            
            [navC.navigationBar setTitleTextAttributes:dikk];
            
            navC.view.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1.0];
            UIBarButtonItem *doneButton = [[UIBarButtonItem alloc ] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissController)];
            
            [doneButton setTintColor:[UIColor colorWithRed:230./255. green:230./255. blue:238./255. alpha:1.0]];
            
            [doneButton setTitleTextAttributes:
             [NSDictionary dictionaryWithObjectsAndKeys:
              [UIColor colorWithWhite:0.0 alpha:0.8], UITextAttributeTextColor,
              [UIColor whiteColor], UITextAttributeTextShadowColor,
              [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset,
              nil] forState:UIControlStateNormal];
            
            
            [doneButton setTitleTextAttributes:
             [NSDictionary dictionaryWithObjectsAndKeys:
              [UIColor colorWithWhite:0.0 alpha:0.96], UITextAttributeTextColor,
              [UIColor whiteColor], UITextAttributeTextShadowColor,
              [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset,
              nil] forState:UIControlEventTouchDown];
            
            
            [sbc setTitle:@"Github"];
            
            sbc.navigationItem.leftBarButtonItem = doneButton;
            
            navC.modalPresentationStyle = UIModalPresentationFormSheet;
            navC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            Screen *s = [Screen screen];
            [s.mEditorController presentModalViewController:navC animated:YES];
            
            return;
            
        }
        
    }
    //Anonymous
    
    NSString *gistCreateURLString = nil;
    
    if(!anonymous)
    {
        gistCreateURLString = [NSString stringWithFormat:@"https://api.github.com/gists?access_token=%@", authToken];
    } else
    {
        gistCreateURLString = [NSString stringWithFormat:@"https://api.github.com/gists"];
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:gistCreateURLString]];
    
    NSDictionary *filedict = nil;
    
    if(title && [title length] > 0)
    {
        filedict = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:_script forKey:@"content"] forKey:[NSString stringWithFormat:@"%@.lua", _title]];
    } else
        filedict = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:_script forKey:@"content"] forKey:@"scratchpad.lua"];
    
    NSDictionary *paramDict = [NSDictionary dictionaryWithObjectsAndKeys:filedict, @"files", @"false", @"public", _description, @"description", nil];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:paramDict options:0 error:nil];
    
    NSString *paramStringDat = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [request setHTTPMethod:@"POST"];
    [request addValue:[NSString stringWithFormat:@"application/json"] forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[paramStringDat dataUsingEncoding:NSUTF8StringEncoding]];
    
    self.gistConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [gistConnection start];
}



#pragma Mark NSURLConnection delegates

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return cachedResponse;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)_data
{
    [self.data appendData:_data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"Could not save Gist."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [self.data setLength:0];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error = nil;
    id jsonDict = [NSJSONSerialization JSONObjectWithData:self.data options:0 error:&error];
    if(jsonDict && !error && [NSJSONSerialization isValidJSONObject:jsonDict])
    {
        DLog(@" json  %@", jsonDict);
        
        //Is this from git?
        if([jsonDict objectForKey:@"git_push_url"])
        {
            NSString *url = [jsonDict objectForKey:@"html_url"];
            [self.data setLength:0];
            
            NSURL *awesmURL = [NSURL URLWithString:@"http://api.awe.sm/url.json"];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:awesmURL];
            
            
            NSDictionary *paramDict = [NSDictionary dictionaryWithObjectsAndKeys:@"3", @"v", url, @"url", kAwesmAPIKey, @"key", kAwesmTool, @"tool", @"extract", @"channel", nil];
            
            NSString *paramString = [paramDict urlEncodedString];
            
            NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
            
            [request setHTTPMethod:@"POST"];
            [request addValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@",charset] forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:[paramString dataUsingEncoding:NSUTF8StringEncoding]];
            
            
            self.shortenConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            
            [shortenConnection start];
            
        } else
        {
            
            NSString *shortURL = [jsonDict objectForKey:@"awesm_url"];
            if(shortURL)
            {
                shortURL = [shortURL lowercaseString];
                
                [[UIPasteboard generalPasteboard] setValue:shortURL forPasteboardType:@"public.text"];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Gist Saved"
                                                                message:@"A URL for this Gist has been saved to your Pasteboard."
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"OK", nil];
                [alert show];
                
            } else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Could not save Gist."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
                
        }
        
    } else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Could not save Gist."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }

    
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
    return request;
}



@end