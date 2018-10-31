//
//  AACollectionViewLayout.h
//  TestAPI
//
//  Created by 乔杰 on 2018/10/30.
//  Copyright © 2018年 乔杰. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class AACollectionViewLayout;

@protocol AACollectionViewLayoutDelegate <NSObject>

@required

/**
 *  竖直滚动时生效单元格高度
 *
 *  @paream layout      视图布局
 *  @paream indexPath   单元格索引
 *
 *  @return 返回单元格高度
 */
- (CGFloat)customLayout:(AACollectionViewLayout *)layout heightForItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  水平滚动时生效单元格宽度
 *
 *  @paream layout      视图布局
 *  @paream indexPath   单元格索引
 *
 *  @return 返回单元格宽度
 */
- (CGFloat)customLayout:(AACollectionViewLayout *)layout widthForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional

/**
 *  设置CollectionView滚动方向
 *  @paream layout      视图布局
 *  @return 返回CollectionView滚动方向
 */
- (UICollectionViewScrollDirection)customLayoutScrollDirection:(AACollectionViewLayout *)layout;

/**
 *  设置CollectionView滚动方向上的列数或者行数
 *  @paream layout      视图布局
 *  @paream section     区索引
 *  @return 返回滚动方向上的列数或者行数
 */
- (NSInteger)customLayout:(AACollectionViewLayout *)layout numberOfScrollForSection:(NSInteger)section;

/**
 *  设置CollectionView单元格间距
 *  @paream layout      视图布局
 *  @paream section     区索引
 *  @return 返回单元格间距
 */
- (UIEdgeInsets)customLayout:(AACollectionViewLayout *)layout itemEdgeInsetForSection:(NSInteger)section;

/**
 *  设置CollectionView区头高度
 *  @paream layout      视图布局
 *  @paream section     区索引
 *  @return 返回区头高度
 */
- (CGFloat)customLayout:(AACollectionViewLayout *)layout headViewHeightForSection:(NSInteger)section;

/**
 *  设置CollectionView区尾高度
 *  @paream layout      视图布局
 *  @paream section     区索引
 *  @return 返回区尾高度
 */
- (CGFloat)customLayout:(AACollectionViewLayout *)layout footViewHeightForSection:(NSInteger)section;

/**
 *  设置CollectionView区头缩进
 *  @paream layout      视图布局
 *  @paream section     区索引
 *  @return 返回区头缩进
 */
- (UIEdgeInsets)customLayout:(AACollectionViewLayout *)layout edgeInsetForSectionHead:(NSInteger)section;

/**
 *  设置CollectionView区尾缩进
 *  @paream layout      视图布局
 *  @paream section     区索引
 *  @return 返回区尾缩进
 */
- (UIEdgeInsets)customLayout:(AACollectionViewLayout *)layout edgeInsetForSectionFoot:(NSInteger)section;

@end

@interface AACollectionViewLayout : UICollectionViewLayout

//代理
@property (nonatomic, weak)   id<AACollectionViewLayoutDelegate> delegate;
//单元格间距设置此参数默认各区单元格间距相同
@property (nonatomic, assign) UIEdgeInsets itemEdgeInsets;
//滚动方向
@property (nonatomic, assign) UICollectionViewScrollDirection scrollDirection;

@end

NS_ASSUME_NONNULL_END
