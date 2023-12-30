// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

//import {Ownable} from '../openzeppelin-contracts/contracts/access/Ownable.sol';
import {Ownable} from './Ownable.sol';

import {LensModule} from './LensModule.sol';

contract LensModuleMetadata is LensModule, Ownable {
    string public metadataURI = 'https://nftz.mypinata.cloud/ipfs/QmTityZU2gwWwarhMsDyATjAArg2BYWkgbjPpmNGbNrhQs';

    constructor(address owner_) Ownable() {
        _transferOwnership(owner_);
    }

    function setModuleMetadataURI(string memory _metadataURI) external onlyOwner {
        metadataURI = _metadataURI;
    }

    function getModuleMetadataURI() external view returns (string memory) {
        return metadataURI;
    }
}