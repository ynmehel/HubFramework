#import <XCTest/XCTest.h>

#import "HUBViewModelBuilderImplementation.h"
#import "HUBViewModelImplementation.h"
#import "HUBComponentModelBuilder.h"
#import "HUBComponentModel.h"
#import "HUBJSONSchemaImplementation.h"

@interface HUBViewModelBuilderTests : XCTestCase

@end

@implementation HUBViewModelBuilderTests

- (void)testPropertyAssignment
{
    NSString * const featureIdentifier = @"feature";
    
    HUBViewModelBuilderImplementation * const builder = [[HUBViewModelBuilderImplementation alloc] initWithFeatureIdentifier:featureIdentifier];
    
    XCTAssertNotNil(builder.viewIdentifier);
    XCTAssertEqualObjects(builder.featureIdentifier, featureIdentifier);
    
    builder.viewIdentifier = @"view";
    builder.featureIdentifier = @"another feature";
    builder.entityIdentifier = @"entity";
    builder.navigationBarTitle = @"nav title";
    builder.extensionURL = [NSURL URLWithString:@"www.spotify.com"];
    builder.customData = @{@"custom": @"data"};
    
    HUBViewModelImplementation * const model = [builder build];
    
    XCTAssertEqualObjects(model.identifier, builder.viewIdentifier);
    XCTAssertEqualObjects(model.featureIdentifier, builder.featureIdentifier);
    XCTAssertEqualObjects(model.entityIdentifier, builder.entityIdentifier);
    XCTAssertEqualObjects(model.navigationBarTitle, builder.navigationBarTitle);
    XCTAssertEqualObjects(model.extensionURL, builder.extensionURL);
    XCTAssertEqualObjects(model.customData, builder.customData);
}

- (void)testHeaderComponentBuilder
{
    HUBViewModelBuilderImplementation * const builder = [[HUBViewModelBuilderImplementation alloc] initWithFeatureIdentifier:@"feature"];
    XCTAssertEqualObjects(builder.headerComponentModelBuilder.modelIdentifier, @"header");
    XCTAssertNil(builder.headerComponentModelBuilder.componentIdentifier);
}

- (void)testBodyComponentBuilders
{
    NSString * const componentModelIdentifier = @"identifier";
    
    HUBViewModelBuilderImplementation * const builder = [[HUBViewModelBuilderImplementation alloc] initWithFeatureIdentifier:@"feature"];
    
    XCTAssertFalse([builder builderExistsForBodyComponentModelWithIdentifier:componentModelIdentifier]);
    
    id<HUBComponentModelBuilder> const componentBuilder = [builder builderForBodyComponentModelWithIdentifier:componentModelIdentifier];
    
    XCTAssertNotNil(componentBuilder);
    XCTAssertTrue([builder builderExistsForBodyComponentModelWithIdentifier:componentModelIdentifier]);
    XCTAssertEqual(componentBuilder,  [builder builderForBodyComponentModelWithIdentifier:componentModelIdentifier]);
}

- (void)testFeatureIdentifierMatchingComponentTargetInitialViewModelFeatureIdentifier
{
    HUBViewModelBuilderImplementation * const builder = [[HUBViewModelBuilderImplementation alloc] initWithFeatureIdentifier:@"feature"];
    XCTAssertEqualObjects(builder.headerComponentModelBuilder.targetInitialViewModelBuilder.featureIdentifier, builder.featureIdentifier);
}

- (void)testAddingViewModelDictionaryJSONData
{
    NSString * const viewIdentifier = @"identifier";
    NSString * const featureIdentifier = @"feature";
    NSString * const entityIdentifier = @"entity";
    NSString * const navigationBarTitle = @"nav bar title";
    NSString * const headerComponentIdentifier = @"headerComponent";
    NSString * const bodyComponentIdentifier = @"bodyComponent";
    NSURL * const extensionURL = [NSURL URLWithString:@"https://spotify.com/extension"];
    NSDictionary * const customData = @{@"custom": @"data"};
    
    NSDictionary * const dictionary = @{
        @"id": viewIdentifier,
        @"feature": featureIdentifier,
        @"entity": entityIdentifier,
        @"title": navigationBarTitle,
        @"header": @{
            @"component": headerComponentIdentifier
        },
        @"body": @[
            @{
                @"component": bodyComponentIdentifier
            }
        ],
        @"extension": extensionURL.absoluteString,
        @"custom": customData
    };
    
    HUBViewModelBuilderImplementation * const builder = [[HUBViewModelBuilderImplementation alloc] initWithFeatureIdentifier:@"temp"];
    [builder addDataFromJSONDictionary:dictionary usingSchema:[HUBJSONSchemaImplementation new]];
    HUBViewModelImplementation * const model = [builder build];
    
    XCTAssertEqualObjects(model.identifier, viewIdentifier);
    XCTAssertEqualObjects(model.featureIdentifier, featureIdentifier);
    XCTAssertEqualObjects(model.entityIdentifier, entityIdentifier);
    XCTAssertEqualObjects(model.navigationBarTitle, navigationBarTitle);
    XCTAssertEqualObjects(model.headerComponentModel.componentIdentifier, headerComponentIdentifier);
    XCTAssertEqualObjects([model.bodyComponentModels firstObject].componentIdentifier, bodyComponentIdentifier);
    XCTAssertEqualObjects(model.extensionURL, extensionURL);
    XCTAssertEqualObjects(model.customData, customData);
}

- (void)testAddingComponentModelArrayJSONData
{
    NSString * const firstComponentIdentifier = @"component1";
    NSString * const lastComponentIdentifier = @"component2";
    
    NSArray * const array = @[
        @{
            @"component": firstComponentIdentifier
        },
        @{
            @"component": lastComponentIdentifier
        }
    ];
    
    HUBViewModelBuilderImplementation * const builder = [[HUBViewModelBuilderImplementation alloc] initWithFeatureIdentifier:@"temp"];
    [builder addDataFromJSONArray:array usingSchema:[HUBJSONSchemaImplementation new]];
    HUBViewModelImplementation * const model = [builder build];
    
    XCTAssertEqualObjects([model.bodyComponentModels firstObject].componentIdentifier, firstComponentIdentifier);
    XCTAssertEqualObjects([model.bodyComponentModels lastObject].componentIdentifier, lastComponentIdentifier);
}

- (void)testIsEmpty
{
    HUBViewModelBuilderImplementation * const builder = [[HUBViewModelBuilderImplementation alloc] initWithFeatureIdentifier:@"feature"];
    XCTAssertTrue(builder.isEmpty);
}

- (void)testNotEmptyAfterAddingHeaderComponentIdentifier
{
    HUBViewModelBuilderImplementation * const builder = [[HUBViewModelBuilderImplementation alloc] initWithFeatureIdentifier:@"feature"];
    builder.headerComponentModelBuilder.componentIdentifier = @"component";
    XCTAssertFalse(builder.isEmpty);
}

- (void)testNotEmptyAfterAddingBodyComponentModel
{
    HUBViewModelBuilderImplementation * const builder = [[HUBViewModelBuilderImplementation alloc] initWithFeatureIdentifier:@"feature"];
    [builder builderForBodyComponentModelWithIdentifier:@"id"];
    XCTAssertFalse(builder.isEmpty);
}

@end
