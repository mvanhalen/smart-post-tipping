// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {TippingPublicationAction} from "src/TippingOpenAction.sol";

contract TippingScript is Script {
    function setUp() public {}

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address moduleOwner = vm.envAddress("MODULE_OWNER");
        vm.startBroadcast(deployerPrivateKey);
        address lensHubProxyAddress = vm.envAddress("LENS_HUB_PROXY");
        new TippingPublicationAction(lensHubProxyAddress, address(moduleOwner));

        vm.stopBroadcast();
    }
}