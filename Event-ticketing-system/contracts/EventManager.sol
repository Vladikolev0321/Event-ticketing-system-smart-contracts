// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract EventManager is ERC1155{

    struct Event {
        uint eventId;
        // mapping(uint => uint) ticketIdsAmounts;
        uint[] ticketIds;
        uint[] ticketAmounts;
    }

    constructor() public ERC1155("https://game.example/api/item/{id}.json") {
    }

    mapping(uint => Event) public events; // id => event
    uint public eventsCount;

    event EventCreated(address _address);

    function createEvent(address to, uint256[] memory ids, uint256[] memory amounts) public {

        // mint event
        _mint(msg.sender, eventsCount, 1, "");
        // mint tickets
        _mintBatch(to, ids, amounts, "");

        eventsCount++;
        events[eventsCount] = Event (
            eventsCount,
            // ticketIdsAmounts
            ids,
            amounts
        );// ticketId and corresponding amount
    }

    function getEventInfo(uint eventId) public view returns(uint[] memory, uint[] memory){
        return (events[eventId].ticketIds, events[eventId].ticketAmounts);
    }



    // buyTickets()

    //editEventInfo() // maybe edit from metadata

    // addTickets()

    //setTicketForSale()










}