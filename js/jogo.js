// ENDEREÇO EHTEREUM DO CONTRATO
var contractAddress = "0x14334e23b7e6fc1c8a38fb5664bb9894c0b7531d";

// Inicializa o objeto DApp
document.addEventListener("DOMContentLoaded", onDocumentLoad);
function onDocumentLoad() {
  DApp.init();
}

// Nosso objeto DApp que irá armazenar a instância web3
const DApp = {
  web3: null,
  contracts: {},
  account: null,

  init: function () {
    return DApp.initWeb3();
  },

  // Inicializa o provedor web3
  initWeb3: async function () {
    if (typeof window.ethereum !== "undefined") {
      try {
        const accounts = await window.ethereum.request({ // Requisita primeiro acesso ao Metamask
          method: "eth_requestAccounts",
        });
        DApp.account = accounts[0];
        window.ethereum.on('accountsChanged', DApp.updateAccount); // Atualiza se o usuário trcar de conta no Metamaslk
      } catch (error) {
        console.error("Usuário negou acesso ao web3!");
        return;
      }
      DApp.web3 = new Web3(window.ethereum);
    } else {
      console.error("Instalar MetaMask!");
      return;
    }
    return DApp.initContract();
  },

  // Atualiza 'DApp.account' para a conta ativa no Metamask
  updateAccount: async function() {
    DApp.account = (await DApp.web3.eth.getAccounts())[0];
    atualizaInterface();
  },

  // Associa ao endereço do seu contrato
  initContract: async function () {
    DApp.contracts.Mira = new DApp.web3.eth.Contract(abi, contractAddress);
    return DApp.render();
  },

  // Inicializa a interface HTML com os dados obtidos
  render: async function () {
    inicializaInterface();
  },
};

// *** MÉTODOS (de consulta - view) DO CONTRATO ** //

function verQuantidadeTokens() {
    return DApp.contracts.Mira.methods.verQuantidadeTokens().call({ from: DApp.account });
}
  
function verScore() {
    return DApp.contracts.Mira.methods.verScore().call({ from: DApp.account });
}

function verPremio() {
    return DApp.contracts.Mira.methods.verPremio().call();
}
  
function verPrecoToken() {
    return DApp.contracts.Mira.methods.verPrecoToken().call();
}

function verificarPodeJogar() {
    return DApp.contracts.Mira.methods.verificarPodeJogar().call({ from: DApp.account });
}
  
function verTop1() {
    return DApp.contracts.Mira.methods.verTop1().call();
}

function verTop2() {
    return DApp.contracts.Mira.methods.verTop2().call();
}

function verTop3() {
    return DApp.contracts.Mira.methods.verTop3().call();
}
  
function isOwner() {
    return DApp.contracts.Mira.methods.isOwner().call({ from: DApp.account });
}


// *** MÉTODOS (de escrita) DO CONTRATO ** //

function comprarToken() {
    let quant = document.getElementById("quantidadeFichas").value;
    let preco = 100000000000000000 * quant;
    return DApp.contracts.Mira.methods.comprarToken(quant).send({ from: DApp.account, value: preco }).then(atualizaInterface);;
}
  
function distribuirPremio() {
    return DApp.contracts.Mira.methods.distribuirPremio().send({ from: DApp.account }).then(atualizaInterface);;
}

function sacar() {
    return DApp.contracts.Mira.methods.sacar().send({ from: DApp.account }).then(atualizaInterface);;
}

function registraScore() {
    return DApp.contracts.Mira.methods.registraScore(hits).send({ from: DApp.account }).then(atualizaInterface);;
}

// *** ATUALIZAÇÃO DO HTML *** //

function inicializaInterface() {
    if(document.getElementById('comprarFichaBtn')){
        document.getElementById("comprarFichaBtn").onclick = comprarToken;
        document.getElementById("distribuirPremioBtn").onclick = distribuirPremio;
        document.getElementById("sacarBtn").onclick = sacar;
        atualizaInterface();
    }
}

function atualizaInterface() {
    verQuantidadeTokens().then((result) => {
        document.getElementById("total-fichas").innerHTML = result;
    });

    verScore().then((result) => {
        document.getElementById("score").innerHTML = result;
    });

    verPremio().then((result) => {
        document.getElementById("premios").innerHTML =
            result / 1000000000000000000 + " ETH";
    });

    verPrecoToken().then((result) => {
        document.getElementById("preco").innerHTML =
            "Preço da Ficha: " + result / 1000000000000000000 + " ETH";
    });

    verTop1().then((result) => {
        document.getElementById("scoreTop1").innerHTML = result[0];
        document.getElementById("enderecoTop1").innerHTML = result[1];
    });

    verTop2().then((result) => {
        document.getElementById("scoreTop2").innerHTML = result[0];
        document.getElementById("enderecoTop2").innerHTML = result[0];
    });

    verTop3().then((result) => {
        document.getElementById("scoreTop3").innerHTML = result[0];
        document.getElementById("enderecoTop3").innerHTML = result[0];
    });

    document.getElementById("endereco").innerHTML = DApp.account;

    document.getElementById("distribuirPremioBtn").style.display = "none";
    isOwner().then((result) => {
        if (result) {
            document.getElementById("distribuirPremioBtn").style.display = "block";
        }
    });

    document.getElementById("sacarBtn").style.display = "none";
    isOwner().then((result) => {
        if (result) {
            document.getElementById("sacarBtn").style.display = "block";
        }
    });
}

// *** Métodos relacionados ao jogo *** //
var altura
var largura
var hearts = 3
var hits = 0

function ajustarTamanhoJanelaJogo() {
    altura = window.innerHeight
    largura = window.innerWidth

    console.log(largura, altura)
}

ajustarTamanhoJanelaJogo()

function posicaoRandom(){

    // remover alvo anterior caso exista
    if(document.getElementById('alvoReal')){
        document.getElementById('alvoReal').remove()

        // Game Over
        if(hearts < 1){
            clearInterval(respawnAlvo)
            // chamar função para registrar score
            registraScore().then((result) => {});
            
            alert("Game Over! Hits: " + hits)
            window.location.replace("index.html")
        }
        document.getElementById("heart" + hearts).src = "imagens/emptyHeart.png"
        hearts--
    }

    // variáveis randomicas
    var eixoX = Math.floor(Math.random() * (largura-60))
    var eixoY = Math.floor(Math.random() * (altura-60))
    var tamanho = Math.floor(Math.random() * 30) + 30

    // setando propriedades de alvo
    var alvo = document.createElement("div")
    alvo.className = "alvo"
    alvo.style.left = eixoX + "px"
    alvo.style.top = eixoY + "px"
    alvo.style.position = "absolute"
    alvo.style.width = tamanho + "px"
    alvo.style.height = tamanho + "px"
    alvo.id = "alvoReal"
    alvo.onclick = function(){
        // incrementar score
        hits += 1
        document.getElementById("scoreHits").innerHTML = hits
        this.remove()
    }

    document.body.appendChild(alvo)
}

function iniciarJogo(){

    verificarPodeJogar().then((result) => {
        if(result){
            window.location.replace("app.html")
        }
        else{
            alert("Quantidade de tokens insuficiente para jogar!")
        }
    });
}
