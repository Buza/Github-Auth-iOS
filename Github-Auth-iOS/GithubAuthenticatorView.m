//
//  GithubAuthenticatorView.m
//  Github-Auth-iOS
//
//  Created by buza on 9/25/12.
//  Copyright (c) 2012 buza. All rights reserved.
//

#import "GithubAuthenticatorView.h"

#import "NSDictionary+UrlEncoding.h"

@interface GithubAuthenticatorView()
@property(nonatomic, strong) NSMutableData *data;
@property(nonatomic, strong) NSURLConnection *tokenRequestConnection;
@end

@implementation GithubAuthenticatorView

@synthesize data;
@synthesize authDelegate;
@synthesize tokenRequestConnection;

-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self)
    {
        self.authDelegate = nil;
        self.tokenRequestConnection = nil;
        self.data = [NSMutableData data];
        self.scalesPageToFit = YES;
        [self authorize];
    }
    
    return self;
}

-(void) dealloc
{
    [tokenRequestConnection cancel];
    self.delegate = nil;
}

-(void) authorize
{
    //Scopes: http://developer.github.com/v3/oauth/#scopes
    //user
    //public_repo
    //repo
    //repo:status
    //delete_repo
    //gist
        
    NSString *scope = @"user";
    
    NSString *requestURL = [NSString stringWithFormat:@"https://github.com/login/oauth/authorize?client_id=%@&redirect_uri=%@&scope=%@", GITHUB_CLIENT_ID, GITHUB_CALLBACK_URL, scope];
    
    NSURLRequest *urlReq = [NSURLRequest requestWithURL:[NSURL URLWithString:requestURL]];
    self.delegate = self;
    [self loadRequest:urlReq];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *responseURL = [request.URL absoluteString];
    
    NSString *codeString = [NSString stringWithFormat:@"%@/?code=", GITHUB_CALLBACK_URL];
    if([responseURL hasPrefix:codeString])
    {
        NSInteger strLen = [codeString length];
        NSString *code = [responseURL substringFromIndex:strLen];
        
        //Request the token.
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://github.com/login/oauth/access_token"]];
        
        NSDictionary *paramDict = [NSDictionary dictionaryWithObjectsAndKeys:code, @"code",
                                   GITHUB_CLIENT_ID, @"client_id",
                                   GITHUB_CALLBACK_URL, @"redirect_uri",
                                   GITHUB_CLIENT_SECRET, @"client_secret", nil];
        
        NSString *paramString = [paramDict urlEncodedString];
        
        NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
        
        [request setHTTPMethod:@"POST"];
        [request addValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@",charset] forHTTPHeaderField:@"Content-Type"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setHTTPBody:[paramString dataUsingEncoding:NSUTF8StringEncoding]];
        
        self.tokenRequestConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        [tokenRequestConnection start];

        return NO;
    }
    
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{

}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{

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
    [self.data setLength:0];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *jsonError = nil;
    id jsonData = [NSJSONSerialization JSONObjectWithData:self.data options:0 error:&jsonError];
    if(jsonData && [NSJSONSerialization isValidJSONObject:jsonData])
    {
        NSString *accesstoken = [jsonData objectForKey:@"access_token"];
        if(accesstoken)
        {
            [self.authDelegate didAuth:accesstoken];
            return;
        }
    }

    [self.authDelegate didAuth:nil];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
    return request;
}



@end
