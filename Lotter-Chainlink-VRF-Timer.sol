// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract Lottery is VRFConsumerBase {
    address payable public admin;
    address payable[] public players;
    

    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 public randomResult;

    uint start;
    uint end;
    uint256 bal;

    modifier onlyAdmin {
        require(msg.sender == admin);
        _;
    }

    constructor() VRFConsumerBase(0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9, 
            0xa36085F69e2889c224210F603D836748e7dC0088) public {
        admin = payable(msg.sender);
        start = block.timestamp;
        keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
        fee = 0.1 * 10 ** 18;
    }

    function getRandomNumber() public returns (bytes32 requestId) {
        return requestRandomness(keyHash, fee);
    }


    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = randomness;
    }

    function Enter() public payable {
        require(msg.value == 1 ether, "Please enter 0.01 Ether");
        require(end <= start + 1 hours, "You cannot enter the Lottery Contract now.");
        require(msg.sender != admin, "You are the owner of this contract, you cannot play.");
        end = block.timestamp;
        players.push(payable(msg.sender));
    }

    function pickWinner() public payable onlyAdmin {
        uint index = randomResult % players.length;
        address payable winner;
        winner = players[index];
        winner.transfer(address(this).balance);
        players = new address payable[](0);
    } 
}
