
#include "Kiwi.h"

#import "PGUtils.h"
#include "Photo.h"

SPEC_BEGIN(PhotoSpec)

describe(@"Testing Photo CoreData Entity wrapper class", ^{
    __block NSManagedObjectContext *managedContext;
    
    context(@"wrapper behavior", ^{
        
        // setup
        managedContext = [[PGUtils getInstance]managedObjectContext];
        [managedContext shouldNotBeNil];
        
        context(@"when entity", ^{
            UIImage *image = [UIImage imageNamed:@"kenny.png"];
            [image shouldNotBeNil];
            
            __block Photo *entity;
            __block NSString *filePath;
            
            context(@"creating from image", ^{
                it(@"should properly instantiate new entity", ^{
                    entity = [Photo newPhotoFromImage:image];
                    [entity shouldNotBeNil];
                    NSLog(@"Entity:\n%@", entity);
                });
                
                it(@"should be properly initialized", ^{
                    [[entity timestamp]shouldNotBeNil];
                    [[entity fileName]shouldNotBeNil];
                    
                    NSURL *fileURL = [Photo makeAbsolutePathForPhotoFile:[entity fileName]];
                    filePath = [fileURL path];
                    [filePath shouldNotBeNil];
                });
                
                it(@"should save image to storage", ^{
                    NSFileManager *fm = [NSFileManager defaultManager];
                    BOOL fileExists = [fm fileExistsAtPath:filePath];
                    [[theValue(fileExists) should] beYes];
                    
                    [[entity getImage]shouldNotBeNil];
                });
            });
            
            context(@"deleting existing entity", ^{
                it(@"should properly delete entity from database", ^{
                    NSManagedObjectID *objectID = [entity objectID];
                    [[theValue([entity deletePhoto]) should] beYes];
                    
                    [[managedContext objectRegisteredForID:objectID] shouldBeNil];
                });
                
                it(@"should delete image from storage also", ^{
                    NSFileManager *fm = [NSFileManager defaultManager];
                    [[theValue([fm fileExistsAtPath:filePath]) should] beNo];
                });
            });
        });
    });
    
});

SPEC_END