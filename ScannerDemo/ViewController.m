//
//  ViewController.m
//  ScannerDemo
//
//  Created by zy on 16/1/31.
//  Copyright © 2016年 zybug. All rights reserved.
//

#import "ViewController.h"
#import "ZYScannerView.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)btnClick:(id)sender {
    __weak typeof(_detailLabel) weakLabel = _detailLabel;
    [[ZYScannerView sharedScannerView] showOnView:self.view block:^(NSString *str) {
        __strong typeof(weakLabel) strongLabel = weakLabel;
        strongLabel.text = str;
    }];
}

@end
