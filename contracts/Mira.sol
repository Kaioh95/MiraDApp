pragma solidity ^0.7.0;

contract Mira {
    
    address owner;
    mapping(address => uint) tokens;
    mapping(address => uint) scores;

    address[] top3;

    uint valorToken = 0.1 ether;
    
    event Sorteio(address winner);
    event RifaComprada(address comprador, uint quant);
    
    constructor();
    
    modifier onlyOwner;

    function verificarPodeJogar() public returns (bool);

    function comprarToken(uint _quant) public payable;

    function registraScore(uint score) public;

    function printToken() public view return(uint);

    function printScore() public view return(uint);

    function distribuirPremio() external onlyOwner;

    function verPremio() public view returns (uint);
        
    function verTop3() public view returns (address, address, address);

    //Premios: 40%, 20% e 10%. Mostrar prêmio mostra apenas 70% do balanço.
    function resetar() public onlyOwner;
    
    function isOwner() public view returns (bool);
    
}