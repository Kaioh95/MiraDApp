var altura
var largura
var hearts = 3

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

        if(hearts < 1){
            clearInterval(respawnAlvo)
            alert("Game Over")
            // Game Over
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
        this.remove()
        // incrementar score
    }

    document.body.appendChild(alvo)
    //console.log(eixoX, eixoY, tamanho)
}

function iniciarJogo(){
    window.location.replace("app.html");
}
