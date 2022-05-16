// SPDX-License-Identifier: MIT
pragma solidity =0.8.4;

import "hardhat/console.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {
    IOtokenFactory,
    IOtoken,
    IController,
    GammaTypes
} from "./interfaces/GammaInterface.sol";

contract DemoVault is ERC20,Ownable,ReentrancyGuard{
    IERC20 public vaultAsset;
    IERC20 public strikeAsset;
    IOtokenFactory public oTokenFactory;
    IController public gammaController;
    address public oToken;
    address public marginPool;

    constructor(address _vaultAsset,address _strikeAsset,address _oTokenFactory,address _gammaController, address _marginPool)ERC20("Vault", "VLT"){
        vaultAsset = IERC20(_vaultAsset);
        strikeAsset = IERC20(_strikeAsset);
        oTokenFactory = IOtokenFactory(_oTokenFactory);
        gammaController = IController(_gammaController);
        marginPool = _marginPool;
    }

    function deposit(uint256 _amount) external{
        vaultAsset.transferFrom(msg.sender, address(this), _amount);
    }

    function genOToken() external onlyOwner {
        oToken =
            oTokenFactory.createOtoken(
                address(vaultAsset),
                address(strikeAsset),
                address(vaultAsset),
                3500*10**18,
                1652774400,
                false
            );
    }

    function createShort() external onlyOwner nonReentrant returns (uint256){      
        console.log("here");

        uint256 newVaultID = 1;
            //  (gammaController.getAccountVaultCounter(address(this))) + 1;

        console.log("here1", newVaultID);

        uint256 depositAmount = vaultAsset.balanceOf(address(this));

        console.log("here2", depositAmount);

        vaultAsset.approve(marginPool, depositAmount);

        console.log("here3 approved");

        IController.ActionArgs[] memory actions =
            new IController.ActionArgs[](3);        

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
        console.log("here4 actions");
        gammaController.operate(actions);
        console.log("here5 operate");
        return depositAmount;

    }
}