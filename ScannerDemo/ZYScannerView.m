//
//  ZYScannerView.m
//  ScannerDemo
//
//  Created by zy on 16/1/31.
//  Copyright © 2016年 zybug. All rights reserved.
//

#import "ZYScannerView.h"
#import <AVFoundation/AVFoundation.h>

@interface ZYScannerView () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *perviewLayer;
@property (nonatomic, strong) UIView *scannerView;

@end

@implementation ZYScannerView


+ (ZYScannerView *)sharedScannerView {
    static ZYScannerView *v = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        v = [[ZYScannerView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    });
    return v;
}

- (void)showOnView:(UIView *)view block:(BackBlock)block{
    self.back = [block copy];
    [self.session startRunning];
    [view addSubview:self];
    self.hidden = NO;
}

- (void)dismiss {
    [self.session stopRunning];
    self.hidden = YES;
    [self removeFromSuperview];
}

#pragma mark - 内部调用

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        _scannerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 250)];
        _scannerView.backgroundColor = [UIColor clearColor];
        _scannerView.layer.borderWidth = 2.0;
        _scannerView.layer.borderColor = [UIColor whiteColor].CGColor;
        _scannerView.center = self.center;
        [self addSubview:_scannerView];
        [self start];
        
    }
    return self;
}

- (void)start {
    // 摄像头设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 设置输入
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error) {
        NSLog(@"启动摄像头失败：%@",error.localizedDescription);
        return;
    }
    
    // 设置输入元素
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // 设置拍摄会话
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    [session addInput:input];
    [session addOutput:output];
    
    session.sessionPreset = AVCaptureSessionPreset1920x1080;
    
    // 制定输入类型
    [output setMetadataObjectTypes:[output availableMetadataObjectTypes]];
    
    
    // 设置预览图次
    AVCaptureVideoPreviewLayer *perviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    perviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    perviewLayer.frame = self.bounds;
    _perviewLayer = perviewLayer;
    
    [self.layer insertSublayer:_perviewLayer atIndex:0];
    //    [self.view.layer addSublayer:_perviewLayer];
    
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGRect cropRect = _scannerView.frame;
    CGFloat p1 = size.height/size.width;
    CGFloat p2 = 1920./1080.;  //使用1080p的图像输出
    if (p1 < p2) {
        CGFloat fixHeight = [UIScreen mainScreen].bounds.size.width * 1920. / 1080.;
        CGFloat fixPadding = (fixHeight - size.height)/2;
        output.rectOfInterest = CGRectMake((cropRect.origin.y + fixPadding)/fixHeight,
                                           cropRect.origin.x/size.width,
                                           cropRect.size.height/fixHeight,
                                           cropRect.size.width/size.width);
    } else {
        CGFloat fixWidth = [UIScreen mainScreen].bounds.size.height * 1080. / 1920.;
        CGFloat fixPadding = (fixWidth - size.width)/2;
        output.rectOfInterest = CGRectMake(cropRect.origin.y/size.height,
                                           (cropRect.origin.x + fixPadding)/fixWidth,
                                           cropRect.size.height/size.height,
                                           cropRect.size.width/fixWidth);
    }
    
    _session = session;

}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection

{
    
    NSLog(@"%@", metadataObjects);
    if (metadataObjects.count > 0) {
        
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        NSLog(@"obj:%@",obj);
        NSLog(@"stringValue:%@",obj.stringValue);
        if (self.back) {
            self.back(obj.stringValue);
            [self dismiss];
        }
    }
}





@end
