//
//  ViewController.m
//  CorePlotStudy
//
//  Created by suhc on 16/1/19.
//  Copyright © 2016年 kongjianjia. All rights reserved.
//

#import "ViewController.h"
#import "CorePlot-CocoaTouch.h"
#import "CPTGraphHostingView.h"

#define BLUE_PLOT_IDENTIFIER @"BLUE_PLOT_IDENTIFIER"
#define GREEN_PLOT_IDENTIFIER @"GREEN_PLOT_IDENTIFIER"
@interface ViewController ()<CPTPlotDataSource,CPTAxisDelegate>
{
    CPTXYGraph *_graph;
    NSMutableArray *_dataForPlot;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupCoreplotViews];
}

- (void)setupCoreplotViews{
    // Create graph from theme: 设置主题
    _graph = [[CPTXYGraph alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    _graph.backgroundColor = (__bridge CGColorRef _Nullable)([CPTColor redColor]);
    CPTTheme *theme = [CPTTheme themeNamed:kCPTSlateTheme];
    [_graph applyTheme:theme];
    
    CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    hostingView.collapsesLayers = NO; // Setting to YES reduces GPU memory usage, but can slow drawing/scrolling
    hostingView.hostedGraph = _graph;
    [self.view addSubview:hostingView];
    
    _graph.paddingLeft = _graph.paddingRight = 50.0;
    _graph.paddingTop = _graph.paddingBottom = 50.0;
    
    // Setup plot space: 设置一屏内可显示的x,y量度范围
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)_graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.xRange = [self CPTPlotRangeFromFloat:1.0 length:2.0];
    plotSpace.yRange = [self CPTPlotRangeFromFloat:1.0 length:3.0];
    
    // Axes: 设置x,y轴属性，如原点，量度间隔，标签，刻度，颜色等
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)_graph.axisSet;
    lineStyle.miterLimit = 1.0f;
    lineStyle.lineWidth = 2.0;
    lineStyle.lineColor = [CPTColor redColor];
    
    CPTXYAxis *x = axisSet.xAxis;
    // 原点的 x 位置
    x.orthogonalPosition = @0;
    // x轴主刻度：显示数字标签的量度间隔
    x.majorIntervalLength = @0.5;
    // x轴细分刻度：每一个主刻度范围内显示细分刻度的个数
    x.minorTicksPerInterval = 0;
    x.minorTickLineStyle = lineStyle;
    
    // 需要排除的不显示数字的主刻度
    NSArray *exclusionRanges = [NSArray arrayWithObjects:
    [self CPTPlotRangeFromFloat:0.99 length:0.02],
    [self CPTPlotRangeFromFloat:2.99 length:0.02],
    nil];
    x.labelExclusionRanges = exclusionRanges;
    
    
    CPTXYAxis *y = axisSet.yAxis;
    // 原点的 y 位置
    y.orthogonalPosition = @0;
    // y轴主刻度：显示数字标签的量度间隔
    y.majorIntervalLength = @0.5;
    // y轴细分刻度：每一个主刻度范围内显示细分刻度的个数
    y.minorTicksPerInterval = 0;
    
    y.minorTickLineStyle = lineStyle;
    exclusionRanges = [NSArray arrayWithObjects:
                       [self CPTPlotRangeFromFloat:1.99 length:0.02],
                       [self CPTPlotRangeFromFloat:2.99 length:0.02],
                       nil];
    y.labelExclusionRanges = exclusionRanges;
    y.delegate = self;
    
    //添加曲线的描述
    // Create a red-blue plot area //
    lineStyle.miterLimit        = 1.0f;
    lineStyle.lineWidth         = 3.0f;
    lineStyle.lineColor         = [CPTColor blueColor];
    
    CPTScatterPlot *boundLinePlot  = [[CPTScatterPlot alloc] init];
    boundLinePlot.dataLineStyle = lineStyle;
    boundLinePlot.identifier    = BLUE_PLOT_IDENTIFIER;
    boundLinePlot.dataSource    = self;
    // Do a red-blue gradient: 渐变色区域 //
    CPTColor * blueColor        = [CPTColor colorWithComponentRed:0.3 green:0.3 blue:1.0 alpha:0.8];
    CPTColor * redColor         = [CPTColor colorWithComponentRed:1.0 green:0.3 blue:0.3 alpha:0.8];
    CPTGradient * areaGradient1 = [CPTGradient gradientWithBeginningColor:blueColor
                                                              endingColor:redColor];
    areaGradient1.angle = -90.0f;
    CPTFill * areaGradientFill  = [CPTFill fillWithGradient:areaGradient1]; boundLinePlot.areaFill = areaGradientFill;
    boundLinePlot.areaBaseValue = [NSDecimalNumber numberWithFloat:1.0];// 渐变色的起点位置
    // Add plot symbols: 表示数值的符号的形状 //
    CPTMutableLineStyle * symbolLineStyle = [CPTMutableLineStyle lineStyle];
    symbolLineStyle.lineColor = [CPTColor blackColor];
    symbolLineStyle.lineWidth = 2.0;
    
    CPTPlotSymbol * plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol.fill          = [CPTFill fillWithColor:[CPTColor blueColor]];
    plotSymbol.lineStyle     = symbolLineStyle;
    plotSymbol.size          = CGSizeMake(10.0, 10.0); boundLinePlot.plotSymbol = plotSymbol;
    
    [_graph addPlot:boundLinePlot];
    
    // Create a green plot area: 画破折线 //
    lineStyle                = [CPTMutableLineStyle lineStyle];
    lineStyle.lineWidth      = 3.f;
    lineStyle.lineColor      = [CPTColor greenColor];
    lineStyle.dashPattern = [NSArray arrayWithObjects:
                             [NSNumber numberWithFloat:5.0f],
                             [NSNumber numberWithFloat:5.0f], nil];
    
    CPTScatterPlot * dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.dataLineStyle = lineStyle;
    dataSourceLinePlot.identifier = GREEN_PLOT_IDENTIFIER;
    dataSourceLinePlot.dataSource = self;
    // Put an area gradient under the plot above //
    CPTColor * areaColor            = [CPTColor colorWithComponentRed:0.3 green:1.0 blue:0.3 alpha:0.8];
    CPTGradient * areaGradient      = [CPTGradient gradientWithBeginningColor:areaColor
                                                                  endingColor:[CPTColor clearColor]];
    areaGradient.angle              = -90.0f;
    areaGradientFill                = [CPTFill fillWithGradient:areaGradient];
    dataSourceLinePlot.areaFill     = areaGradientFill;
    dataSourceLinePlot.areaBaseValue= @1.75; // Animate in the new plot: 淡入动画
    dataSourceLinePlot.opacity = 0.0f;
    
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAnimation.duration            = 3.0f;
    fadeInAnimation.removedOnCompletion = NO;
    fadeInAnimation.fillMode            = kCAFillModeForwards;
    fadeInAnimation.toValue             = [NSNumber numberWithFloat:1.0];
    [dataSourceLinePlot addAnimation:fadeInAnimation forKey:@"animateOpacity"];
    [_graph addPlot:dataSourceLinePlot];
    
    // Add some initial data //
    _dataForPlot = [NSMutableArray arrayWithCapacity:100];
    NSUInteger i;
    for ( i = 0; i < 100; i++ ) {
        id x = [NSNumber numberWithFloat:0 + i * 0.05];
        id y = [NSNumber numberWithFloat:1.2 * rand() / (float)RAND_MAX + 1.2];
        [_dataForPlot addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:x, @"x", y, @"y", nil]];
    }
    
//    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(changePlotRange) userInfo:nil repeats:YES];
}

- (CPTPlotRange *)CPTPlotRangeFromFloat:(float)location length:(float)length{
    return [CPTPlotRange plotRangeWithLocation:[NSNumber numberWithFloat:location] length:[NSNumber numberWithFloat:length]];
}

#pragma mark - #pragma mark Axis Delegate Methods

-(BOOL)axis:(CPTAxis *)axis shouldUpdateAxisLabelsAtLocations:(NSSet *)locations
{
    static CPTTextStyle * positiveStyle = nil;
    static CPTTextStyle * negativeStyle = nil;
    
    NSNumberFormatter *formatter   = (NSNumberFormatter *)axis.labelFormatter;
    CGFloat labelOffset             = axis.labelOffset;
    NSDecimalNumber * zero          = [NSDecimalNumber zero];
    
    NSMutableSet * newLabels        = [NSMutableSet set]; for (NSDecimalNumber * tickLocation in locations) {
        CPTTextStyle *theLabelTextStyle;
        if ([tickLocation isGreaterThanOrEqualTo:zero]) { if (!positiveStyle) {
            CPTMutableTextStyle * newStyle = [axis.labelTextStyle mutableCopy];
            newStyle.color = [CPTColor greenColor];
            positiveStyle  = newStyle;
        }
            
            theLabelTextStyle = positiveStyle;
        } else { if (!negativeStyle) {
            CPTMutableTextStyle * newStyle = [axis.labelTextStyle mutableCopy];
            newStyle.color = [CPTColor redColor];
            negativeStyle  = newStyle;
        }
            
            theLabelTextStyle = negativeStyle;
        }
        
        NSString * labelString      = [formatter stringForObjectValue:tickLocation];
        CPTTextLayer * newLabelLayer= [[CPTTextLayer alloc] initWithText:labelString style:theLabelTextStyle];
        
        CPTAxisLabel * newLabel     = [[CPTAxisLabel alloc] initWithContentLayer:newLabelLayer];
        newLabel.tickLocation       = tickLocation;
        newLabel.offset             = labelOffset;
        
        [newLabels addObject:newLabel];
    }
    
    axis.axisLabels = newLabels; return NO;
}

#pragma mark - #pragma mark Plot Data Source Methods

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot{
    return [_dataForPlot count];
}

- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index{
    NSString * key = (fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y");
    NSNumber * num = [[_dataForPlot objectAtIndex:index] valueForKey:key];// Green plot gets shifted above the blue
    if ([(NSString *)plot.identifier isEqualToString:GREEN_PLOT_IDENTIFIER]) { if (fieldEnum == CPTScatterPlotFieldY) {
    num = [NSNumber numberWithDouble:[num doubleValue] + 1.0];
    }
    }
    return num;
}

//- (void)changePlotRange{
//    // Change plot space
//    CPTXYPlotSpace * plotSpace = (CPTXYPlotSpace *)_graph.defaultPlotSpace;
//    
//    plotSpace.xRange = [self CPTPlotRangeFromFloat:0.0 length:(3.0 + 2.0 * rand() / RAND_MAX)];
//    plotSpace.yRange = [self CPTPlotRangeFromFloat:0.0 length:(3.0 + 2.0 * rand() / RAND_MAX)];
//}

@end
