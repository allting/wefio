//
//  ViewController.m
//  Wefio
//
//  Created by kkr on 2015. 6. 29..
//  Copyright (c) 2015년 allting. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

@interface ViewController()
@property (nonatomic) IBOutlet WebView* webView;
@property (nonatomic) JSContext* context;
@property (nonatomic) JSManagedValue* wefio;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.webView.frameLoadDelegate = self;
    self.webView.UIDelegate = self;
    
    NSString* indexFile = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"html/sakamies-Lion-CSS-UI-Kit"];
    [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:indexFile]]];
    
    [self loadPlugin];
}

-(void)loadPlugin{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Wefio" ofType:@"js"];
    NSString *script = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    _context = [[JSContext alloc] init];
    
    [self loadPluginWithContext:_context script:script];
}

-(void)loadPluginWithContext:(JSContext*)context script:(NSString*)script{
    // We insert the AppDelegate into the global object so that when we call
    // -addManagedReference:withOwner: for the plugin object we're about to load
    // and pass the AppDelegate as the owner, the AppDelegate itself is reachable from
    // within JavaScript. If we didn't do this, the AppDelegate wouldn't be reachable
    // from JavaScript, and there wouldn't be anything keeping the plugin object alive.
    context[@"AppDelegate"] = self;
    
    // Insert a block so that the plugin can create NSColors to return to us later.
    context[@"jsc_files"] = ^(NSString *dir){
        NSLog(@"dir:%@", dir);
        return @[@{@"name":@"test1", @"size":@1234, @"attributes":@755, @"type":@"image/png"}];
    };
    
    JSValue *plugin = [context evaluateScript:script];
    
    _wefio = [JSManagedValue managedValueWithValue:plugin];
    [_context.virtualMachine addManagedReference:_wefio withOwner:self];
}

-(void)unloadPlugin{
    [_context.virtualMachine removeManagedReference:_wefio withOwner:self];
    _wefio = nil;
    _context = nil;
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
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Wefio" ofType:@"js"];
    NSString *script = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];

    [self loadPluginWithContext:context script:script];
}

@end
