import XCTest
@testable import SongLinkKit

final class SongLinkKitTests: XCTestCase {
    private var server: SongLinkKit?
    
    func testFetchSongFromNetwork() {
        let request = CoreRequest(identifier: 939990, title: "Lucky", artist: "Make do and mend", album: "", index: 0)
        server = SongLinkKit()
        let expectation = XCTestExpectation(description: "wait")
        server!.fetchSongs([request], update: { song in
            let expectedTrackURL = "https://music.apple.com/us/album/lucky/525167153?i=525167163&uo=4"
            XCTAssert(song.appleURL == expectedTrackURL)
            XCTAssert(song.songLinkURL == "https://song.link/\(expectedTrackURL)&app=music")
            expectation.fulfill()
        }, completion: { _ in
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 5)
    }

    static var allTests = [
        ("testExample", testExample)
    ]
}
