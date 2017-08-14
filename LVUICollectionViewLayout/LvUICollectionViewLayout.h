//
//  LvUICollectionViewLayout.h
//  CardTableView
//
//  Created by lvzhenhua on 16/7/28.
//  Copyright © 2016年 viper. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LvUICollectionViewLayout;
@protocol LvUICollectionViewLayoutDelegate <NSObject>

@required

- (CGFloat)collectionViewLayout:(LvUICollectionViewLayout *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath itemWidth:(CGFloat)itemWidth;

@optional
- (CGFloat)columnCountInLayout:(LvUICollectionViewLayout *)collectionViewLayout;
- (CGFloat)columnMarginInLayout:(LvUICollectionViewLayout *)collectionViewLayout;
- (CGFloat)rowMarginInLayout:(LvUICollectionViewLayout *)collectionViewLayout;
- (UIEdgeInsets)edgeInsetsInLayout:(LvUICollectionViewLayout *)collectionViewLayout;
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(LvUICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(LvUICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section;
/** 这个方法是在刷新的时候需要去调用的（Bug） */
- (CGFloat)flowLayoutRefreshAndLoadMoreData;
@end

@interface LvUICollectionViewLayout : UICollectionViewFlowLayout

@property (nonatomic ,weak) id<LvUICollectionViewLayoutDelegate> delegate;
@end
