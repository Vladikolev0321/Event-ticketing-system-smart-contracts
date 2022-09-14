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
    }

    mapping(uint => Event) public events; // id => event
    // Event[] public events;
    uint public eventsCount;

    event EventCreated(address _address);


    constructor() public ERC1155("https://game.example/api/item/{id}.json") {
    }

    function createEvent(address to, uint256[] memory ids, uint256[] memory amounts) public {

        // mint event
        _mint(msg.sender, eventsCount, 1, "");
        // mint tickets
        _mintBatch(to, ids, amounts, "");

        eventsCount++;
        Event storage newEvent = events[eventsCount];
        newEvent.eventId = eventsCount;

        for (uint i=0; i < ids.length; i++) {
            newEvent.tickets[ids[i]] = Ticket(eventsCount, ids[i], amounts[i]);
        }

    }

    function getEventInfo(uint eventId, uint ticketId) public view returns(uint){
        // return (events[eventId].ticketIds, events[eventId].ticketAmounts);
        return (events[eventId].tickets[ticketId].amount);
    }

    // buyTickets()
    function buyTickets(uint[] memory ticketIds) external payable {


    }

    //editEventInfo() // maybe edit from metadata

    // addTickets()
    // function addTickets(uint eventId, address to, uint256[] memory ids, uint256[] memory amounts) public {
        
    //     // mint tickets
    //     _mintBatch(to, ids, amounts, "");
    //     for (uint i=0; i < ids.length; i++) {
    //         events[eventId].ticketIds.push(ids[i]);
    //     }
    //     for (uint i=0; i < ids.length; i++) {
    //         events[eventId].ticketAmounts.push(amounts[i]);
    //     }


    // }
    //setTicketForSale()










}