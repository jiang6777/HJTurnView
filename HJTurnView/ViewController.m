//
//  ViewController.m
//  HJTurnView
//
//  Created by Power on 2019/11/11.
//  Copyright © 2019 Power. All rights reserved.
//

#import "ViewController.h"
#import "PVTurnView.h"

@interface ViewController ()

@property (nonatomic, strong) PVTurnView *turnView;
@property (nonatomic, strong) NSArray *array;
@property (weak, nonatomic) IBOutlet UIButton *targetBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.turnView = [[PVTurnView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 160, 100, 320, 320)];
    [self.view addSubview:self.turnView];
    self.array = @[@"-2.0",@"-1.7",@"-1.3",@"-1.0",@"-0.7",@"-0.3",@"0",@"+0.3",@"+0.7",@"+1.0",@"+1.3",@"+1.7",@"+2.0"];
    [self.turnView addTurnView:self.array];
}

@end
