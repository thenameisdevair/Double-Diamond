// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../contracts/interfaces/IDiamondCut.sol";
import "../contracts/facets/DiamondCutFacet.sol";
import "../contracts/facets/NFTBuild.sol";
import "../contracts/facets/ERC20Facet.sol";
import "../contracts/facets/MultisigFacet.sol";
import "../contracts/facets/StakingFacet.sol";
import "../contracts/facets/SVGFacet.sol";
import "../contracts/facets/BorrowerFacet.sol";
import "../contracts/facets/MarketplaceFacet.sol";
import "../contracts/upgradeInitializers/NFTDiamondInit.sol";
import "../contracts/Diamond.sol";

contract NFTDiamondTest is Test, IDiamondCut {

    Diamond diamond;
    DiamondCutFacet dCutFacet;
    NFTBuild nftFacet;
    ERC20Facet erc20Facet;
    MultisigFacet multisigFacet;
    StakingFacet stakingFacet;
    SVGFacet svgFacet;
    BorrowerFacet borrowerFacet;
    MarketplaceFacet marketplaceFacet;
    NFTDiamondInit diamondInit;

    // address owner = address(this);
    // address user1 = makeAddr("user1");
    // address user2 = makeAddr("user2");
    // address signer1 = makeAddr("signer1");
    // address signer2 = makeAddr("signer2");

    address owner = address(this);
    address user1 = address(0x1);
    address user2 = address(0x2);
    address signer1 = address(0x3);
    address signer2 = address(0x4);

    function setUp() public {
        // 1. Deploy all facets
        dCutFacet      = new DiamondCutFacet();
        nftFacet       = new NFTBuild();
        erc20Facet     = new ERC20Facet();
        multisigFacet  = new MultisigFacet();
        stakingFacet   = new StakingFacet();
        svgFacet       = new SVGFacet();
        borrowerFacet  = new BorrowerFacet();
        marketplaceFacet = new MarketplaceFacet();
        diamondInit    = new NFTDiamondInit();

        // 2. Deploy Diamond
        diamond = new Diamond(owner, address(dCutFacet));

        // 3. Build cut for all facets
        FacetCut[] memory cut = new FacetCut[](7);

        cut[0] = FacetCut({
            facetAddress: address(nftFacet),
            action: FacetCutAction.Add,
            functionSelectors: generateSelectors("NFTBuild")
        });
        cut[1] = FacetCut({
            facetAddress: address(erc20Facet),
            action: FacetCutAction.Add,
            functionSelectors: generateSelectors("ERC20Facet")
        });
        cut[2] = FacetCut({
            facetAddress: address(multisigFacet),
            action: FacetCutAction.Add,
            functionSelectors: generateSelectors("MultisigFacet")
        });
        cut[3] = FacetCut({
            facetAddress: address(stakingFacet),
            action: FacetCutAction.Add,
            functionSelectors: generateSelectors("StakingFacet")
        });
        cut[4] = FacetCut({
            facetAddress: address(svgFacet),
            action: FacetCutAction.Add,
            functionSelectors: generateSelectors("SVGFacet")
        });
        cut[5] = FacetCut({
            facetAddress: address(borrowerFacet),
            action: FacetCutAction.Add,
            functionSelectors: generateSelectors("BorrowerFacet")
        });
        cut[6] = FacetCut({
            facetAddress: address(marketplaceFacet),
            action: FacetCutAction.Add,
            functionSelectors: generateSelectors("MarketplaceFacet")
        });

        // 4. Encode init call
        address[] memory signers = new address[](2);
        signers[0] = signer1;
        signers[1] = signer2;

        bytes memory initCall = abi.encodeWithSelector(
            NFTDiamondInit.init.selector,
            "DiamondNFT", "DNFT",
            "DiamondToken", "DTK",
            18,
            signers,
            2
        );

        // 5. Cut all facets in + initialize
        IDiamondCut(address(diamond)).diamondCut(cut, address(diamondInit), initCall);
    }

    // ==================== ERC721 TESTS ====================

    function testMint() public {
        NFTBuild nft = NFTBuild(address(diamond));
        nft.mint(user1, "ipfs://token1");
        assertEq(nft.ownerOf(1), user1);
        assertEq(nft.balanceOfNFT(user1), 1);
    }

    function testTransferFrom() public {
        NFTBuild nft = NFTBuild(address(diamond));
        nft.mint(user1, "ipfs://token1");
        vm.prank(user1);
        nft.transferFromNFT(user1, user2, 1);
        assertEq(nft.ownerOf(1), user2);
        assertEq(nft.balanceOfNFT(user1), 0);
        assertEq(nft.balanceOfNFT(user2), 1);
    }

    function testApprove() public {
        NFTBuild nft = NFTBuild(address(diamond));
        nft.mint(user1, "ipfs://token1");
        vm.prank(user1);
        nft.approveNFT(user2, 1);
        assertEq(nft.getApproved(1), user2);
    }

    function testSetApprovalForAll() public {
        NFTBuild nft = NFTBuild(address(diamond));
        vm.prank(user1);
        nft.setApprovalForAll(user2, true);
        assertTrue(nft.isApprovedForAll(user1, user2));
    }

    // ==================== ERC20 TESTS ====================

    function testERC20Mint() public {
        ERC20Facet erc20 = ERC20Facet(address(diamond));
        erc20.mint(user1, 1000 * 1e18);
        assertEq(erc20.balanceOf(user1), 1000 * 1e18);
    }

    function testERC20Transfer() public {
        ERC20Facet erc20 = ERC20Facet(address(diamond));
        erc20.mint(user1, 1000 * 1e18);
        vm.prank(user1);
        erc20.transfer(user2, 100 * 1e18);
        assertEq(erc20.balanceOf(user2), 100 * 1e18);
        assertEq(erc20.balanceOf(user1), 900 * 1e18);
    }

    // ==================== STAKING TESTS ====================

    function testStake() public {
        NFTBuild nft = NFTBuild(address(diamond));
        StakingFacet staking = StakingFacet(address(diamond));
        nft.mint(user1, "ipfs://token1");
        vm.prank(user1);
        staking.stake(1);
        assertEq(staking.stakedToken(user1), 1);
    }

    function testClaimRewards() public {
        NFTBuild nft = NFTBuild(address(diamond));
        StakingFacet staking = StakingFacet(address(diamond));
        ERC20Facet erc20 = ERC20Facet(address(diamond));
        nft.mint(user1, "ipfs://token1");
        vm.prank(user1);
        staking.stake(1);
        vm.warp(block.timestamp + 1 days);
        vm.prank(user1);
        staking.claimRewards();
        assertGt(erc20.balanceOf(user1), 0);
    }

    // ==================== MARKETPLACE TESTS ====================

    function testListAndBuy() public {
        NFTBuild nft = NFTBuild(address(diamond));
        ERC20Facet erc20 = ERC20Facet(address(diamond));
        MarketplaceFacet market = MarketplaceFacet(address(diamond));

        nft.mint(user1, "ipfs://token1");
        erc20.mint(user2, 1000 * 1e18);

        vm.prank(user1);
        market.listToken(1, 100 * 1e18);

        vm.prank(user2);
        market.buyToken(1);

        assertEq(nft.ownerOf(1), user2);
        assertEq(erc20.balanceOf(user1), 100 * 1e18);
    }

    // ==================== BORROWER TESTS ====================

    function testBorrowAndReturn() public {
        NFTBuild nft = NFTBuild(address(diamond));
        ERC20Facet erc20 = ERC20Facet(address(diamond));
        BorrowerFacet borrower = BorrowerFacet(address(diamond));

        nft.mint(user1, "ipfs://token1");
        erc20.mint(user2, 1000 * 1e18);

        vm.prank(user2);
        borrower.borrow(1, 1 days);
        assertEq(nft.ownerOf(1), user2);

        vm.prank(user2);
        borrower.returnToken(1);
        assertEq(nft.ownerOf(1), user2); // original owner
    }

    // ==================== MULTISIG TESTS ====================

    function testMultisigProposal() public {
        MultisigFacet multisig = MultisigFacet(address(diamond));

        FacetCut[] memory cut = new FacetCut[](0);

        vm.prank(signer1);
        uint256 proposalId = multisig.proposeDiamondCut(cut, address(0), "");

        vm.prank(signer1);
        multisig.approveProposal(proposalId);

        vm.prank(signer2);
        multisig.approveProposal(proposalId);

        assertEq(multisig.getProposalApprovals(proposalId), 2);
    }

    // ==================== HELPERS ====================

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