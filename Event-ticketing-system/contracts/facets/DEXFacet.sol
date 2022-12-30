// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "../libraries/LibEventStorage.sol";

contract DEXFacet is ERC1155Holder{

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

    AppStorage internal s;

	function getListingsCount() public view returns(uint) {
		return s.listingCount;
	}

    //listTicket()
    function listTicket(address token, uint tokenId, uint amount, uint price) external {
        // s = LibEventStorage.diamondStorage();
        IERC1155(token).safeTransferFrom(msg.sender, address(this), tokenId, amount, "");

		Listing memory listing = Listing(
			ListingStatus.Active,
			msg.sender,
			token,
			tokenId,
			price
		);

		s._listingId++;
		s.listingCount++;

		s.listings[s._listingId] = listing;

		emit Listed(
			s._listingId,
			msg.sender,
			token,
			tokenId,
			price
		);
	}

    //buyTicket()
    function buyTicket(uint listingId) external payable {
        // s = LibEventStorage.diamondStorage();
		Listing storage listing = s.listings[listingId];

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
        // s = LibEventStorage.diamondStorage();
		return s.listings[listingId];
	}
}
