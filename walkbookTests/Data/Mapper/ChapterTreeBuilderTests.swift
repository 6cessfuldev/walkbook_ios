import XCTest
import FirebaseFirestoreInternal

@testable import walkbook

class ChapterTreeBuilderTests: XCTestCase {

    var builder: ChapterTreeBuilder!

    override func setUp() {
        super.setUp()
        builder = ChapterTreeBuilder()
    }

    override func tearDown() {
        builder = nil
        super.tearDown()
    }

    func testBuildTree_singleRoot() {
        // Given
        let flatChapters = [
            ChapterModel(id: "1", storyId: nil, title: "Root Chapter", childChapters: [])
        ]

        // When
        let root = builder.buildTree(flatChapters: flatChapters)

        // Then
        XCTAssertNotNil(root)
        XCTAssertEqual(root?.id, "1")
        XCTAssertEqual(root?.title, "Root Chapter")
        XCTAssertEqual(root?.childChapters.count, 0)
    }

    func testBuildTree_multipleLevels() {
        // Given
        let flatChapters = [
            ChapterModel(id: "1", storyId: nil, title: "Root Chapter", childChapters: ["2", "3"]),
            ChapterModel(id: "2", storyId: nil, title: "Child Chapter 1", childChapters: ["4"]),
            ChapterModel(id: "3", storyId: nil, title: "Child Chapter 2", childChapters: []),
            ChapterModel(id: "4", storyId: nil, title: "Child Chapter 1.1", childChapters: [])
        ]

        // When
        let root = builder.buildTree(flatChapters: flatChapters)

        // Then
        XCTAssertNotNil(root)
        XCTAssertEqual(root?.id, "1")
        XCTAssertEqual(root?.childChapters.count, 2)
        XCTAssertEqual(root?.childChapters[0].id, "2")
        XCTAssertEqual(root?.childChapters[1].id, "3")
        XCTAssertEqual(root?.childChapters[0].childChapters.count, 1)
        XCTAssertEqual(root?.childChapters[0].childChapters[0].id, "4")
    }

    func testBuildTree_emptyInput() {
        // Given
        let flatChapters: [ChapterModel] = []

        // When
        let root = builder.buildTree(flatChapters: flatChapters)

        // Then
        XCTAssertNil(root)
    }

    func testBuildTree_locationConversion() {
        // Given
        let flatChapters = [
            ChapterModel(
                id: "1",
                storyId: nil,
                title: "Root Chapter",
                location: GeoPoint(latitude: 37.7749, longitude: -122.4194),
                childChapters: []
            )
        ]

        // When
        let root = builder.buildTree(flatChapters: flatChapters)

        // Then
        XCTAssertNotNil(root)
        XCTAssertEqual(root?.id, "1")
        XCTAssertEqual(root?.location?.latitude, 37.7749)
        XCTAssertEqual(root?.location?.longitude, -122.4194)
    }
    
    func testBuildTree_largeNestedTree() {
        let flatChapters = [
            ChapterModel(id: "1", storyId: nil, title: "Root Chapter", childChapters: ["2", "3", "4"]),
            ChapterModel(id: "2", storyId: nil, title: "Child Chapter 1", childChapters: ["5", "6"]),
            ChapterModel(id: "3", storyId: nil, title: "Child Chapter 2", childChapters: ["7"]),
            ChapterModel(id: "4", storyId: nil, title: "Child Chapter 3", childChapters: []),
            ChapterModel(id: "5", storyId: nil, title: "Child Chapter 1.1", childChapters: []),
            ChapterModel(id: "6", storyId: nil, title: "Child Chapter 1.2", childChapters: ["8", "9"]),
            ChapterModel(id: "7", storyId: nil, title: "Child Chapter 2.1", childChapters: []),
            ChapterModel(id: "8", storyId: nil, title: "Child Chapter 1.2.1", childChapters: []),
            ChapterModel(id: "9", storyId: nil, title: "Child Chapter 1.2.2", childChapters: ["10"]),
            ChapterModel(id: "10", storyId: nil, title: "Child Chapter 1.2.2.1", childChapters: [])
        ]

        // When
        let root = builder.buildTree(flatChapters: flatChapters)

        // Then
        XCTAssertNotNil(root)
        XCTAssertEqual(root?.id, "1")
        XCTAssertEqual(root?.childChapters.count, 3)
        XCTAssertEqual(root?.childChapters[0].id, "2")
        XCTAssertEqual(root?.childChapters[0].childChapters.count, 2)
        XCTAssertEqual(root?.childChapters[0].childChapters[1].childChapters.count, 2)
        XCTAssertEqual(root?.childChapters[0].childChapters[1].childChapters[1].childChapters.count, 1)
    }
    
    func testBuildTree_deepNestedTree() {
        let flatChapters = [
            ChapterModel(id: "1", storyId: nil, title: "Root Chapter", childChapters: ["2"]),
            ChapterModel(id: "2", storyId: nil, title: "Level 1 Chapter", childChapters: ["3"]),
            ChapterModel(id: "3", storyId: nil, title: "Level 2 Chapter", childChapters: ["4"]),
            ChapterModel(id: "4", storyId: nil, title: "Level 3 Chapter", childChapters: ["5"]),
            ChapterModel(id: "5", storyId: nil, title: "Level 4 Chapter", childChapters: ["6"]),
            ChapterModel(id: "6", storyId: nil, title: "Level 5 Chapter", childChapters: ["7"]),
            ChapterModel(id: "7", storyId: nil, title: "Level 6 Chapter", childChapters: ["8"]),
            ChapterModel(id: "8", storyId: nil, title: "Level 7 Chapter", childChapters: ["9"]),
            ChapterModel(id: "9", storyId: nil, title: "Level 8 Chapter", childChapters: ["10"]),
            ChapterModel(id: "10", storyId: nil, title: "Level 9 Chapter", childChapters: [])
        ]

        // When
        let root = builder.buildTree(flatChapters: flatChapters)

        XCTAssertNotNil(root)
        XCTAssertEqual(root?.id, "1")
        var currentNode = root
        for level in 2...10 {
            XCTAssertEqual(currentNode?.childChapters.count, 1)
            XCTAssertEqual(currentNode?.childChapters.first?.id, "\(level)")
            currentNode = currentNode?.childChapters.first
        }
        XCTAssertEqual(currentNode?.childChapters.count, 0)
    }
    
    func testBuildTree_동일한_자식을_공유하는_경우() {
        let flatChapters = [
            ChapterModel(id: "1", storyId: nil, title: "Root Chapter", childChapters: ["2", "3"]),
            ChapterModel(id: "2", storyId: nil, title: "Child Chapter 1", childChapters: ["4"]),
            ChapterModel(id: "3", storyId: nil, title: "Child Chapter 2", childChapters: ["4"]),
            ChapterModel(id: "4", storyId: nil, title: "Shared Chapter", childChapters: ["5"]),
            ChapterModel(id: "5", storyId: nil, title: "Child Chapter 1.1", childChapters: [])
        ]

        // When
        let root = builder.buildTree(flatChapters: flatChapters)

        // Then
        XCTAssertNotNil(root)
        XCTAssertEqual(root?.id, "1")
        XCTAssertEqual(root?.childChapters.count, 2)
        XCTAssertEqual(root?.childChapters[0].id, "2")
        XCTAssertEqual(root?.childChapters[1].id, "3")
        XCTAssertEqual(root?.childChapters[0].childChapters.first?.id, "4")
        XCTAssertEqual(root?.childChapters[1].childChapters.first?.id, "4")
        XCTAssertEqual(root?.childChapters[0].childChapters.first?.childChapters.first?.id, "5")
    }
}
