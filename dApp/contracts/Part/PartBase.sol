pragma solidity ^0.4.20;

import './DMissionAccessControl.sol';
import "./ERC721Draft.sol";

contract PartBase is DMissionAccessControl, ERC721
{
    /*** EVENTS ***/

    event ManufacturedMatchbox(address owner, uint256 matchboxId, uint256 seriesId);

    event Transfer(address from, address to, uint256 tokenId);

    /*** DATA TYPES ***/

    struct Part {
        uint256 partId;
        
        uint256 blueprintId;

        uint64 manufactureTime;

        uint256 wearValue;
    }
    
    /*** STORAGE ***/

    Part[] parts;
    
    mapping (uint256 => address) public partIndexToOwner;

    mapping (address => uint256) partOwnershipTokenCount;

    mapping (uint256 => address) public partIndexToApproved;
}