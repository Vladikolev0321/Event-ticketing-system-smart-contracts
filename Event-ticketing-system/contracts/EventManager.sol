// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract EventManager is ERC1155{

    struct Event {
        uint eventId;
        uint[] ticketIds;
        mapping(uint => Ticket) tickets;
    }

    struct Ticket {
        uint eventId;
        uint ticketId;
        uint amount;
        uint price;
        bool isBought;
    }

    mapping(uint => Event) public events; // id => event
    mapping(uint => Ticket) public tickets; // id => ticket
    mapping(uint => string) public idToIpfsHash; // id => hash
    mapping(uint => address) private ticketidToOwner; 
    uint[] public eventsIds;
    uint[] public ticketsIds;

    uint public eventsCount;
    uint public ticketsCount;
    uint public counter = 0;

    event EventCreated(uint eventId);
    event BoughtTickets();


    constructor() public ERC1155("https://game.example/api/item/{id}.json") {
    }

    function createEvent(address to, string memory eventHash, string[] memory ticketHashes,/*string[] memory ids,*/ uint256[] memory amounts, uint256[] memory prices) public {

        counter++;
        // mint event
        _mint(to, counter, 1, "");
        idToIpfsHash[counter] = eventHash;
        Event storage newEvent = events[counter];
        newEvent.eventId = counter;
        eventsIds.push(counter);
        eventsCount++;

        uint[] memory ids = new uint[](ticketHashes.length);
        for (uint i=0; i < ticketHashes.length; i++) {
            counter++;
            Ticket storage ticket = tickets[counter];
            ticket.eventId = newEvent.eventId;
            ticket.ticketId = counter;
            ticket.amount = amounts[i];
            ticket.price = prices[i];
            ticket.isBought = false;
            newEvent.tickets[counter] = ticket;
            ids[i] = counter;
            ticketsIds.push(counter);
            //
            newEvent.ticketIds.push(counter);
            ticketidToOwner[counter] = to;
            //
            ticketsCount++;
            if(keccak256(abi.encodePacked(ticketHashes[i])) != keccak256(abi.encodePacked(""))){
                idToIpfsHash[counter] = ticketHashes[i];
            }
        }
        
        // mint tickets
        _mintBatch(to, ids, amounts, "");

        emit EventCreated(newEvent.eventId);

    }

    function getEventInfo(uint eventId, uint ticketId) public view returns(uint){
        return (events[eventId].tickets[ticketId].amount);
    }

    //buyTicket()
    function buyTicket(address ownerOfTickets, uint ticketId, uint amount, uint price) external payable {
        require(msg.sender != ownerOfTickets, "Seller cannot be buyer");
		require(msg.value >= amount*price, "Insufficient payment");

        _safeTransferFrom(ownerOfTickets, msg.sender, ticketId, amount, ""); 

		payable(ownerOfTickets).transfer(price*amount);

    }

    // buyTickets()
    function buyTickets( uint[] memory ticketIds, uint256[] memory amounts, uint256[] memory prices) external payable {
        uint amountToPay;
        for(uint i=0; i < ticketIds.length; i++){
            require(msg.sender != ticketidToOwner[ticketIds[i]], "Seller cannot be buyer");

            amountToPay += amounts[i]*prices[i];
        }

        require(msg.value >= amountToPay, "Insufficient payment");

        for(uint i=0; i < ticketIds.length; i++){
            
            _safeTransferFrom(ticketidToOwner[ticketIds[i]], msg.sender, ticketIds[i], amounts[i], "");
		    payable(ticketidToOwner[ticketIds[i]]).transfer(prices[i]*amounts[i]);
            Ticket storage currTicket = tickets[ticketIds[i]];
            currTicket.amount--;
            if(currTicket.amount == 0){ 
                currTicket.isBought = true;
            }
        }
        emit BoughtTickets();

    }

    //editEventInfo() // edit metadata
    function editInfo(uint eventId, string memory ipfsHash) public {
        uint balance = balanceOf(msg.sender, eventId);
        require(balance == 1, "Only owner can edit event info");
        idToIpfsHash[eventId] = ipfsHash;
    }

    // addTickets()
    function addTickets(uint eventId, address to, /*string[] memory ids,*/ uint256[] memory amounts, uint256[] memory prices) public {
        Event storage currEvent = events[eventId];

        // check if there is such ticket id
        
        uint[] memory ids = new uint[](amounts.length);
        for (uint i=0; i < amounts.length; i++) {
            counter++;
            currEvent.tickets[counter] = Ticket(currEvent.eventId, ids[i], amounts[i], prices[i], false);
            ids[i] = counter;
        }
        _mintBatch(to, ids, amounts, "");
    }
    //setTicketForSale()


    // uri()
    function uri(uint256 id) public view virtual override returns (string memory) {
        return (
            string(abi.encodePacked("https://ipfs.moralis.io:2053/ipfs/", idToIpfsHash[id]))
        );
    }

    function getEventTickets(uint eventId) public view returns(uint[] memory, uint[] memory, uint[] memory, bool[] memory){
        Event storage currEvent = events[eventId];
        uint[] memory ticketIds = currEvent.ticketIds;
        uint[] memory amounts = new uint[](currEvent.ticketIds.length);
        uint[] memory prices = new uint[](currEvent.ticketIds.length);
        bool[] memory areBought = new bool[](currEvent.ticketIds.length);
        for(uint i=0; i < currEvent.ticketIds.length; i++){
            Ticket storage currTicket = tickets[currEvent.ticketIds[i]];
            amounts[i] = currTicket.amount;
            prices[i] = currTicket.price;
            areBought[i] = currTicket.isBought;
        }
        return (ticketIds, amounts, prices, areBought);
    }

    function getTicketInfo(uint ticketId) public view returns(uint, uint, uint){
        Ticket storage currTicket = tickets[ticketId];
        return (currTicket.eventId, currTicket.amount, currTicket.price);
    }

}