// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

contract DEX is ERC1155Holder{
    enum ListingStatus {
		Active,
		Sold,
		Cancelled
	}

    struct Listing {
		ListingStatus status;
		address seller;
		address token;
		uint tokenId;
		uint price;
	}

    event Listed(
		uint listingId,
		address seller,
		address token,
		uint tokenId,
		uint price
	);

    event Sale(
		uint listingId,
		address buyer,
		address token,
		uint tokenId,
		uint price
	);

    uint private _listingId = 0;
	uint public listingCount = 0;
	mapping(uint => Listing) public listings;


    //listTicket()
    function listTicket(address token, uint tokenId, uint amount, uint price) external {
        IERC1155(token).safeTransferFrom(msg.sender, address(this), tokenId, amount, "");

		Listing memory listing = Listing(
			ListingStatus.Active,
			msg.sender,
			token,
			tokenId,
			price
		);

		_listingId++;
		listingCount++;

		listings[_listingId] = listing;

		emit Listed(
			_listingId,
			msg.sender,
			token,
			tokenId,
			price
		);
	}

    //buyTicket()
    function buyTicket(uint listingId) external payable {
		Listing storage listing = listings[listingId];

		require(msg.sender != listing.seller, "Seller cannot be buyer");
		require(listing.status == ListingStatus.Active, "Listing is not active");

		require(msg.value >= listing.price, "Insufficient payment");

		listing.status = ListingStatus.Sold;

        IERC1155(listing.token).safeTransferFrom(address(this), msg.sender, listing.tokenId, 1, ""); // ?????

		payable(listing.seller).transfer(listing.price);

		emit Sale(
			listingId,
			msg.sender,
			listing.token,
			listing.tokenId,
			listing.price
		);
	}

    function getListing(uint listingId) public view returns (Listing memory) {
		return listings[listingId];
	}

    
}