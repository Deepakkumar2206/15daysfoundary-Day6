// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "../src/Auction.sol";

contract AuctionTest is Test {
    Auction auction;
    address owner = address(0xABCD);
    address bidder1 = address(0x1111);
    address bidder2 = address(0x2222);

    function setUp() public {
        vm.startPrank(owner);
        auction = new Auction(100); // Auction lasts 100 seconds
        vm.stopPrank();
    }

    function testBidAndEmitEvent() public {
        vm.deal(bidder1, 2 ether);

        vm.prank(bidder1);
        vm.expectEmit(true, true, false, true);
        emit Auction.HighestBidIncreased(bidder1, 1 ether);
        auction.bid{value: 1 ether}();

        assertEq(auction.highestBid(), 1 ether);
        assertEq(auction.highestBidder(), bidder1);
    }

    function testRefundPreviousBidder() public {
        vm.deal(bidder1, 3 ether);
        vm.deal(bidder2, 3 ether);

        vm.prank(bidder1);
        auction.bid{value: 1 ether}();

        vm.prank(bidder2);
        auction.bid{value: 2 ether}();

        assertEq(auction.pendingReturns(bidder1), 1 ether);
        assertEq(auction.highestBid(), 2 ether);
        assertEq(auction.highestBidder(), bidder2);
    }

    function testWithdrawRefund() public {
        vm.deal(bidder1, 3 ether);
        vm.deal(bidder2, 3 ether);

        vm.prank(bidder1);
        auction.bid{value: 1 ether}();

        vm.prank(bidder2);
        auction.bid{value: 2 ether}();

        vm.prank(bidder1);
        bool success = auction.withdraw();
        assertTrue(success);
        assertEq(bidder1.balance, 3 ether); // got refund
    }

    function testEndAuctionAndTransfer() public {
        vm.deal(bidder1, 2 ether);

        vm.prank(bidder1);
        auction.bid{value: 1 ether}();

        vm.warp(block.timestamp + 200); // fast forward time

        vm.prank(owner);
        vm.expectEmit(true, true, false, true);
        emit Auction.AuctionEnded(bidder1, 1 ether);
        auction.endAuction();

        assertEq(owner.balance, 1 ether);
        assertTrue(auction.ended());
    }
}
