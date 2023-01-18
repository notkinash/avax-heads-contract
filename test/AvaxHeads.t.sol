// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/AvaxHeads.sol";

contract AvaxHeadsTest is Test {
    AvaxHeads public avaxHeads;
    address public receiver = address(0xdfa321672451c1abc808f761cae7AFC8AB095b9A);

    function setUp() public {
        avaxHeads = new AvaxHeads(
            0.3 ether,
            333,
            receiver,
            500,
            "ipfs://test/"
        );
    }

    // Whitelist

    function testWhitelistSingle() public {
        vm.prank(address(this));
        avaxHeads.whitelistAdd(msg.sender, 1);
        assertEq(avaxHeads.whitelisted(msg.sender), true);
    }

    function testWhitelistMultiple() public {
        uint256 quantity = 50;
        address[] memory addresses = new address[](quantity);
        for (uint160 i = 0; i < quantity; i++) {
            addresses[i] = address(uint160(msg.sender) + i);
        }
        vm.prank(address(this));
        avaxHeads.whitelistAdd(addresses, quantity);
        assertEq(avaxHeads.whitelisted(addresses[quantity - 1]), true);
    }

    function testWhitelistMultipleQuantity() public {
        uint256 quantity = 50;
        address[] memory addresses = new address[](quantity);
        uint256[] memory quantities = new uint256[](quantity);
        for (uint160 i = 0; i < quantity; i++) {
            addresses[i] = address(uint160(msg.sender) + i);
            quantities[i] = quantity;
        }
        vm.prank(address(this));
        avaxHeads.whitelistAdd(addresses, quantities);
        assertEq(avaxHeads.whitelisted(addresses[quantity - 1]), true);
    }

    // Whitelist mint

    function testWhitelistMintSingle() public {
        vm.prank(address(this));
        avaxHeads.toggleMint();
        testWhitelistSingle();
        vm.prank(msg.sender);
        avaxHeads.mint(1);
        assertEq(avaxHeads.balanceOf(msg.sender), 1);
        assertEq(avaxHeads.whitelisted(msg.sender), false);
    }

    function testWhitelistMintMultiple() public {
        uint256 quantity = 2;
        vm.prank(address(this));
        avaxHeads.toggleMint();
        vm.prank(address(this));
        avaxHeads.whitelistAdd(msg.sender, quantity);
        vm.prank(msg.sender);
        avaxHeads.mint(quantity);
        assertEq(avaxHeads.balanceOf(msg.sender), quantity);
        assertEq(avaxHeads.whitelisted(msg.sender), false);
    }

    function testFailWhitelistMintMultiple() public {
        vm.prank(address(this));
        avaxHeads.toggleMint();
        testWhitelistSingle();
        uint256 quantity = 2;
        vm.prank(msg.sender);
        avaxHeads.mint(quantity);
        assertEq(avaxHeads.balanceOf(msg.sender), quantity);
        assertEq(avaxHeads.whitelisted(msg.sender), false);
    }

    // Public mint

    function testPublicMintSingle() public {
        vm.prank(address(this));
        avaxHeads.toggleMint();
        uint256 quantity = 1;
        uint256 price = avaxHeads.mintPrice() * quantity;
        vm.prank(msg.sender);
        avaxHeads.mint{value: price}(quantity);
        assertEq(avaxHeads.balanceOf(msg.sender), quantity);
    }

    function testPublicMintMultiple() public {
        vm.prank(address(this));
        avaxHeads.toggleMint();
        uint256 quantity = 2;
        uint256 price = avaxHeads.mintPrice() * quantity;
        vm.prank(msg.sender);
        avaxHeads.mint{value: price}(quantity);
        assertEq(avaxHeads.balanceOf(msg.sender), quantity);
    }

    function testFailPublicMintMultiple() public {
        vm.prank(address(this));
        avaxHeads.toggleMint();
        uint256 quantity = 2;
        uint256 price = avaxHeads.mintPrice() * quantity - 1;
        vm.prank(msg.sender);
        avaxHeads.mint{value: price}(quantity);
        assertEq(avaxHeads.balanceOf(msg.sender), quantity);
    }
}