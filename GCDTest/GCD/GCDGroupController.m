//
//  GCDGroupController.m
//  GCDTest
//
//  Created by wjyx on 2018/12/17.
//  Copyright © 2018 nuomi. All rights reserved.
//


#define LOG_FUNC_INVOKE_STATE NSLog(@"%s 函数调用线程:%@",__func__,NSThread.currentThread)

#import "GCDGroupController.h"

@interface GCDGroupController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView * tableView;
@property (nonatomic,strong) NSArray * list;

@end

@implementation GCDGroupController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"GCD-Group";
    [self initSubView];
    // 在dispatch queue追加的所有任务全部执行结束以后，追加一个收尾的任务。这种场景经常会遇到
    // 在使用串行队列时，只需将收尾任务最后追加到串行队列中。
    // 但在使用concurrent队列时，代码就会变得复杂。
    // 使用dispatch_group_t，可以让代码变得很简单。

}

/*---------------------------------测试代码-----------------------------------------*/
- (void)group_async_wait_forever{
    LOG_FUNC_INVOKE_STATE;
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("com.gcdtest.grouptest", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_async(group, queue, ^{
        NSLog(@"任务1 -->%@",NSThread.currentThread);
    });
    dispatch_group_async(group, queue, ^{
        sleep(1);
        NSLog(@"任务2 -->%@",NSThread.currentThread);
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"任务3 -->%@",NSThread.currentThread);
    });
    // queue中任务未全部执行前，会阻塞当前函数调用线程
    long result = dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    NSLog(@"5 -->%@ %@  任务等待结果%ld",NSThread.currentThread,group,result);
}


- (void)group_async_2000msTask_wait_500ms{
    LOG_FUNC_INVOKE_STATE;
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("com.gcdtest.grouptest", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_async(group, queue, ^{
        NSLog(@"任务1 -->%@",NSThread.currentThread);
    });
    dispatch_group_async(group, queue, ^{
        sleep(2);
        NSLog(@"任务2 耗时任务2秒钟 -->%@",NSThread.currentThread);
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"任务3 -->%@",NSThread.currentThread);
    });
    // 阻塞当前函数调用线程500ms,如果500ms内，block还未执行完毕，不再等待
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 500ull*NSEC_PER_MSEC);
    // 成功：result == 0
    // 失败：result != 0 , e.g timeout
    long result = dispatch_group_wait(group, time);
    NSLog(@"5 -->%@ %@  任务等待结果%ld",NSThread.currentThread,group,result);
}

- (void)group_async_300msTask_wait_500ms{
    LOG_FUNC_INVOKE_STATE;
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("com.gcdtest.grouptest", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_async(group, queue, ^{
        NSLog(@"任务1 -->%@",NSThread.currentThread);
    });
    dispatch_group_async(group, queue, ^{
        sleep(0.3);
        NSLog(@"任务2 耗时任务0.3秒钟 -->%@",NSThread.currentThread);
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"任务3 -->%@",NSThread.currentThread);
    });
    // 阻塞当前函数调用线程500ms,如果500ms内，block还未执行完毕，不再等待
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 500ull*NSEC_PER_MSEC);
    // 成功：result == 0
    // 失败：result != 0 , e.g timeout
    long result = dispatch_group_wait(group, time);
    NSLog(@"5 -->%@ %@  任务等待结果%ld",NSThread.currentThread,group,result);
}


- (void)group_async_notify{
    
    LOG_FUNC_INVOKE_STATE;
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("com.gcdtest.grouptest", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_async(group, queue, ^{
        NSLog(@"任务1 -->%@",NSThread.currentThread);
    });
    dispatch_group_async(group, queue, ^{
        sleep(1);
        NSLog(@"任务2 -->%@",NSThread.currentThread);
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"任务3 -->%@",NSThread.currentThread);
    });
    // 不会阻塞当前函数调用线程
    dispatch_group_notify(group, queue, ^{
        NSLog(@"收尾任务4 -->%@",NSThread.currentThread);
    });
    NSLog(@"5 -->%@ %@",NSThread.currentThread,group);
}

- (void)group_mutil_queue{
    LOG_FUNC_INVOKE_STATE;
    // 多个队列中的任务同步
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue_a = dispatch_queue_create("com.gcdtest.grouptest_a", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t queue_b = dispatch_queue_create("com.gcdtest.grouptest_b", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_async(group, queue_a, ^{
        NSLog(@"任务a_1 -->%@",NSThread.currentThread);
    });
    dispatch_group_async(group, queue_a, ^{
        NSLog(@"任务a_2 -->%@",NSThread.currentThread);
    });
    dispatch_group_async(group, queue_b, ^{
        NSLog(@"任务b_1 -->%@",NSThread.currentThread);
    });
    dispatch_group_async(group, queue_b, ^{
        NSLog(@"任务b_2 -->%@",NSThread.currentThread);
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"收尾任务4 -->%@",NSThread.currentThread);
    });
    NSLog(@"5 -->%@ %@",NSThread.currentThread,group);
}

- (void)group_queue_taskContainOtherAsyncTask{
    LOG_FUNC_INVOKE_STATE;
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("com.gcdtest.grouptest", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_async(group, queue, ^{
        NSLog(@"任务1 -->%@",NSThread.currentThread);
    });
    dispatch_group_async(group, queue, ^{
        [self asyncComplexTask:^{
            NSLog(@"任务2耗时任务结束，%@",NSThread.currentThread);
        }];
        NSLog(@"任务2 -->%@",NSThread.currentThread);
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"收尾任务4 -->%@",NSThread.currentThread);
    });
    NSLog(@"5 -->%@ %@",NSThread.currentThread,group);
}

- (void)group_enter_leave{
    LOG_FUNC_INVOKE_STATE;
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("com.gcdtest.grouptest", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_async(group, queue, ^{
        NSLog(@"任务1 -->%@",NSThread.currentThread);
    });
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        [self asyncComplexTask:^{
            NSLog(@"任务2耗时任务结束，%@",NSThread.currentThread);
            dispatch_group_leave(group);
        }];
        NSLog(@"任务2 -->%@",NSThread.currentThread);
    });

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"收尾任务4 -->%@",NSThread.currentThread);
    });
    NSLog(@"5 -->%@ %@",NSThread.currentThread,group);
}


// 异步复杂任务
- (void)asyncComplexTask:(dispatch_block_t)completeBlock{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        sleep(2);
        if (completeBlock) {
            dispatch_async(dispatch_get_main_queue(), completeBlock);
        }
    });
}

/*----------------------------------UI---------------------------------------*/

- (void)initSubView{
    self.list = @[
                  @{@"title": NSStringFromSelector(@selector(group_async_wait_forever))},
                  @{@"title": NSStringFromSelector(@selector(group_async_2000msTask_wait_500ms))},
                  @{@"title": NSStringFromSelector(@selector(group_async_300msTask_wait_500ms))},
                  @{@"title": NSStringFromSelector(@selector(group_async_notify))},
                  @{@"title": NSStringFromSelector(@selector(group_mutil_queue))},
                  @{@"title": NSStringFromSelector(@selector(group_queue_taskContainOtherAsyncTask))},
                  @{@"title": NSStringFromSelector(@selector(group_enter_leave))},
                  ];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 55;
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];
    self.view.backgroundColor = UIColor.whiteColor;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString * funcStr = self.list[indexPath.row][@"title"];
    SEL selector = NSSelectorFromString(funcStr);
    if (!selector) return;
    IMP imp = [self methodForSelector:selector];
    void (*func)(id, SEL) = (void *)imp;
    func(self, selector);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * identifier = @"GCDGroupCellIdentifier";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSString * title = self.list[indexPath.row][@"title"];
    cell.textLabel.text = title;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


@end
