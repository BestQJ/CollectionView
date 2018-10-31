//
//  HomeViewController.m
//  TestAPI
//
//  Created by 乔杰 on 2018/10/30.
//  Copyright © 2018年 乔杰. All rights reserved.
//

#import "HomeViewController.h"
#import "AACollectionViewLayout.h"
#import "MJRefresh.h"

@interface HomeViewController () <UICollectionViewDelegate, UICollectionViewDataSource, AACollectionViewLayoutDelegate>

@property (nonatomic, strong) UICollectionView *mCollectionView;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    [self.view addSubview: self.mCollectionView];
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return 80;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"myCell" forIndexPath: indexPath];
    
    cell.backgroundColor = [UIColor colorWithRed: arc4random()%256/255.0 green: arc4random()%256/255.0 blue: arc4random()%256/255.0 alpha: 1];
    
    return cell;
}


#pragma mark - AACollectionViewLayoutDelegate
//竖直滚动时生效
- (CGFloat)customLayout:(AACollectionViewLayout *)layout heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return arc4random()%150 + 100;
}

//水平滚动时生效
- (CGFloat)customLayout:(AACollectionViewLayout *)layout widthForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return arc4random()%150 + 100;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *reusableView;
    if (kind == UICollectionElementKindSectionHeader) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind: UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
        reusableView.backgroundColor = [UIColor redColor];
    }else {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind: UICollectionElementKindSectionFooter withReuseIdentifier:@"footer" forIndexPath:indexPath];
        reusableView.backgroundColor = [UIColor greenColor];
    }
    return reusableView;
}

#pragma mark - Getter

- (UICollectionView *)mCollectionView {
    if (!_mCollectionView) {
        
        AACollectionViewLayout *layout = [[AACollectionViewLayout alloc] init];
        layout.delegate = self;

        _mCollectionView = [[UICollectionView alloc] initWithFrame: CGRectMake(0, 44, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 44) collectionViewLayout: layout];
        _mCollectionView.backgroundColor = [UIColor whiteColor];
        _mCollectionView.delegate = self;
        _mCollectionView.dataSource = self;
        _mCollectionView.showsVerticalScrollIndicator = NO;
        _mCollectionView.showsHorizontalScrollIndicator = NO;
        [_mCollectionView registerClass: [UICollectionViewCell class] forCellWithReuseIdentifier: @"myCell"];
        
        [_mCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
        [_mCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer"];

//        // 下拉刷新
//        __block typeof(self) weakSelf = self;
//        self.mCollectionView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//            // 模拟延迟加载数据，因此2秒后才调用（真实开发中，可以移除这段gcd代码）
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                // 结束刷新
//                [weakSelf.mCollectionView.mj_header endRefreshing];
//            });
//        }];
//        
//        // 设置自动切换透明度(在导航栏下面自动隐藏)
//        _mCollectionView.mj_header.automaticallyChangeAlpha = YES;
//        
//        // 上拉刷新
//        self.mCollectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
//            // 模拟延迟加载数据，因此2秒后才调用（真实开发中，可以移除这段gcd代码）
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                // 结束刷新
//                [weakSelf.mCollectionView.mj_footer endRefreshing];
//            });
//        }];
 
    }
    return _mCollectionView;
}


@end
