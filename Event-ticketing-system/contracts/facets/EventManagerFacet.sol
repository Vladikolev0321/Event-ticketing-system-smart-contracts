// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "../libraries/LibEventStorage.sol";

contract EventManagerFacet is ERC1155{
    event TestEvent(address something);
    event EventCreated(uint eventId);
    event BoughtTickets(address buyer);

    AppStorage internal s;

    constructor() public ERC1155("https://game.example/api/item/{id}.json") {
    }

    function getCounter() public view returns(uint){
        return s.counter;
    }

    function getEventsCount() public view returns(uint){
        return s.eventsCount;
    }

    function getEventId(uint index) public view returns(uint){
        return s.eventsIds[index];
    }

    function getTicketsCount() public view returns(uint){
        return s.ticketsCount;
    }

    function getTicketId(uint index) public view returns(uint){
        return s.ticketsIds[index];
    }

    function createEvent(address to, string memory eventHash, string[] memory ticketHashes,/*string[] memory ids,*/ uint256[] memory amounts, uint256[] memory prices) public {
        // s = LibEventStorage.diamondStorage();
        s.counter++;
        // mint event
        _mint(to, s.counter, 1, "");
        s.idToIpfsHash[s.counter] = eventHash;
        Event storage newEvent = s.events[s.counter];
        newEvent.eventId = s.counter;
        s.eventsIds.push(s.counter);
        s.eventsCount++;

        uint[] memory ids = new uint[](ticketHashes.length);
        for (uint i=0; i < ticketHashes.length; i++) {
            s.counter++;
            Ticket storage ticket = s.tickets[s.counter];
            ticket.eventId = newEvent.eventId;
            ticket.ticketId = s.counter;
            ticket.amount = amounts[i];
            ticket.price = prices[i];
            ticket.isBought = false;
            newEvent.tickets[s.counter] = ticket;
            ids[i] = s.counter;
            s.ticketsIds.push(s.counter);
            //
            newEvent.ticketIds.push(s.counter);
            s.ticketidToOwner[s.counter] = to;
            //
            s.ticketsCount++;
            if(keccak256(abi.encodePacked(ticketHashes[i])) != keccak256(abi.encodePacked(""))){
                s.idToIpfsHash[s.counter] = ticketHashes[i];
            }
        }
        
        // mint tickets
        _mintBatch(to, ids, amounts, "");

        emit EventCreated(newEvent.eventId);

    }

    function getEventInfo(uint eventId, uint ticketId) public view returns(uint){
        return (s.events[eventId].tickets[ticketId].amount);
    }

    // //buyTicket()
    // function buyTicket(address ownerOfTickets, uint ticketId, uint amount, uint price) external payable {
    //     require(msg.sender != ownerOfTickets, "Seller cannot be buyer");
	// 	require(msg.value >= amount*price, "Insufficient payment");

    //     _safeTransferFrom(ownerOfTickets, msg.sender, ticketId, amount, ""); 

	// 	payable(ownerOfTickets).transfer(price*amount);

    // }

    // buyTickets()
    function buyTickets( uint[] memory ticketIds, uint256[] memory amounts, uint256[] memory prices) external payable {
        uint amountToPay;
        for(uint i=0; i < ticketIds.length; i++){
            require(msg.sender != s.ticketidToOwner[ticketIds[i]], "Seller cannot be buyer");

            amountToPay += amounts[i]*prices[i];
        }

        require(msg.value >= amountToPay, "Insufficient payment");

        for(uint i=0; i < ticketIds.length; i++){
            
            _safeTransferFrom(s.ticketidToOwner[ticketIds[i]], msg.sender, ticketIds[i], amounts[i], "");
		    payable(s.ticketidToOwner[ticketIds[i]]).transfer(prices[i]*amounts[i]);
            Ticket storage currTicket = s.tickets[ticketIds[i]];
            currTicket.amount--;
            if(currTicket.amount == 0){ 
                currTicket.isBought = true;
            }
        }
        emit BoughtTickets(msg.sender);

    }

    //editEventInfo() // edit metadata
    function editInfo(uint eventId, string memory ipfsHash) public {
        uint balance = balanceOf(msg.sender, eventId);
        require(balance == 1, "Only owner can edit event info");
        s.idToIpfsHash[eventId] = ipfsHash;
    }

    // addTickets()
    function addTickets(uint eventId, address to, /*string[] memory ids,*/ uint256[] memory amounts, uint256[] memory prices) public {
        Event storage currEvent = s.events[eventId];

        // check if there is such ticket id
        
        uint[] memory ids = new uint[](amounts.length);
        for (uint i=0; i < amounts.length; i++) {
            s.counter++;
            currEvent.tickets[s.counter] = Ticket(currEvent.eventId, ids[i], amounts[i], prices[i], false);
            ids[i] = s.counter;
        }
        _mintBatch(to, ids, amounts, "");
    }
    //setTicketForSale()


    // uri()
    function uri(uint256 id) public view virtual override returns (string memory) {
        // return (
        //     string(abi.encodePacked("https://ipfs.moralis.io:2053/ipfs/", s.idToIpfsHash[id]))
        // );
        return (
            s.idToIpfsHash[id]
        );
    }

    function getEventTickets(uint eventId) public view returns(uint[] memory, uint[] memory, uint[] memory, bool[] memory){
        Event storage currEvent = s.events[eventId];
        uint[] memory ticketIds = currEvent.ticketIds;
        uint[] memory amounts = new uint[](currEvent.ticketIds.length);
        uint[] memory prices = new uint[](currEvent.ticketIds.length);
        bool[] memory areBought = new bool[](currEvent.ticketIds.length);
        for(uint i=0; i < currEvent.ticketIds.length; i++){
            Ticket storage currTicket = s.tickets[currEvent.ticketIds[i]];
            amounts[i] = currTicket.amount;
            prices[i] = currTicket.price;
            areBought[i] = currTicket.isBought;
        }
        return (ticketIds, amounts, prices, areBought);
    }

    function getTicketInfo(uint ticketId) public view returns(uint, uint, uint){
        Ticket storage currTicket = s.tickets[ticketId];
        return (currTicket.eventId, currTicket.amount, currTicket.price);
    }

    // function supportsInterface(bytes4 _interfaceID) external view returns (bool) {}
}
