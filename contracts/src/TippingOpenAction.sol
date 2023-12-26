// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import {HubRestricted} from 'lens/HubRestricted.sol';
import {Types} from 'lens/Types.sol';
//import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {IPublicationActionModule} from 'lens/IPublicationActionModule.sol';
import {LensModule} from 'lens/LensModule.sol';
import {IModuleGlobals} from 'lens/IModuleGlobals.sol';
//import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

contract TippingPublicationAction is
    LensModule,
    HubRestricted,
    IPublicationActionModule
{
    //using SafeERC20 for IERC20;
    mapping(uint256 profileId => mapping(uint256 pubId => address tipReceiver)) internal _tipReceivers;
    event Log(string message);
    error CurrencyNotWhitelisted();
    error TipAmountCannotBeZero();
    error TipAmountNotApproved();
    error TipUnknownError();

    IModuleGlobals public immutable MODULE_GLOBALS;
    constructor(address hub, address moduleGlobals) HubRestricted(hub) {
        MODULE_GLOBALS = IModuleGlobals(moduleGlobals);
    }

    function supportsInterface(
        bytes4 interfaceID
    ) public pure override returns (bool) {
        return
            interfaceID == type(IPublicationActionModule).interfaceId ||
            super.supportsInterface(interfaceID);
    }

    function initializePublicationAction(
        uint256 profileId,
        uint256 pubId,
        address,
        bytes calldata data
    ) external override onlyHub returns (bytes memory) {
        address tipReceiver = abi.decode(data,(address));

        _tipReceivers[profileId][pubId] = tipReceiver;

        emit Log(string(abi.encodePacked("Post action init",tipReceiver,profileId,pubId)));
          
        return data;
    }
    function processPublicationAction(
        Types.ProcessActionParams calldata processActionParams
    ) external override onlyHub returns (bytes memory) {
        (address currency, uint256 tipAmount) = abi.decode(
            processActionParams.actionModuleData,
            (address, uint256)
        );
        emit Log(string(abi.encodePacked("processPub input",currency,tipAmount)));
        // if (!MODULE_GLOBALS.isCurrencyWhitelisted(currency)) {
        //      revert CurrencyNotWhitelisted();
        // }

        // if (tipAmount == 0) {
        //     revert TipAmountCannotBeZero();
        // }

        address tipReceiver = _tipReceivers[processActionParams.publicationActedProfileId][processActionParams.publicationActedId];
        emit Log(string(abi.encodePacked("processPub tiprec",tipReceiver)));
        // bool approved = false;
        // IERC20 ierc = IERC20(currency);
        // //uint256 allowance = ierc.allowance(address(this),params.transactionExecutor);
        // //emit Log(string(abi.encodePacked("processPub allowance",allowance)));
        // //if(allowance>= tipAmount){
        // //    approved = true;
        // //}else{
        //     approved = ierc.approve(processActionParams.transactionExecutor,tipAmount);
        // //}
        // emit Log(string(abi.encodePacked("processPub approved",approved)));
        // if(approved){
        //     ierc.safeTransferFrom(
        //          processActionParams.transactionExecutor,
        //          tipReceiver,
        //          tipAmount
        //     );
        // }else{
        //     revert TipAmountNotApproved();
        // }
        
        return abi.encode(tipReceiver, currency, tipAmount);
    }

    function getModuleMetadataURI() external view returns (string memory) {
        return 'https://nftz.mypinata.cloud/ipfs/QmUMP6eWA7MZL5CeSRULzrALhFKak5BibioXyhoZ4jU6H1';
    }
    
}