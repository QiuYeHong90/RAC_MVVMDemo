//
//  ViewController.m
//  RACDemo
//
//  Created by 赵 on 2018/1/25.
//  Copyright © 2018年 袁书辉. All rights reserved.
//


#import "ViewModel.h"

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *button;

@property (nonatomic,copy) NSString *reactiveString;

@property (nonatomic,strong) ViewModel * viewModel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.reactiveString = @"ABC";
//    监听属性值变化
    [[ RACObserve(self,reactiveString) filter:^BOOL(id value) {
        return [value hasPrefix:@"A"];
    }] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    
    
    __block int aNumber = 0;
    RACSignal *aSignal =[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        aNumber++;
        [subscriber sendNext:@(aNumber)];
        [subscriber sendCompleted];
        return nil;
    }];
 
    // This will print "subscriber one: 1"
    [aSignal subscribeNext:^(id x) {
        NSLog(@"subscriber one: %@", x);
    }];
    
    // This will print "subscriber two: 2"
    [aSignal subscribeNext:^(id x) {
        NSLog(@"subscriber two: %@", x);
    }];

    // This will print "subscriber two: 2"
    [aSignal subscribeNext:^(id x) {
        NSLog(@"subscriber three: %@", x);
    }];
    
    self.viewModel = [ViewModel new];
    self.viewModel.usernameValid = 0.5;
    
    RACSignal *usernameIsValidSignal = RACObserve(self.viewModel, usernameValid);
    RAC(self.button, alpha) = [usernameIsValidSignal
                               map:^id(NSNumber *valid) {
                                   
                                   NSLog(@"===%@",valid);
                                   return valid. boolValue?@1:@0.5;
                               }];
  
    
//    3. Subscriber － 订阅者 － RACSubscriber协议
    RACSignal *repeatSignal = [[RACSignal interval:1 onScheduler:[RACScheduler mainThreadScheduler]] repeat];
    [repeatSignal subscribeNext:^(id x) {
        NSLog(@"===%@",x);
    }];
    
    
    [repeatSignal subscribeNext: ^(NSDate* time){
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm:ss"];
        NSLog(@"%@",[formatter stringFromDate:time]);
    }];
    
 
//    4. Subjects － 手动控制信号 － RACSubject
    
    // 1.创建信号
    RACSubject *subject = [RACSubject subject];
    
    // 2.订阅信号 First
    [subject subscribeNext:^(id x) {
        // block调用时刻：当信号发出新值，就会调用.
        NSLog(@"FirstSubscribeNext%@",x);
    }];
    // 2.订阅信号 Second
    [subject subscribeNext:^(id x) {
        // block调用时刻：当信号发出新值，就会调用.
        NSLog(@"SecondSubscribeNext%@",x);
    }];
    // 3.发送信号
    [subject sendNext:@"1"];
    [subject sendNext:@"2"];
    
//    5. ReplaySubject － 手动回放控制信号 － RACReplaySubject
    // 1.创建信号
    RACReplaySubject *replaySubject = [RACReplaySubject subject];
    // 2.发送信号
    [replaySubject sendNext:@"1"];
    [replaySubject sendNext:@"2"];
    // 3.订阅信号 First
    [replaySubject subscribeNext:^(id x) {
        NSLog(@"FirstSubscribeNext%@",x);
    }];
    // 3.订阅信号 Second
    [replaySubject subscribeNext:^(id x) {
        NSLog(@"SecondSubscribeNext%@",x);
    }];
    
//    6. Command－ 命令信号 － RACCommand
//    表示订阅响应Action信号，通常由UI来出发，比如一个Button当控件被触发时会被自动禁用掉。
    
//    UIButton *reactiveBtn = [[UIButton alloc] init];
    [self.button setTitle:@"点我" forState:UIControlStateNormal];
    self.button.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(UIButton *input) {
        NSLog(@"点击了我:%@",input.currentTitle);
        //返回一个空的信号量
        return [RACSignal empty];
    }];
//    7. Sequences－ 集合 － RACSequence
//    表示一个不可变的序列值且不能包含空值，使用-rac_sequence.signal来获取Signal。
    RACSignal *signal = [@"A B C D E F G H I" componentsSeparatedByString:@" "].rac_sequence.signal;
    // Outputs
    [signal subscribeNext:^(NSString *x) {
        NSLog(@"%@", x);
    }];
    

    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
