struct Event {
    uint256 eventId;
    uint256[] ticketIds;
    mapping(uint256 => Ticket) tickets;
}

struct Ticket {
    uint256 eventId;
    uint256 ticketId;
    uint256 amount;
    uint256 price;
    bool isBought;
}

enum ListingStatus {
    Active,
    Sold,
    Cancelled
}

struct Listing {
    ListingStatus status;
    address seller;
    address token;
    uint256 tokenId;
    uint256 price;
}

struct AppStorage {
    mapping(uint256 => Event) events; // id => event
    mapping(uint256 => Ticket) tickets; // id => ticket
    mapping(uint256 => string) idToIpfsHash; // id => hash
    mapping(uint256 => address) ticketidToOwner;
    uint256[] eventsIds;
    uint256[] ticketsIds;
    /* ========= COUNTERS ======== */
    uint256 eventsCount;
    uint256 ticketsCount;
    uint256 counter;
    // event EventCreated(uint eventId);
    // event BoughtTickets();

    uint256 _listingId;
    uint256 listingCount;
    mapping(uint256 => Listing) listings;
}

library LibEventStorage {
    function diamondStorage() internal pure returns (AppStorage storage ds) {
        assembly {
            ds.slot := 0
        }
    }
}
