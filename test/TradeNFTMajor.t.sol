// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";

import {ITokenCF} from "../src/token/ITokenCF.sol";
import {IProduceNFT} from "../src/produce/IProduceNFT.sol";
import {ITradeNFT} from "../src/trading/ITradeNFT.sol";
import {IProduct} from "../src/produce/IProduct.sol";
import {IAskBid} from "../src/trading/IAskBid.sol";

import {DeployResolver} from "../script/DeployResolver.s.sol";
import {DeployTokenCF} from "../script/DeployTokenCF.s.sol";
import {DeployProduceNFT} from "../script/DeployProduceNFT.s.sol";
import {DeployTradeNFT} from "../script/DeployTradeNFT.s.sol";
import {TokenCF} from "../src/token/Token.CF.sol";

contract TradeNFTMajor is IProduct, IAskBid, Test {
    string constant ADMIN = "Admin";
    string constant SELLER = "Seller";
    string constant BUYER_1 = "Buyer_1";
    string constant BUYER_2 = "Buyer_2";
    string constant BUYER_3 = "Buyer_3";

    uint256 constant BUYER_BALANCE = 10000;
    uint256 constant BID_PRICE_1 = 1000;
    uint256 constant BID_PRICE_2 = 1500;
    uint256 constant BID_PRICE_3 = 1200;

    ITokenCF private tokenCf;
    IProduceNFT private produceNft;
    ITradeNFT private tradeNft;

    address private admin;
    address private seller;
    address private buyer1;
    address private buyer2;
    address private buyer3;

    string constant TOKEN_1_EXTERNAL_ID = "1234567-875";
    string constant TOKEN_1_URI = "https://example.com/token/1";

    function setUp() public {
        // Deploy resolver and register contracts via deployment scripts
        // Use deployment script contracts so the test also covers deployment logic
        DeployResolver dr = new DeployResolver();
        address resolverAddr = dr.deploy();

        DeployTokenCF dt = new DeployTokenCF();
        address tokenAddr = dt.deploy(resolverAddr);

        DeployProduceNFT dp = new DeployProduceNFT();
        address produceAddr = dp.deploy(resolverAddr);

        DeployTradeNFT dtr = new DeployTradeNFT();
        address tradeAddr = dtr.deploy(resolverAddr);

        // Initialize interfaces
        tokenCf = ITokenCF(tokenAddr);
        produceNft = IProduceNFT(produceAddr);
        tradeNft = ITradeNFT(tradeAddr);

        // Init party addresses
        admin = makeAddr(ADMIN);
        seller = makeAddr(SELLER);
        buyer1 = makeAddr(BUYER_1);
        buyer2 = makeAddr(BUYER_2);
        buyer3 = makeAddr(BUYER_3);

        // Mint tokens to admin so they can transfer to buyers in tests
        TokenCF(payable(address(tokenCf))).mint(admin, 1000000);

        // Label addresses for nicer traces
        vm.label(address(tokenCf), "TokenCF");
        vm.label(address(produceNft), "ProduceNFT");
        vm.label(address(tradeNft), "TradeNFT");
    }

    /**
     * @notice Test the major happy path for the TradeNFT contract
     *
     * @dev
     * 1. Admin: Supplies tokens to buyers (3)
     * 2. Seller: Mints NFT by seller
     * 3. Seller: Creates Ask order
     * 4. Each buyer (three in total): Increases allowance and places bid
     * 5. Seller 3: Cancels bid order.
     * 6. Seller: Retrieve active bids and chooses the highest bid
     * 7. Seller: Accepts the highest bid
     *
     *
     * @dev TODO - retrieve ids from logs
     */
    function testMajorHappyPath() public {
        // 1. Top up buyer balances
        vm.startPrank(admin);
        assertTrue(tokenCf.transferFrom(admin, buyer1, BUYER_BALANCE));
        assertTrue(tokenCf.transferFrom(admin, buyer2, BUYER_BALANCE));
        assertTrue(tokenCf.transferFrom(admin, buyer3, BUYER_BALANCE));
        vm.stopPrank();
        // Assertions
        assertEq(tokenCf.balanceOf(buyer1), BUYER_BALANCE, "Buyer 1 balance should be equal to BUYER_BALANCE");
        assertEq(tokenCf.balanceOf(buyer2), BUYER_BALANCE, "Buyer 2 balance should be equal to BUYER_BALANCE");
        assertEq(tokenCf.balanceOf(buyer3), BUYER_BALANCE, "Buyer 3 balance should be equal to BUYER_BALANCE");

        // 2. Seller: Mints NFT by seller
        vm.prank(seller);
        ProductInfo memory p =
            ProductInfo({externalId: TOKEN_1_EXTERNAL_ID, producer: seller, attributes: new Attribute[](0)});
        uint256 tokenId = produceNft.mint(p, TOKEN_1_URI);
        // Assertions
        assertEq(produceNft.ownerOf(tokenId), seller, "Seller should be the owner of the minted NFT");
        assertProductInfoEq(p, produceNft.getProductInfo(tokenId));
        assertEq(produceNft.tokenURI(tokenId), TOKEN_1_URI, "Token URI should match the expected value");

        // 3. Seller: Approve marketplace and Creates Ask order
        vm.prank(seller);
        produceNft.setApprovalForAll(address(tradeNft), true);
        AskParams memory ask = AskParams({seller: seller, tokenId: tokenId});
        vm.prank(seller);
        uint256 askId = tradeNft.createAsk(ask);
        // Assertions
        assertAskEq(ask, tradeNft.getAsk(askId));

        // 4. Place Bid 1
        vm.startPrank(buyer1);
        tokenCf.increaseAllowance(address(tradeNft), BID_PRICE_1);
        BidParams memory bid1 = BidParams({askId: askId, bidder: buyer1, price: BID_PRICE_1});
        uint256 bidId1 = tradeNft.createBid(bid1);
        vm.stopPrank();

        // 4. Place Bid 2
        vm.startPrank(buyer2);
        tokenCf.increaseAllowance(address(tradeNft), BID_PRICE_2);
        BidParams memory bid2 = BidParams({askId: askId, bidder: buyer2, price: BID_PRICE_2});
        tradeNft.createBid(bid2);
        vm.stopPrank();

        // 4. Place Bid 3
        vm.startPrank(buyer3);
        tokenCf.increaseAllowance(address(tradeNft), BID_PRICE_3);
        BidParams memory bid3 = BidParams({askId: askId, bidder: buyer3, price: BID_PRICE_3});
        uint256 bidId3 = tradeNft.createBid(bid3);
        vm.stopPrank();

        // Assertions
        // First retreive all bids and assert they are correct
        Bid[] memory allBids = tradeNft.listBidsByAskId(askId);
        assertBidEq(bid1, allBids[0], "Bid 1 should match the created bid");

        // helper overload supports optional message in assertion
        // (no-op for now, kept for compatibility)
        assertBidEq(bid2, allBids[1], "Bid 2 should match the created bid");
        assertBidEq(bid3, allBids[2], "Bid 3 should match the created bid");
        // Secondly, assert that the status of all bids is Active
        assertEq(uint256(allBids[0].status), uint256(BidStatus.ACTIVE), "Bid 1 status should be Active");
        assertEq(uint256(allBids[1].status), uint256(BidStatus.ACTIVE), "Bid 2 status should be Active");
        assertEq(uint256(allBids[2].status), uint256(BidStatus.ACTIVE), "Bid 3 status should be Active");
        // Thirdly, assert that buyer balances are reduced by their bid prices
        assertEq(
            tokenCf.balanceOf(buyer1), BUYER_BALANCE - BID_PRICE_1, "Buyer 1 balance should be reduced by bid price"
        );
        assertEq(
            tokenCf.balanceOf(buyer2), BUYER_BALANCE - BID_PRICE_2, "Buyer 2 balance should be reduced by bid price"
        );
        assertEq(
            tokenCf.balanceOf(buyer3), BUYER_BALANCE - BID_PRICE_3, "Buyer 3 balance should be reduced by bid price"
        );
        // Fourthly, assert that tradeNFT balance is correct
        assertEq(
            tokenCf.balanceOf(address(tradeNft)),
            BID_PRICE_1 + BID_PRICE_2 + BID_PRICE_3,
            "tradeNFT balance should be equal to the sum of bid prices"
        );

        // 5. Seller 3: Cancels bid order.
        vm.prank(buyer3);
        tradeNft.cancelBid(bidId3);
        // Assertions
        // First assert that the bid is canceled
        assertEq(
            uint256(tradeNft.getBid(bidId3).status), uint256(BidStatus.CANCELLED), "Bid 3 status should be Canceled"
        );
        // Second assert that it is not in the active bids list
        allBids = tradeNft.listBidsByAskId(askId); // Refresh the list
        assertBidNotInList(allBids, bidId3);
        // Thirdly, assert that tradeNFT balance is correct
        assertEq(
            tokenCf.balanceOf(address(tradeNft)),
            BID_PRICE_1 + BID_PRICE_2,
            "tradeNFT balance should be equal to the sum of bid prices after cancellation"
        );
        // Fourthly, assert that buyer3 balance is restored
        assertEq(tokenCf.balanceOf(buyer3), BUYER_BALANCE, "Buyer 3 balance should be restored after cancellation");

        // 6. Seller: Retrieve active bids and chooses the highest bid
        vm.prank(seller);
        Bid[] memory bids = tradeNft.listActiveBidsByAskId(askId);
        assertBidEq(bid1, bids[0]);
        assertBidEq(bid2, bids[1]);
        Bid memory highestPriceBid = chooseBidWithHighestPrice(bids);

        // 7. Seller: Accepts the highest bid
        vm.prank(seller);
        tradeNft.acceptBid(highestPriceBid.bidId);

        // Final Assertions

        // 1. Seller asserts
        // Assert that the ask order is ACCEPTED after accepting the bid
        assertEq(
            uint256(tradeNft.getAsk(askId).status),
            uint256(AskStatus.ACCEPTED),
            "Ask order should be ACCEPTED after accepting the bid"
        );
        // Assert that seller isn't an owner of the NFT anymore
        assertNotEq(produceNft.ownerOf(tokenId), seller, "Seller should not be the owner of the NFT anymore");
        // Assert that seller has received the tokens from the highest bid
        assertEq(tokenCf.balanceOf(seller), BID_PRICE_2, "Seller should have received the tokens from the highest bid");
        // 2. Buyer asserts
        // Assert that the bid order is ACCEPTED after accepting the bid
        assertEq(
            uint256(tradeNft.getBid(highestPriceBid.bidId).status),
            uint256(BidStatus.ACCEPTED),
            "The highest bid status should be Accepted"
        );
        // Assert that the buyer is now the owner of the NFT
        assertEq(produceNft.ownerOf(tokenId), highestPriceBid.bidder, "Buyer should be the owner of the NFT");
        // Assert that the buyer balance is reduced by the bid price (buyer paid the bid)
        assertEq(
            tokenCf.balanceOf(highestPriceBid.bidder),
            BUYER_BALANCE - highestPriceBid.price,
            "Buyer balance should be reduced by the bid price after accepting the bid"
        );

        // 3. Rejected bidders asserts
        // Assert that the first order is REJECTED after accepting the bid
        assertEq(
            uint256(tradeNft.getBid(bidId1).status),
            uint256(BidStatus.REJECTED),
            "The first bid status should be REJECTED after accepting the bid"
        );
        // Assert that the first bidder balance is restored
        assertEq(tokenCf.balanceOf(buyer1), BUYER_BALANCE, "Buyer 1 balance should be restored after accepting the bid");

        // 4. Contract asserts
        // Assert that there is no active bids left
        assertEq(
            tradeNft.listActiveBidsByAskId(askId).length,
            0,
            "There should be no active bids left after accepting the bid"
        );
        // Assert that the contract balance is 0
        assertEq(tokenCf.balanceOf(address(tradeNft)), 0, "Contract balance should be 0 after accepting the bid");
    }

    function assertBidEq(Bid memory bid1, Bid memory bid2) internal pure {
        assertEq(bid1.bidId, bid2.bidId, "Bid IDs should be equal");
        assertEq(bid1.bidder, bid2.bidder, "bidder addresses should be equal");
        assertEq(bid1.askId, bid2.askId, "Ask IDs should be equal");
        assertEq(bid1.price, bid2.price, "Prices should be equal");
        assertEq(uint256(bid1.status), uint256(bid2.status), "Statuses should be equal");
    }

    function assertBidEq(BidParams memory bid1, Bid memory bid2) internal pure {
        assertEq(bid1.bidder, bid2.bidder, "bidder addresses should be equal");
        assertEq(bid1.askId, bid2.askId, "Ask IDs should be equal");
        assertEq(bid1.price, bid2.price, "Prices should be equal");
    }

    function assertBidEq(BidParams memory bid1, Bid memory bid2, string memory) internal pure {
        assertBidEq(bid1, bid2);
    }

    function assertAskEq(Ask memory ask1, Ask memory ask2) internal pure {
        assertEq(ask1.askId, ask2.askId, "Ask IDs should be equal");
        assertEq(ask1.seller, ask2.seller, "Seller addresses should be equal");
        assertEq(ask1.tokenId, ask2.tokenId, "Token IDs should be equal");
        assertEq(uint256(ask1.status), uint256(ask2.status), "Statuses should be equal");
    }

    function assertAskEq(AskParams memory ask1, Ask memory ask2) internal pure {
        assertEq(ask1.seller, ask2.seller, "Seller addresses should be equal");
        assertEq(ask1.tokenId, ask2.tokenId, "Token IDs should be equal");
    }

    function chooseBidWithHighestPrice(Bid[] memory bids) internal pure returns (Bid memory) {
        Bid memory highestPriceBid = bids[0];
        for (uint256 i = 1; i < bids.length; i++) {
            if (bids[i].price > highestPriceBid.price) {
                highestPriceBid = bids[i];
            }
        }
        return highestPriceBid;
    }

    function assertProductInfoEq(ProductInfo memory product1, ProductInfo memory product2) internal pure {
        assertEq(
            keccak256(abi.encodePacked(product1.externalId)),
            keccak256(abi.encodePacked(product2.externalId)),
            "External IDs should be equal"
        );
        assertEq(product1.producer, product2.producer, "Producer addresses should be equal");
        assertEq(product1.attributes.length, product2.attributes.length, "Attribute lengths should be equal");
    }

    function assertBidNotInList(Bid[] memory bids, uint256 bidId) internal pure {
        for (uint256 i = 0; i < bids.length; i++) {
            assert(bidId != bids[i].bidId);
        }
    }
}
