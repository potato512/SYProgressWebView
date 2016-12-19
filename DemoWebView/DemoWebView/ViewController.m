//
//  ViewController.m
//  DemoWebView
//
//  Created by zhangshaoyu on 16/12/14.
//  Copyright © 2016年 zhangshaoyu. All rights reserved.
//

#import "ViewController.h"
#import "SYWebViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"网页加载";
    
    UIBarButtonItem *pushItem = [[UIBarButtonItem alloc] initWithTitle:@"push" style:UIBarButtonItemStyleDone target:self action:@selector(pushClick)];
    UIBarButtonItem *presentItem = [[UIBarButtonItem alloc] initWithTitle:@"present" style:UIBarButtonItemStyleDone target:self action:@selector(presentClick)];
    self.navigationItem.rightBarButtonItems = @[pushItem, presentItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
}

- (void)pushClick
{
    SYWebViewController *nextVC = [[SYWebViewController alloc] init];
    [self.navigationController pushViewController:nextVC animated:YES];
}

- (void)presentClick
{
    SYWebViewController *nextVC = [[SYWebViewController alloc] init];
    UINavigationController *nextNav = [[UINavigationController alloc] initWithRootViewController:nextVC];
    [self presentViewController:nextNav animated:YES completion:nil];
}

@end
