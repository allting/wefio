//
//  ViewController.m
//  Wefio
//
//  Created by kkr on 2015. 6. 29..
//  Copyright (c) 2015년 allting. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

@interface ViewController()
@property (nonatomic) IBOutlet WebView* webView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.webView.frameLoadDelegate = self;
    self.webView.UIDelegate = self;
    
    NSString* indexFile = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"html/sakamies-Lion-CSS-UI-Kit"];
    [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:indexFile]]];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

-(void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame
{
    //Did start Load
    // Only report feedback for the main frame.
    if (frame == [sender mainFrame]){
        NSString *url = [[[[frame provisionalDataSource] request] URL] absoluteString];
        NSLog(@"Main frame start webView:%@, webFrame:%@, url:%@", sender, frame, url);
    }
}

- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame
{
    // Report feedback only for the main frame.
    if (frame == [sender mainFrame]){
        [[sender window] setTitle:title];
    }
}

-(void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    //Did finish Load
    NSLog(@"completed webView:%@, webFrame:%@, url:%@", sender, frame, frame.dataSource.request.URL);
    NSString* html = [(DOMHTMLElement *)[[frame DOMDocument] documentElement] outerHTML];
    NSLog(@"completed responseHeader:%@, html:%@", frame.dataSource.response, html);
    
}

-(void)webView:(WebView *)webView didCreateJavaScriptContext:(JSContext *)context forFrame:(WebFrame *)frame{
    
}

@end
