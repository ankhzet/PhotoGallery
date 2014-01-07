
#import "Kiwi.h"

#import "PhotoGalleryCell.h"

// dirty hack, i'm too lazy to make it in proper way =\.
@interface CellReceiver : NSObject
@property (nonatomic, strong) PhotoGalleryCell * photoCell;
@end
@implementation CellReceiver

@end

SPEC_BEGIN(PhotoGalleryCellCpec)

describe(@"PhotoGalleryCell controller class", ^{
    context(@"behavior", ^{
        __block PhotoGalleryCell *cell;
        
        it(@"shold properly load from .nib", ^{
            CellReceiver *cellOwner = [[CellReceiver alloc]init];
            NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"PhotoGalleryCell" owner:cellOwner options:nil];
            
            cell = nibs[0];
            
            [cell shouldNotBeNil];
            [[cell should] beKindOfClass:[PhotoGalleryCell class]];
        });
        
        it(@"should be properly initialized", ^{
            [[cell titleLabel] shouldNotBeNil];
            [[cell descriptionLabel] shouldNotBeNil];
            [[cell imageView] shouldNotBeNil];
            [[cell loadingIndicator] shouldNotBeNil];
            
            [[theValue([[cell loadingIndicator] isHidden]) should] beNo];
        });
    });
});

SPEC_END