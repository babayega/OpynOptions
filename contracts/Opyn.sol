// SPDX-License-Identifier: MIT
pragma solidity =0.8.4;

import "hardhat/console.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IOtokenFactory, IOtoken, IController, GammaTypes} from "./interfaces/GammaInterface.sol";

contract OpynVault is ERC20, Ownable, ReentrancyGuard {
    /// @notice Stores the address of underlying asset of the vault
    IERC20 public vaultAsset;

    /// @notice Stores the address of the asset used for strike price
    IERC20 public strikeAsset;

    /// @notice Address of the oToken Factory of the GammaProtocol
    IOtokenFactory public oTokenFactory;

    /// @notice Address of the controller of the GammaProtocol
    IController public gammaController;

    /// @notice Stores the address of the newly created oToken
    address public oToken;

    /// @notice Address of the margin pool of the GammaProtocol
    address public marginPool;

    /************************************************
     *  CONSTRUCTOR & INITIALIZATION
     ***********************************************/

    /**
     * @notice Initializes the contract with immutable variables
     * @param _vaultAsset is the underlying asset for the vault
     * @param _strikeAsset is the asset used for strike price
     * @param _oTokenFactory is the contract address for opyn oToken factory
     * @param _gammaController is the contract address of controller for gamma protocol
     * @param _marginPool is the contract address for providing collateral to opyn
     */
    constructor(
        address _vaultAsset,
        address _strikeAsset,
        address _oTokenFactory,
        address _gammaController,
        address _marginPool
    ) ERC20("Vault", "VLT") {
        vaultAsset = IERC20(_vaultAsset);
        strikeAsset = IERC20(_strikeAsset);
        oTokenFactory = IOtokenFactory(_oTokenFactory);
        gammaController = IController(_gammaController);
        marginPool = _marginPool;
    }

    /**
     * @notice Deposits the `asset` from msg.sender.
     * @param _amount is the amount of `asset` to deposit
     */
    function deposit(uint256 _amount) external {
        vaultAsset.transferFrom(msg.sender, address(this), _amount);
        // This method is just for experiment purpose. Ideally after the transfer
        // new vault tokens should be minted for the depositor.
    }

    /**
     * @notice Generates a new oToken
     */
    function genOToken() external onlyOwner {
        // This tries to generate a new oToken everytime. Ideally first it should be checked
        // whether a similar oToken exists, if not then only create new.

        // Strike price should also be calculated
        oToken = oTokenFactory.createOtoken(
            address(vaultAsset), // underlying asset(WETH)
            address(strikeAsset), // strike price quoting asset(USDC)
            address(vaultAsset), // collateral asset
            3500 * 10 ** 18, // strike price
            block.timestamp + 7 days, // expiry
            false // is option PUT or not
        );
    }

    /**
     * @notice Creates the actual Opyn short position by depositing collateral and minting otokens
     * @return the otoken mint amount
     */
    function createShort() external onlyOwner nonReentrant returns (uint256) {
        uint256 newVaultID = (
            gammaController.getAccountVaultCounter(address(this))
        ) + 1;

        //Approve Opyn margin pool to pull asset from this contract
        uint256 depositAmount = vaultAsset.balanceOf(address(this));
        vaultAsset.approve(marginPool, depositAmount);

        IController.ActionArgs[] memory actions = new IController.ActionArgs[](
            3
        );

        actions[0] = IController.ActionArgs(
            IController.ActionType.OpenVault,
            address(this), // owner
            address(this), // receiver
            address(0), // asset, otoken
            newVaultID, // vaultId
            0, // amount
            0, //index
            "" //data
        );

        actions[1] = IController.ActionArgs(
            IController.ActionType.DepositCollateral,
            address(this), // owner
            address(this), // address to transfer from
            address(vaultAsset), // deposited asset
            newVaultID, // vaultId
            depositAmount, // amount
            0, //index
            "" //data
        );

        actions[2] = IController.ActionArgs(
            IController.ActionType.MintShortOption,
            address(this), // owner
            address(this), // address to transfer to
            oToken, // option address
            newVaultID, // vaultId
            depositAmount, // amount
            0, //index
            "" //data
        );

        gammaController.operate(actions);

        return depositAmount;
    }
}
