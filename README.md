## YKScrollView


`YKScrollView` is an iOS `Autoscroll Banner`. 


*Advantages* 

	- Just create Three ImageView object to display the images
	- when you see the middle imageView the 2 images preload
	- You can set the animation time easy

	
![](http://7xr4z1.com1.z0.glb.clouddn.com/Untitled.gif)


### Requirements

`YKScrollView ` works on iOS 6+ and requires ARC to build. It depends on the following frameworks, which should  be included with most Project you work on:

* SDWebImage


MayBe After some versions this dependency will be removed.


### Usage

```objc
    YKCycleScrollView * cycleScrollView = [[YKCycleScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 150)];
    
    [cycleScrollView setImageUrlNames:@[imagePath1, imagePath2, imagePath3, imagePath4] animationDuration:3];
    
    [self.view addSubview:cycleScrollView];
```

Everything have been done, you can also setting style like this



``` objc
	 //You can setting the color like PageControl
    cycleScrollView.pageControl.normalColor = [UIColor greenColor];
    cycleScrollView.pageControl.selectedColor = [UIColor redColor];
    
    //You can Change the pointStyle By your self
    cycleScrollView.pageControl.pointStyle = YTPageControlPointStyleRectangle;
```

If you want to observe the imageView click, you can the delegate like `UITableView`

The protocol is `YKCycleScrollViewDelegate`

```
- (void)cycleScrollView:(YKCycleScrollView *)cycleScrollView DidTapImageView:(NSInteger)index
{
	//the index is the image order you tap
}
```


