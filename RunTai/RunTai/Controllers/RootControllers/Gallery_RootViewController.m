//
//  Gallery_RootViewController.m
//  RunTai
//
//  Created by Joel Chen on 16/3/15.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "Gallery_RootViewController.h"
#import "GalleryRiverCell.h"

#define IMAGEWIDTH 120
#define IMAGEHEIGHT 160

@interface Gallery_RootViewController ()<UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UICollectionView *myCollectionView;

@property (strong, nonatomic) NSMutableArray *list;

@end

@implementation Gallery_RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    _myCollectionView = ({
//        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds];
//        collectionView.backgroundColor = GlobleTableViewBackgroundColor;
//        collectionView.delegate = self;
//        collectionView.dataSource = self;
//        [collectionView registerClass:[GalleryRiverCell class] forCellWithReuseIdentifier:kCellIdentifier_GalleryRiverCell];
//        [self.view addSubview:collectionView];
//        [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.equalTo(self.view);
//        }];
//        collectionView;
//    });
    
    self.view.backgroundColor = GlobleTableViewBackgroundColor;
    
    self.list = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self getData];
    
    self.navigationItem.rightBarButtonItem = [self BarButtonItemWithBackgroudImageName:@"navigationbar_refresh" highBackgroudImageName:@"navigationbar_refresh_highlighted" target:self action:@selector(switchClicked)];
}

- (void)getData{
    NSMutableArray *photoPaths = [[NSMutableArray alloc]init];
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    
    NSLog(@"path =%@", path);
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSArray *fileNames = [fm contentsOfDirectoryAtPath:path error:nil];
    for (NSString *fileName in fileNames ) {
        if ([fileName hasSuffix:@"jpg"] || [fileName hasSuffix:@"JPG"]) {
            NSString *photoPath = [path stringByAppendingPathComponent:fileName];
            [photoPaths addObject:photoPath];
        }
    }
    //添加9个图片到界面中
    if (photoPaths) {
        for (int i = 0; i < 10; i++) {
            float X = arc4random()%((int)self.view.bounds.size.width - IMAGEWIDTH);
            float Y = arc4random()%((int)self.view.bounds.size.height - IMAGEHEIGHT - 10);
            float W = IMAGEWIDTH;
            float H = IMAGEHEIGHT;
            
            GalleryRiverCell *photo = [[GalleryRiverCell alloc]initWithFrame:CGRectMake(X, Y, W, H)];
            [photo updateImage:[UIImage imageWithContentsOfFile:photoPaths[i]]];
            [self.view addSubview:photo];
            
            float alpha = i*1.0/10 + 0.4;
            [photo setImageAlphaAndSpeedAndSize:alpha];
            
            [self.list addObject:photo];
        }
    }
}

- (void)switchClicked{
    for (GalleryRiverCell *photo in self.list) {
        if (photo.state == XYZPhotoStateDraw || photo.state == XYZPhotoStateBig) {
            return;
        }
    }
    
    float W = self.view.bounds.size.width / 3;
    float H = self.view.bounds.size.height / 3;
    
    [UIView animateWithDuration:1 animations:^{
        for (int i = 0; i < self.list.count; i++) {
            GalleryRiverCell *photo = [self.list objectAtIndex:i];
            
            if (photo.state == XYZPhotoStateNormal) {
                photo.oldAlpha = photo.alpha;
                photo.oldFrame = photo.frame;
                photo.oldSpeed = photo.speed;
                photo.alpha = 1;
                photo.frame = CGRectMake(i%3*W, i/3*H, W, H);
                photo.imageView.frame = photo.bounds;
                photo.drawView.frame = photo.bounds;
                photo.speed = 0;
                photo.state = XYZPhotoStateTogether;
            } else if (photo.state == XYZPhotoStateTogether) {
                photo.alpha = photo.oldAlpha;
                photo.frame = photo.oldFrame;
                photo.speed = photo.oldSpeed;
                photo.imageView.frame = photo.bounds;
                photo.drawView.frame = photo.bounds;
                photo.state = XYZPhotoStateNormal;
            }
        }
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIBarButtonItem *)BarButtonItemWithBackgroudImageName:(NSString *)backgroudImage highBackgroudImageName:(NSString *)highBackgroudImageName target:(id)target action:(SEL)action
{
    UIButton *button = [[UIButton alloc] init];
    [button setBackgroundImage:[UIImage imageWithName:backgroudImage] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageWithName:highBackgroudImageName] forState:UIControlStateHighlighted];
    
    // 设置按钮的尺寸为背景图片的尺寸
    button.size = button.currentBackgroundImage.size;
    
    // 监听按钮点击
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

#pragma mark -UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.list.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    GalleryRiverCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier_GalleryRiverCell forIndexPath:indexPath];
    
    return cell;
}


#pragma mark -UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}


#pragma mark -UICollectionViewDelegateFlowLayout

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((CGRectGetWidth(collectionView.bounds)-20)/2, 80);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
