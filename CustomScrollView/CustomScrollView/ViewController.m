//
//  ViewController.m
//  CustomScrollView
//
//  Created by bifangao on 16/6/14.
//  Copyright © 2016年 bifangao. All rights reserved.
//

#import "ViewController.h"
#import "BFScrollView.h"

@interface ViewController ()
@property (nonatomic, strong) BFScrollView *scrollView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self customScrollView];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)customScrollView {
    self.scrollView = [[BFScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.contentSize = CGSizeMake(800, 1000);
    UIView *redView = [[UIView alloc] initWithFrame:CGRectMake(20, 20, 100, 100)];
    UIView *greenView = [[UIView alloc] initWithFrame:CGRectMake(150, 160, 150, 200)];
    UIView *blueView = [[UIView alloc] initWithFrame:CGRectMake(40, 400, 200, 150)];
    UIView *yellowView = [[UIView alloc] initWithFrame:CGRectMake(100, 600, 180, 150)];
    
    redView.backgroundColor = [UIColor colorWithRed:0.815 green:0.007 blue:0.105 alpha:1];
    greenView.backgroundColor = [UIColor colorWithRed:0.494 green:0.827 blue:0.129 alpha:1];
    blueView.backgroundColor = [UIColor colorWithRed:0.29 green:0.564 blue:0.886 alpha:1];
    yellowView.backgroundColor = [UIColor colorWithRed:0.972 green:0.905 blue:0.109 alpha:1];
    
    [self.scrollView addSubview:redView];
    [self.scrollView addSubview:greenView];
    [self.scrollView addSubview:blueView];
    [self.scrollView addSubview:yellowView];
    
    
    
    UIView *redView1 = [[UIView alloc] initWithFrame:CGRectMake(20, 500+20, 100, 100)];
    UIView *greenView1 = [[UIView alloc] initWithFrame:CGRectMake(150, 500+160, 150, 200)];
    UIView *blueView1 = [[UIView alloc] initWithFrame:CGRectMake(40, 500+400, 200, 150)];
    UIView *yellowView1 = [[UIView alloc] initWithFrame:CGRectMake(100, 500+600, 180, 150)];
    
    redView1.backgroundColor = [UIColor purpleColor];
    greenView1.backgroundColor = [UIColor redColor];
    blueView1.backgroundColor = [UIColor grayColor];
    yellowView1.backgroundColor = [UIColor blackColor];
    
    [self.scrollView addSubview:redView1];
    [self.scrollView addSubview:greenView1];
    [self.scrollView addSubview:blueView1];
    [self.scrollView addSubview:yellowView1];
    
    
    [self.view addSubview:_scrollView];

}
@end
