//
//  PGDataPproxyContainer.m
//  PhotoGallery
//
//  Created by Ankh on 08.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "PGDataProxyContainer.h"
#import "DataProxy.h"

@interface PGDataProxyContainer ()

@end

@implementation PGDataProxyContainer

@synthesize managedObjectContext;

// instantiation of singletone object
+(PGDataProxyContainer *) initInstance: (DataProxy *)proxy {
	static PGDataProxyContainer *instance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		if (!proxy) {
			// proubably, called (+getInstance) before (+initInstance:)
			@throw [NSException exceptionWithName:@"PGDataProxyContainerInit" reason:@"Container not initialized yet, can't use ::getInstance()" userInfo:nil];
		}
		
		instance = [[PGDataProxyContainer alloc] initWithProxy:proxy];
	});
	
	return instance;
}

// if singletone was initialized with initInstance:, returns singletone object, else throws error.
+(PGDataProxyContainer *) getInstance {
	return [self initInstance:nil];
}

// direct initialization
-(id) initWithProxy: (DataProxy *)proxy {
	if (!(self = [super init]))
		return nil;
	
	self.dataProxy = proxy;
	
	return self;
}

#pragma mark - Core Data proxies

-(NSManagedObjectContext *) managedObjectContext {
	return self.dataProxy.managedObjectContext;
}

-(NSPersistentStoreCoordinator *) persistentStoreCoordinator {
	return self.dataProxy.persistentStoreCoordinator;
}

-(NSManagedObjectModel *) managedObjectModel {
	return self.dataProxy.managedObjectModel;
}

+(BOOL) saveContext {
	return [[self getInstance].dataProxy saveContext];
}

@end
