// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import "forge-std/console.sol";
import {TippingPublicationAction} from "src/TippingOpenAction.sol";
import {IModuleRegistry} from 'lens/IModuleRegistry.sol';

contract TippingScript is Script {

    function setUp() public {}

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address moduleOwner = vm.envAddress("MODULE_OWNER");
        vm.startBroadcast(deployerPrivateKey);
        address lensHubProxyAddress = vm.envAddress("LENS_HUB_PROXY");
        TippingPublicationAction tippingPublicationAction = new TippingPublicationAction(lensHubProxyAddress, address(moduleOwner));
        
        address deployedContractAddress = address(tippingPublicationAction);
        console.log(deployedContractAddress);
        IModuleRegistry moduleRegistry = IModuleRegistry(deployedContractAddress);
        console.log('check module');
        bool registered = moduleRegistry.isModuleRegistered(deployedContractAddress);
        console.log('registered',registered);
        if(!registered){
            console.log('register module');
            bool success = moduleRegistry.registerModule(deployedContractAddress, 1);
            console.log(success);
        }
        
        // require(success, "Failed to register module");
        vm.stopBroadcast();
    }
}

  