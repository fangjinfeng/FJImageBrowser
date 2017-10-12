# FJImageBrowser

具体详见:[简书链接](http://www.jianshu.com/p/57c94ab121c3)

图片浏览器 :上下拖动、横竖屏旋转、支持加载过程先居中，加载完成后放大和直接放大两种效果、支持本地图片和网络图片自动判断。

# 集成方法

1. 静态：手动将``FJImageBrowser``文件夹拖入到工程中。
2. 动态：``CocoaPods：pod 'FJImageBrowser', '~> 1.0.0``。

效果图:

![imageBrowserPortrait](https://github.com/fangjinfeng/FJImageBrowser/blob/master/FJImageBrowserDemo/Snapshots/imageBrowserPortrait.gif)

![imageBrowserLandscape](https://github.com/fangjinfeng/FJImageBrowser/blob/master/FJImageBrowserDemo/Snapshots/imageBrowserLandscape.gif)

![imageBrowser](https://github.com/fangjinfeng/FJImageBrowser/blob/master/FJImageBrowserDemo/Snapshots/imageBrowser.gif)


# 一. 属性分析

**1. photoBrowserType:**

    /**
     浏览 显示 模式
     */
    @property (nonatomic, assign) FJPhotoViewShowType photoBrowserType;

``FJPhotoViewShowType`` 有两种方式:

    // 显示 模式
    typedef NS_ENUM(NSInteger, FJPhotoViewShowType){
        // 模仿微博显示
        FJPhotoViewShowTypeOfWeiBo = 0,
        // 模仿微信显示
        FJPhotoViewShowTypeOfWeiXin = 1,
    };

``FJPhotoViewShowTypeOfWeiBo`` 模式: 就是加载过程中直接放大，类似微博图片浏览器的效果。

``FJPhotoViewShowTypeOfWeiXin``模式:是加载过程中先将小图居中，加载完成后在放大。类似早起微信图片浏览器的效果，现在微信图片浏览器也改成加载过程中直接放大的效果。

**2. photoModeArray:**

    /**
     视图模型数据源(不需要自己 实现代理,如果实现,代理优先级高)
     */
    @property (nonatomic, copy, nonnull) NSMutableArray  <FJImageModel *>*photoModeArray;

``photoModeArray``是数据源，里面包含的是``FJImageModel``模型。

    @interface FJImageModel : NSObject
    // 图片url / 图片image
    @property (nonatomic, weak) id imageInfo;
    // 原图
    @property (nonatomic, weak) UIImageView *imageView;
    @end

``FJImageModel``有两个属性:

- ``imageInfo`` 是数据源，比如图片``URL``地址或是本地图片的``image``

- ``imageView`` 是原图，这个属性主要用来作为占位图、获取原图位置等。

如果传入的是这个视图模型数据源，就不需要实现获取占位图和原来位置的代理，库里面会自动计算，但如果外部实现代理，代理的优先级高。

**3. photoDataArray:**

    /**
     图片数据源（需要自己实现代理）
     */
    @property (nonatomic, copy, nonnull) NSArray  *photoDataArray;

``photoDataArray`` 图片数据源，里面主要包含图片URL或是本地图片的``image``，如果传入这个参数，就需要实现代理来获取占位图和原图位置。

**4. isForbidLandscape:**

是否禁止横屏，如果为``YES``,横屏时，图片浏览依然保持竖屏状态。如果为``NO``，横屏时就进行横屏适配。

**5. isHidesOriginal:**

图片浏览拖动时候是否隐藏原来的图片。

# 二. 使用方法

**1. photoModeArray的使用方法(UICollectionView中)**

-  生成``imageModels``：


        self.imageModels = [NSMutableArray array];
    
        // *************************绑定JKPhotoModel*********************************
    
        [self.bigImageArray enumerateObjectsUsingBlock:^(NSString *imageUrl, NSUInteger idx, BOOL * _Nonnull stop) {
        
           FJImageModel * photoModel = [[FJImageModel alloc] init];
          photoModel.imageInfo = imageUrl;
           [self.imageModels addObject:photoModel];
        }];

- 对原图赋值


       - (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
        FJCollectionImageViewCell *cell = [FJCollectionImageViewCell cellWithCollectionView:collectionView atIndexPath:indexPath];
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:self.smallImageArray[indexPath.row]] placeholderImage:[UIImage imageNamed:KFJPhotoBrowserDefaultImage]];
    
            // *************************绑定cell和imageView*********************************
    
           FJImageModel * photoModel = self.imageModels[indexPath.row];
            photoModel.imageView = cell.imageView;
            return cell;
       }

- 显示图片浏览器


        - (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
            FJImageBrowserView *photosView = [[FJImageBrowserView alloc] init];
           photosView.photoBrowserType = self.switchShowBtn.selected;
            photosView.photoModeArray = self.imageModels;
            photosView.selectedIndex = indexPath.row;
            photosView.isHidesOriginal = YES;
            [photosView showPhotoBrowser];
       }

**2. photoDataArray的使用方法(UICollectionView中)**

- 显示图片浏览器


      - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

           [tableView deselectRowAtIndexPath:indexPath animated:NO];
           FJImageBrowserView *photosView = [[FJImageBrowserView alloc] init];
           photosView.photoDataArray = self.bigImageArray;
           photosView.selectedIndex = indexPath.row;
           photosView.photoBrowserDelegate = self;
           [photosView showPhotoBrowser];
       }

- 实现代理方法



        ************************************* PhotosViewDelegate ***************************************/

        // 返回图片占位小图
        - (UIImageView *)photoBrowser:(FJImageBrowserView *)browser placeholderImageForIndex:(NSInteger)index {
           ChatTableViewCell *cell = (ChatTableViewCell *)[self tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
           return cell.imgView;
       }

       // 返回原图片位置
        - (CGRect)photoBrowser:(FJImageBrowserView *)browser targetRectForIndex:(NSInteger)index {
    
            NSIndexPath *tmpIndexPath = [NSIndexPath indexPathForItem:index inSection:0];
    
             ChatTableViewCell *cell = (ChatTableViewCell *)[self tableView:self.tableView cellForRowAtIndexPath:tmpIndexPath];
              CGRect newImageViewFrame = [cell.imgView convertRect:cell.imgView.bounds toView:self.view];
    
           // 先计算cell的位置,再转化到view中的位置.
           CGRect rectInTableView = [self.tableView rectForRowAtIndexPath:tmpIndexPath];
    
            CGRect rectInSuperView = [self.tableView convertRect:rectInTableView toView:[UIApplication sharedApplication].keyWindow];
            newImageViewFrame.origin = CGPointMake(newImageViewFrame.origin.x, rectInSuperView.origin.y + 10);

           return newImageViewFrame;
        }


