// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import {HubRestricted} from 'lens/HubRestricted.sol';
import {Types} from 'lens/Types.sol';
import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {IPublicationActionModule} from 'lens/IPublicationActionModule.sol';
import {LensModule} from 'lens/LensModule.sol';

import {IModuleGlobals} from 'lens/IModuleGlobals.sol';

contract TippingPublicationAction is
    LensModule,
    HubRestricted,
    IPublicationActionModule
{
    mapping(uint256 profileId => mapping(uint256 pubId => address tipReceiver))
        internal _tipReceivers;

    error CurrencyNotWhitelisted();
    error TipAmountCannotBeZero();

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
        address /* transactionExecutor */,
        bytes calldata data
    ) external override onlyHub returns (bytes memory) {
        address tipReceiver = abi.decode(data, (address));

        _tipReceivers[profileId][pubId] = tipReceiver;

        return data;
    }

    function processPublicationAction(
        Types.ProcessActionParams calldata params
    ) external override onlyHub returns (bytes memory) {
        (address currency, uint96 tipAmount) = abi.decode(
            params.actionModuleData,
            (address, uint96)
        );

        if (!MODULE_GLOBALS.isCurrencyWhitelisted(currency)) {
            revert CurrencyNotWhitelisted();
        }

        if (tipAmount == 0) {
            revert TipAmountCannotBeZero();
        }

        address tipReceiver = _tipReceivers[params.publicationActedProfileId][
            params.publicationActedId
        ];

        IERC20(currency).transferFrom(
            params.transactionExecutor,
            tipReceiver,
            tipAmount
        );

        return abi.encode(tipReceiver, currency, tipAmount);
    }

    function getModuleMetadataURI() external view returns (string memory) {
        return 'https://nftz.mypinata.cloud/ipfs/Qmcev1byf4NPPyjki436rZTDVAhrSgKtMecnPHqdvxguYG';
    }
    
}