// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../contracts/interfaces/IDiamondCut.sol";
import "../contracts/facets/DiamondCutFacet.sol";
import "../contracts/facets/NFTBuild.sol";
import "../contracts/upgradeInitializers/ERC721Init.sol";
import "../contracts/Diamond.sol";

contract NFTDiamondTest is Test, IDiamondCut {

    Diamond diamond;
    DiamondCutFacet dCutFacet;
    NFTBuild nftFacet;
    ERC721Init nftInit;

    function setUp() public {
        // 1. Deploy facets
        dCutFacet = new DiamondCutFacet();
        diamond = new Diamond(address(this), address(dCutFacet));
        nftFacet = new NFTBuild();
        nftInit = new ERC721Init();

        // 2. Build cut
        FacetCut[] memory cut = new FacetCut[](1);
        cut[0] = FacetCut({
            facetAddress: address(nftFacet),
            action: FacetCutAction.Add,
            functionSelectors: generateSelectors("NFTBuild")
        });

        // 3. Encode init call
        bytes memory initCall = abi.encodeWithSelector(
            ERC721Init.init.selector,
            "DiamondNFT",
            "DNFT"
        );

        // 4. Cut facet in + run init
        IDiamondCut(address(diamond)).diamondCut(cut, address(nftInit), initCall);
    }

    function testMint() public {
        NFTBuild nft = NFTBuild(address(diamond));
        nft.mint(address(this));

        assertEq(nft.ownerOf(1), address(this));
        assertEq(nft.balanceOf(address(this)), 1);
    }

    function testTransfer() public {
        NFTBuild nft = NFTBuild(address(diamond));
        nft.mint(address(this));

        address receiver = makeAddr("receiver");
        nft.transferFrom(address(this), receiver, 1);

        assertEq(nft.ownerOf(1), receiver);
        assertEq(nft.balanceOf(address(this)), 0);
        assertEq(nft.balanceOf(receiver), 1);
    }

    function testApprove() public {
        NFTBuild nft = NFTBuild(address(diamond));
        nft.mint(address(this));

        address spender = makeAddr("spender");
        nft.approve(spender, 1);

        assertEq(nft.getApproved(1), spender);
    }

    function generateSelectors(
        string memory _facetName
    ) internal returns (bytes4[] memory selectors) {
        string[] memory cmd = new string[](3);
        cmd[0] = "node";
        cmd[1] = "scripts/genSelectors.js";
        cmd[2] = _facetName;
        bytes memory res = vm.ffi(cmd);
        selectors = abi.decode(res, (bytes4[]));
    }

    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {}
}