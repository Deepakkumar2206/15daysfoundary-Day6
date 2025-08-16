// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Auction {
    address public owner;
    uint256 public auctionEndTime;

    address public highestBidder;
    uint256 public highestBid;

    mapping(address => uint256) public pendingReturns;
    bool public ended;

    // Adding indexed for better event filtering
    event HighestBidIncreased(address indexed bidder, uint256 amount);
    event AuctionEnded(address indexed winner, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(uint256 _biddingTime) {
        owner = msg.sender;
        auctionEndTime = block.timestamp + _biddingTime;
    }

    function bid() external payable {
        require(block.timestamp < auctionEndTime, "Auction already ended");
        require(msg.value > highestBid, "There already is a higher bid");

        if (highestBid != 0) {
            // Refund previous highest bidder
            pendingReturns[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;

        emit HighestBidIncreased(msg.sender, msg.value);
    }

    function withdraw() external returns (bool) {
        uint256 amount = pendingReturns[msg.sender];
        require(amount > 0, "No funds to withdraw");

        pendingReturns[msg.sender] = 0;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Withdraw failed");
        return true;
    }

    function endAuction() external onlyOwner {
        require(block.timestamp >= auctionEndTime, "Auction not yet ended");
        require(!ended, "Auction already ended");

        ended = true;
        emit AuctionEnded(highestBidder, highestBid);

        // Transfer highest bid to owner
        (bool success, ) = payable(owner).call{value: highestBid}("");
        require(success, "Transfer to owner failed");
    }
}
