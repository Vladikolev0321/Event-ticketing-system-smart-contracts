// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract EventManager is ERC1155{

    struct Event {
        uint eventId;
        // mapping(uint => uint) ticketIdsAmounts;
        // uint[] ticketIds;
        // uint[] ticketAmounts;
        // Ticket[] tickets;
        mapping(uint => Ticket) tickets;
    }

    struct Ticket {
        uint eventId;
        uint ticketId;
        uint amount;
        uint price;
    }

    mapping(uint => Event) public events; // id => event
    mapping(uint => string) public idToIpfsHash; // id => hash
    // Event[] public events;
    uint public eventsCount;
    uint public counter = 0;

    event EventCreated(address _address);


    constructor() public ERC1155("https://game.example/api/item/{id}.json") {
    }

    function createEvent(address to, string memory eventHash, string[] memory ticketHashes,/*string[] memory ids,*/ uint256[] memory amounts, uint256[] memory prices) public {

        counter++;
        // mint event
        _mint(to, counter, 1, "");
        idToIpfsHash[counter] = eventHash;
        // eventsCount++;
        Event storage newEvent = events[counter];
        newEvent.eventId = counter;

        uint[] memory ids = new uint[](ticketHashes.length);
        for (uint i=0; i < ticketHashes.length; i++) {
            counter++;
            newEvent.tickets[counter] = Ticket(newEvent.eventId, counter, amounts[i], prices[i]);
            ids[i] = counter;
            if(keccak256(abi.encodePacked(ticketHashes[i])) != keccak256(abi.encodePacked(""))){
                idToIpfsHash[counter] = ticketHashes[i];
            }
        }
        
        // mint tickets
        _mintBatch(to, ids, amounts, "");

    }

    function getEventInfo(uint eventId, uint ticketId) public view returns(uint){
        // return (events[eventId].ticketIds, events[eventId].ticketAmounts);
        return (events[eventId].tickets[ticketId].amount);
    }

    //buyTicket()
    function buyTicket(address ownerOfTickets, uint ticketId, uint amount, uint price) external payable {
        require(msg.sender != ownerOfTickets, "Seller cannot be buyer");
		// require(listing.status == ListingStatus.Active, "Listing is not active");

		require(msg.value >= amount*price, "Insufficient payment");

		// listing.status = ListingStatus.Sold;

        _safeTransferFrom(ownerOfTickets, msg.sender, ticketId, amount, ""); 

		payable(ownerOfTickets).transfer(price*amount);

    }

    // buyTickets()
    function buyTickets(address[] memory ownersOfTickets, uint[] memory ticketIds, uint256[] memory amounts, uint256[] memory prices) external payable {
        // safeTransferFrom(address from, msg.sender, uint256 id, uint256 amount, "");
        uint amountToPay;
        for(uint i=0; i < ticketIds.length; i++){
            require(msg.sender != ownersOfTickets[i], "Seller cannot be buyer");
            amountToPay += amounts[i]*prices[i];
        }

        require(msg.value >= amountToPay, "Insufficient payment");

        for(uint i=0; i < ticketIds.length; i++){
            
            _safeTransferFrom(ownersOfTickets[i], msg.sender, ticketIds[i], amounts[i], "");

		    payable(ownersOfTickets[i]).transfer(prices[i]*amounts[i]);
        }


    }

    //editEventInfo() // maybe edit from metadata

    // addTickets()
    function addTickets(uint eventId, address to, /*string[] memory ids,*/ uint256[] memory amounts, uint256[] memory prices) public {
        

        Event storage currEvent = events[eventId];

        // check if there is such ticket id
        
        uint[] memory ids = new uint[](amounts.length);
        for (uint i=0; i < amounts.length; i++) {
            counter++;
            currEvent.tickets[counter] = Ticket(currEvent.eventId, ids[i], amounts[i], prices[i]);
            ids[i] = counter;
        }
        
        // mint tickets
        _mintBatch(to, ids, amounts, "");
        // for (uint i=0; i < amounts.length; i++) {
        //     counter++;
        //     newEvent.tickets[counter] = Ticket(newEvent.eventId, counter, amounts[i], prices[i]);
        //     ids[i] = counter;
        // }
    }
    //setTicketForSale()

}