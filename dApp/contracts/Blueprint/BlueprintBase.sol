pragma solidity ^0.4.20;

import "./DMissionAccessControl.sol";
import "./Token/ERC721/IERC721.sol";

contract BlueprintBase is DMissionAccessControl, ERC721
{
    /*** EVENTS ***/

    event ManufacturedBlueprint(uint256 blueprintId, address owner, uint256 seriesId, string partName);
    
    event ManufacturedAttribute(uint256 attributetId, address owner, uint256 blueprintId, uint256 targetId, uint128 affect);

    event AttributeTransfer(address from, address to, uint256 tokenId);
    
    event BlueprintTransfer(address from, address to, uint256 tokenId);

    /*** DATA TYPES ***/

    struct Blueprint {
        uint256 seriesId;
        
        string partName;
    }
    
    struct Attribute {
        uint256 blueprintId;
        
        uint256 targetId;
        
        uint128 affect;
    }

    /*** CONSTANTS ***/

    /*** STORAGE ***/

    Blueprint[] blueprints;
    
    mapping (uint256 => address) public blueprintIndexToOwner;

    mapping (address => uint256) blueprintOwnershipTokenCount;

    mapping (uint256 => address) public blueprintIndexToApproved;
    
    Attribute[] attributes;
    
    mapping (uint256 => address) public attributeIndexToOwner;

    mapping (address => uint256) attributeOwnershipTokenCount;

    mapping (uint256 => address) public attributeIndexToApproved;
    
    /// Assigns ownership of a specific Blueprint to an address.
    function _transferBlueprint(address _from, address _to, uint256 _tokenId) internal  onlyCLevel
    {
        // Since the number of Blueprint is capped to 2^32 we can't overflow this
        blueprintOwnershipTokenCount[_to]++;
        
        // transfer ownership
        blueprintIndexToOwner[_tokenId] = _to;
        
        // When creating new Blueprint _from is 0x0, but we can't account that address.
        if (_from != address(0)) {
            blueprintOwnershipTokenCount[_from]--;
            // clear any previously approved ownership exchange
            delete blueprintIndexToApproved[_tokenId];
        }
        
        // Emit the transfer event.
        BlueprintTransfer(_from, _to, _tokenId);
    }
    
    /// Assigns ownership of a specific Attribute to an address.
    function _transferAttribute(address _from, address _to, uint256 _tokenId) internal onlyCLevel 
    {
        // Since the number of Attributes is capped to 2^32 we can't overflow this
        attributeOwnershipTokenCount[_to]++;
        // transfer ownership
        attributeIndexToOwner[_tokenId] = _to;
        // When creating new Attributes _from is 0x0, but we can't account that address.
        if (_from != address(0)) {
            attributeOwnershipTokenCount[_from]--;
            // clear any previously approved ownership exchange
            delete attributeIndexToApproved[_tokenId];
        }
        // Emit the transfer event.
        AttributeTransfer(_from, _to, _tokenId);
    }

    ///  Creates a new Blueprint and stores it.
    function _createBlueprint( uint256 _seriesId, string memory _partName, address _owner ) internal onlyCLevel returns (uint)
    {
        Blueprint memory _blueprint = Blueprint({
            seriesId: uint32(_seriesId),
            partName: _partName
        });
        uint256 newBlueprintId = blueprints.push(_blueprint) - 1;

        // 4 billion limit case
        require(newBlueprintId == uint256(uint32(newBlueprintId)));

        // emit the manufacture event
        ManufacturedBlueprint(
            newBlueprintId,
            _owner,
            uint256(_blueprint.seriesId),
            _partName
        );

        // This will assign ownership, and also emit the Transfer event as
        // per ERC721 draft
        _transferBlueprint(address(0), _owner, newBlueprintId);

        return newBlueprintId;
    }
    
    ///  Creates a new Attribute and stores it.
    function _createAttribute( uint256 _blueprintId, uint256 _targetId, uint128 _affect, address _owner ) internal onlyCLevel returns (uint)
    {
        Attribute memory _attribute = Attribute({
            blueprintId: uint256(_blueprintId),
            targetId: uint256(_targetId),
            affect: uint128(_affect)
        });
        uint256 newAttributeId = attributes.push(_attribute) - 1;

        // 4 billion limit case
        require(newAttributeId == uint256(uint32(newAttributeId)));

        // emit the manufacture event
        ManufacturedAttribute( newAttributeId, _owner, uint256(_attribute.blueprintId), uint256(_attribute.targetId), uint128(_attribute.affect) );

        // This will assign ownership, and also emit the Transfer event as
        // per ERC721 draft
        _transferAttribute(address(0), _owner, newAttributeId);

        return newAttributeId;
    }
    
    ///  Creates new Blueprints in batch to save gas and stores it.
    function _batchCreateBlueprint( uint256[] memory _seriesIds, string[] memory _partNames, address[] memory _owners ) internal onlyCLevel returns (uint[] memory)
    {
        Blueprint memory _blueprint;
        uint256[] memory newBlueprintIds;
        
        if (_seriesIds.length != _partNames.length){
            return newBlueprintIds;
        }
        
        for(uint256 i = 0; i < _seriesIds.length - 1; i++){
        
            _blueprint = Blueprint({
                seriesId: uint32(_seriesIds[i]),
                partName: _partNames[i]
            });
            
            newBlueprintIds[i] = blueprints.push(_blueprint) - 1;
    
            // 4 billion limit case
            require(newBlueprintIds[i] == uint256(uint32(newBlueprintIds[i])));
    
            // emit the manufacture event
            ManufacturedBlueprint( newBlueprintIds[i], _owners[i], uint256(_blueprint.seriesId), _blueprint.partName );
    
            // This will assign ownership, and also emit the Transfer event as
            // per ERC721 draft
            _transferBlueprint(address(0), _owners[i], newBlueprintIds[i]);
        }
        return newBlueprintIds;
    }
    
    ///  Creates new Attributes in batch to save gas and stores it.
    function _batchCreateAttribute( uint256[] memory _blueprintIds, uint256[] memory _targetIds, int128[] memory _affects, address[] memory _owners ) internal onlyCLevel returns (uint[] memory)
    {
        Attribute memory _attribute;
        uint256[] memory newAttributeIds;
        
        if (_blueprintIds.length != _targetIds.length && _blueprintIds.length != _affects.length){
            return newAttributeIds;
        }
        
        for(uint256 i = 0; i < _blueprintIds.length - 1; i++){
        
            _attribute = Attribute({
                blueprintId: uint256(_blueprintIds[i]),
                targetId: uint256(_targetIds[i]),
                affect: uint128(_affects[i])
            });
            
            newAttributeIds[i] = attributes.push(_attribute) - 1;
    
            // 4 billion limit case
            require(newAttributeIds[i] == uint256(uint32(newAttributeIds[i])));
    
            // emit the manufacture event
            ManufacturedAttribute( newAttributeIds[i],  _owners[i], uint256(_attribute.blueprintId), uint256(_attribute.targetId), uint128(_attribute.affect) );
    
            // This will assign ownership, and also emit the Transfer event as
            // per ERC721 draft
            _transferAttribute(address(0), _owners[i], newAttributeIds[i]);
        }

        return newAttributeIds;
    }
}