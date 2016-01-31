//
//  ZYScannerView.h
//  ScannerDemo
//
//  Created by zy on 16/1/31.
//  Copyright © 2016年 zybug. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^BackBlock)(NSString *str);

@interface ZYScannerView : UIView

@property (nonatomic, copy) BackBlock back;

+ (ZYScannerView *)sharedScannerView;

- (void)showOnView:(UIView *)view block:(BackBlock)block;

- (void)dismiss;

@end
