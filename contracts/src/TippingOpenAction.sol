// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import {HubRestricted} from 'lens/HubRestricted.sol';
import {Types} from 'lens/Types.sol';
import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {IPublicationActionModule} from 'lens/IPublicationActionModule.sol';
import {LensModuleMetadata} from 'lens/LensModuleMetadata.sol';
import {IModuleRegistry} from 'lens/IModuleRegistry.sol';
import {SafeERC20} from 'openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol';

contract TippingPublicationAction is
    HubRestricted,
    IPublicationActionModule,
    LensModuleMetadata
{
    using SafeERC20 for IERC20;
    mapping(uint256 profileId => mapping(uint256 pubId => address tipReceiver)) internal _tipReceivers;
    event Log(string message);
    error CurrencyNotWhitelisted();
    error TipAmountCannotBeZero();
    error TipAmountNotApproved();
    error TipUnknownError();

    IModuleRegistry public immutable MODULE_REGISTRY;

    constructor(address hub, address moduleRegistry,address moduleOwner) HubRestricted(hub) LensModuleMetadata(moduleOwner){
        MODULE_REGISTRY = IModuleRegistry(moduleRegistry);
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
        (address currency, uint96 tipAmount) = abi.decode(
            processActionParams.actionModuleData,
            (address, uint96)
        );
        emit Log(string(abi.encodePacked("processPub input",currency,tipAmount)));
        if (!MODULE_REGISTRY.isErc20CurrencyRegistered(currency)) {
              revert CurrencyNotWhitelisted();
        }

        if (tipAmount == 0) {
            revert TipAmountCannotBeZero();
        }

        address tipReceiver = _tipReceivers[processActionParams.publicationActedProfileId][processActionParams.publicationActedId];
        emit Log(string(abi.encodePacked("processPub tiprec",tipReceiver)));
        bool approved = false;
        IERC20 ierc = IERC20(currency);
        
        approved = ierc.approve(processActionParams.transactionExecutor,tipAmount);
        
        emit Log(string(abi.encodePacked("processPub approved",approved)));
        
        if(approved){
            ierc.safeTransferFrom(
                 processActionParams.transactionExecutor,
                 tipReceiver,
                 tipAmount
            );
        }else{
            revert TipAmountNotApproved();
        }
        
        return abi.encode(tipReceiver, currency, tipAmount);
    }

    // function getModuleMetadataURI() override external view returns (string memory) {
    //     return 'https://nftz.mypinata.cloud/ipfs/QmTityZU2gwWwarhMsDyATjAArg2BYWkgbjPpmNGbNrhQs';
    // }
    
}