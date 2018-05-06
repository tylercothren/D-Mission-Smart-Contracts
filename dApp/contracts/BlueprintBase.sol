pragma solidity ^0.4.23;
import "./DMissionAccessControl.sol";

contract BlueprintBase is DMissionAccessControl {
    /*** EVENTS ***/

    event ManufacturedBlueprint(address owner, uint256 blueprintId, uint256 seriesId, string partName);
    
    event ManufacturedAttribute(address owner, uint256 attributetId, uint256 blueprintId, uint256 targetId, int128 affect);

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
        
        int128 affect;
    }

    /*** CONSTANTS ***/

    /*** STORAGE ***/

    storage Blueprint[] blueprints;
    
    mapping (uint256 => address) public blueprintIndexToOwner;

    mapping (address => uint256) blueprintOwnershipTokenCount;

    mapping (uint256 => address) public blueprintIndexToApproved;
    
    storage Attribute[] attributes;
    
    mapping (uint256 => address) public attributeIndexToOwner;

    mapping (address => uint256) attributeOwnershipTokenCount;

    mapping (uint256 => address) public attributeIndexToApproved;
    
    /// Assigns ownership of a specific Blueprint to an address.
    function _transferBlueprint(address _from, address _to, uint256 _tokenId) internal  {
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
    function _transferAttribute(address _from, address _to, uint256 _tokenId) internal  {
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
    function _createBlueprint(
        uint256 _seriesId,
        string _partName
    ) 
        internal
        returns (uint)
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
            _partName,
            uint256(_blueprint.seriesId)
        );

        // This will assign ownership, and also emit the Transfer event as
        // per ERC721 draft
        transferBlueprint(0, _owner, newBlueprintId);

        return newBlueprintId;
    }
    
    ///  Creates a new Attribute and stores it.
    function _createAttribute(
        uint256 _blueprintId,
        uint256 _targetId,
        int128 _affect
    )
        internal
        returns (uint)
    {
        Attribute _attribute = Attribute({
            blueprintId: uint256(_blueprintId),
            targetId: uint256(_targetId),
            affect: int128 (_affect)
        });
        uint256 newAttributeId = attributes.push(_attribute) - 1;

        // 4 billion limit case
        require(newAttributeId == uint256(uint32(newAttributeId)));

        // emit the manufacture event
        ManufacturedAttribute(
            newAttributeId,
            _owner,
            uint256(_attribute.blueprintId),
            uint256(_attribute.targetId),
            uint128(_attribute.affect)
        );

        // This will assign ownership, and also emit the Transfer event as
        // per ERC721 draft
        transferAttribute(0, _owner, newAttributeId);

        return newAttributeId;
    }
    
    ///  Creates new Blueprints in batch to save gas and stores it.
    function _batchCreateBlueprint(
        uint256[] _seriesIds,
        string[] _partNames
    )
        internal
        returns (uint[])
    {
        if (_seriesIds.length != _partNames.length){
            return [0];
        }
        
        uint256[] newBlueprintIds;
        
        for(uint256 i; i < _seriesIds.length - 1; i++){
        
            Blueprint _blueprint = Blueprint({
                seriesId: uint32(_seriesIds[i]),
                partName: _partNames[i]
            });
            
            newBlueprintIds.push(blueprints.push(_blueprint) - 1);
    
            // 4 billion limit case
            require(newBlueprintIds[i] == uint256(uint32(i)));
    
            // emit the manufacture event
            ManufacturedBlueprint(
                newBlueprintIds[i],
                _owner,
                _blueprint.partName,
                uint256(_blueprint.seriesId)
            );
    
            // This will assign ownership, and also emit the Transfer event as
            // per ERC721 draft
            _transferBlueprint(0, _owner, newBlueprintIds[i]);
        }
        return newBlueprintIds;
    }
    
    ///  Creates new Attributes in batch to save gas and stores it.
    function _batchCreateAttribute(
        uint256[] _blueprintIds,
        uint256[] _targetIds,
        int128[] _affects
    )
        internal 
        returns (uint)
    {
        if (_blueprintIds.length != _targetIds.length && _blueprintIds.length != _affects.length){
            return [0];
        }
        
        uint256[] newAttributeIds;
        
        for(uint256 i; i < _blueprintIds.length - 1; i++){
        
            Attribute memory _attribute = Attribute({
                blueprintId: uint256(_blueprintIds[i]),
                targetId: uint256(_targetIds[i]),
                affect: uint128(_affects[i])
            });
            
            newAttributeIds.push(attributes.push(_attribute) - 1);
    
            // 4 billion limit case
            require(newAttributeId[i] == uint256(uint32(i)));
    
            // emit the manufacture event
            ManufacturedAttribute(
                newAttributeIds[i],
                _owner,
                uint256(_attribute.blueprintId),
                uint256(_attribute.targetId),
                uint128(_attribute.affect)
            );
    
            // This will assign ownership, and also emit the Transfer event as
            // per ERC721 draft
            _transferAttribute(0, _owner, newAttributeIds[i]);
        }

        return newAttributeId;
    }
}